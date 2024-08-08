## Linux kernel build targets

# Linux Kernel
LINUX_DIR = $(BUILD_DEST)/linux
LINUX_GIT_URL = https://github.com/torvalds/linux.git
LINUX_GIT_BRANCH = v6.6
LINUX_FLAGS = ARCH=arm64 $(_XC_ARG) -j "$(NPROC)"
LINUX_CONFIG_TARGET = defconfig
LINUX_DTS = arch/arm64/boot/dts/freescale/imx8mq-pico-pi.dts
LINUX_IMAGE_OUT = arch/arm64/boot/Image
LINUX_DTB_OUT = arch/arm64/boot/imx8mq-pico-pi.dtb
LINUX_DTC_BIN = scripts/dtc/dtc
LINUX_EXTRA_PATCH = $(SRC)/patches/linux-imx8mq-power-regs.patch

.PHONY: linux linux_clean linux_config linux_dtb
_LINUX_CONFIG = $(LINUX_DIR)/.config
linux: $(LINUX_DIR)/.git
	$(MAKE) FORCE=1 $(LINUX_DIR)/$(LINUX_IMAGE_OUT)
$(LINUX_DIR)/.git:
	git clone "$(LINUX_GIT_URL)" --depth=1 --branch=$(LINUX_GIT_BRANCH) "$(LINUX_DIR)"

linux_menuconfig: $(_LINUX_CONFIG)
	$(MAKE) $(LINUX_FLAGS) -C "$(LINUX_DIR)" menuconfig

$(LINUX_DIR)/$(LINUX_IMAGE_OUT): $(_LINUX_CONFIG)
	# patch linux board DTB with extra modifications (for power regulator)
	if [[ -n "$(LINUX_EXTRA_PATCH)" ]]; then \
		cd "$(LINUX_DIR)/" && \
		if ! patch -R -p1 -s -f --dry-run < "$(LINUX_EXTRA_PATCH)"; then \
			patch -p1 < "$(LINUX_EXTRA_PATCH)" ; \
		fi \
	fi
	$(MAKE) $(LINUX_FLAGS) -C "$(LINUX_DIR)"
$(_LINUX_CONFIG):
	$(MAKE) $(LINUX_FLAGS) -C "$(LINUX_DIR)" $(LINUX_CONFIG_TARGET)


linux_clean:
	$(MAKE) $(LINUX_FLAGS) -C "$(LINUX_DIR)" clean

linux_dtb:
	$(MAKE) FORCE=1 $(LINUX_DIR)/$(LINUX_DTB_OUT)
$(LINUX_DIR)/$(LINUX_DTB_OUT): $(LINUX_DIR)/$(LINUX_DTS)
	cd "$(LINUX_DIR)" && \
		cpp -nostdinc -I include -undef -x assembler-with-cpp "$(LINUX_DTS)" | \
		$(LINUX_DTC_BIN) -O dtb -o "$(LINUX_DTB_OUT)"

