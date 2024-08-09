################################################################################
## Full firmware+Linux image makefile script for NXP i.MX8M-based boards
################################################################################

# absolute path to current (root) directory
SRC=$(abspath .)

include $(SRC)/scripts/vars.mk
include $(SRC)/scripts/optee.mk
include $(SRC)/scripts/firmware.mk
include $(SRC)/scripts/uboot.mk
include $(SRC)/scripts/linux.mk
include $(SRC)/scripts/buildroot.mk
include $(SRC)/scripts/image.mk
include $(SRC)/scripts/flash.mk

# finally, a clean rule:
.PHONY: clean
clean: uboot_clean atf_clean linux_clean buildroot_clean mkimage_clean

