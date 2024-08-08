# i.MX mkimage script configuration
MKIMAGE_DIR = $(BUILD_DEST)/imx-mkimage
MKIMAGE_GIT_URL = https://github.com/nxp-imx/imx-mkimage.git
MKIMAGE_SOC = iMX8M
MKIMAGE_FLAGS = SOC=$(MKIMAGE_SOC) dtbs=$(UBOOT_DTB)
MKIMAGE_FIRMWARE_DEST = $(MKIMAGE_DIR)/$(MKIMAGE_SOC)
MKIMAGE_OUT_FLASH_BIN = $(MKIMAGE_FIRMWARE_DEST)/flash.bin

# uImage creation config
STAGING_DIR = $(BUILD_DEST)/staging
LINUX_UIMAGE_ITS = $(SRC)/linux-uimage.its
LINUX_UIMAGE_OUT = linux.itb

# EMMC image config
EMMC_IMAGE_OUT = $(BUILD_DEST)/disk.img
EMMC_IMAGE_SIZE ?= 128M
# contents of the uboot.env file (will be created on mmc boot part)
define EMMC_UBOOT_ENV=
bootargs=console=ttymxc0,115200 init=/sbin/init
loadaddr=0x70000000
mmcboot=echo Booting...; load mmc 0:1 $${loadaddr} linux.itb; bootm $${loadaddr}
endef
export EMMC_UBOOT_ENV

# i.MX mkimage build targets + internal vars
_UBOOT_FILENAMES=$(notdir $(UBOOT_GENERATED_FILES))
_FIRMWARE_FILENAMES = $(notdir $(FIRMWARE_COPY_FILES))
_MKIMAGE_DEPS := $(MKIMAGE_FIRMWARE_DEST)/.mkimage-files-copied
.PHONY: mkimage
mkimage: $(_MKIMAGE_DEPS)
	make -C $(MKIMAGE_DIR) $(MKIMAGE_FLAGS) flash_evk

$(MKIMAGE_DIR)/.git:
	git clone "$(MKIMAGE_GIT_URL)" "$(MKIMAGE_DIR)"

# dummy target which copies all required files to imx-mkimage dir
_MKIMAGE_COPY_TMP = $(_FIRMWARE_FILENAMES) $(_UBOOT_FILENAMES) mkimage_uboot
_MKIMAGE_COPY_FILES = $(_MKIMAGE_FILES_TMP:%=$(MKIMAGE_FIRMWARE_DEST)/%)
$(_MKIMAGE_DEPS): $(FIRMWARE_COPY_FILES_FULL) \
		$(UBOOT_GENERATED_FILES_FULL) $(ATF_BIN_FILE_FULL) \
		$(UBOOT_MKIMAGE_BIN) | $(MKIMAGE_DIR)/.git
	# copy files to the imx-mkimage/<SOC> dir
	cp -f $(filter-out $(UBOOT_MKIMAGE_BIN),$^) "$(MKIMAGE_FIRMWARE_DEST)/"
	# mkimage needs to be renamed to mkimage_uboot at the destination
	cp -f "$(UBOOT_MKIMAGE_BIN)" "$(MKIMAGE_FIRMWARE_DEST)/mkimage_uboot"; \
	touch "$@"
	ls -l $^

$(MKIMAGE_OUT_FLASH_BIN): mkimage

mkimage_clean:
	rm -f "$(_MKIMAGE_DEPS)"
	$(MAKE) -C $(MKIMAGE_DIR) clean 

.PHONY: linux_uimage emmc_image
linux_uimage:
	$(MAKE) FORCE=1 $(STAGING_DIR)/$(LINUX_UIMAGE_OUT)
$(STAGING_DIR)/$(LINUX_UIMAGE_OUT): $(LINUX_DIR)/$(LINUX_IMAGE_OUT) \
		$(LINUX_DIR)/$(LINUX_DTB_OUT) $(BUILDROOT_DIR)/$(BUILDROOT_CPIO_OUT) \
		$(LINUX_UIMAGE_ITS) | $(STAGING_DIR)/
	cp -f $^ "$(STAGING_DIR)/"
	cd "$(STAGING_DIR)" && \
		"$(UBOOT_MKIMAGE_BIN)" -f "$(notdir $(LINUX_UIMAGE_ITS))" "$@" && \
		ls -l

$(STAGING_DIR)/:
	mkdir -p "$(STAGING_DIR)"

# Target to generate emmc disk image
_EMMC_DISK_IMG = $(EMMC_IMAGE_OUT)
# Start sector = 10MB / 512b = 10*1024^2/512 = 20480
_EMMC_IMAGE_FDISK_SCRIPT=d$(NL)n$(NL)p$(NL)1$(NL)20480$(NL)$(NL)p$(NL)w$(NL)
export _EMMC_IMAGE_FDISK_SCRIPT
emmc_image:
	$(MAKE) FORCE=1 $(_EMMC_DISK_IMG)
$(_EMMC_DISK_IMG): $(STAGING_DIR)/$(LINUX_UIMAGE_OUT) \
		$(MKIMAGE_OUT_FLASH_BIN) $(_FORCE) | $(STAGING_DIR)/
	truncate --size $(EMMC_IMAGE_SIZE) $(_EMMC_DISK_IMG)
	echo "$$_EMMC_IMAGE_FDISK_SCRIPT"
	echo "$$_EMMC_IMAGE_FDISK_SCRIPT" | fdisk $(_EMMC_DISK_IMG)
	sudo partx -a "$(_EMMC_DISK_IMG)"
	_XPART=$$(ls -1 /dev/loop*p1 | head -1); \
	_LDEV=$${_XPART%p1}; \
	( \
		sudo mkfs.fat -F 32 "$$_XPART"; \
		sudo mount "$$_XPART" /mnt; \
		sudo cp "$(STAGING_DIR)/$(LINUX_UIMAGE_OUT)" /mnt/; \
		echo "$$EMMC_UBOOT_ENV" | sudo tee /mnt/uboot.env; \
		ls -lh /mnt; \
		sudo umount "$$_XPART"; \
		dd if="$(MKIMAGE_OUT_FLASH_BIN)" of="$$_LDEV" bs=1024 seek=33 \
	) || true; \
		sudo umount "$$_XPART"; \
		sudo partx -d "$(_EMMC_DISK_IMG)"; \
		sudo losetup -D $$_LDEV

