## Default toolchain detection / configuration

# Toolchain path
ifneq ("$(USE_NATIVE_COMPILER)","")
ifeq ("$(CROSS_COMPILE)","")
AARCH64_TOOLCHAIN = $(firstword $(wildcard $(shell pwd)/toolchains/*aarch64-none-linux-gnu*/))
CROSS_COMPILE := $(AARCH64_TOOLCHAIN)bin/aarch64-none-linux-gnu-
endif
endif
ifeq ($(TOOLCHAIN_ARM32),1)
CROSS_COMPILE := $(CROSS_COMPILE_ARM32)
endif
ifeq ("$(wildcard $(CROSS_COMPILE)gcc)","")
$(error Toolchain not found! Please export CROSS_COMPILE or edit makefile!)
endif
# this can be used as argument to each make invocation
_XC_ARG = CROSS_COMPILE=$(CROSS_COMPILE)
$(info Using $(_XC_ARG))

