include .env
export

instance_id=$(shell cd terraform && terraform output --json nexus-id)

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
	@echo "${ORANGE}Creating ansible tmp files${NOCOLOR}"
	@mkdir ansible/.tmp
	@cp config/ansible.ini ansible/.tmp/inventory.ini
	@cd terraform && terraform output --json nexus-ip | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' >> ../ansible/.tmp/inventory.ini
	@cd terraform && terraform output --json nexus-details > ../ansible/.tmp/instances.tmp

ansible-exec:
	@echo "${ORANGE}Executing scripts on remote machines${NOCOLOR}"
	ansible-playbook ansible/nginx.yml
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

start:
	@echo "${ORANGE}Starting nexus instance${NOCOLOR} $(instance_id)"
	@aws ec2 start-instances --instance-ids $(instance_id)
	@aws ec2 wait instance-running --instance-ids $(instance_id)
	@echo Nexus IP
	@aws ec2 describe-instances --instance-ids $(instance_id) --query=Reservations[].Instances[].PublicIpAddress --region ap-south-1
	@echo "${GREEN}Started nexus instance${NOCOLOR}"

stop:
	@echo "${ORANGE}Stopping nexus instance${NOCOLOR}"
	@aws ec2 stop-instances --instance-ids $(instance_id)
	@aws ec2 wait instance-stopped --instance-ids $(instance_id)
	@echo "${RED}Stopped nexus instance${NOCOLOR}"
