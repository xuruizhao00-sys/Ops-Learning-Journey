#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/src/config_loader.sh"
source "$BASE_DIR/src/auth.sh"
source "$BASE_DIR/src/menu.sh"
source "$BASE_DIR/src/ssh_utils.sh"
source "$BASE_DIR/src/firewall.sh"

login
main_menu