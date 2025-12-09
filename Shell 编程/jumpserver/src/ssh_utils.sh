#!/bin/bash

setup_ssh_key() {
    target="$1"
    pass="$2"
    if [[ ! -f ~/.ssh/id_rsa ]]; then
        ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    fi
    sshpass -p "$pass" ssh-copy-id "$target"
}
