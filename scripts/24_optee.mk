## OP-TEE Trusted OS (BL32) build rules

# OP-TEE configuration vars
OPTEE_DEST ?= $(BUILD_DEST)/optee_os
OPTEE_GIT_URL ?= https://github.com/OP-TEE/optee_os.git
OPTEE_GIT_BRANCH ?=

OPTEE_PLATFORM ?= UNKNOWN_PLATFORM

OPTEE_MAKE_FLAGS ?= $(_XC_ARG) CROSS_COMPILE64=$(CROSS_COMPILE) \
	PLATFORM=$(OPTEE_PLATFORM) O=build \
	DEBUG=1 CFG_TEE_BENCHMARK=n CFG_TEE_CORE_LOG_LEVEL=3 \
	CFG_UART_BASE=$(TRUSTED_UART_BASE) \
	CFG_DDR_SIZE=$(OPTEE_DDR_SIZE) \
	CFG_TZDRAM_START=$(OPTEE_TZDRAM_ADDR) \
	CFG_TZDRAM_SIZE=$(OPTEE_TZDRAM_SIZE) \
	CFG_TEE_SHMEM_SIZE=$(OPTEE_SHMEM_SIZE)
OPTEE_OUT_BIN = $(OPTEE_DEST)/build/core/tee-raw.bin

ATF_OPTEE_FLAGS = SPD=opteed LOG_LEVEL=40 \
		IMX_BOOT_UART_BASE=$(TRUSTED_UART_BASE) \
		BL32_BASE=$(OPTEE_TZDRAM_ADDR) BL32_SIZE=$(OPTEE_TOTAL_SIZE)

.PHONY: optee optee_clean
$(OPTEE_OUT_BIN): optee
# FIXME: make it depend on invocation flags from files / other configs
optee: $(OPTEE_DEST)/.git
	make -C "$(OPTEE_DEST)" $(OPTEE_MAKE_FLAGS)

$(OPTEE_DEST)/.git:
	$(call mk_git_clone,$(OPTEE_GIT_URL),$(OPTEE_DEST),$(OPTEE_GIT_BRANCH))

optee_clean:
	make -C "$(OPTEE_DEST)" $(OPTEE_MAKE_FLAGS) clean
	rm -rf "$(OPTEE_DEST)/build"

all: $(if $(OPTEE_ENABLED),optee)
clean_all: optee_clean
