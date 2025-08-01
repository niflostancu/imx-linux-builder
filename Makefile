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
include $(MK_FRAMEWORK_SRC)/scripts/05_tools.mk
include $(MK_FRAMEWORK_SRC)/scripts/10_prop_firmware.mk
include $(MK_FRAMEWORK_SRC)/scripts/14_trusted_firmware.mk
include $(MK_FRAMEWORK_SRC)/scripts/20_uboot.mk
include $(MK_FRAMEWORK_SRC)/scripts/24_optee.mk
include $(MK_FRAMEWORK_SRC)/scripts/25_imx_image.mk
include $(MK_FRAMEWORK_SRC)/scripts/32_kernel.mk
include $(MK_FRAMEWORK_SRC)/scripts/42_buildroot.mk
include $(MK_FRAMEWORK_SRC)/scripts/80_linux_fit.mk
include $(MK_FRAMEWORK_SRC)/scripts/85_disk_image.mk

