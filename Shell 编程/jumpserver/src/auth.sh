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
