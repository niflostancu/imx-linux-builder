## Common Makefile vars 

# some commands require bash (esp. for the `[[ ... ]]` conditions)
SHELL=bash
# disable https://www.gnu.org/software/make/manual/html_node/Suffix-Rules.html
.SUFFIXES:

-include $(SRC)/config.local.mk

# Targets to build by default
ALL_TARGETS ?= firmware atf uboot linux buildroot linux_uimage emmc_image

# Common destination root for all build artifacts
# (>20GB disk space required!)
BUILD_DEST ?= /tmp/imx8-build

# Toolchain path
ifeq ("$(CROSS_COMPILE)","")
AARCH64_TOOLCHAIN = $(firstword $(wildcard $(shell pwd)/toolchains/*aarch64-none-linux-gnu*/))
CROSS_COMPILE := $(AARCH64_TOOLCHAIN)bin/aarch64-none-linux-gnu-
endif
# this can be used as argument to each make invocation
_XC_ARG = CROSS_COMPILE=$(CROSS_COMPILE)
$(info Using $(_XC_ARG))
ifeq ("$(wildcard $(CROSS_COMPILE)gcc)","")
$(error Toolchain not found! Please export CROSS_COMPILE or edit makefile!)
endif

# common vars
NPROC ?= $(shell bash -c 'expr $$(nproc) - 2')

blank :=
define NL

$(blank)
endef

all: $(ALL_TARGETS)

# makefile force hack
_FORCE=$(if $(FORCE),.FORCE,)
.PHONY: .FORCE
.FORCE:

