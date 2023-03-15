#!/bin/bash

# Installing Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin cron
sudo -v ; curl https://rclone.org/install.sh | sudo bash
rclone config show
RCLONEFILE=$(rclone config file | tail -1)
mv /home/$USER/rclone.conf $RCLONEFILE

mkdir /home/$USER/mcServer-backup
rclone sync maincra-drive:/ /home/$USER/mcServer-backup/

chmod 774 /home/$USER/mcServer-backup

sudo apt-get install -y wget unzip zip

if test -f "/home/$USER/plugins.zip"; then
  unzip /home/$USER/plugins.zip
  rm /home/$USER/plugins.zip
else
  mkdir /home/$USER/plugins
fi

if test -f "/home/$USER/backup.zip"; then
  unzip /home/$USER/backup.zip
  rm /home/$USER/backup.zip
else
  mkdir /home/$USER/mcServer
  mv /home/$USER/server.properties /home/$USER/mcServer/server.properties
fi

chmod 774 /home/$USER/mcServer
chmod 774 /home/$USER/plugins

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
(crontab -l 2>/dev/null; echo "0 4 * * * rclone sync /home/$USER/mcServer-backup/ maincra-drive:/") | crontab -
echo "Backups Started"

echo "Done!"
