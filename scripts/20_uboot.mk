## U-Boot (SPL/BL21 + BL31) build targets

# U-Boot settings (for both SPL & BL3x builds)
UBOOT_DEST ?= $(BUILD_DEST)/u-boot
UBOOT_GIT_URL ?= https://github.com/TechNexion/u-boot-tn-imx.git
UBOOT_GIT_BRANCH = tn-imx_v2023.04_6.1.55_2.2.0-stable
#UBOOT_GIT_BRANCH = tn-imx_v2022.04_5.15.71_2.2.0-stable
#UBOOT_GIT_URL = https://github.com/nxp-imx/uboot-imx.git
#UBOOT_GIT_BRANCH = lf_v2024.04

UBOOT_DEFCONFIG ?= pico-imx8mq_defconfig
UBOOT_DEVICE_TREE ?= imx8mq-pico-pi
UBOOT_ARCH ?= arm
# one may also specify an out-of-tree device tree (defaults in-tree ovbiously):
UBOOT_DTB_FULL ?= $(UBOOT_DEST)/arch/$(UBOOT_ARCH)/dts/$(UBOOT_DEVICE_TREE).dtb
# copy external (board-specific) device tree to in-tree source?
UBOOT_COPY_DTS ?=

UBOOT_CFLAGS ?=
UBOOT_MAKE_FLAGS ?= $(_XC_ARG) -j$(NPROC) KCFLAGS="$(UBOOT_CFLAGS)"
UBOOT_MAKE_FLAGS += V=1
# https://docs.u-boot.org/en/latest/develop/devicetree/control.html
UBOOT_MAKE_FLAGS += $(if $(UBOOT_DEVICE_TREE),DEVICE_TREE="$(UBOOT_DEVICE_TREE)")
# custom patch files to apply to u-boot
UBOOT_APPLY_PATCHES ?=

# u-boot config + environment overlays
UBOOT_DEFAULT_ENV_FILE ?= $(SRC)/configs/uboot-default.env
UBOOT_EXTRA_CONFIG_FILES ?= $(SRC)/configs/uboot-imx8mq.config
UBOOT_EXTRA_CONFIG_TEXT ?= $(UBOOT_DEF_CONFIG_ENVFILE)
define UBOOT_DEF_CONFIG_ENVFILE=
CONFIG_USE_DEFAULT_ENV_FILE=y
CONFIG_DEFAULT_ENV_FILE="$(UBOOT_DEFAULT_ENV_FILE)"
$(blank)
endef

# generated targets (files) usable through the stages:
UBOOT_OUT_SPL_BIN = $(UBOOT_DEST)/spl/u-boot-spl.bin
UBOOT_OUT_NODTB_IMG = $(UBOOT_DEST)/u-boot-nodtb.bin
UBOOT_OUT_BIN_IMG = $(UBOOT_DEST)/u-boot.img
UBOOT_MKIMAGE_BIN = $(UBOOT_DEST)/tools/mkimage

_UBOOT_GEN_DEPS = $(UBOOT_OUT_SPL_BIN) $(UBOOT_OUT_BIN_IMG) \
				   $(UBOOT_OUT_BIN_FIT) $(UBOOT_DTB_FULL) \
				   $(UBOOT_MKIMAGE_BIN)

_UBOOT_BUILD_DEPS ?=
_UBOOT_BUILD_DEPS += $(UBOOT_DEST)/.config $(UBOOT_APPLY_PATCHES)
_UBOOT_COMPILED_GUARD = $(UBOOT_DEST)/.uboot-compiled

.PHONY: uboot uboot_clean
uboot: $(UBOOT_DEST)/.git
	$(MAKE_FORCED) $(_UBOOT_COMPILED_GUARD)

$(UBOOT_DEST)/.git:
	$(call mk_git_clone,$(UBOOT_GIT_URL),$(UBOOT_DEST),$(UBOOT_GIT_BRANCH))

# rule to copy external device tree to arch..dts dir:
ifneq ("$(UBOOT_COPY_DTS)","")
_UBOOT_DTS_DEST := $(UBOOT_DTB_FULL:%.dtb=%.dts)
$(_UBOOT_DTS_DEST): $(UBOOT_COPY_DTS)
	cp -f "$<" "$@"
_UBOOT_BUILD_DEPS += $(_UBOOT_DTS_DEST)
endif

$(_UBOOT_COMPILED_GUARD): $(_UBOOT_BUILD_DEPS) $(_FORCE)
	$(foreach patchfile,$(UBOOT_APPLY_PATCHES),\
		$(call mk_apply_patch,$(patchfile),$(UBOOT_DEST)))
	$(MAKE) -C $(UBOOT_DEST) $(UBOOT_MAKE_FLAGS)
	touch "$@"
# generated files:
$(_UBOOT_GEN_DEPS): $(_UBOOT_COMPILED_GUARD)

# merge with the makefile-supplied .extraconfig
$(UBOOT_DEST)/.config: | $(UBOOT_DEST)/.extraconfig
	$(MAKE) -C $(UBOOT_DEST) $(UBOOT_MAKE_FLAGS) $(UBOOT_DEFCONFIG)
	cd "$(UBOOT_DEST)" && \
		scripts/kconfig/merge_config.sh ".config" ".extraconfig"

# Create extra config / patches (if any)
$(UBOOT_DEST)/.extraconfig: $(UBOOT_EXTRA_CONFIG_FILES) | $(UBOOT_DEST)/.git
	# when cat has no arguments (no extra configs), echo will provide empty stdin
	echo "$$_UBOOT_CONFIG_OVERLAY_" | cat $(UBOOT_EXTRA_CONFIG_FILES) - > "$@"
export _UBOOT_CONFIG_OVERLAY_=$(UBOOT_EXTRA_CONFIG_TEXT)

uboot_menuconfig:
	$(MAKE) -C $(UBOOT_DEST) $(UBOOT_MAKE_FLAGS) menuconfig

uboot_clean:
	rm -f "$(_UBOOT_COMPILED_GUARD)"
	rm -f "$(UBOOT_DEST)/.extraconfig"
	$(MAKE) -C $(UBOOT_DEST) clean 

all: uboot
clean_all: uboot_clean
