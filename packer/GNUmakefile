default: help

.PHONY: base-os-ami
base-os-ami: ## Build AMI for Ubuntu 16.04 ("Xenial") LTS
	@cd base-os-ami && cfgt convert -i template.json5 | packer build -

.PHONY: base-os-config
base-os-config: ## Build AMI with basic configuration. Starts from base-os-ami.
	$(call check_defined, PACKER_VPC_ID, VPC ID in which to run source machine)
	$(call check_defined, PACKER_SUBNET_ID, Subnet ID in which to run source machine)
	$(call check_defined, PACKER_APT_REPO, HTTP Address of the APT repository)
	$(call check_defined, PACKER_CA_ROOTS_PACKAGE, Name of the CA Roots package)
	$(call check_defined, PACKER_SSH_CA_PACKAGE, Name of the SSH CA package)
	$(call check_defined, PACKER_ENVIRONMENT, Name of the Environment for MOTD configuration)
	$(call check_defined, AWS_REGION, Region in which to build the AMI)
	@cd base-os-config && cfgt convert -i template.json5 | packer build -

.PHONY: consul-server
consul-server: ## Build Consul Server AMI. Starts from base-os-config.
	$(call check_defined, PACKER_VPC_ID, VPC ID in which to run source machine)
	$(call check_defined, PACKER_SUBNET_ID, Subnet ID in which to run source machine)
	$(call check_defined, PACKER_ENVIRONMENT, Name of the Environment for Consul configuration)
	$(call check_defined, AWS_REGION, Region in which to build the AMI)
	@cd consul-server && cfgt convert -i template.json5 | packer build -

.PHONY: help
help: ## Display this information. Default target.
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check_defined = \
		$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
		  $(if $(value $1),, \
		  $(error Undefined $1$(if $2, ($2))))
