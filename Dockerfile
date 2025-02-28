FROM ubuntu:22.04

# Install required dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wget gpg && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    lib32gcc-s1 \
    curl \
    software-properties-common \
    ca-certificates \
    lib32stdc++6 \
    libsdl2-2.0-0:i386 \
    libc6:i386 \
    libstdc++6:i386 \
    && \
    add-apt-repository multiverse && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y steamcmd && \
    rm -rf /var/lib/apt/lists/*

# Create steam user
RUN useradd -m steam

# Create directories
RUN mkdir -p /dayz-server && \
    chown -R steam:steam /dayz-server /usr/games/steamcmd

# Switch to steam user
USER steam

# Create Steam directories and symlinks
RUN mkdir -p /home/steam/.steam/sdk32 && \
    mkdir -p /home/steam/.steam/sdk64 && \
    ln -s /usr/games/steamcmd /home/steam/steamcmd && \
    /usr/games/steamcmd +login anonymous +quit

# Set up symlinks after first run
RUN ln -s /home/steam/.local/share/Steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so && \
    ln -s /home/steam/.local/share/Steam/steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

# Install DayZ Dedicated Server
WORKDIR /dayz-server
RUN /usr/games/steamcmd +@sSteamCmdForcePlatformType linux +force_install_dir /dayz-server \
    +login anonymous \
    +app_update 223350 validate \
    +quit

# Switch back to root for copying files
USER root

# Add server startup script
COPY start-server.sh /dayz-server/
RUN chmod +x /dayz-server/start-server.sh && \
    chown -R steam:steam /dayz-server

# Switch back to steam user for running the server
USER steam

# Default command
CMD ["./start-server.sh"] 