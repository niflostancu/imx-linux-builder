## Board-specific config for TechNexion PICO-PI-IMX8MQ board

IMX_SOC = imx8m
ATF_PLATFORM ?= imx8mq
OPTEE_PLATFORM ?= imx-mx8mqevk
IMX_MKIMAGE_SOC ?= iMX8M

# Use custom TechNexion U-Boot fork
UBOOT_GIT_URL ?= https://github.com/TechNexion/u-boot-tn-imx.git
UBOOT_GIT_BRANCH ?= tn-imx_v2023.04_6.1.55_2.2.0-stable
UBOOT_DEFCONFIG ?= pico-imx8mq_defconfig
# UBOOT_COPY_DTS ?= $(MK_BOARD_SRC)/uboot/pico-pi-imx8mq.dts
UBOOT_DEVICE_TREE ?= imx8mq-pico-pi
UBOOT_EXTRA_CONFIG_FILES ?= $(MK_BOARD_SRC)/uboot/usb-gadget.config
UBOOT_DEFAULT_ENV_FILE ?= $(MK_BOARD_SRC)/uboot/default.env

# Enable OP-TEE?
OPTEE_ENABLED ?=
# Memory configuration
TRUSTED_UART_BASE ?= 0x30860000
# allocate 32MB for TZDRAM, then 4MB for shared memory at the end of DRAM
OPTEE_TZDRAM_ADDR ?= 0xbdc00000
OPTEE_TZDRAM_SIZE ?= 0x02000000
OPTEE_SHMEM_SIZE ?= 0x00400000
OPTEE_SHMEM_ADDR ?= 0xbfc00000
OPTEE_TOTAL_SIZE ?= 0x02400000
OPTEE_DDR_SIZE = 0x80000000

# Use Linux mainline
KERNEL_GIT_BRANCH ?= v6.6
KERNEL_DTS ?= arch/$(SOC_ARCH)/boot/dts/freescale/imx8mq-pico-pi.dts
LINUX_UIMAGE_ITS ?= $(MK_BOARD_SRC)/linux-uimage.its
# apply some patches...
KERNEL_APPLY_PATCHES = \
		$(MK_BOARD_SRC)/linux/imx8mq-power-regs.patch \
		$(MK_BOARD_SRC)/linux/imx8mq-optee.patch

# Buildroot config
BUILDROOT_EXTRA_CONFIG_FILES ?= $(MK_BOARD_SRC)/buildroot/default.config
BUILDROOT_EXTRA_CONFIG_FILES += \
		$(if $(OPTEE_ENABLED),$(MK_BOARD_SRC)/buildroot/optee.config)

# Image options
EMMC_IMAGE_SIZE = 256M
define EMMC_UBOOT_ENV=
bootargs=console=ttymxc0,115200 init=/sbin/init
loadaddr=0x70000000
mmcboot=echo Booting...; load mmc 0:1 $${loadaddr} linux.itb; bootm $${loadaddr}
endef

# Load SoC defaults
MK_SOC_DIR := $(MK_FRAMEWORK_LIB)/soc/$(IMX_SOC)
include $(MK_SOC_DIR)/soc_cfg.mk
