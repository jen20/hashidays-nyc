PACKAGE_NAME = vault
PACKAGE_ARCH = amd64
PACKAGE_MAINTAINER = Operator Error <ops@operator-error.com>
PACKAGE_VENDOR = HashiCorp
PACKAGE_DESCRIPTION = Secrets Management Platform
PACKAGE_SECTION = net
PACKAGE_HOMEPAGE = https://www.vaultproject.io
PACKAGE_DEP_FLAGS = --depends 'consul >= 0.8.0'

VAULT_VERSION = 0.7.2
VAULT_SHA256 = 22575dbb8b375ece395b58650b846761dffbf5a9dc5003669cafbb8731617c39

VAULT_URL = https://releases.hashicorp.com/vault/$(VAULT_VERSION)/vault_$(VAULT_VERSION)_linux_$(PACKAGE_ARCH).zip

SOURCE_DIR = $(CURDIR)/sources
BUILD_DIR = $(CURDIR)/deb-pkg
TARGET_DIR = $(CURDIR)/../packages

default: help

pkg: $(TARGET_DIR)/$(PACKAGE_NAME)-$(VAULT_VERSION)-$(PACKAGE_ARCH).deb ## Build package

$(TARGET_DIR)/$(PACKAGE_NAME)-$(VAULT_VERSION)-$(PACKAGE_ARCH).deb: layout
	mkdir -p $(TARGET_DIR)
	fpm -t deb -s dir \
		-C "$(BUILD_DIR)" \
		-p "$(TARGET_DIR)" \
		-n "$(PACKAGE_NAME)" \
		-v "$(VAULT_VERSION)" \
		-a "$(PACKAGE_ARCH)" \
		--after-install ./scripts/postinst \
		--after-remove ./scripts/postrm \
		--before-install ./scripts/preinst \
		--before-remove ./scripts/prerm \
		--category "$(PACKAGE_SECTION)" \
		--config-files=/etc \
		--deb-no-default-config-files \
		--deb-user root \
		--deb-group root \
		--description "$(PACKAGE_DESCRIPTION)" \
		--maintainer "$(PACKAGE_MAINTAINER)" \
		--url "$(PACKAGE_HOMEPAGE)" \
		--vendor "$(PACKAGE_VENDOR)" \
		$(PACKAGE_DEP_FLAGS) \
		.

$(SOURCE_DIR)/vault.zip:
	mkdir -p $(SOURCE_DIR)
	wget -O $(SOURCE_DIR)/vault.zip $(VAULT_URL)

.PHONY: layout
layout: $(SOURCE_DIR)/vault.zip ## Lay out the package image structure
	@if [ "$(shell shasum --algorithm 256 $(SOURCE_DIR)/vault.zip | cut -d ' ' -f 1)" != "$(VAULT_SHA256)" ]; then \
		echo "SHA256 of vault.zip is not $(VAULT_SHA256)" && exit 1; \
		fi
	cd $(SOURCE_DIR) && unzip -u $(SOURCE_DIR)/vault.zip
	# Main Vault directory
	mkdir -p $(BUILD_DIR)/usr/local/bin
	cp -r $(SOURCE_DIR)/vault $(BUILD_DIR)/usr/local/bin

.PHONY: clean
clean: ## Clean sources excluding downloaded sources
	rm -rf $(CURDIR)/target
	git clean -xdf $(BUILD_DIR)

clean-all: ## Clean sources including downloaded sources
	rm -rf $(CURDIR)/target
	git clean -xdf $(BUILD_DIR)
	git clean -xdf $(SOURCE_DIR)

.PHONY: help
help:
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+%*:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
