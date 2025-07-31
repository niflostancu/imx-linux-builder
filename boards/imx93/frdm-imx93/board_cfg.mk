## Board-specific config for TechNexion PICO-PI-IMX8MQ board

IMX_SOC = imx93
ATF_PLATFORM ?= imx93
IMX_MKIMAGE_SOC ?= iMX93

UBOOT_DEFCONFIG ?= imx93_frdm_defconfig
UBOOT_DEVICE_TREE ?= imx93-11x11-frdm
UBOOT_EXTRA_CONFIG_FILES ?=

# Use Linux mainline
KERNEL_DTS ?= arch/$(SOC_ARCH)/boot/dts/freescale/imx93-11x11-evk.dts
#LINUX_UIMAGE_ITS ?= $(MK_BOARD_SRC)/linux-uimage.its

# Load RV1106 SoC defaults
MK_SOC_DIR := $(MK_FRAMEWORK_LIB)/soc/$(IMX_SOC)
include $(MK_SOC_DIR)/soc_cfg.mk
