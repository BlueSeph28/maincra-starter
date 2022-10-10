SHELL := /bin/bash
#ENV := qa

# Bash Strict Mode
.SHELLFLAGS := -eu -o pipefail -c

all: applyinfra setstate

applyinfra:
	terraform apply --auto-approve

setstate:
	bash ./utils/state.sh

prepareaccess:
	bash ./utils/prepare.sh

destroy:
	bash ./utils/destroy.sh
