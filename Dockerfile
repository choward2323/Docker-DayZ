FROM cm2network/steamcmd:root

# Install required dependencies
RUN apt-get update && apt-get install -y \
    lib32gcc-s1 \
    && rm -rf /var/lib/apt/lists/*

# Create directory for DayZ server
RUN mkdir -p /dayz-server

# Set working directory
WORKDIR /dayz-server

# Install DayZ Dedicated Server (App ID: 223350)
RUN /home/steam/steamcmd/steamcmd.sh +force_install_dir /dayz-server +login anonymous +app_update 223350 validate +quit

# Add server startup script
COPY start-server.sh /dayz-server/
RUN chmod +x /dayz-server/start-server.sh

# Default command
CMD ["./start-server.sh"] 