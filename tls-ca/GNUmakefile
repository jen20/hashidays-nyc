default: help

STATE_BUCKET = hashistack-aws-state
REGION = us-west-2

TLS_BUCKET = $(shell cd ../terraform/roots/account_bootstrap && terraform output tls_key_bucket_name)
TLS_KEY_ID = $(shell cd ../terraform/roots/account_bootstrap && terraform output hashistack_tls_kms_key_id)

.PHONY: cas
cas: consul-ca nomad-ca vault-ca ## Build all CAs

consul/.terraform/terraform.tfstate:
	@cd consul && \
		terraform init \
			-backend-config "bucket=$(STATE_BUCKET)"

.PHONY: consul-ca
consul-ca: consul/bundle.cert ## Build Consul CA

consul/bundle.cert: consul/.terraform/terraform.tfstate
	@cd consul && \
		AWS_REGION=$(REGION) \
		terraform apply -backup=- && \
		aws kms encrypt \
			--region "$(REGION)" \
			--key-id "$(TLS_KEY_ID)" \
			--plaintext "`terraform output server_cert`" \
			--query CiphertextBlob \
			--output text | base64 --decode > server.cert.enc && \
		aws s3 cp server.cert.enc "s3://$(TLS_BUCKET)/consul/server.cert.enc" && \
		rm -f server.cert.enc && \
		aws kms encrypt \
			--region "$(REGION)" \
			--key-id "$(TLS_KEY_ID)" \
			--plaintext "`terraform output server_key`" \
			--query CiphertextBlob \
			--output text | base64 --decode > server.key.enc && \
		aws s3 cp server.key.enc "s3://$(TLS_BUCKET)/consul/server.key.enc" && \
		rm -f server.key.enc && \
		echo "`terraform output root_cert`" > bundle.cert && \
		echo "`terraform output intermediate_cert`" >> bundle.cert

nomad/.terraform/terraform.tfstate:
	@cd nomad && \
		terraform init \
			-backend-config "bucket=$(STATE_BUCKET)"

.PHONY: nomad-ca
nomad-ca: nomad/bundle.cert ## Build Nomad CA

nomad/bundle.cert: nomad/.terraform/terraform.tfstate
	@cd nomad && \
		AWS_REGION=$(REGION) \
		terraform apply -backup=- && \
		aws kms encrypt \
			--region "$(REGION)" \
			--key-id "$(TLS_KEY_ID)" \
			--plaintext "`terraform output server_cert`" \
			--query CiphertextBlob \
			--output text | base64 --decode > server.cert.enc && \
		aws s3 cp server.cert.enc "s3://$(TLS_BUCKET)/nomad/server.cert.enc" && \
		rm -f server.cert.enc && \
		aws kms encrypt \
			--region "$(REGION)" \
			--key-id "$(TLS_KEY_ID)" \
			--plaintext "`terraform output server_key`" \
			--query CiphertextBlob \
			--output text | base64 --decode > server.key.enc && \
		aws s3 cp server.key.enc "s3://$(TLS_BUCKET)/nomad/server.key.enc" && \
		rm -f server.key.enc && \
		echo "`terraform output root_cert`" > bundle.cert && \
		echo "`terraform output intermediate_cert`" >> bundle.cert

vault/.terraform/terraform.tfstate:
	@cd vault && \
		terraform init \
			-backend-config "bucket=$(STATE_BUCKET)"

.PHONY: vault-ca
vault-ca: vault/bundle.cert ## Build Vault CA

vault/bundle.cert: vault/.terraform/terraform.tfstate
	@cd nomad && \
		AWS_REGION=$(REGION) \
		terraform apply -backup=- && \
		aws kms encrypt \
			--region "$(REGION)" \
			--key-id "$(TLS_KEY_ID)" \
			--plaintext "`terraform output server_cert`" \
			--query CiphertextBlob \
			--output text | base64 --decode > server.cert.enc && \
		aws s3 cp server.cert.enc "s3://$(TLS_BUCKET)/nomad/server.cert.enc" && \
		rm -f server.cert.enc && \
		aws kms encrypt \
			--region "$(REGION)" \
			--key-id "$(TLS_KEY_ID)" \
			--plaintext "`terraform output server_key`" \
			--query CiphertextBlob \
			--output text | base64 --decode > server.key.enc && \
		aws s3 cp server.key.enc "s3://$(TLS_BUCKET)/nomad/server.key.enc" && \
		rm -f server.key.enc && \
		echo "`terraform output root_cert`" > bundle.cert && \
		echo "`terraform output intermediate_cert`" >> bundle.cert

.PHONY: help
help: ## Display this information. Default target.
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
