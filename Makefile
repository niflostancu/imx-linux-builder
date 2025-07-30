## Default entrypoint for NXP iMX firmware builder
## Feel free to copy this Makefile and start customizing your build!

# Load local (user) config (from makefile's working directory)
-include config.local.mk

# Note: make this point back to the framework path if you copy this Makefile
MK_FRAMEWORK_SRC := .

# absolute path to current (root) directory
SRC=$(abspath .)

include $(MK_FRAMEWORK_SRC)/scripts/00_init.mk
include $(MK_FRAMEWORK_SRC)/scripts/01_toolchain.mk
include $(MK_FRAMEWORK_SRC)/scripts/10_prop_firmware.mk
include $(MK_FRAMEWORK_SRC)/scripts/14_trusted_firmware.mk
include $(MK_FRAMEWORK_SRC)/scripts/20_uboot.mk

include $(MK_FRAMEWORK_SRC)/scripts/optee.mk
include $(MK_FRAMEWORK_SRC)/scripts/linux.mk
include $(MK_FRAMEWORK_SRC)/scripts/buildroot.mk
include $(MK_FRAMEWORK_SRC)/scripts/image.mk
include $(MK_FRAMEWORK_SRC)/scripts/flash.mk

