#!/bin/bash

NAME="maincra"

# Installing Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

mkdir /home/$NAME/mcServer
mkdir /home/$NAME/plugins
mkdir /home/$NAME/mcServer-backup

chmod 774 /home/$NAME/mcServer
chmod 774 /home/$NAME/plugins
chmod 774 /home/$NAME/mcServer-backup

apt-get install -y wget

wget -O ~/plugins/floodgate-spigot.jar https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/build/libs/floodgate-spigot.jar
wget -O ~/plugins/Geyser-spigot.jar https://ci.opencollab.dev//job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/build/libs/Geyser-Spigot.jar
wget -O ~/plugins/SkinsRestorer.jar https://www.spigotmc.org/resources/skinsrestorer.2124/download?version=464299

mkdir /home/$NAME/mcServer
mkdir /home/$NAME/plugins
mkdir /home/$NAME/mcServer-backup3

sudo docker run -d -v /home/$NAME/plugins:/data/plugins -v /home/$NAME/mcServer:/data --name mcServer -e MOTD='David es joto automatizado' -e MODE=survival -e PVP=true -e VERSION=1.16.5 -e EULA=TRUE -e ENABLE_RCON=TRUE -e RCON_PASSWORD=davidjoto2806 -e REPLACE_ENV_VARIABLES=TRUE -e TYPE=BUKKIT -e PLUGINS_SYNC_UPDATE=false -p 25565:25565 -p 25575:25575 itzg/minecraft-server
sudo docker run -d -v /home/$NAME/mcServer:/data:ro -v /home/$NAME/mcServer-backup:/backups -e SRC_DIR=/data -e BACKUP_NAME=world -e INITIAL_DELAY=2m -e BACKUP_INTERVAL=24h -e PRUNE_BACKUPS_DAYS=3 -e BACKUP_METHOD=tar -e RCON_PASSWORD=davidjoto2806 --network="host" itzg/mc-backup



while true; do
  str=`docker ps -a`
  echo Output: $str
  if [[ $str =~ "(healthy)" ]]; then
    break
  fi
  sleep .5
done
echo "Done!"