#!/bin/bash

# Create the Minecraft server directory
sudo mkdir /opt/minecraft

# https://www.minecraft.net/en-us/download/server
# minecraft_server.1.21.4.jar
wget https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar

# Move the jar file
sudo mv server.jar /opt/minecraft
cd /opt/minecraft

# Run the server once to generate eula.txt file, then kill it
sudo java -jar server.jar --nogui &
sleep 10
pkill -f server.jar

# Accept the EULA
echo 'eula=true' | sudo tee eula.txt

# Create a user and group for Minecraft
sudo adduser --system --home /opt/minecraft minecraft
sudo groupadd minecraft
sudo adduser minecraft minecraft 

# Assign ownership of the Minecraft directory to the Minecraft user
sudo chown -R minecraft:minecraft /opt/minecraft

# Create the systemd service file
echo '[Unit]
Description=start and stop the minecraft-server

[Service]
WorkingDirectory=/opt/minecraft
User=minecraft
Group=minecraft
Restart=on-failure
RestartSec=20 5
ExecStart=/usr/bin/java -Xmx3384M -Xms3300M -jar server.jar --nogui

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/minecraft.service

# Reload the system daemon, enable, and start the service
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl restart minecraft.service
sudo journalctl -fu minecraft.service
