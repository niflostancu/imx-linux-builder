# Linux U-Boot FIT image generation scripts

# uImage creation config
STAGING_DEST ?= $(BUILD_DEST)/staging
LINUX_UIMAGE_OUT ?= $(STAGING_DEST)/$(notdir $(LINUX_UIMAGE_ITS)).itb

# default to using a generated ITS file:
LINUX_UIMAGE_ITS ?= $(GEN_LINUX_FIT_OUT_ITS)
LINUX_UIMAGE_DEPS ?= $(GEN_LINUX_FIT_DEPS)
LINUX_UIMAGE_COPY_FILES ?= $(GEN_LINUX_FIT_DEPS)

# load the generator definitions
include $(MK_FRAMEWORK_LIB)/snippets/gen_linux_fit.mk

.PHONY: linux_uimage
linux_uimage:
	$(MAKE_FORCED) $(LINUX_UIMAGE_OUT)
$(LINUX_UIMAGE_OUT): $(LINUX_UIMAGE_ITS) $(LINUX_UIMAGE_DEPS) | $(STAGING_DEST)/
	cp -f $(LINUX_UIMAGE_COPY_FILES) "$(STAGING_DEST)/"
	cd "$(STAGING_DEST)" && \
		"$(UBOOT_MKIMAGE_BIN)" -f "$(notdir $(LINUX_UIMAGE_ITS))" "$@" && \
		ls -l

$(STAGING_DEST)/:
	mkdir -p "$(STAGING_DEST)"

.PHONY: linux_uimage_clean
linux_uimage_clean:
	rm -rf "$(STAGING_DEST)"

clean: linux_uimage_clean

