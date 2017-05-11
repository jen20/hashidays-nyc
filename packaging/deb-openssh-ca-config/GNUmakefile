PACKAGE_NAME = openssh-ca-config
PACKAGE_ARCH = amd64
PACKAGE_MAINTAINER = Operator Error <ops@operator-error.com>
PACKAGE_VENDOR = Operator Error
PACKAGE_DESCRIPTION = OpenSSH and CA Configuration
PACKAGE_SECTION = net
PACKAGE_HOMEPAGE = https://www.openssh.com
PACKAGE_DEP_FLAGS = --depends 'ssh >= 1:7.2'

PACKAGE_VERSION =1.0

BUILD_DIR = $(CURDIR)/deb-pkg
TARGET_DIR = $(CURDIR)/../packages

default: help

pkg: $(TARGET_DIR)/$(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(PACKAGE_ARCH).deb ## Build package

$(TARGET_DIR)/$(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(PACKAGE_ARCH).deb:
	mkdir -p $(TARGET_DIR)
	fpm -t deb -s dir \
		-C "$(BUILD_DIR)" \
		-p "$(TARGET_DIR)" \
		-n "$(PACKAGE_NAME)" \
		-v "$(PACKAGE_VERSION)" \
		-a "$(PACKAGE_ARCH)" \
		--after-install ./scripts/postinst \
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

.PHONY: help
help:
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+%*:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'


