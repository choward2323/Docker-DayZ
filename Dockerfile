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
WORKDIR /home/steam/steamcmd

# Initialize SteamCMD and install DayZ Dedicated Server (App ID: 223350)
RUN mkdir -p /home/steam/Steam && \
    ./steamcmd.sh +login anonymous +quit && \
    ./steamcmd.sh +force_install_dir /home/steam/steamcmd/dayz \
    +login anonymous \
    +app_update 223350 validate \
    +quit && \
    cp -r /home/steam/steamcmd/dayz/* /dayz-server/

# Switch back to root for copying files
USER root
WORKDIR /dayz-server

# Add server startup script
COPY start-server.sh /dayz-server/
RUN chmod +x /dayz-server/start-server.sh && \
    chown -R steam:steam /dayz-server

# Switch back to steam user for running the server
USER steam

# Default command
CMD ["./start-server.sh"] 