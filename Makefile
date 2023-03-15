SHELL := /bin/bash
#ENV := qa

# Bash Strict Mode
.SHELLFLAGS := -eu -o pipefail -c

all: apply provisioning

init:
	bash ./utils/prepare.sh
	terraform -chdir=./infrastructure init

plan:
	terraform -chdir=./infrastructure plan

apply:
	terraform -chdir=./infrastructure apply --auto-approve
	terraform -chdir=./infrastructure output -raw ip_host > ip_host
	terraform -chdir=./infrastructure output -raw user_host > user_host
	terraform -chdir=./infrastructure output -raw server_private_key > server_private_key.pem

.ONESHELL:
provisioning:
	$(eval iphost := $(shell cat ./ip_host))
	$(eval userhost := $(shell cat ./user_host))
	ssh -i server_private_key.pem -o StrictHostKeychecking=no $(userhost)@$(iphost) "bash /tmp/install_script.sh"

.ONESHELL:
baremetalProvision:
	scp -i baremetal_server_private_key.pem -o StrictHostKeychecking=no ./utils/baremetal-install.sh $USERHOST@$IPHOST:/tmp/install.sh
	scp -i baremetal_server_private_key.pem -o StrictHostKeychecking=no ./server-conf/rclone.conf $USERHOST@$IPHOST:~/rclone.conf

	if [ -a ./server-conf/plugins.zip ];
	then
	scp -i baremetal_server_private_key.pem -o StrictHostKeychecking=no ./server-conf/plugins.zip $USERHOST@$IPHOST:~/plugins.zip
	fi

	if [ -a ./server-conf/backup.zip ];
	then
	scp -i baremetal_server_private_key.pem -o StrictHostKeychecking=no ./server-conf/backup.zip $USERHOST@$IPHOST:~/backup.zip
	fi

	ssh -i baremetal_server_private_key.pem -o StrictHostKeychecking=no $USERHOST@$IPHOST "bash /tmp/install.sh"

destroy:
	bash ./utils/destroy.sh
