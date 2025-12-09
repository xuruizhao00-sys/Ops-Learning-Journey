#!/bin/bash

CONF_DIR="$(cd "$(dirname "$0")/../config" && pwd)"
HOSTS_CONF="$CONF_DIR/hosts.conf"
USERS_CONF="$CONF_DIR/users.conf"

declare -A hosts_prod hosts_test hosts_dev
declare -A passwd roles

load_hosts() {
    local section=""
    while IFS= read -r line; do
        line="${line%%#*}"
        [[ -z "$line" ]] && continue
        if [[ "$line" =~ ^\[(.*)\]$ ]]; then
            section="${BASH_REMATCH[1]}"
            continue
        fi
        if [[ "$line" =~ ^([0-9]+)=(.*)$ ]]; then
            idx="${BASH_REMATCH[1]}"
            entry="${BASH_REMATCH[2]}"
            case "$section" in
                prod) hosts_prod[$idx]="$entry" ;;
                test) hosts_test[$idx]="$entry" ;;
                dev) hosts_dev[$idx]="$entry" ;;
            esac
        fi
    done < "$HOSTS_CONF"
}

load_users() {
    while IFS= read -r line; do
        line="${line%%#*}"
        [[ -z "$line" ]] && continue
        if [[ "$line" =~ ^([^:]+):([^:]+):([^:]+)$ ]]; then
            u="${BASH_REMATCH[1]}"
            passwd[$u]="${BASH_REMATCH[2]}"
            roles[$u]="${BASH_REMATCH[3]}"
        fi
    done < "$USERS_CONF"
}

load_hosts
load_users
