FROM ubuntu:22.04

# Install required dependencies
RUN apt-get update && apt-get install -y \
    lib32gcc-s1 \
    curl \
    software-properties-common \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create steam user
RUN useradd -m steam

# Create directories
RUN mkdir -p /home/steam/steamcmd /dayz-server && \
    chown -R steam:steam /home/steam/steamcmd /dayz-server

# Switch to steam user
USER steam
WORKDIR /home/steam/steamcmd

# Download and extract SteamCMD
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Create Steam directory and initialize SteamCMD
RUN mkdir -p /home/steam/.steam/sdk32 && \
    ./steamcmd.sh +login anonymous +quit && \
    ln -s /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so

# Install DayZ Dedicated Server
RUN ./steamcmd.sh +force_install_dir /dayz-server \
    +login anonymous \
    +app_update 223350 validate \
    +quit

# Switch back to root for copying files
USER root
WORKDIR /dayz-server

# Add server startup script
COPY start-server.sh /dayz-server/
RUN chmod +x /dayz-server/start-server.sh && \
    chown -R steam:steam /dayz-server

# Switch back to steam user for running the server
USER steam
WORKDIR /dayz-server

# Default command
CMD ["./start-server.sh"] 