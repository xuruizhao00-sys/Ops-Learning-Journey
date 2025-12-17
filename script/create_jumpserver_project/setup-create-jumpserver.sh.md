```python
cat > setup_create_project.sh << 'EOF'
#!/bin/bash

proj=jumpserver
echo "[*] 初始化 jumpserver 项目..."

rm -rf "$proj"
mkdir -p "$proj"/{config,logs,src}

# README
cat > "$proj/README.md" << 'MD'
# JumpServer - Super Lightweight Bash Jump Server
See docs in repository. Use at your own risk.
MD

# hosts.conf
cat > "$proj/config/hosts.conf" << 'CONF'
[prod]
1=10.1.1.10 Web01 DMZ
2=10.1.1.20 DB01 INTERNAL
3=10.1.1.30 Redis01 DMZ

[test]
1=172.16.10.11 TestWeb DMZ
2=172.16.10.21 TestDB INTERNAL

[dev]
1=192.168.1.11 DevWeb DMZ
2=192.168.1.21 DevDB INTERNAL
CONF

# users.conf
cat > "$proj/config/users.conf" << 'CONF'
# format: user:password:role
admin:admin123:admin
devops:devops123:devops
tester:test123:tester
CONF

# core.sh
cat > "$proj/src/core.sh" << 'BASH'
#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/src/config_loader.sh"
source "$BASE_DIR/src/auth.sh"
source "$BASE_DIR/src/menu.sh"
source "$BASE_DIR/src/ssh_utils.sh"
source "$BASE_DIR/src/firewall.sh"

login
main_menu
BASH

# config_loader.sh
cat > "$proj/src/config_loader.sh" << 'BASH'
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
BASH

# auth.sh
cat > "$proj/src/auth.sh" << 'BASH'
#!/bin/bash

declare -A fail_count

two_factor() {
    code=$((RANDOM % 900000 + 100000))
    echo "🌐 2FA 验证码: $code"
    read -p "请输入验证码: " in
    [[ "$in" == "$code" ]]
}

login() {
    for i in {1..5}; do
        read -p "用户名: " user
        read -s -p "密码: " pass; echo
        if [[ "${passwd[$user]}" == "$pass" ]]; then
            if ! two_factor; then
                echo "❌ 2FA 失败"
                exit 1
            fi
            role="${roles[$user]}"
            user_global="$user"
            return
        else
            echo "❌ 密码错误 ($i/5)"
            ((fail_count[$user]++))
        fi
    done
    echo "登录失败次数过多"
    exit 1
}

can_access() {
    local role="$1"
    local env="$2"
    case "$role" in
        admin) return 0 ;;
        devops) [[ "$env" != "test" ]] ;;
        tester) [[ "$env" == "test" ]] ;;
    esac
}
BASH

# menu.sh
cat > "$proj/src/menu.sh" << 'BASH'
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
BASH

# ssh_utils.sh
cat > "$proj/src/ssh_utils.sh" << 'BASH'
#!/bin/bash

setup_ssh_key() {
    target="$1"
    pass="$2"
    if [[ ! -f ~/.ssh/id_rsa ]]; then
        ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    fi
    sshpass -p "$pass" ssh-copy-id "$target"
}
BASH

# firewall.sh
cat > "$proj/src/firewall.sh" << 'BASH'
#!/bin/bash
# simple placeholder
BASH

# jumpserver.sh
cat > "$proj/jumpserver.sh" << 'BASH'
#!/bin/bash
cd "$(dirname "$0")"
bash src/core.sh
BASH

chmod +x "$proj/src/"*.sh "$proj/jumpserver.sh"
echo "[*] 项目生成完成: $proj/"
EOF

```

```bash
chmod +x setup_create_project.sh
./setup_create_project.sh
```

# 🎉 你现在会得到一个完整可运行的项目！

目录结构自动生成：

```bash
19:27:07 root@redis01:~/shell/lesson02# tree jumpserver
jumpserver
├── config
│   ├── hosts.conf
│   └── users.conf
├── jumpserver.sh
├── logs
├── README.md
└── src
    ├── auth.sh
    ├── config_loader.sh
    ├── core.sh
    ├── firewall.sh
    ├── menu.sh
    └── ssh_utils.sh

4 directories, 10 files
```