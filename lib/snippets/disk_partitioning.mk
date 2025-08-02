## Disk partitioning & file formatting/copying utils (usable by Makefile targets)

# Common linux utilities
SUDO ?= sudo
LOSETUP ?= $(SUDO) losetup
MOUNT ?= $(SUDO) mount
UMOUNT ?= $(SUDO) umount
DD ?= $(SUDO) dd
MKFS_FAT32 ?= $(SUDO) mkfs.fat -F 32
MKFS_EXT4 ?= $(SUDO) mkfs.ext4

## Good ol' fdisk (quick MBR partitioning) partitioning templates
# generic macros
_fdisk_mkp = n$(nl)p$(nl)$(nl)$(1)$(nl)$(2)$(nl)
_fdisk_p_wr = $(nl)p$(nl)w$(nl)
# 1 bootable partition at 10MB offset (sector size: 512)
PART_FDISK_1P_BOOT_FULL = $(call _fdisk_mkp,20480)a$(nl)$(_fdisk_p_wr)
# 2 partitions, 1st boot (128MB @ 10MB offset), 2nd filling the rest
PART_FDISK_2P_BOOT_128 = $(call strip-spaces, \
		$(call _fdisk_mkp,20480,+128M)a$(nl) \
		$(call _fdisk_mkp,282624) $(_fdisk_p_wr) )
# 2 partitions like above, but boot partition is 256MB
PART_FDISK_2P_BOOT_256 = $(call strip-spaces, \
		$(call _fdisk_mkp,20480,+128M)a$(nl) \
		$(call _fdisk_mkp,544768) $(_fdisk_p_wr) )

# macro to create an empty disk image
# usage: $(call disk_image_create,$(DISK_IMAGE_SIZE),$(DISK_IMAGE_OUT))
define disk_image_create=
truncate --size $(1) $(2)
endef

# macro to run fdisk-based partitioning script (must be exported as env var)
# usage: $(call part_fdisk $(_SCRIPT_VAR),$(DISK_IMG))
define part_fdisk=
echo "$$$(1)" | fdisk $(2)
endef
PART_MACRO_FDISK=part_fdisk

# script macro to mount a disk image to a loop device
# usage: $(call disk_lodev_attach,$(DISK_IMAGE))
# see its implementation below for the shell vars available
define disk_lodev_attach=
ECODE=0
LOOP_DEV=$$($(LOSETUP) --find --show --partscan "$(1)")
LOPARTS=$$(ls -1d "$${LOOP_DEV}"p* 2>/dev/null)
(
set -e
endef

# macro to disconnect/cleanup a mounted loop device
# to be appended at the end of a command list to properly detach everything
# uses shell variables defined by disk_lodev_attach
define disk_lodev_cleanup=
) || { ECODE=$$?; }
# umount / disconnect devices
for p in "$${LOPARTS[@]}"; do
	mountpoint -q "$$p" && $(UMOUNT) "$$p" || true; done
$(LOSETUP) -d $${LOOP_DEV}p1
exit "$$ECODE"
endef

