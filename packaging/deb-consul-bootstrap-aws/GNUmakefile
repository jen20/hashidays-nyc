CONSUL_VERSION = 0.8.3

PACKAGE_NAME = consul-bootstrap-aws
PACKAGE_ARCH = amd64
PACKAGE_MAINTAINER = Operator Error <ops@operator-error.com>
PACKAGE_VENDOR = Operator Error
PACKAGE_DESCRIPTION = Consul Bootstrapping for AWS
PACKAGE_SECTION = net
PACKAGE_HOMEPAGE = https://www.operator-error.com
PACKAGE_DEP_FLAGS = --depends 'awscli >= 1.11.13' \
					--depends 'curl >= 7.47.0' \
					--depends 'gomplate >= 1.6.0' \
					--depends 'consul >= $(CONSUL_VERSION)' \
					--depends 'dnsmasq >= 2.75'

SOURCE_DIR = $(CURDIR)/sources
BUILD_DIR = $(CURDIR)/deb-pkg
TARGET_DIR = $(CURDIR)/../packages

default: help

pkg: $(TARGET_DIR)/$(PACKAGE_NAME)-$(CONSUL_VERSION)-$(PACKAGE_ARCH).deb ## Build package

$(TARGET_DIR)/$(PACKAGE_NAME)-$(CONSUL_VERSION)-$(PACKAGE_ARCH).deb:
	mkdir -p $(TARGET_DIR)
	fpm -t deb -s dir \
		-C "$(BUILD_DIR)" \
		-p "$(TARGET_DIR)" \
		-n "$(PACKAGE_NAME)" \
		-v "$(CONSUL_VERSION)" \
		-a "$(PACKAGE_ARCH)" \
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


