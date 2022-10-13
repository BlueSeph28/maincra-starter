#!/bin/bash

IP=$(cat ./ip_host)

ssh -i ./creds/gcloud_instance maincra@$IP -o StrictHostKeychecking=no "sudo docker stop mcServer"

mkdir -p ./backups
ssh -i ./creds/gcloud_instance -o StrictHostKeychecking=no maincra@$IP "zip -r LastBackup.zip ~/mcServer"
scp -i ./creds/gcloud_instance -o StrictHostKeychecking=no maincra@$IP:~/LastBackup.zip ./backups/LastBackup.zip

terraform destroy -chdir=./infrastructure --auto-approve

echo <<EOF
terraform {
  required_version = ">= 1.2.0"
}
EOF > ./infrastructure/backend.tf

rm -rf ./creds
rm ./ip_host