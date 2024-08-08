# NXP i.MX board upload/flashing utility targets

MFGTOOLS_DIR = $(BUILD_DEST)/mfgtools
MFGTOOLS_GIT_URL = https://github.com/nxp-imx/mfgtools
UUU = $(MFGTOOLS_DIR)/build/uuu/uuu

# uuu (mfgtools) build target
.PHONY: uuu_build uuu_clean
uuu_build: $(UUU)
$(UUU): $(MFGTOOLS_DIR)/.git
	export CROSS_COMPILER= && \
		mkdir -p "$(MFGTOOLS_DIR)/build" && \
		cd "$(MFGTOOLS_DIR)/build" && \
		cmake .. && cmake --build .
uuu_clean:
	rm -rf "$(MFGTOOLS_DIR)/build"
$(MFGTOOLS_DIR)/.git:
	git clone "$(MFGTOOLS_GIT_URL)" "$(MFGTOOLS_DIR)"

.PHONY: uuu_spl upload_spl
uuu_spl: upload_spl
upload_spl: $(UUU)
	$(UUU) -b spl $(MKIMAGE_OUT_FLASH_BIN)

