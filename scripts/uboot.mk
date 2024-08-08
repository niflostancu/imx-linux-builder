## U-Boot (BL21 + BL31) build targets

# U-Boot settings (for both SPL & BL3x builds)
UBOOT_DIR = $(BUILD_DEST)/u-boot-tn-imx
UBOOT_GIT_URL = https://github.com/TechNexion/u-boot-tn-imx.git
UBOOT_GIT_BRANCH = tn-imx_v2023.04_6.1.55_2.2.0-stable
#UBOOT_GIT_BRANCH = tn-imx_v2022.04_5.15.71_2.2.0-stable
#UBOOT_GIT_URL = https://github.com/nxp-imx/uboot-imx.git
#UBOOT_GIT_BRANCH = lf_v2024.04
UBOOT_DTB = imx8mq-pico-pi.dtb
UBOOT_GENERATED_FILES = spl/u-boot-spl.bin u-boot-nodtb.bin  \
		  arch/arm/dts/$(UBOOT_DTB)
UBOOT_GENERATED_FILES_FULL = $(UBOOT_GENERATED_FILES:%=$(UBOOT_DIR)/%)
UBOOT_MKIMAGE_BIN = $(UBOOT_DIR)/tools/mkimage
UBOOT_MAKE_FLAGS = $(_XC_ARG) -j "$(NPROC)"
# uncomment for make script debugging
#UBOOT_MAKE_FLAGS += V=1
UBOOT_EXTRA_CONFIGS ?= $(SRC)/configs/uboot-imx8mq.config

UBOOT_DEFAULT_ENV_FILE ?= $(SRC)/configs/uboot-default.env
UBOOT_ENV_OVERLAY_CONFIG = $(UBOOT_DIR)/env-overlay.config
UBOOT_EXTRA_CONFIGS += $(UBOOT_ENV_OVERLAY_CONFIG)

.PHONY: uboot uboot_clean
_UBOOT_COMPILED_TARGET = $(UBOOT_DIR)/.uboot-compiled
uboot: $(UBOOT_DIR)/.git
	$(MAKE) FORCE=1 $(_UBOOT_COMPILED_TARGET)

$(UBOOT_DIR)/.git:
	git clone "$(UBOOT_GIT_URL)" --branch="$(UBOOT_GIT_BRANCH)" "$(UBOOT_DIR)"

$(UBOOT_GENERATED_FILES_FULL): $(_UBOOT_COMPILED_TARGET)
$(_UBOOT_COMPILED_TARGET): $(UBOOT_DIR)/.config $(UBOOT_EXTRA_PATCH) $(_FORCE)
	if [[ -n "$(UBOOT_EXTRA_PATCH)" ]]; then \
		cd "$(UBOOT_DIR)/" && \
		if ! patch -R -p1 -s -f --dry-run < "$(UBOOT_EXTRA_PATCH)"; then \
			patch -p1 < "$(UBOOT_EXTRA_PATCH)" ; \
		fi \
	fi
	$(MAKE) -C $(UBOOT_DIR) $(UBOOT_MAKE_FLAGS)
	touch "$@"

# merge with the makefile-supplied .extraconfig
$(UBOOT_DIR)/.config: $(UBOOT_DIR)/.extraconfig
	$(MAKE) -C $(UBOOT_DIR) $(UBOOT_MAKE_FLAGS) pico-imx8mq_defconfig
	cd "$(UBOOT_DIR)" && \
		scripts/kconfig/merge_config.sh ".config" ".extraconfig"

# Create extra config / patches
$(UBOOT_DIR)/.extraconfig: $(UBOOT_EXTRA_CONFIGS) | $(UBOOT_DIR)/.git
	echo | cat $(UBOOT_EXTRA_CONFIGS) > "$@"

$(UBOOT_ENV_OVERLAY_CONFIG): $(UBOOT_DEFAULT_ENV_FILE) | $(UBOOT_DIR)/.git
	echo "$$_UBOOT_ENV_OVERLAY_" > $@
define _UBOOT_ENV_OVERLAY_=
CONFIG_USE_DEFAULT_ENV_FILE=y
CONFIG_DEFAULT_ENV_FILE="$(UBOOT_DEFAULT_ENV_FILE)"

endef
export _UBOOT_ENV_OVERLAY_

uboot_menuconfig:
	$(MAKE) -C $(UBOOT_DIR) $(UBOOT_MAKE_FLAGS) menuconfig

uboot_clean:
	rm -f "$(_UBOOT_COMPILED_TARGET)"
	rm -f "$(UBOOT_DIR)/.extraconfig"
	$(MAKE) -C $(UBOOT_DIR) clean 

