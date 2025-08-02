## Generic Linux uImage (bootable FIT) generator from Makefile

# Customize using SoC/board configuration:
GEN_LINUX_FIT_NAME ?= linux
GEN_LINUX_FIT_DESCR ?= Linux bootable FIT image
GEN_LINUX_FIT_ARCH ?= $(SOC_ARCH)
GEN_LINUX_FIT_KERNEL_IMAGE ?= Image
GEN_LINUX_FIT_FDT_BIN ?= $(notdir $(KERNEL_OUT_DTB))
# Note: initrd entry is disabled unless set to 1
GEN_LINUX_FIT_INITRD_ENABLED ?=
GEN_LINUX_FIT_INITRD_IMAGE ?= rootfs.cpio

# Note: you need to change all addresses below to point to DRAM phys. space
GEN_LINUX_FIT_KERNEL_LOAD ?= 0x81000000
GEN_LINUX_FIT_KERNEL_ENTRY ?= $(GEN_LINUX_FIT_KERNEL_LOAD)
GEN_LINUX_FIT_FDT_LOAD ?= 0x8E000000
GEN_LINUX_FIT_INITRD_LOAD ?= 0x90000000

# Makefile dependencies / target files to be used
GEN_LINUX_FIT_DEPS ?= $(KERNEL_OUT_IMAGE) $(KERNEL_OUT_DTB) \
                      $(if $(GEN_LINUX_FIT_INITRD_ENABLED), \
                           $(BUILDROOT_OUT_CPIO))
GEN_LINUX_FIT_DEST ?= $(STAGING_DEST)
GEN_LINUX_FIT_OUT_ITS ?= $(GEN_LINUX_FIT_DEST)/$(GEN_LINUX_FIT_NAME).its
GEN_LINUX_FIT_OUT_ITB ?= $(GEN_LINUX_FIT_OUT_ITS:%.its=%.itb)

# FIT image template + fragments below
define _gen_linux_fit_tpl=
/dts-v1/;
/ {
    description = "$(LINUX_UIMAGE_GEN_DESCR)";
    #address-cells = <1>;

    images {
        kernel {
            description = "Linux kernel";
            data = /incbin/("$(GEN_LINUX_FIT_KERNEL_IMAGE)");
            type = "kernel";
            arch = "$(GEN_LINUX_FIT_ARCH)";
            os = "linux";
            compression = "none";
            load = <$(GEN_LINUX_FIT_KERNEL_LOAD)>;
            entry = <$(GEN_LINUX_FIT_KERNEL_ENTRY)>;
        };
        fdt {
            description = "Device tree";
            data = /incbin/("$(GEN_LINUX_FIT_FDT_BIN)");
            type = "flat_dt";
            arch = "$(GEN_LINUX_FIT_ARCH)";
            compression = "none";
            load = <$(GEN_LINUX_FIT_FDT_LOAD)>;
        };
        $(if $(GEN_LINUX_FIT_INITRD_ENABLED),$(_gen_linux_fit_initrd_tpl))
    };
    configurations {
        default = "normal-boot";
        normal-boot {
            description = "Normal boot config";
            kernel = "kernel";
            fdt = "fdt";
            $(if $(GEN_LINUX_FIT_INITRD_ENABLED),ramdisk = "initrd";)
        };
    };
};
endef

define _gen_linux_fit_initrd_tpl=
        initrd {
            description = "Ramdisk";
            data = /incbin/("$(GEN_LINUX_FIT_INITRD_IMAGE)");
            type = "ramdisk";
            arch = "$(GEN_LINUX_FIT_ARCH)";
            os = "linux";
            compression = "none";
            load = <$(GEN_LINUX_FIT_INITRD_LOAD)>;
        };
endef

# FIT image source goal
$(GEN_LINUX_FIT_OUT_ITS): $(GEN_LINUX_FIT_DEPS) | $(GEN_LINUX_FIT_DEST)/
	echo "$$_GEN_LINUX_FIT_TPL_" > "$@"
export _GEN_LINUX_FIT_TPL_=$(_gen_linux_fit_tpl)

