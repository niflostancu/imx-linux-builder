## Build script for OP-TEE

.PHONY: optee optee_clean
ifneq ("$(OPTEE_ENABLED)","")
# OP-TEE configuration vars
OPTEE_DIR = $(BUILD_DEST)/optee_os
OPTEE_GIT_URL = https://github.com/OP-TEE/optee_os.git
TRUSTED_UART_BASE=0x30860000

# allocate 32MB for TZDRAM, then 4MB for shared memory at the end of DRAM
OPTEE_TZDRAM_ADDR = 0xbdc00000
OPTEE_TZDRAM_SIZE = 0x02000000
OPTEE_SHMEM_SIZE = 0x00400000
OPTEE_SHMEM_ADDR = 0xbfc00000
OPTEE_TOTAL_SIZE = 0x02400000
OPTEE_MAKE_FLAGS = $(_XC_ARG) CROSS_COMPILE64=$(CROSS_COMPILE) \
	PLATFORM=imx-mx8mqevk O=build \
	DEBUG=1 CFG_TEE_BENCHMARK=n CFG_TEE_CORE_LOG_LEVEL=3 \
	CFG_UART_BASE=$(TRUSTED_UART_BASE) \
	CFG_DDR_SIZE=0x80000000 \
	CFG_TZDRAM_START=$(OPTEE_TZDRAM_ADDR) \
	CFG_TZDRAM_SIZE=$(OPTEE_TZDRAM_SIZE) \
	CFG_TEE_SHMEM_SIZE=$(OPTEE_SHMEM_SIZE)
OPTEE_OUT_BIN=$(OPTEE_DIR)/build/core/tee-raw.bin

ATF_MAKE_FLAGS_OPTEE = SPD=opteed LOG_LEVEL=40 \
		IMX_BOOT_UART_BASE=$(TRUSTED_UART_BASE) \
		BL32_BASE=$(OPTEE_TZDRAM_ADDR) BL32_SIZE=$(OPTEE_TOTAL_SIZE)

MKIMAGE_OPTEE_FLAGS = TEE_LOAD_ADDR=$(OPTEE_TZDRAM_ADDR)
MKIMAGE_OPTEE_DEPS := $(OPTEE_OUT_BIN)

BUILDROOT_EXTRA_CONFIGS += $(SRC)/configs/buildroot-optee.config

# OP-TEE Trusted OS
$(OPTEE_OUT_BIN): optee
optee: $(OPTEE_DIR)/.git
	make -C "$(OPTEE_DIR)" $(OPTEE_MAKE_FLAGS)
optee_clean:
	make -C "$(OPTEE_DIR)" $(OPTEE_MAKE_FLAGS) clean
	rm -rf "$(OPTEE_DIR)/build"

$(OPTEE_DIR)/.git:
	git clone "$(OPTEE_GIT_URL)" "$(OPTEE_DIR)"

else

optee_clean: optee
optee:
	echo "Please set OPTEE_ENABLED config.local.mk variable to 1!" >&2 && exit 1

endif

