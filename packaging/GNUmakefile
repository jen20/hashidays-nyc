BUCKET_REGION ?= us-west-2
STAGE_NAME ?= apt-hashistack-stage
BUCKET_NAME ?= apt.hashistack.gentec-systems.com

CODENAME ?= xenial
SUITE ?= stable
COMPONENT ?= main

APT_SIGNING_FINGERPRINT ?= C6398F90FA354C7FA2D411B82CE07C37E69C1453 
APT_KEY_DIRECTORY ?= $(HOME)/.

# Do not edit below here

FIND = $(shell (which gfind find || true) | head -n 1)
PACKAGES := $(shell $(FIND) deb-* -maxdepth 0 -xtype d)
REPO_DIR = ./packages

GPG_OPTS=\-\-no-tty \-\-digest-algo SHA256 \-\-passphrase='$(APT_SIGNING_PASSPHRASE)'

.PHONY: default
default: help

.PHONY: world
world: $(PACKAGES) ## Build all packages

.PHONY: $(PACKAGES)
$(PACKAGES): ## Build named package
	@mkdir -p $(REPO_DIR)
	@echo "Building $@..."
	@cd $@ && $(MAKE) pkg

.PHONY: repo
repo: ## Upload packages to repository
	@AWS_REGION=$(BUCKET_REGION) \
		deb-s3 upload \
			--preserve-versions \
			--codename="$(CODENAME)" \
			--suite="$(SUITE)" \
			--component="$(COMPONENT)" \
			--sign="$(APT_SIGNING_FINGERPRINT)" \
			--gpg-options="$(GPG_OPTS)" \
			--visibility private \
			--bucket="$(STAGE_NAME)" \
			$(shell $(FIND) $(REPO_DIR)/*.deb)
	@aws s3 sync s3://${STAGE_NAME} s3://${BUCKET_NAME}

.PHONY: clean
clean: ## Clean built packages
	rm -rf "$(REPO_DIR)"

.PHONY: help
help:
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+%*:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
