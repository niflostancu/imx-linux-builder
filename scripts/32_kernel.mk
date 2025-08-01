## Linux kernel build targets

# Linux Kernel
KERNEL_DEST ?= $(BUILD_DEST)/linux
KERNEL_GIT_URL ?= https://github.com/torvalds/linux.git
KERNEL_GIT_BRANCH ?= v6.12
KERNEL_GIT_SHALLOW ?= 1

# kernel configuration & device tree options
KERNEL_ARCH ?= $(SOC_ARCH)
KERNEL_DEFCONFIG ?= defconfig
KERNEL_CONFIG_FRAGMENTS ?=
KERNEL_DTS ?= arch/$(KERNEL_ARCH)/boot/dts/UNKNOWN.dts
# copy external (board-specific) kernel device trees to source
KERNEL_COPY_DTS ?=

# Linux kernel make
KERNEL_MAKE_ARGS ?= ARCH=$(KERNEL_ARCH) $(_XC_ARG) -j$(NPROC)
KERNEL_APPLY_PATCHES ?=

KERNEL_OUT_IMAGE ?= $(KERNEL_DEST)/arch/$(KERNEL_ARCH)/boot/Image
KERNEL_OUT_DTB ?= $(KERNEL_DEST)/$(KERNEL_DTS:%.dts=%.dtb)
KERNEL_DTC_BIN ?= scripts/dtc/dtc
KERNEL_MODULES_INSTALL=$(BUILD_DEST)/linux-modules-overlay

# Internal variables
_KERNEL_CONFIG = $(KERNEL_DEST)/.config
_KERNEL_BUILD_DEPS ?=
_KERNEL_BUILD_DEPS += $(_KERNEL_CONFIG) $(KERNEL_APPLY_PATCHES)


.PHONY: linux linux_clean linux_config linux_dtb
linux: $(KERNEL_DEST)/.git
	$(MAKE_FORCED) $(KERNEL_OUT_IMAGE)

_KERNEL_CLONE_ARGS ?= $(if $(KERNEL_GIT_SHALLOW),--depth=1)
$(KERNEL_DEST)/.git:
	$(call mk_git_clone,$(KERNEL_GIT_URL),$(KERNEL_DEST),$(KERNEL_GIT_BRANCH),$(_KERNEL_CLONE_ARGS))

# Kernel configuration / menuconfig rules
$(_KERNEL_CONFIG):
	$(MAKE) $(KERNEL_MAKE_ARGS) -C "$(KERNEL_DEST)" $(KERNEL_DEFCONFIG)
	$(if $(KERNEL_CONFIG_FRAGMENTS), \
		$(MAKE) $(KERNEL_MAKE_ARGS) -C "$(KERNEL_DEST)" \
			olddefconfig $(KERNEL_CONFIG_FRAGMENTS) )

linux_menuconfig: $(_KERNEL_CONFIG)
	$(MAKE) $(KERNEL_MAKE_ARGS) -C "$(KERNEL_DEST)" menuconfig

$(KERNEL_OUT_IMAGE): $(_KERNEL_BUILD_DEPS) $(_FORCE)
	# patch linux kernel (optional)
	$(foreach patchfile,$(KERNEL_APPLY_PATCHES),\
		$(call mk_apply_patch,$(patchfile),$(KERNEL_DEST)))
	$(MAKE) $(KERNEL_MAKE_ARGS) -C "$(KERNEL_DEST)"

# installs modules to the given path (usually, a buildroot overlay)
linux_modules:
	mkdir -p "$(KERNEL_MODULES_INSTALL)"
	$(MAKE) $(KERNEL_MAKE_ARGS) INSTALL_MOD_PATH="$(KERNEL_MODULES_INSTALL)" \
		-C "$(KERNEL_DEST)" modules modules_install

# rule to copy external device tree to arch..dts dir:
ifneq ("$(KERNEL_COPY_DTS)","")
_KERNEL_DTS_FILES := $(foreach copy_file,$(KERNEL_COPY_DTS),\
					 $(KERNEL_DEST)/$(dir $(KERNEL_DTS))/$(notdir $(copy_file)))
$(_KERNEL_DTS_FILES): $(KERNEL_COPY_DTS)
	cp -f "$^" "$@"
$(info KERNEL DTS $(_KERNEL_DTS_FILES))
_KERNEL_DTB_DEPS += $(_KERNEL_DTS_FILES)
endif

# Rule to [re]build DTB
linux_dtb: $(KERNEL_OUT_DTB)
$(KERNEL_OUT_DTB): $(KERNEL_DEST)/$(KERNEL_DTS) $(_KERNEL_DTB_DEPS)
	$(MAKE) $(KERNEL_MAKE_ARGS) -C "$(KERNEL_DEST)" $(notdir $(KERNEL_OUT_DTB))

linux_clean:
	$(MAKE) $(KERNEL_MAKE_ARGS) -C "$(KERNEL_DEST)" mrproper

# aliases
kernel: linux
kernel_clean: linux_clean

all: linux
clean_all: linux_clean
