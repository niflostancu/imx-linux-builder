
# Buildroot config.
BUILDROOT_DIR = $(BUILD_DEST)/buildroot
BUILDROOT_GIT_URL = https://github.com/buildroot/buildroot.git
BUILDROOT_FLAGS = -j "$(NPROC)"
BUILDROOT_DEFCONFIG = defconfig
BUILDROOT_CPIO_OUT = output/images/rootfs.cpio
define BUILDROOT_EXTRA_CONFIG=
BR2_aarch64=y
BR2_LINUX_KERNEL=n
BR2_PACKAGE_FREESCALE_IMX=y
BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8M=y
BR2_TARGET_ROOTFS_CPIO=y
BR2_TARGET_ARM_TRUSTED_FIRMWARE=n
BR2_TARGET_UBOOT=n
BR2_PACKAGE_HOST_DOSFSTOOLS=y
BR2_PACKAGE_HOST_MTOOLS=y
BR2_PACKAGE_HOST_GENIMAGE=n
BR2_PACKAGE_HOST_IMX_MKIMAGE=n
BR2_PACKAGE_HOST_UBOOT_TOOLS=n
BR2_PACKAGE_HOST_UBOOT_TOOLS_FIT_SUPPORT=n
endef
export BUILDROOT_EXTRA_CONFIG

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

$(BUILDROOT_DIR)/.extraconfig:
	echo "$$BUILDROOT_EXTRA_CONFIG" > "$@"

buildroot_clean:
	$(MAKE) $(BUILDROOT_FLAGS) -C "$(BUILDROOT_DIR)" clean
	rm -f "$(BUILDROOT_DIR)/.extraconfig"

