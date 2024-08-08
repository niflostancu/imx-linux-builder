# NXP i.MX board firmware + linux build scripts 

For now, only targets the [TechNexion's iMX8MQ Pico Pi
board](https://www.technexion.com/products/system-on-modules/evk/pico-pi-imx8m/).

Uses / builds the following components:

* NXP binary blobs (auto-downloaded);
* NXP's [ARM Trusted Firmware fork](https://github.com/nxp-imx/imx-atf);
* [U-Boot](https://github.com/TechNexion/u-boot-tn-imx) (TechNexion fork, for now) for BL2 and BL33;
* [Mainline Linux Kernel](https://www.kernel.org);
* A [Buildroot](https://www.kernel.org) rootfs (as ramdisk, for now);

## Building the components

First, clone this repository somewhere inside your documents:
```sh
git clone https://github.com/niflostancu/imx-linux-builder.git
```

Afterwards, copy the sample config file as `config.sample.mk` and set your BUILD_DEST and CROSS_COMPILE variables (mandatory!).

Finally, use the bundled makefile:
```sh
make
```

## Booting from Linux Image

Start the board in serial boot mode, then:
```sh
# use the builtin makefile target:
make uuu_spl
```

Afterwards, in u-boot, start the USB Mass Storage program:
```
u-boot> ums mmc 0
```

Burn the disk image:
```sh
# first, print your block devices:
lsblk
# ^ take note of the USB device's identifier, then:
cd ~/tmp/your-build-dir/...
dd if=disk.img of=/dev/sd??? bs=4k
# replace with your disk; BE CAREFUL NOT TO ERASE YOUR LINUX PARTITIONS!
```

The usual way of booting Linux from a FIT image is the following:
```
u-boot=> setenv bootargs console=ttymxc0,115200
# Note: default load address overlaps during the load process, so we change it:
u-boot=> setenv loadaddr 0x70000000
u-boot=> load mmc 0:1 ${loadaddr} linux.itb; bootm ${loadaddr}
```

Fortunately, our custom u-boot has the following script defined as [u-boot default environment](./configs/uboot-default.env):
```
run linux
```

Enjoy!

## Makefile script docs

Makefile targets (`make <target>`):

* `all`: builds ALL images (firmware, linux, buildroot, disk image etc.);
* `clean`: cleans intermmediate files (Warning: you will need to REBUILD EVERYTHING);
* `uboot`: [re]builds u-boot BL2+BL33;
* `atf`: [re]builds the ARM Trusted Firmware (BL31);
* `mkimage`: [re]builds the firmware package (`flash.bin`);
* `linux`: [re]builds the Linux kernel;
* `buildroot`: [re]builds the Root FS as CPIO (used as InitRamFS);
* `linux_uimage`: [re]builds the unified Linux U-Boot image (`linux.itb`);
* `emmc_image`: [re]builds the disk image (FAT32 partition + `linux.itb` + `flash.bin` burned at 33k offset);
