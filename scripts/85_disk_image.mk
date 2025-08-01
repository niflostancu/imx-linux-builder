# i.MX mkimage script configuration

# uImage creation config
STAGING_DEST ?= $(BUILD_DEST)/staging
LINUX_UIMAGE_ITS ?= linux-uimage.its
LINUX_UIMAGE_OUT ?= $(STAGING_DEST)/linux.itb

# EMMC image config
EMMC_IMAGE_OUT = $(BUILD_DEST)/disk.img
EMMC_IMAGE_SIZE ?= 128M
# Default partitioning script (fdisk syntax)
# Start sector = 10MB / 512b = 10*1024^2/512 = 20480
EMMC_FDISK_SCRIPT ?= d$(nl)n$(nl)p$(nl)1$(nl)20480$(nl)$(nl)a$(nl)p$(nl)w$(nl)
# optional contents for the uboot.env file (will be created on mmc boot part)
EMMC_UBOOT_ENV?=


.PHONY: linux_uimage emmc_image
linux_uimage:
	$(MAKE_FORCED) $(LINUX_UIMAGE_OUT)
$(LINUX_UIMAGE_OUT): $(KERNEL_OUT_IMAGE) $(KERNEL_OUT_DTB) \
		$(BUILDROOT_OUT_CPIO) $(LINUX_UIMAGE_ITS) | $(STAGING_DEST)/
	cp -f $^ "$(STAGING_DEST)/"
	cd "$(STAGING_DEST)" && \
		"$(UBOOT_MKIMAGE_BIN)" -f "$(notdir $(LINUX_UIMAGE_ITS))" "$@" && \
		ls -l

$(STAGING_DEST)/:
	mkdir -p "$(STAGING_DEST)"

# target to generate emmc disk image
emmc_image:
	$(MAKE_FORCED) $(EMMC_IMAGE_OUT)
$(EMMC_IMAGE_OUT): $(LINUX_UIMAGE_OUT) $(IMX_MKIMAGE_OUT_FLASH_BIN) \
		$(_FORCE) | $(STAGING_DEST)/
	truncate --size $(EMMC_IMAGE_SIZE) $(EMMC_IMAGE_OUT)
	echo "$$_EMMC_IMAGE_FDISK_SCRIPT_"
	echo "$$_EMMC_IMAGE_FDISK_SCRIPT_" | fdisk $(EMMC_IMAGE_OUT)
	sudo partx -a "$(EMMC_IMAGE_OUT)"
	_XPART=$$(ls -1 /dev/loop*p1 | head -1); \
	_LDEV=$${_XPART%p1}; \
	( \
		sudo mkfs.fat -F 32 "$$_XPART"; \
		sudo mount "$$_XPART" /mnt; \
		sudo cp "$(LINUX_UIMAGE_OUT)" /mnt/; \
		echo "$$_EMMC_UBOOT_ENV_CONTENTS_" | sudo tee /mnt/uboot.env; \
		ls -lh /mnt; \
		sudo umount "$$_XPART"; \
		dd if="$(IMX_MKIMAGE_OUT_FLASH_BIN)" of="$$_LDEV" bs=1024 seek=33 \
	) || true; \
		sudo umount "$$_XPART"; \
		sudo partx -d "$(EMMC_IMAGE_OUT)"; \
		sudo losetup -D $$_LDEV

export _EMMC_IMAGE_FDISK_SCRIPT_=$(EMMC_FDISK_SCRIPT)
export _EMMC_UBOOT_ENV_CONTENTS_=$(EMMC_UBOOT_ENV)

all: emmc_image

.PHONY: imx_upload_emmc
imx_upload_emmc: $(UUU)
	$(UUU) -b emmc_all $(IMX_OUT_FLASH_BIN) $(EMMC_IMAGE_OUT)

