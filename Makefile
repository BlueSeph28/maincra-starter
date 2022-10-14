SHELL := /bin/bash
#ENV := qa

# Bash Strict Mode
.SHELLFLAGS := -eu -o pipefail -c

all: apply provisioning setstate

init:
	bash ./utils/prepare.sh
	terraform -chdir=./infrastructure init

plan:
	terraform -chdir=./infrastructure plan

apply:
	terraform -chdir=./infrastructure apply --auto-approve
	terraform -chdir=./infrastructure output -raw ip_host > ip_host
	terraform -chdir=./infrastructure output -raw user_host > user_host
	terraform -chdir=./infrastructure output -raw use_backup > use_backup

.ONESHELL:
provisioning:
	$(eval iphost := $(shell cat ./ip_host))
	$(eval userhost := $(shell cat ./user_host))
	$(eval usebackup := $(shell cat ./use_backup))
	ssh -i ./creds/gcloud_instance -o StrictHostKeychecking=no $(userhost)@$(iphost) "bash /tmp/install_script.sh $(usebackup)"

setstate:
	bash ./utils/state.sh

prepareaccess:
	bash ./utils/prepare.sh

destroy:
	bash ./utils/destroy.sh
