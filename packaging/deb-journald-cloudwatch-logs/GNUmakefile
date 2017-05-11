PACKAGE_NAME = journald-cloudwatch-logs
PACKAGE_ARCH = amd64
PACKAGE_MAINTAINER = Operator Error <ops@operator-error.com>
PACKAGE_VENDOR = Say Media
PACKAGE_DESCRIPTION = Ships Cloudwatch Logs from Journald
PACKAGE_SECTION = net
PACKAGE_HOMEPAGE = https://www.github.com/jen20/journald-cloudwatch-logs
PACKAGE_DEP_FLAGS = --depends 'awscli >= 1.11.13'

LOGS_VERSION = 0.5
LOGS_SHA256 = bc20e93b2f17edb0b2e13f3edb232228cab250370d5a994134e9d9b1677e3720
LOGS_URL = https://github.com/jen20/journald-cloudwatch-logs/releases/download/$(LOGS_VERSION)/journald-cloudwatch-logs

SOURCE_DIR = $(CURDIR)/sources
BUILD_DIR = $(CURDIR)/deb-pkg
TARGET_DIR = $(CURDIR)/../packages

default: help

pkg: $(TARGET_DIR)/$(PACKAGE_NAME)-$(GOMPLATE_VERSION)-$(PACKAGE_ARCH).deb ## Build package

$(TARGET_DIR)/$(PACKAGE_NAME)-$(GOMPLATE_VERSION)-$(PACKAGE_ARCH).deb: layout
	mkdir -p $(TARGET_DIR)
	fpm -t deb -s dir \
		-C "$(BUILD_DIR)" \
		-p "$(TARGET_DIR)" \
		-n "$(PACKAGE_NAME)" \
		-v "$(LOGS_VERSION)" \
		-a "$(PACKAGE_ARCH)" \
		--after-install ./scripts/postinst \
		--after-remove ./scripts/postrm \
		--before-install ./scripts/preinst \
		--category "$(PACKAGE_SECTION)" \
		--deb-no-default-config-files \
		--deb-user root \
		--deb-group root \
		--description "$(PACKAGE_DESCRIPTION)" \
		--maintainer "$(PACKAGE_MAINTAINER)" \
		--url "$(PACKAGE_HOMEPAGE)" \
		--vendor "$(PACKAGE_VENDOR)" \
		$(PACKAGE_DEP_FLAGS) \
		.

$(SOURCE_DIR)/journald-cloudwatch-logs:
	mkdir -p $(SOURCE_DIR)
	wget -O $(SOURCE_DIR)/journald-cloudwatch-logs $(LOGS_URL)

.PHONY: layout
layout: $(SOURCE_DIR)/journald-cloudwatch-logs ## Lay out the package image structure
	@if [ "$(shell shasum --algorithm 256 $(SOURCE_DIR)/journald-cloudwatch-logs | cut -d ' ' -f 1)" != "$(LOGS_SHA256)" ]; then \
		echo "SHA256 of gomplate is not $(LOGS_SHA256)" && exit 1; \
		fi
	mkdir -p $(BUILD_DIR)/usr/local/bin
	cp -r $(SOURCE_DIR)/journald-cloudwatch-logs $(BUILD_DIR)/usr/local/bin
	chmod +x $(BUILD_DIR)/usr/local/bin/journald-cloudwatch-logs

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


