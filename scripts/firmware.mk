## i.MX8 firmware build script 
# (will be automatically downloaded)

FIRMWARE_DIR = $(BUILD_DEST)/firmware
FIRMWARE_VER = 8.22
FIRMWARE_URL = http://sources.buildroot.net/firmware-imx/firmware-imx-$(FIRMWARE_VER).bin
FIRMWARE_BIN = firmware-imx-$(FIRMWARE_VER).bin
FIRMWARE_EXTRACT_DIR = $(FIRMWARE_DIR)/firmware-imx-$(FIRMWARE_VER)
FIRMWARE_COPY_FILES := firmware/ddr/synopsys/lpddr4_pmu_train_1d_dmem.bin \
		  firmware/ddr/synopsys/lpddr4_pmu_train_1d_imem.bin \
		  firmware/ddr/synopsys/lpddr4_pmu_train_2d_dmem.bin \
		  firmware/ddr/synopsys/lpddr4_pmu_train_2d_imem.bin \
		  firmware/hdmi/cadence/signed_hdmi_imx8m.bin
# full path to the [extracted] source firmware files
FIRMWARE_COPY_FILES_FULL = $(FIRMWARE_COPY_FILES:%=$(FIRMWARE_EXTRACT_DIR)/%)

# ARM TrustedFirmware-A build settings
ATF_DIR = $(BUILD_DEST)/imx-atf
ATF_GIT_URL = https://github.com/nxp-imx/imx-atf.git
ATF_MAKE_FLAGS = $(_XC_ARG) PLAT=imx8mq SPD=none LOG_LEVEL=40
ATF_BIN_FILENAME = bl31.bin
ATF_BIN_FILE_FULL = $(ATF_DIR)/build/imx8mq/release/$(ATF_BIN_FILENAME)

_FIRMWARE_EXTRACTED_TARGET = $(FIRMWARE_EXTRACT_DIR)/.extracted
$(FIRMWARE_COPY_FILES_FULL): $(_FIRMWARE_EXTRACTED_TARGET)

.PHONY: firmware firmware_clean
# i.MX8 firmware download -> extract -> copy rule
firmware:
	$(MAKE) FORCE=1 $(_FIRMWARE_EXTRACTED_TARGET)
$(_FIRMWARE_EXTRACTED_TARGET):
	mkdir -p "$(FIRMWARE_DIR)"
	[[ -f "$(FIRMWARE_DIR)/$(FIRMWARE_BIN)" ]] || \
		wget $(FIRMWARE_URL) -O "$(FIRMWARE_DIR)/$(FIRMWARE_BIN)"
	chmod +x "$(FIRMWARE_DIR)/$(FIRMWARE_BIN)"
	[[ -f "$(firstword $(FIRMWARE_COPY_FILES_FULL))" ]] || \
		( cd "$(FIRMWARE_DIR)" && ./$(FIRMWARE_BIN) --auto-accept; )
	# finally, create a dummy file to mark target as done
	touch "$@"

firmware_clean:
	rm -rf "$(FIRMWARE_DIR)"

# ARM Trusted Firmware Rules
.PHONY: atf clean_atf
atf: $(ATF_DIR)/.git
	$(MAKE) FORCE=1 $(ATF_BIN_FILE_FULL)
$(ATF_DIR)/.git:
	git clone "$(ATF_GIT_URL)" "$(ATF_DIR)"
$(ATF_BIN_FILE_FULL): $(_FORCE)
	make -C "$(ATF_DIR)" $(ATF_MAKE_FLAGS) bl31
atf_clean:
	$(MAKE) -C "$(ATF_DIR)" clean
	rm -rf "$(ATF_DIR)/build/imx8mq/"

