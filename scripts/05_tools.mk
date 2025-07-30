## Builds some hosted tools required for development

# NXP iMX mfgtools (`uuu`) bootloader utility
MFGTOOLS_DEST ?= $(BUILD_DEST)/tools/mfgtools
MFGTOOLS_GIT_URL ?= https://github.com/nxp-imx/mfgtools
MFGTOOLS_UUU = $(MFGTOOLS_DEST)/build/uuu/uuu
UUU ?= $(MFGTOOLS_UUU)

.PHONY: mfgtools_build mfgtools_clean
mfgtools_build: $(MFGTOOLS_UUU)
$(MFGTOOLS_DEST)/.git:
	$(call mk_git_clone,$(MFGTOOLS_GIT_URL),$(MFGTOOLS_DEST))
$(MFGTOOLS_UUU): $(MFGTOOLS_DEST)/.git
	export CROSS_COMPILER= && \
		mkdir -p "$(MFGTOOLS_DEST)/build" && \
		cd "$(MFGTOOLS_DEST)/build" && \
		cmake .. && cmake --build .
mfgtools_clean:
	rm -rf "$(MFGTOOLS_DEST)/build"

all: mfgtools_build
clean_all: mfgtools_clean
