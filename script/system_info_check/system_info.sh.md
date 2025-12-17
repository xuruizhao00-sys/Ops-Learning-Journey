
- **CPU 使用情况**（包括用户、系统、空闲时间等）
- **内存使用情况**
- **磁盘使用率**
- **网络流量**（上传、下载）
- **系统负载**（1分钟、5分钟、15分钟）
- **进程状态**（检查服务是否运行）
- **系统负载情况**（当前进程数量、运行时间等）

该脚本将包括 **告警机制**，在指标超过设定阈值时，通过 **邮件通知** 系统管理员，方便及时处理系统异常。
### 脚本：

```bash
#!/bin/bash

# =======================================
# 生产级系统巡检脚本
# 功能：定期检查系统的各项性能指标，包括 CPU、内存、磁盘、网络流量、服务进程等。
# 通过邮件发送告警，当负载过高、磁盘满或内存不足时。
# =======================================

# 1. 配置项：阈值设置
HIGH_LOAD_THRESHOLD=1.00      # CPU负载阈值（超过时告警）
HIGH_MEM_USAGE=90             # 内存使用率阈值（超过时告警）
HIGH_DISK_USAGE=90            # 磁盘使用率阈值（超过时告警）
ALERT_EMAIL="admin@example.com"  # 告警邮件接收者

# 2. 定义索引数组：系统性能检查的指标
metrics=("CPU Load" "CPU Usage" "Memory Usage" "Disk Usage" "Network Traffic" "Process Status")

# 3. 定义关联数组：各项监控对应的实际命令
declare -A metric_check=(
    ["CPU Load"]="check_cpu_load"
    ["CPU Usage"]="check_cpu_usage"
    ["Memory Usage"]="check_memory_usage"
    ["Disk Usage"]="check_disk_usage"
    ["Network Traffic"]="check_network_traffic"
    ["Process Status"]="check_process_status"
)

# =======================================
# 4. 定义检查函数
# =======================================

# 检查 CPU Load
check_cpu_load() {
    # 获取 CPU load
    loads=($(uptime | awk -F'load average: ' '{print $2}' | tr ',' ' '))

    # 1min, 5min, 15min
    for i in {0..2}; do
        load=${loads[$i]}
        if (( $(echo "$load > $HIGH_LOAD_THRESHOLD" | bc -l) )); then
            echo "警告: CPU负载超出阈值，当前负载为 $load"
            echo "CPU 负载已达到 $load，请检查系统负载。" | mail -s "CPU Load Alert" "$ALERT_EMAIL"
        fi
    done
}

# 检查 CPU 使用情况
check_cpu_usage() {
    # 获取 CPU 使用情况：用户、系统、空闲
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    if (( $(echo "$cpu_usage > $HIGH_LOAD_THRESHOLD" | bc -l) )); then
        echo "警告: CPU 使用率超出阈值，当前使用率为 $cpu_usage%"
        echo "CPU 使用率已达到 $cpu_usage%，请检查系统 CPU 占用。" | mail -s "CPU Usage Alert" "$ALERT_EMAIL"
    fi
}

# 检查内存使用情况
check_memory_usage() {
    # 获取内存信息
    mem_info=$(free | awk '/Mem/ {print $3/$2 * 100.0}')
    
    if (( $(echo "$mem_info > $HIGH_MEM_USAGE" | bc -l) )); then
        echo "警告: 内存使用率超出阈值，当前使用率为 $mem_info%"
        echo "内存使用率已达到 $mem_info%，请检查内存占用情况。" | mail -s "Memory Usage Alert" "$ALERT_EMAIL"
    fi
}

# 检查磁盘使用情况
check_disk_usage() {
    # 获取磁盘使用情况
    disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if (( disk_usage > $HIGH_DISK_USAGE )); then
        echo "警告: 磁盘使用率超出阈值，当前使用率为 $disk_usage%"
        echo "磁盘使用率已达到 $disk_usage%，请检查磁盘空间。" | mail -s "Disk Usage Alert" "$ALERT_EMAIL"
    fi
}

# 检查网络流量
check_network_traffic() {
    # 获取网络流量数据
    net_stats=$(ifstat -i eth0 1 1 | awk 'NR==3 {print $1, $2}')
    
    echo "网络流量：$net_stats"
    # 可以根据实际需求添加更多判断条件，比如流量阈值告警
}

# 检查进程状态
check_process_status() {
    processes=("nginx" "mysql" "apache2")
    
    for proc in "${processes[@]}"; do
        if ! pgrep -x "$proc" > /dev/null; then
            echo "警告: $proc 进程未运行！"
            echo "$proc 进程未运行，请检查服务状态。" | mail -s "$proc Process Alert" "$ALERT_EMAIL"
        fi
    done
}

# =======================================
# 5. 执行各项检查
# =======================================
for metric in "${metrics[@]}"; do
    echo "开始检查: $metric"
    ${metric_check[$metric]}  # 调用相应的检查函数
done

echo "系统巡检完成！"

# 6. 脚本成功执行
exit 0
```

---

## 代码详细解读

### 1. **配置项**

- 设置了几个阈值：`HIGH_LOAD_THRESHOLD`、`HIGH_MEM_USAGE`、`HIGH_DISK_USAGE`，并通过 `ALERT_EMAIL` 设置告警邮件接收者。

### 2. **定义索引数组与关联数组**

- **`metrics`**：索引数组，用于列出所有要检查的系统指标。
- **`metric_check`**：关联数组，用于映射每个指标和其对应的检查函数。

### 3. **检查函数**
每个检查函数负责：
- 获取当前系统状态。
- 判断是否超出阈值。
- 超出阈值时，发送告警邮件。

#### 示例：

```bash
check_cpu_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$cpu_usage > $HIGH_LOAD_THRESHOLD" | bc -l) )); then
        echo "警告: CPU 使用率超出阈值，当前使用率为 $cpu_usage%"
        echo "CPU 使用率已达到 $cpu_usage%，请检查系统 CPU 占用。" | mail -s "CPU Usage Alert" "$ALERT_EMAIL"
    fi
}
```

### 4. **循环执行所有检查**

- 脚本遍历 `metrics` 数组，依次执行每个性能检查函数。

### 5. **告警通知**

- 当负载超出阈值时，脚本会通过 `mail` 命令发送告警邮件。需要配置好邮件服务。
### 6. **脚本扩展**

- 可以在此基础上继续扩展，加入更多的监控项，定制化告警条件。

---

## 使用方法

### 1. **定时运行**
可以将该脚本添加到 **`crontab`** 中，定期执行巡检：

```bash
crontab -e
```

添加以下定时任务（例如每小时运行一次）：

```bash
0 * * * * /path/to/your/script.sh
```

### 2. **发送告警邮件**
确保系统配置了邮件服务（如 `sendmail`、`msmtp`、`mail` 等），否则告警邮件将无法发送。

### 3. **查看日志**
可以将脚本输出写入日志文件，方便后续查看：

```bash
/path/to/your/script.sh >> /var/log/system_check.log 2>&1
```

---

## 进一步的扩展
根据你的使用场景可以继续进行如下的扩展

- **日志记录**：可以将每次巡检结果记录到日志文件中，方便后续查看。
- **多节点监控**：通过 SSH 在多台服务器上执行此脚本，集中监控。
- **图形化显示**：可以将脚本结果输出到监控平台，进行图形化展示。
    

---
