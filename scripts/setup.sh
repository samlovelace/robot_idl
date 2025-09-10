#!/bin/bash
set -e

source "$(dirname "$0")/config.sh"

mkdir -p "$WORKSPACE_DIR/src"
cd "$WORKSPACE_DIR/src"

echo "🚀 Cloning modules: ${REPOS[*]}"
for module in "${REPOS[@]}"; do
    echo "🔧 Processing module: $module"

    repos="${MODULES[$module]}"

    if [ -z "$repos" ]; then
        echo "⚠️  Warning: No repos defined for module '$module'. Skipping."
        continue
    fi

    for repo in $repos; do
        if [ ! -d "$repo" ]; then
            echo "📦 Cloning $repo..."
            git clone "$REPO_BASE_URL/$repo.git"
        else
            echo "✅ $repo already exists."
        fi
	
	# run install script for each repo
	cd "$WORKSPACE_DIR/src/$repo"
	chmod +x setup.sh
	sudo ./setup.sh

    done
done
