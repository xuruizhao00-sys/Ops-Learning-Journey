### 新增功能说明：

1. **关闭 SELinux**（仅 CentOS）：
    
    - 临时关闭（`setenforce 0`）立即生效
    - 永久关闭（修改 `/etc/selinux/config`），重启后完全生效
    - Ubuntu 系统默认无 SELinux，自动跳过
2. **阿里云源替换**：
    
    - 自动备份原软件源（避免误操作无法恢复）
    - 适配 Ubuntu 22.04/24.04+ 和 CentOS 7/8/9 不同版本的源格式
    - 源地址采用阿里云官方镜像，提高软件安装 / 更新速度
3. **系统基础设置**：
    
    - 时区配置：默认设置为 `Asia/Shanghai`，并启用时间同步服务
    - 文件描述符：调整为 65535，避免高并发场景下的限制
    - SSH 优化：禁用 DNS 反向解析，加快 SSH 连接速度
    - 系统监控：启用 `sysstat`，支持 `sar`/`iostat` 等监控命令
4. **软件列表优化**：
    
    - 新增 `rsync`（文件同步）、`lrzsz`（文件上传下载）、`sysstat`（系统监控）等实用工具
    - 保留基础编译工具、网络工具、文本编辑工具

### 使用方法：

1. 保存脚本为 `init_system_v2.sh`
2. 添加执行权限 
    ```bash
    chmod +x init_system_v2.sh
    ```  
3. 切换 root 用户执行：
 
    ```bash
    sudo -i  # 必须 root 用户，否则权限不足
    ./init_system_v2.sh
    ```

### 验证方法：

1. **源替换验证**：
    - Ubuntu：`cat /etc/apt/sources.list` 查看是否为阿里云地址
    - CentOS：`cat /etc/yum.repos.d/CentOS-Base.repo` 查看是否为阿里云地址
2. **SELinux 验证**（CentOS）：
    ```bash
    getenforce  # 输出 Disabled 表示临时生效
    cat /etc/selinux/config | grep SELINUX=disabled  # 有输出表示永久配置生效
    ```
    
3. **时区验证**：
    ```bash
    timedatectl  # 查看 Timezone 是否为 Asia/Shanghai
    ```
    
4. **文件描述符验证**：
    ```bash
    ulimit -n  # 输出 65535 表示配置生效
    ```
    
5. **SSH 验证**：
 
    ```bash
    cat /etc/ssh/sshd_config | grep UseDNS=no  # 有输出表示配置生效
    ```
    

### 注意事项：

1. **生产环境建议**：
    
    - 防火墙关闭后安全性较低，生产环境需根据业务需求配置防火墙规则（如开放 22/80/443 等必要端口）
    - SELinux 关闭后减少了一层安全防护，若需启用，可修改脚本中 `SELINUX=disabled` 为 `SELINUX=enforcing` 并配置相应规则
    - Swap 关闭后依赖物理内存，建议服务器内存 ≥4G 时使用
2. **重启建议**：
    
    - 脚本执行完成后，建议重启系统使所有配置（如 SELinux、swap 永久关闭）完全生效：
        ```bash
        reboot
        ```
        
3. **自定义调整**：
    
    - 时区：修改脚本中 `TIMEZONE` 变量（如 `Europe/London`）
    - 软件列表：修改 `COMMON_PACKAGES` 数组，添加 / 删除需要的软件（如 `docker`、`nginx` 等）
    - 文件描述符：修改 `limits.conf` 中的数值（如 102400）



```bash
#!/bin/bash
set -euo pipefail  # 严格模式：报错即退出，禁止未定义变量，管道错误传递

# ==================== 可配置参数 ====================
# 常用软件列表（按需调整）
COMMON_PACKAGES=(
  wget curl vim net-tools telnet zip unzip tar gcc gcc-c++ make
  chrony git bash-completion tree htop iotop iftop sysstat
  openssh-server rsync lrzsz
)

# 时区配置（默认 Asia/Shanghai）
TIMEZONE="Asia/Shanghai"

# ==================== 工具函数 ====================
info() {
  echo -e "\033[32m[INFO] $1\033[0m"
}

warning() {
  echo -e "\033[33m[WARNING] $1\033[0m"
}

error() {
  echo -e "\033[31m[ERROR] $1\033[0m"
  exit 1
}

# 检测操作系统（精确到版本）
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
  else
    error "无法检测操作系统类型，仅支持 Ubuntu 22.04+ 和 CentOS 7/8/9"
  fi

  # 验证支持的版本
  case $OS in
    ubuntu)
      if ! echo "$VERSION" | grep -E '^22\.04|^24\.04' >/dev/null; then
        error "仅支持 Ubuntu 22.04/24.04+，当前版本：$VERSION"
      fi
      ;;
    centos)
      if ! echo "$VERSION" | grep -E '^7|^8|^9' >/dev/null; then
        error "仅支持 CentOS 7/8/9，当前版本：$VERSION"
      fi
      ;;
    *)
      error "不支持的操作系统：$OS"
      ;;
  esac
}

# ==================== 核心功能 ====================
# 1. 权限校验（必须 root）
check_root() {
  if [ $EUID -ne 0 ]; then
    error "请使用 root 用户执行（sudo -i 切换后运行）"
  fi
}

# 2. 关闭防火墙 + SELinux
disable_security_tools() {
  info "开始关闭防火墙和 SELinux..."

  # 关闭防火墙
  case $OS in
    ubuntu)
      systemctl stop ufw || true
      systemctl disable ufw || true
      systemctl disable 
      info "Ubuntu 防火墙 ufw 已关闭并禁用开机自启"
      ;;
    centos)
      systemctl stop firewalld || true
      systemctl disable firewalld || true
      # 清理 iptables 规则（CentOS 7 兼容）
      iptables -F || true
      info "CentOS 防火墙 firewalld 已关闭并禁用开机自启"
      ;;
  esac

  # 关闭 SELinux（临时+永久）
  if [ $OS = "centos" ]; then
    # 临时关闭（立即生效）
    setenforce 0 2>/dev/null || true
    # 永久关闭（修改配置文件）
    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 2>/dev/null || true
    sed -i 's/^SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config 2>/dev/null || true
    info "CentOS SELinux 已设置为 disabled（重启后完全生效）"
  else
    # Ubuntu 默认无 SELinux，跳过
    info "Ubuntu 系统无需关闭 SELinux"
  fi
}

# 3. 关闭 swap（临时+永久）
disable_swap() {
  info "开始关闭 swap 交换分区..."
  
  # 临时关闭（立即生效）
  swapoff -a || true
  info "临时关闭 swap 成功"
  
  # 永久关闭（注释 fstab 中的 swap 行）
  sed -i '/swap/s/^/#/' /etc/fstab || error "修改 /etc/fstab 失败"
  info "永久关闭 swap 成功（已注释 /etc/fstab 中的 swap 配置）"
  
  # 验证
  if [ $(swapon --show | wc -l) -eq 0 ]; then
    info "swap 状态验证：已完全关闭"
  else
    warning "swap 未完全关闭，请检查系统配置"
  fi
}

# 4. 替换为阿里云软件源
replace_aliyun_repo() {
  info "开始替换为阿里云软件源..."

  # 备份原源（避免误操作无法恢复）
  local repo_backup_dir="/etc/yum.repos.d/backup"
  if [ $OS = "centos" ]; then
    mkdir -p $repo_backup_dir
    mv /etc/yum.repos.d/*.repo $repo_backup_dir/ 2>/dev/null || true
  else
    mv /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null || true
  fi

  # 替换为阿里云源
  case $OS in
    ubuntu)
      # Ubuntu 22.04 (jammy) / 24.04 (noble) 通用源
      cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
EOF
      info "Ubuntu 阿里云源替换完成"
      ;;
    centos)
      if [ "$VERSION" = "7" ]; then
        # CentOS 7 阿里云源
        cat > /etc/yum.repos.d/CentOS-Base.repo <<EOF
[base]
name=CentOS-\$releasever - Base - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-\$releasever - Updates - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-\$releasever - Extras - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
EOF
      else
        # CentOS 8/9 阿里云源（兼容 Stream 版本）
        cat > /etc/yum.repos.d/CentOS-Base.repo <<EOF
[baseos]
name=CentOS-\$releasever - BaseOS - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/centos/\$releasever/BaseOS/\$basearch/os/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-\$releasever

[appstream]
name=CentOS-\$releasever - AppStream - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/centos/\$releasever/AppStream/\$basearch/os/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-\$releasever
EOF
      fi
      info "CentOS 阿里云源替换完成"
      ;;
  esac
}

# 5. 安装常用软件
install_common_packages() {
  info "开始安装常用软件..."
  case $OS in
    ubuntu)
      apt update -y || error "apt 更新源失败"
      apt install -y "${COMMON_PACKAGES[@]}" || error "软件安装失败"
      apt clean  # 清理缓存
      info "Ubuntu 常用软件安装完成"
      ;;
    centos)
      # 清理 yum/dnf 缓存
      if [ "$VERSION" -ge 8 ]; then
        dnf clean all || true
        dnf makecache || error "dnf 缓存生成失败"
        dnf install -y "${COMMON_PACKAGES[@]}" || error "软件安装失败"
      else
        yum clean all || true
        yum makecache || error "yum 缓存生成失败"
        yum install -y "${COMMON_PACKAGES[@]}" || error "软件安装失败"
      fi
      info "CentOS 常用软件安装完成"
      ;;
  esac
}

# 6. 系统基础设置（时区、文件描述符、SSH优化）
system_basic_settings() {
  info "开始配置系统基础设置..."

  # 设置时区（并同步时间）
  timedatectl set-timezone $TIMEZONE || error "时区设置失败"
  # 启用时间同步服务
  if [ $OS = "ubuntu" ]; then
    systemctl start systemd-timesyncd || true
    systemctl enable systemd-timesyncd || true
  else
    systemctl start chronyd || true
    systemctl enable chronyd || true
  fi
  chronyc sync || true  # 强制时间同步
  info "时区已设置为 $TIMEZONE，时间同步完成"

  # 调整最大文件描述符（避免高并发时限制）
  cat >> /etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOF
  info "最大文件描述符已调整为 65535"

  # SSH 优化（禁用 DNS 反向解析，加快连接速度）
  sed -i 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config 2>/dev/null || true
  sed -i 's/^UseDNS yes/UseDNS no/' /etc/ssh/sshd_config 2>/dev/null || true
  systemctl restart sshd || true
  info "SSH 配置优化完成（禁用 DNS 反向解析）"

  # 启用 sysstat 系统监控（CentOS 需额外设置）
  if [ $OS = "centos" ] && [ "$VERSION" = "7" ]; then
    sed -i 's/^ENABLED="false"/ENABLED="true"/' /etc/default/sysstat || true
  fi
  systemctl start sysstat || true
  systemctl enable sysstat || true
  info "sysstat 系统监控已启用"
}

# ==================== 主流程 ====================
main() {
  info "===== 开始初始化系统（支持 Ubuntu 22.04+ / CentOS 7/8/9）====="
  
  # 前置检查
  check_root
  detect_os
  info "检测到操作系统：$OS $VERSION"
  
  # 核心操作（顺序不可随意调整）
  disable_security_tools
  disable_swap
  replace_aliyun_repo
  install_common_packages
  system_basic_settings
  
  info "===== 系统初始化完成 ====="
  info "需要重启才能完全生效的配置："
  info "  1. SELinux 永久关闭（CentOS）"
  info "  2. swap 永久关闭（可选重启，不重启也不影响当前会话）"
  info "生产环境注意：防火墙和 SELinux 已关闭，建议按需配置安全规则"
}

# 执行主流程
main
```

