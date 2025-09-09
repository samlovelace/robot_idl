
#!/bin/bash

REPO_BASE_URL="https://github.com/samlovelace"
WORKSPACE_DIR=~/robot_ws
REPOS=("perception")

# Declare associative array of modules
declare -A MODULES

# Each key is a module, value is space-separated list of repos
MODULES[autonomy]="neo cortex"
MODULES[manipulation]="arm_configs arm"
MODULES[perception]="vision"
MODULES[vehicle]="abv_controller"
