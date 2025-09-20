#!/bin/bash
set -e

# Detect if running inside Docker
if [ -f /.dockerenv ]; then
    SUDO=""
else
    SUDO="sudo"
fi

source "$(dirname "$0")/config.sh" "$@"
source "$(dirname "$0")/common.sh" "$@"

mkdir -p "$WORKSPACE_DIR/src"
cd "$WORKSPACE_DIR/src"

for module in "${REPOS[@]}"; do
    echo "Processing module: $module"

    repos="${MODULES[$module]}"

    if [ -z "$repos" ]; then
        echo "Warning: No repos defined for module '$module'. Skipping."
        continue
    fi

    for repo in $repos; do
        if [ ! -d "$repo" ]; then
            echo "Cloning $repo..."
            git clone --recursive "$REPO_BASE_URL/$repo.git" "$WORKSPACE_DIR/src/$repo"
        else
            echo "$repo already exists."
        fi

        cd "$WORKSPACE_DIR/src/$repo"
        chmod +x deps.sh
        source deps.sh

        # Install dependencies if defined
        if [ "${#DEPENDENCIES[@]}" -gt 0 ]; then
            for pkg in "${DEPENDENCIES[@]}"; do
                check_and_install "$pkg"
            done
        fi

        # Run custom build steps if defined
        if declare -f run_custom_build_steps > /dev/null; then
            echo "Running custom build steps for $repo..."
            run_custom_build_steps
        fi

        # build pkg
        cd "$WORKSPACE_DIR"
        colcon build --packages-select robot_idl "$repo"

    done
done
