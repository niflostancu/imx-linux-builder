## NXP iMX8M SoC defaults for the build system

SOC_ARCH := arm64
SOC_ARCH_PATH ?= arch/$(SOC_ARCH)

# iMX binary firmwares (wildcard patterns allowed)
_IMX_FW_LPDDR4_NAMES ?= \
			lpddr4_pmu_train_1d_dmem.bin lpddr4_pmu_train_1d_imem.bin \
			lpddr4_pmu_train_2d_dmem.bin lpddr4_pmu_train_2d_imem.bin
IMX_FW_LPDDR4 ?= $(_IMX_FW_LPDDR4_NAMES:%=$(IMX_FW_EXTRACT_DIR)/firmware/ddr/synopsys/%)
IMX_FW_HDMI ?= $(IMX_FW_EXTRACT_DIR)/firmware/hdmi/cadence/signed_hdmi_imx8m.bin
IMX_FIRMWARE_FILES_FULL ?= $(IMX_FW_LPDDR4) $(IMX_FW_HDMI)

# ARM Trusted Firmware for imx8m
ATF_PLATFORM ?= imx8mX

# U-boot build parmeters
UBOOT_DEFCONFIG ?= defconfig
#UBOOT_DEVICE_TREE ?= DEFINED_BY_BOARD

IMX_MKIMAGE_MK_TARGET ?= flash_evk

# Linux kernel build vars
KERNEL_DEFCONFIG ?= defconfig
#KERNEL_DTS ?= DEFINED_BY_BOARD

