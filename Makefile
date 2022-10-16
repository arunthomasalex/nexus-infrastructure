include .env
export

DELAY=10

RED:=\033[0;31m
GREEN:=\033[0;32m
ORANGE:=\033[0;33m
NOCOLOR:=\033[0m

edit: terraform wait ansible provisioned

clean: ansible-destroy terraform-destroy destroyed

wait:
	@echo "${ORANGE}Waiting for ${DELAY} seconds.${NOCOLOR}"
	@sleep ${DELAY}

terraform: terraform-init terraform-plan terraform-apply

ansible: ansible-init ansible-exec ansible-destroy

ansible-init:
	@echo "${ORANGE}Initializing ansible tmp files${NOCOLOR}"
	@mkdir ansible/.tmp
	@cp config/ansible.ini ansible/.tmp/inventory.ini
	@cd terraform && terraform output --json nexus-ip | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' >> ../ansible/.tmp/inventory.ini

ansible-exec:
	@echo "${ORANGE}Executing scripts on remote machines${NOCOLOR}"
	ansible-playbook -i ansible/.tmp/inventory.ini ansible/playbook.yml

ansible-destroy:
	@echo "${RED}Destroying ansible tmp files${NOCOLOR}"
	@rm -rf ansible/.tmp

terraform-init:
	@echo "${ORANGE}terraform init${NOCOLOR}"
	@cd terraform && \
	terraform init -upgrade

terraform-plan:
	@echo "${ORANGE}terraform plan${NOCOLOR}"
	@cd terraform && \
	terraform plan -out=out.tfplan

terraform-apply:
	@echo "${ORANGE}terraform apply${NOCOLOR}"
	@cd terraform && \
	terraform apply -auto-approve out.tfplan

terraform-destroy:
	@echo "${RED}terraform destroy${NOCOLOR}"
	@cd terraform && \
	terraform destroy -auto-approve

terraform-output:
	@echo "${GREEN}terraform apply${NOCOLOR}"
	@cd terraform && \
	terraform output --json

provisioned:
	@echo "${GREEN}Completed provisioning${NOCOLOR}"

destroyed:
	@echo "${RED}Completely destroyed${NOCOLOR}"