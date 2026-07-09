## U-Boot (SPL/BL21 + BL31) build targets

# U-Boot settings (for both SPL & BL3x builds)
UBOOT_DEST ?= $(BUILD_DEST)/u-boot
UBOOT_GIT_URL ?= https://github.com/u-boot/u-boot.git
UBOOT_GIT_BRANCH ?= master

UBOOT_DEFCONFIG ?= defconfig
UBOOT_DEVICE_TREE ?= UNKNOWN_BOARD
UBOOT_ARCH ?= arm
# one may also specify an out-of-tree device tree (defaults in-tree ovbiously):
UBOOT_DTB_FULL ?= $(UBOOT_DEST)/arch/$(UBOOT_ARCH)/dts/$(UBOOT_DEVICE_TREE).dtb
# copy external (board-specific) device tree to in-tree source?
UBOOT_COPY_DTS ?=
UBOOT_COPY_FILES ?=

UBOOT_CFLAGS ?=
UBOOT_MAKE_FLAGS ?= $(_XC_ARG) -j$(NPROC) KCFLAGS="$(UBOOT_CFLAGS)"
UBOOT_MAKE_FLAGS += V=1
# https://docs.u-boot.org/en/latest/develop/devicetree/control.html
UBOOT_MAKE_FLAGS += $(if $(UBOOT_DEVICE_TREE),DEVICE_TREE="$(UBOOT_DEVICE_TREE)")
# custom patch files to apply to u-boot
UBOOT_APPLY_PATCHES ?=

# u-boot config + environment overlays
UBOOT_EXTRA_CONFIG_FILES ?=
UBOOT_EXTRA_CONFIG_TEXT ?= $(if $(UBOOT_DEFAULT_ENV_FILE),$(UBOOT_DEF_CONFIG_ENVFILE))
UBOOT_DEFAULT_ENV_FILE ?=
define UBOOT_DEF_CONFIG_ENVFILE=
CONFIG_ENV_USE_DEFAULT_ENV_TEXT_FILE=y
CONFIG_ENV_DEFAULT_ENV_TEXT_FILE="$(UBOOT_DEFAULT_ENV_FILE)"
$(blank)
endef

# generated targets (files) usable through the stages:
UBOOT_OUT_SPL_BIN = $(UBOOT_DEST)/spl/u-boot-spl.bin
UBOOT_OUT_BIN = $(UBOOT_DEST)/u-boot.bin
UBOOT_OUT_NODTB_BIN = $(UBOOT_DEST)/u-boot-nodtb.bin
UBOOT_OUT_BIN_IMG = $(UBOOT_DEST)/u-boot.img
UBOOT_MKIMAGE_BIN = $(UBOOT_DEST)/tools/mkimage
UBOOT_MKENVIMAGE_BIN = $(UBOOT_DEST)/tools/mkenvimage

# macro-command to compile a u-boot env as binary
uboot_mk_env_stdin = $(UBOOT_MKENVIMAGE_BIN) -s 0x4000 -o $(1) -
uboot_mk_env_txt = $(UBOOT_MKENVIMAGE_BIN) -s 0x4000 -o $(2) $(1)

_UBOOT_GEN_DEPS = $(UBOOT_OUT_SPL_BIN) $(UBOOT_OUT_BIN_IMG) \
				   $(UBOOT_OUT_NODTB_BIN) $(UBOOT_OUT_BIN) $(UBOOT_DTB_FULL) \
				   $(UBOOT_MKIMAGE_BIN)

_UBOOT_PATCH_TARGET ?= $(UBOOT_DEST)/.patches-applied
_UBOOT_BUILD_DEPS ?=
_UBOOT_BUILD_DEPS += $(UBOOT_DEST)/.config $(_UBOOT_PATCH_TARGET)
_UBOOT_COMPILED_GUARD = $(UBOOT_DEST)/.uboot-compiled

.PHONY: uboot
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

_UBOOT_COPY_FILENAMES := $(notdir $(UBOOT_COPY_FILES))
_UBOOT_COPY_FILES_DEST := $(_UBOOT_COPY_FILENAMES:%=$(UBOOT_DEST)/%)
_UBOOT_BUILD_DEPS += $(_UBOOT_COPY_FILES_DEST)
_UBOOT_COPY_TARGET := $(UBOOT_DEST)/.uboot-files-copied
$(_UBOOT_COPY_TARGET): $(UBOOT_COPY_FILES)
	cp -f $^ "$(UBOOT_DEST)/"
	touch "$@"
$(_UBOOT_COPY_FILES_DEST): $(_UBOOT_COPY_TARGET)

$(_UBOOT_PATCH_TARGET): $(UBOOT_APPLY_PATCHES) | $(UBOOT_DEST)/.git
	$(foreach patchfile,$(UBOOT_APPLY_PATCHES),\
		$(call mk_apply_patch,$(patchfile),$(UBOOT_DEST)))
	touch "$@"

$(_UBOOT_COMPILED_GUARD): $(_UBOOT_BUILD_DEPS) $(_FORCE)
	$(MAKE) -C $(UBOOT_DEST) $(UBOOT_MAKE_FLAGS)
	touch "$@"
# generated files:
$(_UBOOT_GEN_DEPS): $(_UBOOT_COMPILED_GUARD)

# merge with the makefile-supplied .extraconfig
$(UBOOT_DEST)/.config: $(_UBOOT_BUILD_DEPS) | $(UBOOT_DEST)/.extraconfig
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

.PHONY: uboot_clean uboot_cleanconfig
uboot_clean:
	rm -f "$(_UBOOT_COMPILED_GUARD)"
	rm -f "$(UBOOT_DEST)/.extraconfig"
	$(MAKE) -C $(UBOOT_DEST) clean 
uboot_cleanconfig:
	rm -f $(UBOOT_DEST)/.config $(UBOOT_DEST)/.extraconfig

all: uboot
clean_all: uboot_clean
