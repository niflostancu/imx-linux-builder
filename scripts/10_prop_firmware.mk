## NXP proprietary firmware targets 
# (will be automatically downloaded)

# i.MX firmware blobs (downloaded)
IMX_FW_DEST ?= $(BUILD_DEST)/firmware
IMX_FW_URL ?= http://sources.buildroot.net/firmware-imx/firmware-imx-$(IMX_FW_VER).bin
IMX_FW_VER ?= 8.22
IMX_FW_BIN ?= firmware-imx-$(IMX_FW_VER).bin
IMX_FW_EXTRACT_DIR ?= $(IMX_FW_DEST)/firmware-imx-$(IMX_FW_VER)

# IMX Sentinel Firmware for iMX >= 9
# From: https://docs.u-boot.org/en/latest/board/nxp/imx93_frdm.html
IMX_SENTINEL_URL ?= https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-sentinel-$(IMX_SENTINEL_VER).bin
IMX_SENTINEL_VER ?= 0.11
IMX_SENTINEL_BIN ?= firmware-sentinel-$(IMX_SENTINEL_VER).bin
IMX_SENTINEL_EXTRACT_DIR ?= $(IMX_FW_DEST)/firmware-sentinel-$(IMX_SENTINEL_VER)

# full path to the extracted firmware files to be included by imx-mkimage
IMX_FIRMWARE_FILES_FULL ?=
IMX_SENTINEL_FILES_FULL ?=

# use a dummy extraction target due to multiple artifacts being produced
_IMX_FW_EXTRACTED_TARGET = $(IMX_FW_EXTRACT_DIR)/.extracted
$(IMX_FIRMWARE_FILES_FULL): $(_IMX_FW_EXTRACTED_TARGET)
.PHONY: imx_fw imx_fw_clean
# i.MX firmware download -> extract AIO rule
imx_fw:
	$(MAKE_FORCED) $(_IMX_FW_EXTRACTED_TARGET)
$(_IMX_FW_EXTRACTED_TARGET):
	mkdir -p "$(IMX_FW_DEST)"
	[[ -f "$(IMX_FW_DEST)/$(IMX_FW_BIN)" ]] || \
		wget $(IMX_FW_URL) -O "$(IMX_FW_DEST)/$(IMX_FW_BIN)"
	chmod +x "$(IMX_FW_DEST)/$(IMX_FW_BIN)"
	[[ -f "$(firstword $(IMX_FIRMWARE_FILES_FULL))" ]] || \
		( cd "$(IMX_FW_DEST)" && ./$(IMX_FW_BIN) --auto-accept; )
	# finally, create a dummy file to mark target as done
	touch "$@"

imx_fw_clean:
	rm -rf "$(IMX_FW_DEST)"

all: imx_fw
clean_all: imx_fw_clean

# i.MX Sentinel Firmware download target
_IMX_SENTINEL_EXTRACTED_TARGET = $(IMX_SENTINEL_EXTRACT_DIR)/.extracted
$(IMX_SENTINEL_FILES_FULL): $(_IMX_SENTINEL_EXTRACTED_TARGET)
.PHONY: imx_sentinel imx_sentinel_clean
imx_sentinel:
	$(MAKE_FORCED) $(_IMX_SENTINEL_EXTRACTED_TARGET)
$(_IMX_SENTINEL_EXTRACTED_TARGET):
	mkdir -p "$(IMX_FW_DEST)"
	# download sentinel bin file from HTTP (using CLI tool wget)
	[[ -f "$(IMX_FW_DEST)/$(IMX_SENTINEL_BIN)" ]] || \
		wget $(IMX_SENTINEL_URL) -O "$(IMX_FW_DEST)/$(IMX_SENTINEL_BIN)"
	chmod +x "$(IMX_FW_DEST)/$(IMX_SENTINEL_BIN)"
	# extract sentinel if not already (auto-accept license)
	[[ -f "$(firstword $(IMX_SENTINEL_FILES_FULL))" ]] || \
		( cd "$(IMX_FW_DEST)" && ./$(IMX_SENTINEL_BIN) --auto-accept; )
	# finally, create a dummy file to mark target as done
	touch "$@"

