# TODO: rename as config.local.mk in order to apply these settings!

# Common destination root for all build artifacts
# (>20GB disk space required!)
# FIXME: change this!
BUILD_DEST ?= $(HOME)/tmp/imx8-build-2024

# Toolchain prefix
# FIXME: change this!
#CROSS_COMPILE=$(HOME)/.local/embedded/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
# or just use this if you're building on a native platform
#USE_NATIVE_COMPILER=1

# feel free to override the makefile variables below!

# Custom U-Boot config & default environment
#UBOOT_EXTRA_CONFIGS = $(SRC)/configs/uboot-imx8mq.config
#UBOOT_DEFAULT_ENV_FILE = $(SRC)/configs/uboot-default.env

# Enable OP-TEE?
#OPTEE_ENABLED = 1

# Extra Linux patch
#LINUX_EXTRA_PATCH = $(SRC)/patches/linux-imx8mq-power-regs.patch

# custom buildroot configs / overlays (examples / uncomment)
#BUILDROOT_ADD_LINUX_MODULES = 1

# Image options
#EMMC_IMAGE_SIZE = 256M

