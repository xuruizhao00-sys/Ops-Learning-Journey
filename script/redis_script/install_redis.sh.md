```bash
# ==============================================================================
# 脚本基础信息
# filename: install_redis.sh
# name: xuruizhao
# email: xuruizhao00@163.com
# v: LnxGuru
# GitHub: xuruizhao00-sys
# ==============================================================================
#!/bin/bash

#本脚本支持在线和离线安装

REDIS_VERSION=redis-8.2.1
#REDIS_VERSION=redis-8.0.3
#REDIS_VERSION=redis-7.4.2
#REDIS_VERSION=redis-7.2.5
#REDIS_VERSION=redis-7.2.4
#REDIS_VERSION=redis-7.2.3
#REDIS_VERSION=redis-7.2.1
#REDIS_VERSION=redis-7.0.11
#REDIS_VERSION=redis-7.0.7
#REDIS_VERSION=redis-7.0.3
#REDIS_VERSION=redis-6.2.6
#REDIS_VERSION=redis-4.0.14

PASSWORD=123456

INSTALL_DIR=/apps/redis

CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`

. /etc/os-release

color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "
    elif [ $2 = "failure" -o $2 = "1"  ] ;then
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo
}


prepare(){
    if [ $ID = "centos" -o $ID = "rocky" ];then
        yum  -y install gcc make jemalloc-devel systemd-devel
    else
        apt update
        #redis-8.X以后版本安装下面相关包
        apt install -y --no-install-recommends  gcc make ca-certificates  wget dpkg-dev  g++  libc6-dev  libssl-dev  git cmake python3 python3-pip python3-venv python3-dev unzip rsync  clang  automake   autoconf libtool libjemalloc-dev pkg-config libsystemd-dev
        #redis-7.X以前版本安装下面相关包
        #apt -y install  gcc make libjemalloc-dev libsystemd-dev
    fi
    if [ $? -eq 0 ];then
        color "安装软件包成功"  0
    else
        color "安装软件包失败，请检查网络配置" 1
        exit
    fi
}

install() {
    if [ ! -f ${REDIS_VERSION}.tar.gz ];then
        wget http://download.redis.io/releases/${REDIS_VERSION}.tar.gz || { color "Redis 源码下载失败" 1 ; exit; }
    fi
    tar xf ${REDIS_VERSION}.tar.gz -C /usr/local/src
    cd /usr/local/src/${REDIS_VERSION}
	#redis-8.x以后版本需要提定下面环境变量
	export BUILD_TLS=no BUILD_WITH_MODULES=no INSTALL_RUST_TOOLCHAIN=no DISABLE_WERRORS=yes
    make -j $CUPS USE_SYSTEMD=yes PREFIX=${INSTALL_DIR} install && color "Redis 编译安装完成" 0 || { color "Redis 编译安装失败" 1 ;exit ; }

    ln -s ${INSTALL_DIR}/bin/redis-*  /usr/local/bin/

    mkdir -p ${INSTALL_DIR}/{etc,log,data,run}

    cp redis.conf  ${INSTALL_DIR}/etc/

    sed -i -e 's/bind 127.0.0.1/bind 0.0.0.0/'  -e "/# requirepass/a requirepass $PASSWORD"  -e "/^dir .*/c dir ${INSTALL_DIR}/data/"  -e "/logfile .*/c logfile ${INSTALL_DIR}/log/redis-6379.log"  -e  "/^pidfile .*/c  pidfile ${INSTALL_DIR}/run/redis_6379.pid" ${INSTALL_DIR}/etc/redis.conf


    if id redis &> /dev/null ;then
         color "Redis 用户已存在" 1
    else
         useradd -r -s /sbin/nologin redis
         color "Redis 用户创建成功" 0
    fi

    chown -R redis:redis ${INSTALL_DIR}

    cat >> /etc/sysctl.conf <<EOF
net.core.somaxconn = 1024
vm.overcommit_memory = 1
EOF
    sysctl -p
    if [ $ID = "centos" -o $ID = "rocky" ];then
        echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local
        chmod +x /etc/rc.d/rc.local
        /etc/rc.d/rc.local
    else
        echo -e '#!/bin/bash\necho never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
        chmod +x /etc/rc.local
        /etc/rc.local
    fi


cat > /lib/systemd/system/redis.service <<EOF
[Unit]
Description=Redis persistent key-value database
After=network.target

[Service]
ExecStart=${INSTALL_DIR}/bin/redis-server ${INSTALL_DIR}/etc/redis.conf --supervised systemd
ExecStop=/bin/kill -s QUIT \$MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
     systemctl daemon-reload
     systemctl enable --now  redis &> /dev/null
     if [ $? -eq 0 ];then
         color "Redis 服务启动成功,Redis信息如下:"  0
     else
        color "Redis 启动失败" 1
        exit
     fi
     sleep 2
     redis-cli -a $PASSWORD INFO Server 2> /dev/null
}

prepare

install

```


```bash
# ==============================================================================
# 脚本基础信息
# filename: install_redis.sh
# name: xuruizhao
# email: xuruizhao00@163.com
# v: LnxGuru
# GitHub: xuruizhao00-sys
# 功能说明：支持 Redis 4.x-8.x 在线/离线编译安装，自动适配 CentOS/Rocky/Ubuntu/Debian
# 优化特性：root 校验、智能依赖、配置增强、错误捕获、安装总结、清理选项
# ==============================================================================
#!/bin/bash
set -euo pipefail  # 开启严格模式，遇到错误立即退出

# ============================ 自定义配置区（用户可修改）===========================
REDIS_VERSION="redis-8.2.1"  # 默认安装版本，支持注释切换
# REDIS_VERSION=redis-8.0.3
# REDIS_VERSION=redis-7.4.2
# REDIS_VERSION=redis-7.2.5
# REDIS_VERSION=redis-6.2.6
# REDIS_VERSION=redis-4.0.14

REDIS_PORT=6379              # Redis 监听端口
PASSWORD="123456"            # Redis 访问密码（建议修改为强密码）
INSTALL_DIR="/apps/redis"    # 安装目录
DATA_DIR="${INSTALL_DIR}/data"  # 数据目录
LOG_DIR="${INSTALL_DIR}/log"    # 日志目录
RUN_DIR="${INSTALL_DIR}/run"    # 运行目录
CONF_FILE="${INSTALL_DIR}/etc/redis.conf"  # 配置文件路径
LOG_FILE="/var/log/redis_install.log"  # 安装日志文件
CLEAR_SOURCE="yes"           # 安装完成后是否清理源码包（yes/no）
# ==============================================================================

# 系统信息变量
CPUS=$(lscpu | awk '/^CPU\(s\)/{print $2}')  # 修复原脚本笔误（CUPS→CPUS）
. /etc/os-release  # 加载系统版本信息

# ============================ 工具函数 ============================
# 颜色输出函数
color() {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_INFO="echo -en \\033[1;34m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    case "$2" in
        success|0)
            ${SETCOLOR_SUCCESS} && echo -n "  OK  "
            ;;
        failure|1)
            ${SETCOLOR_FAILURE} && echo -n "FAILED"
            ;;
        warning|2)
            ${SETCOLOR_WARNING} && echo -n "WARNING"
            ;;
        info|3)
            ${SETCOLOR_INFO} && echo -n " INFO "
            ;;
        *)
            ${SETCOLOR_NORMAL} && echo -n "     "
            ;;
    esac
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo
}

# 信号捕获：用户中断（Ctrl+C）时清理资源
trap 'color "用户中断安装，开始清理资源..." 2; clean_up; exit 1' SIGINT SIGTERM

# 清理函数
clean_up() {
    # 清理编译残留
    if [ -d "/usr/local/src/${REDIS_VERSION}" ]; then
        rm -rf "/usr/local/src/${REDIS_VERSION}" >/dev/null 2>&1
    fi
    # 清理临时文件
    rm -f "/tmp/${REDIS_VERSION}.tar.gz" >/dev/null 2>&1
    color "资源清理完成" 0
}

# 前置校验函数
pre_check() {
    # 校验是否为 root 用户
    if [ "$(id -u)" -ne 0 ]; then
        color "错误：请使用 root 用户执行脚本（sudo -i 切换）" 1
        exit 1
    fi

    # 校验依赖工具是否存在
    local tools=("wget" "curl" "tar" "gcc" "make")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            color "缺少依赖工具：$tool，开始自动安装..." 3
            if [ "$ID" = "centos" ] || [ "$ID" = "rocky" ]; then
                yum install -y "$tool" >> "$LOG_FILE" 2>&1
            else
                apt install -y "$tool" >> "$LOG_FILE" 2>&1
            fi
            if [ $? -ne 0 ]; then
                color "依赖工具 $tool 安装失败，请手动安装后重试" 1
                exit 1
            fi
        fi
    done

    # 校验安装目录是否存在
    if [ -d "$INSTALL_DIR" ]; then
        color "警告：安装目录 $INSTALL_DIR 已存在" 2
        read -p "是否覆盖原有安装（数据会保留，配置会更新）？[y/N] " -n 1 -r
        echo
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
            color "用户取消覆盖，安装终止" 1
            exit 0
        fi
    fi

    # 校验端口是否被占用
    if ss -tuln | grep -q ":$REDIS_PORT"; then
        color "错误：端口 $REDIS_PORT 已被占用，请修改 REDIS_PORT 后重试" 1
        exit 1
    fi

    color "前置校验通过，开始安装准备..." 0
}

# 依赖安装函数（按系统+Redis版本智能适配）
install_deps() {
    color "开始安装编译依赖包..." 3
    if [ "$ID" = "centos" ] || [ "$ID" = "rocky" ]; then
        # CentOS/Rocky：先安装 EPEL 源（解决 jemalloc-devel 依赖）
        if ! rpm -q epel-release >/dev/null 2>&1; then
            yum install -y epel-release >> "$LOG_FILE" 2>&1
        fi
        # 安装依赖包
        yum install -y gcc make jemalloc-devel systemd-devel openssl-devel >> "$LOG_FILE" 2>&1
    else
        # Ubuntu/Debian：按 Redis 版本区分依赖
        apt update >> "$LOG_FILE" 2>&1
        if [[ "$REDIS_VERSION" =~ ^redis-8\. ]]; then
            # Redis 8.x+ 依赖（原有基础上补充必要依赖）
            apt install -y --no-install-recommends gcc make ca-certificates wget dpkg-dev g++ \
                libc6-dev libssl-dev git cmake python3 python3-pip python3-venv python3-dev \
                unzip rsync clang automake autoconf libtool libjemalloc-dev pkg-config libsystemd-dev >> "$LOG_FILE" 2>&1
        else
            # Redis 7.x- 依赖
            apt install -y gcc make libjemalloc-dev libsystemd-dev libssl-dev >> "$LOG_FILE" 2>&1
        fi
    fi

    if [ $? -eq 0 ]; then
        color "依赖包安装完成" 0
    else
        color "依赖包安装失败，查看日志：$LOG_FILE" 1
        exit 1
    fi
}

# 源码下载/解压函数
download_source() {
    color "开始处理 Redis 源码（版本：$REDIS_VERSION）..." 3
    local source_url="http://download.redis.io/releases/${REDIS_VERSION}.tar.gz"
    local local_tar="${REDIS_VERSION}.tar.gz"

    # 检查本地是否有源码包（离线安装支持）
    if [ -f "$local_tar" ]; then
        color "发现本地源码包：$local_tar，直接使用" 3
        cp "$local_tar" "/tmp/" >> "$LOG_FILE" 2>&1
    else
        color "本地无源码包，开始在线下载：$source_url" 3
        # 优先用 wget，失败则用 curl
        if ! wget -q -O "/tmp/$local_tar" "$source_url"; then
            color "wget 下载失败，尝试用 curl 下载..." 2
            if ! curl -sSL -o "/tmp/$local_tar" "$source_url"; then
                color "源码下载失败（网络问题或版本不存在），查看日志：$LOG_FILE" 1
                exit 1
            fi
        fi
    fi

    # 解压源码
    color "开始解压源码包..." 3
    tar xf "/tmp/$local_tar" -C /usr/local/src >> "$LOG_FILE" 2>&1
    if [ ! -d "/usr/local/src/${REDIS_VERSION}" ]; then
        color "源码解压失败，查看日志：$LOG_FILE" 1
        exit 1
    fi
    color "源码解压完成" 0
}

# 编译安装函数
compile_install() {
    color "开始编译 Redis（CPU核心数：$CPUS）..." 3
    cd "/usr/local/src/${REDIS_VERSION}" || exit 1

    # Redis 8.x+ 特殊环境变量（保持原有逻辑，补充注释）
    if [[ "$REDIS_VERSION" =~ ^redis-8\. ]]; then
        export BUILD_TLS=no BUILD_WITH_MODULES=no INSTALL_RUST_TOOLCHAIN=no DISABLE_WERRORS=yes
        color "Redis 8.x+ 启用特殊编译参数" 3
    fi

    # 编译安装（指定 CPU 核心数，启用 systemd 支持）
    make -j "$CPUS" USE_SYSTEMD=yes PREFIX="$INSTALL_DIR" install >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        color "Redis 编译失败，查看日志：$LOG_FILE" 1
        clean_up
        exit 1
    fi
    color "Redis 编译安装完成" 0

    # 创建软链接（方便全局调用）
    ln -sf "${INSTALL_DIR}/bin/redis-"* /usr/local/bin/ >> "$LOG_FILE" 2>&1

    # 创建目录结构
    mkdir -p "$INSTALL_DIR/etc" "$DATA_DIR" "$LOG_DIR" "$RUN_DIR" >> "$LOG_FILE" 2>&1

    # 复制并优化配置文件
    cp -f redis.conf "$CONF_FILE" >> "$LOG_FILE" 2>&1
    color "开始优化 Redis 配置文件..." 3

    # 配置文件修改（精准匹配，避免重复）
    sed -i \
        -e 's/^bind 127.0.0.1/bind 0.0.0.0/' \  # 允许全网访问（生产环境建议限制IP）
        -e 's/^# requirepass foobared/requirepass '"$PASSWORD"'/' \  # 设置密码
        -e 's/^dir \.\//dir '"$DATA_DIR"'/' \  # 数据目录
        -e 's/^logfile ""/logfile '"${LOG_DIR}/redis-${REDIS_PORT}.log"'/' \  # 日志文件
        -e 's/^pidfile \/var\/run\/redis_6379.pid/pidfile '"${RUN_DIR}/redis_${REDIS_PORT}.pid"'/' \  # PID文件
        -e 's/^daemonize yes/daemonize no/' \  # systemd 管理时禁用后台运行
        -e 's/^maxmemory <bytes>/maxmemory 1gb/' \  # 限制最大内存（可修改）
        -e 's/^maxmemory-policy noeviction/maxmemory-policy allkeys-lru/' \  # 内存满时淘汰策略
        -e 's/^appendonly no/appendonly yes/' \  # 启用AOF持久化
        -e 's/^appendfsync everysec/appendfsync everysec/' \  # AOF同步策略
        -e 's/^protected-mode yes/protected-mode yes/' \  # 启用保护模式
        "$CONF_FILE" >> "$LOG_FILE" 2>&1

    color "配置文件优化完成" 0
}

# 系统环境配置函数
system_config() {
    color "开始配置系统环境..." 3

    # 创建 redis 用户（避免重复创建）
    if ! id redis >/dev/null 2>&1; then
        useradd -r -s /sbin/nologin -d "$INSTALL_DIR" redis >> "$LOG_FILE" 2>&1
        color "Redis 用户创建成功" 0
    else
        color "Redis 用户已存在，跳过创建" 3
    fi

    # 设置目录权限
    chown -R redis:redis "$INSTALL_DIR" >> "$LOG_FILE" 2>&1
    chmod 750 "$INSTALL_DIR" "$DATA_DIR" "$LOG_DIR" "$RUN_DIR" >> "$LOG_FILE" 2>&1

    # 内核参数配置（避免重复添加）
    if ! grep -q "net.core.somaxconn = 1024" /etc/sysctl.conf; then
        echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf
    fi
    if ! grep -q "vm.overcommit_memory = 1" /etc/sysctl.conf; then
        echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
    fi
    # 应用内核参数
    sysctl -p >> "$LOG_FILE" 2>&1 || color "部分内核参数应用失败（不影响核心功能）" 2

    # 禁用透明大页（Redis 性能优化关键）
    if [ "$ID" = "centos" ] || [ "$ID" = "rocky" ]; then
        if ! grep -q "transparent_hugepage/enabled" /etc/rc.d/rc.local; then
            echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local
            chmod +x /etc/rc.d/rc.local
        fi
        /etc/rc.d/rc.local >> "$LOG_FILE" 2>&1
    else
        if ! grep -q "transparent_hugepage/enabled" /etc/rc.local; then
            echo -e '#!/bin/bash\necho never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
            chmod +x /etc/rc.local
        fi
        /etc/rc.local >> "$LOG_FILE" 2>&1
    fi

    # 验证透明大页是否禁用
    if [ "$(cat /sys/kernel/mm/transparent_hugepage/enabled)" != "never" ]; then
        color "警告：透明大页未禁用，可能影响 Redis 性能" 2
    else
        color "透明大页禁用成功" 0
    fi

    color "系统环境配置完成" 0
}

# 服务配置与启动函数
service_config() {
    color "开始配置 Redis 系统服务..." 3

    # 创建 systemd 服务文件
    cat > /lib/systemd/system/redis.service <<EOF
[Unit]
Description=Redis persistent key-value database (Version: $REDIS_VERSION)
After=network.target network-online.target
Wants=network-online.target

[Service]
ExecStart=${INSTALL_DIR}/bin/redis-server ${CONF_FILE} --supervised systemd
ExecStop=/bin/kill -s QUIT \$MAINPID
ExecReload=/bin/kill -s HUP \$MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
LimitNOFILE=1000000
LimitNPROC=1000000
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

    # 重载 systemd 并启动服务
    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    systemctl enable --now redis >> "$LOG_FILE" 2>&1

    # 验证服务状态
    sleep 3
    if systemctl is-active --quiet redis; then
        color "Redis 服务启动成功" 0
    else
        color "Redis 服务启动失败，查看日志：$LOG_FILE 或 journalctl -u redis" 1
        clean_up
        exit 1
    fi

    # 验证端口监听
    if ss -tuln | grep -q ":$REDIS_PORT"; then
        color "Redis 端口 $REDIS_PORT 监听成功" 0
    else
        color "Redis 端口 $REDIS_PORT 未监听，服务可能异常" 1
        exit 1
    fi

    # 输出 Redis 基础信息
    color "Redis 服务基础信息：" 3
    redis-cli -a "$PASSWORD" -p "$REDIS_PORT" INFO Server 2>/dev/null | grep -E "redis_version|redis_git_sha1|redis_git_dirty|redis_build_id|redis_mode|os|arch_bits|multiplexing_api|gcc_version"
}

# 安装总结函数
install_summary() {
    echo -e "\n==================================== 安装总结 ===================================="
    color "Redis 安装完成！以下是关键信息：" 3
    echo "✅ 安装版本：$REDIS_VERSION"
    echo "✅ 安装目录：$INSTALL_DIR"
    echo "✅ 配置文件：$CONF_FILE"
    echo "✅ 数据目录：$DATA_DIR"
    echo "✅ 日志目录：$LOG_DIR"
    echo "✅ 监听端口：$REDIS_PORT"
    echo "✅ 访问密码：$PASSWORD"
    echo "✅ 服务名称：redis"
    echo -e "\n📌 常用命令："
    echo "   启动服务：systemctl start redis"
    echo "   停止服务：systemctl stop redis"
    echo "   重启服务：systemctl restart redis"
    echo "   查看状态：systemctl status redis"
    echo "   连接测试：redis-cli -a $PASSWORD -p $REDIS_PORT"
    echo "   查看日志：tail -f ${LOG_DIR}/redis-${REDIS_PORT}.log"
    echo -e "\n⚠️  注意事项："
    echo "   1. 生产环境建议修改 bind 为指定IP（而非 0.0.0.0），增强安全性"
    echo "   2. 请根据服务器内存调整 maxmemory 配置（当前为 1GB）"
    echo "   3. 定期备份数据目录 $DATA_DIR 和 AOF 文件"
    echo -e "===================================================================================\n"
}

# ============================ 主执行流程 ============================
# 初始化日志文件
> "$LOG_FILE"  # 清空原有日志
color "Redis 编译安装脚本启动（日志文件：$LOG_FILE）" 3

# 执行流程
pre_check          # 前置校验
install_deps       # 安装依赖
download_source    # 下载/解压源码
compile_install    # 编译安装
system_config      # 系统环境配置
service_config     # 服务配置与启动

# 清理源码（可选）
if [ "$CLEAR_SOURCE" = "yes" ]; then
    color "开始清理源码包和编译目录..." 3
    clean_up
fi

# 输出安装总结
install_summary

exit 0
```