FROM cm2network/steamcmd:root

# Install required dependencies
RUN apt-get update && apt-get install -y \
    lib32gcc-s1 \
    && rm -rf /var/lib/apt/lists/*

# Create directory for DayZ server and set permissions
RUN mkdir -p /dayz-server && \
    chown -R steam:steam /dayz-server

# Switch to steam user
USER steam

# Set working directory
WORKDIR /dayz-server

# Initialize SteamCMD and install DayZ Dedicated Server (App ID: 223350)
RUN mkdir -p /home/steam/Steam && \
    /home/steam/steamcmd/steamcmd.sh +login anonymous +quit && \
    /home/steam/steamcmd/steamcmd.sh +force_install_dir /dayz-server \
    +login anonymous \
    +app_update 223350 validate \
    +quit

# Switch back to root for copying files
USER root

# Add server startup script
COPY start-server.sh /dayz-server/
RUN chmod +x /dayz-server/start-server.sh && \
    chown steam:steam /dayz-server/start-server.sh

# Switch back to steam user for running the server
USER steam

# Default command
CMD ["./start-server.sh"] 