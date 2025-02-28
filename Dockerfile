# Stage 1: Install DayZ Server
FROM cm2network/steamcmd:root as builder

# Create directory for DayZ server
WORKDIR /dayz

# Install DayZ Dedicated Server
RUN /home/steam/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType linux \
    +force_install_dir /dayz \
    +login anonymous \
    +app_update 223350 validate \
    +quit || \
    if [ -f /home/steam/Steam/logs/stderr.txt ]; then cat /home/steam/Steam/logs/stderr.txt; fi

# Stage 2: Setup runtime environment
FROM ubuntu:22.04

# Install runtime dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    libsdl2-2.0-0:i386 \
    libc6:i386 \
    libstdc++6:i386 \
    && rm -rf /var/lib/apt/lists/*

# Create steam user
RUN useradd -m steam

# Create server directory
RUN mkdir -p /dayz-server && \
    chown -R steam:steam /dayz-server

# Copy DayZ server files from builder
COPY --from=builder --chown=steam:steam /dayz /dayz-server

# Add server startup script
COPY --chown=steam:steam start-server.sh /dayz-server/
RUN chmod +x /dayz-server/start-server.sh

# Switch to steam user
USER steam
WORKDIR /dayz-server

# Default command
CMD ["./start-server.sh"] 