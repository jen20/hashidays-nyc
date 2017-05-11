default: help

STATE_BUCKET = hashistack-aws-state
REGION = us-west-2

ACTION ?= plan

.PHONY: state-bootstrap
state-bootstrap: ## Run Terraform to bootstrap remote state bucket
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/state_bucket && \
		AWS_REGION=$(REGION) \
		terraform $(ACTION) \
			-var 'bucket_name=$(STATE_BUCKET)'  \
			-state /dev/null \
			-lock=false

roots/account_bootstrap/.terraform/terraform.tfstate:
	@cd roots/account_bootstrap && \
		terraform init \
			-backend-config "bucket=$(STATE_BUCKET)"

.PHONY: account-bootstrap
account-bootstrap: roots/account_bootstrap/.terraform/terraform.tfstate ## Run Terraform to bootstrap empty AWS account
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/account_bootstrap && \
		AWS_REGION=$(REGION) \
		terraform $(ACTION)

roots/base_vpc/.terraform/terraform.tfstate:
	@cd roots/base_vpc && \
		terraform init \
			-backend-config "bucket=$(STATE_BUCKET)"

.PHONY: base-vpc
base-vpc: roots/base_vpc/.terraform/terraform.tfstate ## Run Terraform to create base VPC
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/base_vpc && \
		AWS_REGION=$(REGION) \
		terraform $(ACTION)

roots/apt_repo/.terraform/terraform.tfstate:
	@cd roots/apt_repo && \
		terraform init \
			-backend-config "bucket=$(STATE_BUCKET)"

.PHONY: apt-repo
apt-repo: roots/apt_repo/.terraform/terraform.tfstate ## Run Terraform to create APT repository
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/apt_repo && \
		AWS_REGION=$(REGION) \
		terraform $(ACTION) \
			-var "state_bucket=$(STATE_BUCKET)"

roots/consul_servers/.terraform/terraform.tfstate:
	@cd roots/consul_servers && \
		terraform init \
			-backend-config "bucket=$(STATE_BUCKET)"

.PHONY: consul-servers
consul-servers: roots/consul_servers/.terraform/terraform.tfstate ## Run Terraform to create Consul Servers
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/consul_servers && \
		AWS_REGION=$(REGION) \
		terraform $(ACTION) \
			-var "state_bucket=$(STATE_BUCKET)"

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
