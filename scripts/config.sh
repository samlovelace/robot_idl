#!/bin/bash

REPO_BASE_URL="https://github.com/samlovelace"
WORKSPACE_DIR=robot_ws

# Declare associative array of modules
declare -A MODULES
MODULES[autonomy]="neo cortex"
MODULES[manipulation]="arm"
MODULES[perception]="vision"
MODULES[vehicle]="abv_controller"
MODULES[commander]="abv_teleop robot_commander"

# Use passed arguments or default to all keys
if [ "$#" -eq 0 ]; then
    REPOS=("${!MODULES[@]}")
else
    REPOS=("$@")
fi
