## Copy + rename as config.local.mk in order to apply these settings!

# Common destination root for all build artifacts
# (>20GB disk space required!)
# FIXME: change this!
#BUILD_DEST ?= $(HOME)/tmp/arm-builder/$(notdir $(CFG))

# Toolchain prefix
# FIXME: change this!
#CROSS_COMPILE=$(HOME)/.local/embedded/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
#CROSS_COMPILE_ARM32=$(HOME)/.local/embedded/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
# or just use this if you're building on a native platform:
#USE_NATIVE_COMPILER=1

# feel free to override the makefile variables below!

# default board configuration name (overridable using `make CFG=myboard ...`)
#CFG ?= imx8m/tn-pico-pi-imx8mq

# Custom U-Boot config & default environment
#UBOOT_EXTRA_CONFIG_FILES = $(SRC)/configs/uboot-custom.config
#UBOOT_DEFAULT_ENV_FILE = $(SRC)/configs/uboot-custom.env

# Enable OP-TEE?
#OPTEE_ENABLED = 1

# Extra Linux patch
#KERNEL_APPLY_PATCHES = $(SRC)/patches/my-modifications.patch

# custom buildroot configs / overlays (examples / uncomment)
#BUILDROOT_ADD_LINUX_MODULES = 1

# Image options
#DISKIMG_SIZE_SD = 512M

