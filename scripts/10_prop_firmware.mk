## NXP proprietary firmware targets 
# (will be automatically downloaded)

# i.MX firmware blobs (downloaded)
IMX_FW_DEST ?= $(BUILD_DEST)/firmware
IMX_FW_VER ?= 8.22
IMX_FW_URL ?= http://sources.buildroot.net/firmware-imx/firmware-imx-$(IMX_FW_VER).bin
IMX_FW_BIN ?= firmware-imx-$(IMX_FW_VER).bin
IMX_FW_EXTRACT_DIR ?= $(IMX_FW_DEST)/firmware-imx-$(IMX_FW_VER)
# full path to the extracted firmware files to be included
IMX_FW_BIN_FILES_FULL ?=
# ... and their relative paths:
IMX_FW_BIN_FILES = $(IMX_FW_BIN_FILES_FULL:$(IMX_FW_EXTRACT_DIR)/%=%)

# use a dummy extraction target due to multiple artifacts being produced
_IMX_FW_EXTRACTED_TARGET = $(IMX_FW_EXTRACT_DIR)/.extracted
$(IMX_FW_BIN_FILES_FULL): $(_IMX_FW_EXTRACTED_TARGET)

.PHONY: imx_fw imx_fw_clean
# i.MX firmware download -> extract AIO rule
imx_fw:
	$(MAKE_FORCED) $(_IMX_FW_EXTRACTED_TARGET)
$(_IMX_FW_EXTRACTED_TARGET):
	mkdir -p "$(IMX_FW_DEST)"
	[[ -f "$(IMX_FW_DEST)/$(IMX_FW_BIN)" ]] || \
		wget $(IMX_FW_URL) -O "$(IMX_FW_DEST)/$(IMX_FW_BIN)"
	chmod +x "$(IMX_FW_DEST)/$(IMX_FW_BIN)"
	[[ -f "$(firstword $(IMX_FW_BIN_FILES_FULL))" ]] || \
		( cd "$(IMX_FW_DEST)" && ./$(IMX_FW_BIN) --auto-accept; )
	# finally, create a dummy file to mark target as done
	touch "$@"

imx_fw_clean:
	rm -rf "$(IMX_FW_DEST)"

all: imx_fw
clean_all: imx_fw_clean
