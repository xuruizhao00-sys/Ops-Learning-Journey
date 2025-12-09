#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/src/config_loader.sh"
source "$BASE_DIR/src/auth.sh"
source "$BASE_DIR/src/menu.sh"
source "$BASE_DIR/src/ssh_utils.sh"
source "$BASE_DIR/src/firewall.sh"

login
main_menu
19:20:46 root@redis01:~/shell/lesson02# cat jumpserver/src/firewall.sh 
#!/bin/bash
# simple placeholder
19:21:06 root@redis01:~/shell/lesson02# cat jumpserver/src/menu.sh 
#!/bin/bash

draw_box(){ echo "========== $1 =========="; }

list_env_hosts() {
    local env="$1"
    declare -n g="hosts_${env}"
    for id in "${!g[@]}"; do
        e="${g[$id]}"
        echo "$id) $(echo "$e" | awk '{print $2}')  $(echo "$e" | awk '{print $1}')"
    done
}

search_host() {
    local kw="$1"
    for env in prod test dev; do
        declare -n gp="hosts_${env}"
        for id in "${!gp[@]}"; do
            e="${gp[$id]}"
            if echo "$e" | grep -qi "$kw"; then
                echo "[$env] $id) $e"
            fi
        done
    done
}

main_menu() {
    while true; do
        clear
        draw_box "Shell JumpServer"
        echo "1) PROD"
        echo "2) TEST"
        echo "3) DEV"
        echo "4) 搜索主机"
        echo "0) 退出"
        read -p "选择：" c
        case "$c" in
            1) env="prod";;
            2) env="test";;
            3) env="dev";;
            4) read -p "关键字： " kw; search_host "$kw"; read -n1; continue;;
            5) exit 0;;
        esac

        if ! can_access "$role" "$env"; then
            echo "权限不足"
            sleep 1
            continue
        fi

        clear
        draw_box "主机列表 ($env)"
        list_env_hosts "$env"
        read -p "选择主机编号：" sid

        declare -n grp="hosts_${env}"
        entry="${grp[$sid]}"
        ip=$(echo "$entry" | awk '{print $1}')
        name=$(echo "$entry" | awk '{print $2}')

        read -p "SSH 用户名：" ssh_user
        ssh "$ssh_user@$ip"
    done
}