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

echo "Cloning modules: ${REPOS[*]}"
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
	
	# run install script for each repo
	cd "$WORKSPACE_DIR/src/$repo"
	chmod +x setup.sh
	$SUDO ./setup.sh "$WORKSPACE_DIR"
    done
done
