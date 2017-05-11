PACKAGE_NAME = gomplate
PACKAGE_ARCH = amd64
PACKAGE_MAINTAINER = Operator Error <ops@operator-error.com>
PACKAGE_VENDOR = Dave Henderson
PACKAGE_DESCRIPTION = Command Line Golang Template Processor 
PACKAGE_SECTION = admin
PACKAGE_HOMEPAGE = https://www.github.com/hairyhenderson/gomplate
PACKAGE_DEP_FLAGS = 

GOMPLATE_VERSION = 1.6.0
GOMPLATE_SHA256 = 07cddc5621ede8da268ca95bcab5b10f15a0bf49380f99f030e3b1a36dea3e08

GOMPLATE_URL = https://github.com/hairyhenderson/gomplate/releases/download/v$(GOMPLATE_VERSION)/gomplate_linux-$(PACKAGE_ARCH)

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
		-v "$(GOMPLATE_VERSION)" \
		-a "$(PACKAGE_ARCH)" \
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

$(SOURCE_DIR)/gomplate:
	mkdir -p $(SOURCE_DIR)
	wget -O $(SOURCE_DIR)/gomplate $(GOMPLATE_URL)

.PHONY: layout
layout: $(SOURCE_DIR)/gomplate ## Lay out the package image structure
	@if [ "$(shell shasum --algorithm 256 $(SOURCE_DIR)/gomplate | cut -d ' ' -f 1)" != "$(GOMPLATE_SHA256)" ]; then \
		echo "SHA256 of gomplate is not $(GOMPLATE_SHA256)" && exit 1; \
		fi
	mkdir -p $(BUILD_DIR)/usr/local/bin
	cp -r $(SOURCE_DIR)/gomplate $(BUILD_DIR)/usr/local/bin

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


