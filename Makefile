SHELL := /bin/bash
#ENV := qa

# Bash Strict Mode
.SHELLFLAGS := -eu -o pipefail -c

all: init apply provisioning setstate

init:
	terraform -chdir=./infrastructure init

plan:
	terraform -chdir=./infrastructure plan

apply:
	terraform -chdir=./infrastructure apply --auto-approve
	terraform -chdir=./infrastructure output -raw ip_host > ip_host
	terraform -chdir=./infrastructure output -raw user_host > user_host
	terraform -chdir=./infrastructure output -raw use_backup > use_backup

iphost := $(shell cat ./ip_host)
userhost := $(shell cat ./user_host)
usebackup := $(shell cat ./use_backup)
provisioning:
	ssh -i ./creds/gcloud_instance -o StrictHostKeychecking=no $(userhost)@$(iphost) "bash /tmp/install_script.sh $(usebackup)"

setstate:
	bash ./utils/state.sh

prepareaccess:
	bash ./utils/prepare.sh

destroy:
	bash ./utils/destroy.sh
