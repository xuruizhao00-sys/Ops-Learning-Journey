
```bash
#!/bin/bash
set -euo pipefail  # Strict mode: exit on error, unset variable, or pipe failure

# ==================== Configurable Parameters ====================
# Common software packages (adjust as needed)
COMMON_PACKAGES=(
  wget curl vim net-tools telnet zip unzip tar gcc gcc-c++ make
  chrony git bash-completion tree htop iotop iftop sysstat
  openssh-server rsync lrzsz
)

# Timezone configuration (default: Asia/Shanghai)
TIMEZONE="Asia/Shanghai"

# ==================== Utility Functions ====================
# Info message (green)
info() {
  echo -e "\033[32m[INFO] $1\033[0m"
}

# Warning message (yellow)
warning() {
  echo -e "\033[33m[WARNING] $1\033[0m"
}

# Error message (red) and exit
error() {
  echo -e "\033[31m[ERROR] $1\033[0m"
  exit 1
}

# Detect operating system and version
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
  else
    error "Failed to detect OS type. Only supports Ubuntu 22.04+ and CentOS 7/8/9"
  fi

  # Validate supported versions
  case $OS in
    ubuntu)
      if ! echo "$VERSION" | grep -E '^22\.04|^24\.04' >/dev/null; then
        error "Only supports Ubuntu 22.04/24.04+. Current version: $VERSION"
      fi
      ;;
    centos)
      if ! echo "$VERSION" | grep -E '^7|^8|^9' >/dev/null; then
        error "Only supports CentOS 7/8/9. Current version: $VERSION"
      fi
      ;;
    *)
      error "Unsupported operating system: $OS"
      ;;
  esac
}

# ==================== Core Functions ====================
# 1. Check if running as root (required for system modifications)
check_root() {
  if [ $EUID -ne 0 ]; then
    error "Please run this script as root (switch with 'sudo -i' first)"
  fi
}

# 2. Disable firewall and SELinux
disable_security_tools() {
  info "Starting to disable firewall and SELinux..."

  # Disable firewall
  case $OS in
    ubuntu)
      systemctl stop ufw || true
      systemctl disable ufw || true
      info "Ubuntu firewall (ufw) has been stopped and disabled on boot"
      ;;
    centos)
      systemctl stop firewalld || true
      systemctl disable firewalld || true
      # Clear iptables rules (compatible with CentOS 7)
      iptables -F || true
      info "CentOS firewall (firewalld) has been stopped and disabled on boot"
      ;;
  esac

  # Disable SELinux (temporary + permanent) - only for CentOS
  if [ $OS = "centos" ]; then
    # Temporary disable (takes effect immediately)
    setenforce 0 2>/dev/null || true
    # Permanent disable (modify config file)
    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 2>/dev/null || true
    sed -i 's/^SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config 2>/dev/null || true
    info "CentOS SELinux has been set to disabled (fully takes effect after reboot)"
  else
    # Ubuntu doesn't have SELinux by default, skip
    info "No need to disable SELinux on Ubuntu systems"
  fi
}

# 3. Disable swap partition (temporary + permanent)
disable_swap() {
  info "Starting to disable swap partition..."
  
  # Temporary disable (takes effect immediately)
  swapoff -a || true
  info "Temporary swap disable successful"
  
  # Permanent disable (comment out swap line in fstab)
  sed -i '/swap/s/^/#/' /etc/fstab || error "Failed to modify /etc/fstab"
  info "Permanent swap disable successful (swap entry commented in /etc/fstab)"
  
  # Verify swap status
  if [ $(swapon --show | wc -l) -eq 0 ]; then
    info "Swap verification: Fully disabled"
  else
    warning "Swap not fully disabled. Please check system configuration"
  fi
}

# 4. Replace default repo with Alibaba Cloud mirrors
replace_aliyun_repo() {
  info "Starting to replace software sources with Alibaba Cloud mirrors..."

  # Backup original repos (prevent data loss)
  local repo_backup_dir="/etc/yum.repos.d/backup"
  if [ $OS = "centos" ]; then
    mkdir -p $repo_backup_dir
    mv /etc/yum.repos.d/*.repo $repo_backup_dir/ 2>/dev/null || true
  else
    mv /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null || true
  fi

  # Replace with Alibaba Cloud repos
  case $OS in
    ubuntu)
      # Universal repo for Ubuntu 22.04 (jammy) / 24.04 (noble)
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
      info "Ubuntu Alibaba Cloud repo replacement completed"
      ;;
    centos)
      if [ "$VERSION" = "7" ]; then
        # Alibaba Cloud repo for CentOS 7
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
        # Alibaba Cloud repo for CentOS 8/9 (compatible with Stream versions)
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
      info "CentOS Alibaba Cloud repo replacement completed"
      ;;
  esac
}

# 5. Install common software packages
install_common_packages() {
  info "Starting to install common software packages..."
  case $OS in
    ubuntu)
      apt update -y || error "Failed to update apt repositories"
      apt install -y "${COMMON_PACKAGES[@]}" || error "Failed to install software packages"
      apt clean  # Clean up cache to save disk space
      info "Ubuntu common software installation completed"
      ;;
    centos)
      # Clean yum/dnf cache
      if [ "$VERSION" -ge 8 ]; then
        dnf clean all || true
        dnf makecache || error "Failed to generate dnf cache"
        dnf install -y "${COMMON_PACKAGES[@]}" || error "Failed to install software packages"
      else
        yum clean all || true
        yum makecache || error "Failed to generate yum cache"
        yum install -y "${COMMON_PACKAGES[@]}" || error "Failed to install software packages"
      fi
      info "CentOS common software installation completed"
      ;;
  esac
}

# 6. Basic system configurations (timezone, file descriptors, SSH optimization)
system_basic_settings() {
  info "Starting basic system configuration..."

  # Set timezone and sync time
  timedatectl set-timezone $TIMEZONE || error "Failed to set timezone"
  # Enable time synchronization service
  if [ $OS = "ubuntu" ]; then
    systemctl start systemd-timesyncd || true
    systemctl enable systemd-timesyncd || true
  else
    systemctl start chronyd || true
    systemctl enable chronyd || true
  fi
  chronyc sync || true  # Force time synchronization
  info "Timezone set to $TIMEZONE. Time synchronization completed"

  # Adjust maximum file descriptors (avoid limits in high-concurrency scenarios)
  cat >> /etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOF
  info "Maximum file descriptors adjusted to 65535"

  # SSH optimization: Disable DNS reverse resolution (speed up connection)
  sed -i 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config 2>/dev/null || true
  sed -i 's/^UseDNS yes/UseDNS no/' /etc/ssh/sshd_config 2>/dev/null || true
  systemctl restart ssh || true
  info "SSH configuration optimized (DNS reverse resolution disabled)"

  # Enable sysstat system monitoring (extra config for CentOS 7)
  if [ $OS = "centos" ] && [ "$VERSION" = "7" ]; then
    sed -i 's/^ENABLED="false"/ENABLED="true"/' /etc/default/sysstat || true
  fi
  systemctl start sysstat || true
  systemctl enable sysstat || true
  info "sysstat system monitoring enabled"
}

# 7. Disable Ubuntu automatic updates (Ubuntu-only feature)
disable_ubuntu_auto_update() {
  if [ $OS = "ubuntu" ]; then
    info "Starting to disable Ubuntu automatic update services..."
    
    # 1. Stop and disable core auto-update services/timers
    local auto_update_services=(
      apt-daily.service        # Daily update service
      apt-daily.timer          # Daily update timer
      apt-daily-upgrade.service # System upgrade service
      apt-daily-upgrade.timer  # System upgrade timer
      unattended-upgrades.service # Unattended upgrade service
    )
    
    for service in "${auto_update_services[@]}"; do
      systemctl stop "$service" || true
      systemctl disable "$service" || true
      systemctl mask "$service" || true  # Prevent accidental activation by other services
    done
    info "Auto-update related services stopped, disabled, and masked"
    
    # 2. Disable unattended-upgrades configuration
    if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
      mv /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades.bak || true
      # Write empty config to fully disable
      cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF
    fi
    info "unattended-upgrades auto-update configuration disabled"
    
    # 3. Uninstall unattended-upgrades package (optional, backup solution)
    apt remove -y unattended-upgrades || true
    apt autoremove -y || true
    info "Ubuntu automatic updates fully disabled"
  else
    info "CentOS has no default auto-update service. Skipping this step"
  fi
}

# ==================== Main Workflow ====================
main() {
  info "===== Starting System Initialization (Ubuntu 22.04+/CentOS 7/8/9) ====="
  
  # Pre-checks
  check_root
  detect_os
  info "Detected operating system: $OS $VERSION"
  
  # Core operations (order matters)
  disable_security_tools
  disable_swap
  replace_aliyun_repo
  install_common_packages
  system_basic_settings
  disable_ubuntu_auto_update  # New: Disable Ubuntu auto-updates
  
  info "===== System Initialization Completed ====="
  info "Configurations requiring reboot to take full effect:"
  info "  1. Permanent SELinux disable (CentOS)"
  info "  2. Permanent swap disable (reboot optional, no impact on current session)"
  info "Production Environment Notes:"
  info "  - Firewall and SELinux are disabled. Configure security rules as needed"
  info "  - Ubuntu auto-updates are disabled. Run 'apt update && apt upgrade' manually for updates"
}

# Execute main workflow
main
```

### Key Features (Same as Chinese Version):

1. **Root Check**: Ensures the script runs with root privileges
2. **OS Detection**: Automatically identifies Ubuntu/CentOS and validates versions
3. **Security Tools**: Disables firewall (ufw/firewalld) and SELinux (CentOS-only)
4. **Swap Disable**: Temporary (immediate) + permanent (fstab modification)
5. **Repo Replacement**: Switches to Alibaba Cloud mirrors (faster in China)
6. **Common Software**: Installs essential tools for system administration
7. **System Tuning**: Timezone setup, file descriptor adjustment, SSH optimization
8. **Auto-update Disable**: Fully disables Ubuntu's automatic update services
### Usage Instructions:

1. Save as `init_system_en.sh`
2. Add execution permission:
    
    ```bash
    chmod +x init_system_en.sh
    ```
    
1. Run as root:
    ```bash
    sudo -i
    ./init_system_en.sh
    ```

### Verification Commands:
- **Repo Check**:
    - Ubuntu: `cat /etc/apt/sources.list`
    - CentOS: `cat /etc/yum.repos.d/CentOS-Base.repo`
- **SELinux Check** (CentOS): `getenforce` (should return `Disabled`)
- **Swap Check**: `swapon --show` (no output = disabled)
- **Auto-update Check** (Ubuntu): `systemctl status unattended-upgrades.service` (should show `masked`)
- **Timezone Check**: `timedatectl` (verify `Timezone: Asia/Shanghai`)

### Notes for Production:

- Re-enable firewall/SELinux with custom rules for production environments
- Manually update systems regularly after disabling auto-updates
- Ensure sufficient physical memory (≥4GB) if swap is disabled
- Adjust the `COMMON_PACKAGES` array or `TIMEZONE` variable as needed for your use case