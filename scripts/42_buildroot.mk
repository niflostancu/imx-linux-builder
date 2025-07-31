## Buildroot rootfs targets

# Buildroot config.
BUILDROOT_DEST ?= $(BUILD_DEST)/buildroot
BUILDROOT_GIT_URL ?= https://github.com/buildroot/buildroot.git
BUILDROOT_GIT_BRANCH ?=

BUILDROOT_DEFCONFIG ?= defconfig
# override this to add extra configurations
BUILDROOT_EXTRA_CONFIG_FILES ?=
BUILDROOT_EXTRA_CONFIG_TEXT ?=

BUILDROOT_MAKE_ARGS ?= -j$(NPROC)
BUILDROOT_OUT_CPIO ?= $(BUILDROOT_DEST)/output/images/rootfs.cpio

.PHONY: buildroot buildroot_clean
buildroot: $(BUILDROOT_DEST)/.git
	$(MAKE_FORCED) $(BUILDROOT_OUT_CPIO)

$(BUILDROOT_DEST)/.git:
	$(call mk_git_clone,$(BUILDROOT_GIT_URL),$(BUILDROOT_DEST),$(BUILDROOT_GIT_BRANCH))

$(BUILDROOT_OUT_CPIO): $(BUILDROOT_DEST)/.config
	$(MAKE) $(BUILDROOT_MAKE_ARGS) -C "$(BUILDROOT_DEST)"

# merge with the makefile-supplied .extraconfig
$(BUILDROOT_DEST)/.config: $(BUILDROOT_DEST)/.extraconfig
	$(MAKE) $(BUILDROOT_MAKE_ARGS) -C $(BUILDROOT_DEST) $(BUILDROOT_DEFCONFIG)
	cd "$(BUILDROOT_DEST)" && \
		support/kconfig/merge_config.sh ".config" ".extraconfig"

# Create extra config file to be merged
$(BUILDROOT_DEST)/.extraconfig: $(BUILDROOT_EXTRA_CONFIG_FILES) | $(BUILDROOT_DEST)/.git
	# when cat has no arguments (no extra configs), echo will provide empty stdin
	echo "$$_BUILDROOT_CONFIG_OVERLAY_" | cat $(BUILDROOT_EXTRA_CONFIG_FILES) - > "$@"
export _BUILDROOT_CONFIG_OVERLAY_=$(BUILDROOT_EXTRA_CONFIG_TEXT)

buildroot_menuconfig: $(BUILDROOT_DEST)/.config
	$(MAKE) $(BUILDROOT_MAKE_ARGS) -C "$(BUILDROOT_DEST)" menuconfig

buildroot_clean:
	$(MAKE) $(BUILDROOT_MAKE_ARGS) -C "$(BUILDROOT_DEST)" clean
	rm -f "$(BUILDROOT_DEST)/.extraconfig"

# aliases
rootfs: buildroot

all: buildroot
clean_all: buildroot_clean
