## ARM Trusted Firmware targets 

ATF_DEST ?= $(BUILD_DEST)/atf
ATF_GIT_URL ?= https://github.com/nxp-imx/imx-atf.git
ATF_GIT_BRANCH ?=
ATF_PLATFORM ?= imx8mq
ATF_OPTEE_FLAGS ?=

# internal vars
ATF_MAKE_FLAGS ?= $(_XC_ARG) PLAT=$(ATF_PLATFORM) \
				  $(if $(OPTEE_ENABLED),$(ATF_OPTEE_FLAGS),SPD=none)
ATF_BIN_NAME = bl31.bin
ATF_BIN_FULL = $(ATF_DEST)/build/$(ATF_PLATFORM)/release/$(ATF_BIN_NAME)

.PHONY: atf atf_clean
atf: $(ATF_DEST)/.git
	$(MAKE_FORCED) $(ATF_BIN_FULL)
$(ATF_DEST)/.git:
	$(call mk_git_clone,$(ATF_GIT_URL),$(ATF_DEST),$(ATF_GIT_BRANCH))
$(ATF_BIN_FULL): $(_FORCE)
	make -C "$(ATF_DEST)" $(ATF_MAKE_FLAGS) bl31

atf_clean:
	$(MAKE) -C "$(ATF_DEST)" clean
	rm -rf "$(ATF_DEST)/build/$(ATF_PLATFORM)/"

all: atf
clean_all: atf_clean
