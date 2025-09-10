#!/bin/bash

REPO_BASE_URL="git@github.com:samlovelace"
WORKSPACE_DIR=/home/sam/dev/cpp/robot_ws

# Declare associative array of modules
declare -A MODULES
MODULES[autonomy]="neo cortex"
MODULES[manipulation]="arm_configs arm"
MODULES[perception]="vision"
MODULES[vehicle]="abv_controller"

# Use passed arguments or default to all keys
if [ "$#" -eq 0 ]; then
    REPOS=("${!MODULES[@]}")
else
    REPOS=("$@")
fi
