## Build-related makefile macros, e.g. for downloading / compiling / patching etc. 

$(call mk_include_guard,__MK_BUILD_HELPERS_INC__)

# default git clone args
MK_GIT_CLONE_ARGS ?=

# Downloads a repository from git
# Usage: $(call mk_git_clone,<REPO_URL>,<DEST_DIR>[,<BRANCH>])
define mk_git_clone=
git clone $(MK_GIT_CLONE_ARGS) "$(1)" \
	$(if $(3),--branch="$(3)") $(4) "$(2)"
endef

# Applies a single patch file (ignores it if already applied)
# Usage: $(call mk_apply_patch_dir,<PATCH_DIR>[,WORK_DIR])
# Also: `make DEBUG_PATCH=1` to show any patch errors!
define mk_apply_patch=
$(if $(1),
	$(if $(2),cd "$(2)/" && ,) \
	if ! $(if $(DEBUG_PATCH),false,patch -R -p1 -s -f --dry-run < "$(1)"); then \
		echo "Applied patch: $(1)"; \
		patch -p1 < "$(1)" ; \
	fi
)
endef

