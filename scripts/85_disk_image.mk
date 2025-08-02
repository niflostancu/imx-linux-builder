# i.MX mkimage script configuration

# load disk partitioning macros
include $(MK_FRAMEWORK_LIB)/snippets/disk_partitioning.mk

# EMMC & SD card image default configs
DISKIMG_OUT_SD = $(BUILD_DEST)/sdcard.img
DISKIMG_OUT_EMMC = $(BUILD_DEST)/emmc.img
DISKIMG_SIZE_SD ?= 128M
DISKIMG_SIZE_EMMC ?= $(DISKIMG_SIZE_SD)
# Partitioning scheme to use
DISKIMG_PART_SCHEME ?= FDISK
DISKIMG_PART_SCRIPT_SD ?= $(PART_FDISK_1P_BOOT_FULL)
DISKIMG_PART_SCRIPT_EMMC ?= $(DISKIMG_PART_SCRIPT_SD)
# optional contents for the uboot.env file (will be created on boot part)
DISKIMG_UBOOT_ENV_SD ?=
DISKIMG_UBOOT_ENV_EMMC ?=
# boot image offset (in 512B sectors) to be written at
DISKIMG_BOOT_SECTOR_SD ?= 2
DISKIMG_BOOT_SECTOR_EMMC ?= $(DISKIMG_BOOT_SECTOR_SD)
# rootfs options
DISKIMG_PART2_COPY_ROOTFS ?=

# Temporary mountpoint to use
DISKIMG_TMP_MOUNTPOINT ?= /tmp/mnt

# Internal/computed vars
_DSKIMG_OUT ?= $(DISKIMG_OUT_$(img_type))
_DSKIMG_SIZE ?= $(DISKIMG_SIZE_$(img_type))
_DSKIMG_BOOT_SECTOR ?= $(DISKIMG_BOOT_SECTOR_$(img_type))
_DSKIMG_PART_MACRO ?= $(PART_MACRO_$(DISKIMG_PART_SCHEME))
_DSKIMG_PART_SCR_VAR ?= _DSKIMG_PART_SCRIPT_$(img_type)_
_DSKIMG_UBOOT_ENV_VAR ?= _DSKIMG_UBOOT_ENV_$(img_type)_

define DISKIMG_SCR_FULL?=
$(call disk_image_create,$(_DSKIMG_SIZE),$(_DSKIMG_OUT))
$(call $(_DSKIMG_PART_MACRO),$(_DSKIMG_PART_SCR_VAR),$(_DSKIMG_OUT))
$(call disk_lodev_attach,$(_DSKIMG_OUT))
# begin default disk image script:
MNT=$(DISKIMG_TMP_MOUNTPOINT)
mkdir -p "$$MNT"
$(_DSKIMG_SCR_PART1)
$(if $(DISKIMG_PART2_COPY_ROOTFS),$(_DSKIMG_SCR_PART2))
$(_DSKIMG_SCR_WRITE_BOOT)
# END disk image script!
$(disk_lodev_cleanup)
endef
# inner script: first (boot) partition
define _DSKIMG_SCR_PART1 ?=
$(MKFS_FAT32) $${LOOP_DEV}p1
$(MOUNT) "$${LOOP_DEV}p1" $$MNT
$(SUDO) cp "$(LINUX_UIMAGE_OUT)" $$MNT/
echo "$$$(_DSKIMG_UBOOT_ENV_VAR)" | $(SUDO) tee $$MNT/uboot.txt
echo "$$$(_DSKIMG_UBOOT_ENV_VAR)" | $(SUDO) $(call uboot_mk_env_stdin,$$MNT/uboot.env) 
ls -lh $$MNT
$(UMOUNT) $$MNT
endef
# inner script: second (rootfs) partition
define _DSKIMG_SCR_PART2 ?=
$(MKFS_EXT4) $${LOOP_DEV}p2
$(MOUNT) "$${LOOP_DEV}p2" $$MNT
$(SUDO) tar xf "$(BUILDROOT_OUT_TAR)" -S -C $$MNT/
ls -lh $$MNT
$(UMOUNT) $$MNT
endef
define _DSKIMG_SCR_WRITE_BOOT ?=
$(DD) if="$(IMX_OUT_FLASH_BIN)" of="$$LOOP_DEV" bs=512 seek=$(_DSKIMG_BOOT_SECTOR)
endef

# SD & eMMC card image targets
.PHONY: emmc_image sd_image
emmc_image:
	$(MAKE_FORCED) $(DISKIMG_OUT_EMMC)
$(DISKIMG_OUT_EMMC): $(LINUX_UIMAGE_OUT) $(IMX_OUT_FLASH_BIN) \
		$(_FORCE) | $(STAGING_DEST)/
	bash -x -c "$$_DSKIMG_SH_SCRIPT_FULL_EMMC_"
sd_image:
	$(MAKE_FORCED) $(DISKIMG_OUT_SD)
$(DISKIMG_OUT_SD): $(LINUX_UIMAGE_OUT) $(IMX_OUT_FLASH_BIN) \
		$(_FORCE) | $(STAGING_DEST)/
	bash -x -c "$$_DSKIMG_SH_SCRIPT_FULL_SD_"
# export some makefile vars for bash usage:
export _DSKIMG_SH_SCRIPT_FULL_SD_=$(let img_type,SD,$(DISKIMG_SCR_FULL))
export _DSKIMG_SH_SCRIPT_FULL_EMMC_=$(let img_type,EMMC,$(DISKIMG_SCR_FULL))
export _DSKIMG_PART_SCRIPT_SD_=$(let img_type,SD,$(DISKIMG_PART_SCRIPT_SD))
export _DSKIMG_PART_SCRIPT_EMMC_=$(let img_type,EMMC,$(DISKIMG_PART_SCRIPT_EMMC))
export _DSKIMG_UBOOT_ENV_SD_=$(let img_type,SD,$(DISKIMG_UBOOT_ENV_SD))
export _DSKIMG_UBOOT_ENV_EMMC_=$(let img_type,EMMC,$(DISKIMG_UBOOT_ENV_EMMC))

.PHONY: uuu_emmc
uuu_emmc: $(DISKIMG_OUT_EMMC) | $(UUU)
	$(UUU) -b emmc_all $(IMX_OUT_FLASH_BIN) $(DISKIMG_OUT_EMMC)

.PHONY: dd_sd
SD_DEV ?= 
dd_sd: $(DISKIMG_OUT_SD)
	@if [ -z "$(SD_DEV)" ]; then \
		echo "ERROR: please specify 'SD_DEV', e.g. SD_DEV=/dev/mmcblk..."; exit 1; \
	fi
	$(SUDO) dd if="$(DISKIMG_OUT_SD)" of="$(SD_DEV)" status=progress

