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

# Create the runtime subdirectories the app expects under $data_dir.
#
# The app creates most of these lazily with mkdirSync(..., {recursive:true}), but
# doing it here means they exist with the right ownership from the start, and it
# documents what actually lives in the data dir. Keep in sync with conf/.env.
_meshmonitor_init_data_dir() {
    mkdir -p \
        "$data_dir/backups" \
        "$data_dir/system-backups" \
        "$data_dir/apprise-config" \
        "$data_dir/geojson" \
        "$data_dir/styles" \
        "$data_dir/scripts"

    chown -R "$app:$app" "$data_dir"
    chmod 750 "$data_dir"
}

# Build the frontend and backend as the app user, using the helper-managed Node.js.
_meshmonitor_build() {
    local dir="$1"

    pushd "$dir" >/dev/null
        # ynh_nodejs_install puts the right node/npm on $PATH, which ynh_exec_as_app preserves.
        # --legacy-peer-deps is required upstream to resolve peer dependency conflicts.
        # puppeteer is a devDependency and npm install pulls devDeps (the build needs
        # vite/tsc). Its postinstall would otherwise fetch a ~150 MB Chromium that this
        # headless server never uses. Upstream's .npmrc also sets puppeteer_skip_download,
        # but this does not rely on that staying put. Exported rather than passed inline
        # so it survives ynh_exec_as_app the same way $PATH does.
        export PUPPETEER_SKIP_DOWNLOAD=true
        ynh_hide_warnings ynh_exec_as_app npm install --legacy-peer-deps
        ynh_hide_warnings ynh_exec_as_app npm run build
        ynh_hide_warnings ynh_exec_as_app npm run build:server
    popd >/dev/null
}
