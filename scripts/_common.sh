#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Node.js version installed via the ynh_nodejs_* helpers (24 LTS is upstream-recommended).
nodejs_version=24

# Git source for the MeshMonitor application (Crazypedia fork).
source_repo="https://github.com/Crazypedia/meshmonitor"

# Git ref to deploy. Tracks the fork's main branch (your working branch).
# Switch to a tag (e.g. "v4.12.1") for a pinned, reproducible release.
source_ref="main"

#=================================================
# PERSONAL HELPERS
#=================================================

# Clone (or re-checkout) the app source at $source_ref WITH submodules.
# The protobufs submodule is required at runtime (protobufLoader.ts reads protobufs/
# from the working directory), so a GitHub tarball is not sufficient.
_meshmonitor_fetch_source() {
    local dest="$1"

    # Ensure the app user owns the destination directory before running git as that user.
    chown -R "$app:" "$dest"

    if [ -d "$dest/.git" ]; then
        ynh_exec_as_app git -C "$dest" remote set-url origin "$source_repo"
        ynh_exec_as_app git -C "$dest" fetch --tags --force origin
    else
        # install_dir is provisioned empty; clone into it.
        ynh_exec_as_app git clone "$source_repo" "$dest"
    fi

    ynh_exec_as_app git -C "$dest" checkout --force "$source_ref"
    ynh_exec_as_app git -C "$dest" submodule sync --recursive
    ynh_exec_as_app git -C "$dest" submodule update --init --recursive --force
}

# Build the frontend and backend as the app user, using the helper-managed Node.js.
_meshmonitor_build() {
    local dir="$1"

    pushd "$dir" >/dev/null
        # ynh_nodejs_install puts the right node/npm on $PATH, which ynh_exec_as_app preserves.
        # --legacy-peer-deps is required upstream to resolve peer dependency conflicts.
        ynh_hide_warnings ynh_exec_as_app npm install --legacy-peer-deps
        ynh_hide_warnings ynh_exec_as_app npm run build
        ynh_hide_warnings ynh_exec_as_app npm run build:server
    popd >/dev/null
}
