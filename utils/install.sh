#!/bin/bash

# Installing Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

mkdir /home/$USER/plugins
mkdir /home/$USER/mcServer-backup

chmod 774 /home/$USER/plugins
chmod 774 /home/$USER/mcServer-backup

sudo apt-get install -y wget unzip zip

if test -f "/home/$USER/plugins.zip"; then
  unzip /home/$USER/plugins.zip
  rm /home/$USER/plugins.zip
fi
# wget -O /home/$USER/plugins/floodgate-spigot.jar https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/build/libs/floodgate-spigot.jar
# wget -O /home/$USER/plugins/Geyser-spigot.jar https://ci.opencollab.dev//job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/build/libs/Geyser-Spigot.jar
# wget -O /home/$USER/plugins/SkinsRestorer.jar https://www.spigotmc.org/resources/skinsrestorer.2124/download?version=464299

if test -f "/home/$USER/backup.zip"; then
  unzip /home/$USER/backup.zip
  rm /home/$USER/backup.zip
else
  mkdir /home/$USER/mcServer
  mv /home/$USER/server.properties /home/$USER/mcServer/server.properties
fi

chmod 774 /home/$USER/mcServer

sudo docker run -d -v /home/$USER/plugins:/data/mods -v /home/$USER/mcServer:/data --name mcServer -e MOTD='David es joto automatizado' -e MODE=survival -e PVP=true -e VERSION=1.19.2 -e EULA=TRUE -e ENABLE_RCON=TRUE -e RCON_PASSWORD=davidjoto2806 -e REPLACE_ENV_VARIABLES=TRUE -e TYPE=FABRIC -e PLUGINS_SYNC_UPDATE=false -p 25565:25565 -p 25575:25575 -p 19132:19132/udp itzg/minecraft-server

while true; do
  str=`sudo docker ps -a`
  echo "Starting Server"
  if [[ $str =~ "(healthy)" ]]; then
    break
  fi
  sleep 5
done

echo "Server Started"

echo "Starting Backups"
sudo docker run -d -v /home/$USER/mcServer:/data:ro -v /home/$USER/mcServer-backup:/backups -e SRC_DIR=/data -e BACKUP_NAME=world -e INITIAL_DELAY=2m -e BACKUP_INTERVAL=24h -e PRUNE_BACKUPS_DAYS=3 -e BACKUP_METHOD=tar -e RCON_PASSWORD=davidjoto2806 -e EXCLUDES=bluemap --network="host" itzg/mc-backup
echo "Backups Started"


echo "Done!"