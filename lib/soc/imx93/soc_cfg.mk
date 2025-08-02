## NXP iMX93 SoC defaults for the build system

SOC_ARCH := arm64
SOC_ARCH_PATH ?= arch/$(SOC_ARCH)

# iMX binary firmwares (wildcard patterns allowed)
_IMX_FW_LPDDR4_NAMES ?= \
		lpddr4_imem_1d_v202201.bin lpddr4_dmem_1d_v202201.bin \
		lpddr4_imem_2d_v202201.bin lpddr4_dmem_2d_v202201.bin \
			lpddr4_pmu_train_1d_dmem.bin lpddr4_pmu_train_1d_imem.bin \
			lpddr4_pmu_train_2d_dmem.bin lpddr4_pmu_train_2d_imem.bin
IMX_FW_LPDDR4 ?= $(_IMX_FW_LPDDR4_NAMES:%=$(IMX_FW_EXTRACT_DIR)/firmware/ddr/synopsys/%)
IMX_SENTINEL_AHAB_CONTAINER ?= $(IMX_SENTINEL_EXTRACT_DIR)/mx93a1-ahab-container.img
IMX_FIRMWARE_FILES_FULL ?= $(IMX_FW_LPDDR4)
IMX_SENTINEL_FILES_FULL ?= $(IMX_SENTINEL_AHAB_CONTAINER)
# imx93 generated flash.bin directly from u-boot's binman (does not use mkimage)
UBOOT_COPY_FILES ?= $(IMX_FIRMWARE_FILES_FULL) $(IMX_SENTINEL_FILES_FULL) \
					$(ATF_BIN_FULL)
IMX_OUT_FLASH_BIN ?= $(UBOOT_DEST)/flash.bin

# ARM Trusted Firmware for imx93
ATF_PLATFORM ?= imx93

# U-boot build parmeters
UBOOT_DEFCONFIG ?= defconfig
#UBOOT_DEVICE_TREE ?= DEFINED_BY_BOARD

IMX_MKIMAGE_MK_TARGET ?= flash_evk

# Linux kernel build vars
KERNEL_DEFCONFIG ?= defconfig
#KERNEL_DTS ?= DEFINED_BY_BOARD

# Boot record for SD/eMMC is at 32KB offset (from Reference Manual)
# in 512B sectors, this is:
DISKIMG_BOOT_SECTOR_SD ?= 64
DISKIMG_BOOT_SECTOR_EMMC ?= $(DISKIMG_BOOT_SECTOR_SD)
