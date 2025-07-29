## Build Framework Initialization
# Must be always included first to initialize top-level vars/macros

# autodetect framework path
_THIS_MK_FILE = $(lastword $(MAKEFILE_LIST))
_THIS_MK_DIR := $(patsubst %/,%,$(dir $(_THIS_MK_FILE)))
MK_FRAMEWORK_DIR := $(patsubst %/,%,$(dir $(_THIS_MK_DIR)))
MK_FRAMEWORK_LIB := $(MK_FRAMEWORK_DIR)/lib

# load makefile utils library
include $(MK_FRAMEWORK_LIB)/utils.mk
include $(MK_FRAMEWORK_LIB)/build_helpers.mk

# TODO: include board-specific config

# some commands require bash (esp. for the `[[ ... ]]` conditions)
SHELL=bash
# disable https://www.gnu.org/software/make/manual/html_node/Suffix-Rules.html
.SUFFIXES:

# Check whether build destination dir was configure
ifeq ("$(BUILD_DEST)","")
$(error Please set BUILD_DEST somewhere you have >20GB free space!)
endif

# common vars
DEBUG ?=
NPROC ?= $(shell nproc --ignore=2)

# Dummy rules for all and clean (filled by each included stage)
.PHONY: all clean_all
all:
clean_all:

# makefile force hack
_FORCE=$(if $(FORCE),.FORCE,)
.PHONY: .FORCE
.FORCE:

MAKE_FORCED = $(MAKE) CFG=$(CFG) FORCE=1

