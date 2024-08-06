
# i.MX mkimage script configuration
MKIMAGE_DIR = $(BUILD_DEST)/imx-mkimage
MKIMAGE_GIT_URL = https://github.com/nxp-imx/imx-mkimage.git
MKIMAGE_SOC = iMX8M
MKIMAGE_FLAGS = SOC=$(MKIMAGE_SOC) dtbs=$(UBOOT_DTB)
MKIMAGE_FIRMWARE_DEST = $(MKIMAGE_DIR)/$(MKIMAGE_SOC)
MKIMAGE_OUT_FLASH_BIN = $(MKIMAGE_FIRMWARE_DEST)/flash.bin

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

.PHONY: upload_spl
upload_spl:
	uuu -b spl $(MKIMAGE_OUT_FLASH_BIN)
