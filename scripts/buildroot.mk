## Buildroot rootfs targets

# Buildroot config.
BUILDROOT_DIR = $(BUILD_DEST)/buildroot
BUILDROOT_GIT_URL ?= https://github.com/buildroot/buildroot.git
BUILDROOT_DEFCONFIG ?= defconfig
# override this to add extra configurations
BUILDROOT_EXTRA_CONFIGS ?= $(SRC)/configs/buildroot-default.config

BUILDROOT_FLAGS = -j "$(NPROC)"
BUILDROOT_CPIO_OUT = output/images/rootfs.cpio

.PHONY: rootfs buildroot buildroot_clean
rootfs: buildroot
buildroot: $(BUILDROOT_DIR)/.git
	$(MAKE) FORCE=1 $(BUILDROOT_DIR)/$(BUILDROOT_CPIO_OUT)

$(BUILDROOT_DIR)/.git:
	git clone "$(BUILDROOT_GIT_URL)" "$(BUILDROOT_DIR)"

buildroot_menuconfig: $(BUILDROOT_DIR)/.config
	$(MAKE) $(BUILDROOT_FLAGS) -C "$(BUILDROOT_DIR)" menuconfig

$(BUILDROOT_DIR)/$(BUILDROOT_CPIO_OUT): $(BUILDROOT_DIR)/.config
	$(MAKE) $(BUILDROOT_FLAGS) -C "$(BUILDROOT_DIR)"

# merge with the makefile-supplied .extraconfig
$(BUILDROOT_DIR)/.config: $(BUILDROOT_DIR)/.extraconfig
	$(MAKE) $(BUILDROOT_FLAGS) -C $(BUILDROOT_DIR) $(BUILDROOT_DEFCONFIG)
	cd "$(BUILDROOT_DIR)" && \
		support/kconfig/merge_config.sh ".config" ".extraconfig"

$(BUILDROOT_DIR)/.extraconfig: $(BUILDROOT_EXTRA_CONFIGS)
	echo | cat $(BUILDROOT_EXTRA_CONFIGS) > "$@"

buildroot_clean:
	$(MAKE) $(BUILDROOT_FLAGS) -C "$(BUILDROOT_DIR)" clean
	rm -f "$(BUILDROOT_DIR)/.extraconfig"

