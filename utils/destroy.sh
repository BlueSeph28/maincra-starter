#!/bin/bash

IP=$(cat ./ip_host)

ssh -i ./creds/gcloud_instance maincra@$IP -o StrictHostKeychecking=no "sudo docker stop mcServer"

mkdir -p ./backups
ssh -i ./creds/gcloud_instance -o StrictHostKeychecking=no maincra@$IP "zip -r LastBackup.zip ~/mcServer"
scp -i ./creds/gcloud_instance -o StrictHostKeychecking=no maincra@$IP:~/LastBackup.zip ./backups/LastBackup.zip

terraform -chdir=./infrastructure destroy  --auto-approve

echo -e "terraform {\n\trequired_version = \">= 1.2.0\"\n}" > ./infrastructure/backend.tf

rm -rf ./creds
rm ./ip_host
rm ./use_backup
rm ./user_host