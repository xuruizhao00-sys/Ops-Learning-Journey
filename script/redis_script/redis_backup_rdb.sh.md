以下是一个完成 Redis RDB 手动备份脚本

```bash
#!/bin/bash
##############################################################################
# Redis RDB 手动备份脚本
# 功能：执行异步BGSAVE、验证备份状态、备份文件归档、旧备份清理
# 依赖：redis-cli（需在PATH中或指定完整路径）
##############################################################################

# ========================= 基础配置（根据实际环境修改）=========================
REDIS_HOST="127.0.0.1"          # Redis主机地址
REDIS_PORT=6379                 # Redis端口
REDIS_PASSWORD="your_password"  # Redis密码（无密码则设为空字符串 ""）
REDIS_DB=0                      # 备份的数据库（0为默认，RDB默认备份所有库）
RDB_FILENAME="dump.rdb"         # Redis配置的RDB文件名（默认dump.rdb）
REDIS_DATA_DIR="/var/lib/redis" # Redis数据目录（需与redis.conf中dir配置一致）

BACKUP_DIR="/data/redis/backup" # 备份文件存放目录
RETENTION_DAYS=7                # 备份保留天数（超过自动删除）
LOG_FILE="/var/log/redis_backup.log" # 日志文件路径
##############################################################################

# ========================= 脚本内部变量（无需修改）=========================
CURRENT_TIME=$(date +"%Y%m%d_%H%M%S")  # 当前时间戳（用于备份文件名）
BACKUP_FILENAME="redis_rdb_backup_${CURRENT_TIME}.rdb"  # 备份文件名
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILENAME}"           # 完整备份路径
REDIS_CLI_CMD="redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT}"  # redis-cli基础命令

# ========================= 日志函数（统一日志格式）=========================
log() {
    local level=$1
    local message=$2
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [${level}] - ${message}" >> "${LOG_FILE}"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [${level}] - ${message}"  # 同时输出到控制台
}

# ========================= 前置检查（确保环境可用）=========================
pre_check() {
    log "INFO" "开始执行Redis RDB备份前置检查"

    # 1. 检查redis-cli是否存在
    if ! command -v ${REDIS_CLI_CMD% *} &> /dev/null; then
        log "ERROR" "未找到redis-cli，请确保其在PATH中或修改脚本中的REDIS_CLI_CMD"
        exit 1
    fi

    # 2. 检查Redis连接状态
    if [ -n "${REDIS_PASSWORD}" ]; then
        CONNECT_TEST=$(${REDIS_CLI_CMD} -a "${REDIS_PASSWORD}" ping 2>/dev/null)
    else
        CONNECT_TEST=$(${REDIS_CLI_CMD} ping 2>/dev/null)
    fi

    if [ "${CONNECT_TEST}" != "PONG" ]; then
        log "ERROR" "Redis连接失败（主机：${REDIS_HOST}:${REDIS_PORT}，密码：${REDIS_PASSWORD:-(无)}）"
        exit 1
    fi

    # 3. 检查Redis数据目录是否存在
    if [ ! -d "${REDIS_DATA_DIR}" ]; then
        log "ERROR" "Redis数据目录不存在：${REDIS_DATA_DIR}（请与redis.conf中的dir配置一致）"
        exit 1
    fi

    # 4. 检查RDB文件是否存在
    if [ ! -f "${REDIS_DATA_DIR}/${RDB_FILENAME}" ]; then
        log "WARNING" "当前未找到RDB文件：${REDIS_DATA_DIR}/${RDB_FILENAME}，将执行首次备份"
    fi

    # 5. 检查备份目录是否存在，不存在则创建
    if [ ! -d "${BACKUP_DIR}" ]; then
        log "INFO" "备份目录不存在，创建目录：${BACKUP_DIR}"
        mkdir -p "${BACKUP_DIR}" || {
            log "ERROR" "创建备份目录失败：${BACKUP_DIR}"
            exit 1
        }
    fi

    log "INFO" "前置检查通过，开始执行备份"
}

# ========================= 执行RDB备份（异步BGSAVE）=========================
execute_backup() {
    log "INFO" "开始执行Redis BGSAVE命令（异步备份，不阻塞Redis）"

    # 执行BGSAVE命令
    if [ -n "${REDIS_PASSWORD}" ]; then
        BGSAVE_RESULT=$(${REDIS_CLI_CMD} -a "${REDIS_PASSWORD}" bgsave 2>/dev/null)
    else
        BGSAVE_RESULT=$(${REDIS_CLI_CMD} bgsave 2>/dev/null)
    fi

    # 检查BGSAVE命令是否提交成功
    if [ "${BGSAVE_RESULT}" != "Background saving started" ]; then
        log "ERROR" "BGSAVE命令执行失败，返回结果：${BGSAVE_RESULT:-未知错误}"
        exit 1
    fi

    log "INFO" "BGSAVE命令已提交，等待备份完成..."

    # 等待备份完成（轮询检查备份状态）
    BACKUP_COMPLETED=0
    MAX_WAIT_SECONDS=3600  # 最大等待时间（1小时）
    WAIT_SECONDS=0

    while [ ${BACKUP_COMPLETED} -eq 0 ] && [ ${WAIT_SECONDS} -lt ${MAX_WAIT_SECONDS} ]; do
        # 获取Redis备份状态
        if [ -n "${REDIS_PASSWORD}" ]; then
            INFO_RESULT=$(${REDIS_CLI_CMD} -a "${REDIS_PASSWORD}" info persistence 2>/dev/null)
        else
            INFO_RESULT=$(${REDIS_CLI_CMD} info persistence 2>/dev/null)
        fi

        # 提取rdb_bgsave_in_progress状态（1=备份中，0=备份完成）
        BGSAVE_IN_PROGRESS=$(echo "${INFO_RESULT}" | grep "rdb_bgsave_in_progress:" | awk -F: '{print $2}' | tr -d '[:space:]')
        
        if [ "${BGSAVE_IN_PROGRESS}" == "0" ]; then
            # 检查备份是否成功（rdb_last_bgsave_status=ok）
            BGSAVE_STATUS=$(echo "${INFO_RESULT}" | grep "rdb_last_bgsave_status:" | awk -F: '{print $2}' | tr -d '[:space:]')
            if [ "${BGSAVE_STATUS}" == "ok" ]; then
                log "INFO" "Redis BGSAVE备份完成"
                BACKUP_COMPLETED=1
            else
                log "ERROR" "BGSAVE备份失败，状态：${BGSAVE_STATUS}"
                exit 1
            fi
        else
            # 每10秒检查一次
            sleep 10
            WAIT_SECONDS=$((WAIT_SECONDS + 10))
            log "INFO" "备份中，已等待${WAIT_SECONDS}秒（最大${MAX_WAIT_SECONDS}秒）"
        fi
    done

    # 检查是否超时
    if [ ${WAIT_SECONDS} -ge ${MAX_WAIT_SECONDS} ]; then
        log "ERROR" "BGSAVE备份超时（超过${MAX_WAIT_SECONDS}秒）"
        exit 1
    fi
}

# ========================= 备份文件归档（复制+校验）=========================
archive_backup() {
    log "INFO" "开始归档备份文件"

    # 复制RDB文件到备份目录（保留原文件，避免影响Redis）
    cp -f "${REDIS_DATA_DIR}/${RDB_FILENAME}" "${BACKUP_PATH}" || {
        log "ERROR" "复制RDB文件失败：${REDIS_DATA_DIR}/${RDB_FILENAME} -> ${BACKUP_PATH}"
        exit 1
    }

    # 校验备份文件（检查文件大小是否正常）
    SOURCE_SIZE=$(du -b "${REDIS_DATA_DIR}/${RDB_FILENAME}" | awk '{print $1}')
    BACKUP_SIZE=$(du -b "${BACKUP_PATH}" | awk '{print $1}')

    if [ "${SOURCE_SIZE}" -ne "${BACKUP_SIZE}" ]; then
        log "WARNING" "备份文件大小与源文件不一致（源：${SOURCE_SIZE}字节，备份：${BACKUP_SIZE}字节），可能备份损坏"
    else
        log "INFO" "备份文件归档成功：${BACKUP_PATH}（大小：${SOURCE_SIZE}字节）"
    fi
}

# ========================= 清理旧备份（按保留天数删除）=========================
clean_old_backups() {
    if [ ${RETENTION_DAYS} -le 0 ]; then
        log "INFO" "保留天数设置为${RETENTION_DAYS}，不清理旧备份"
        return
    fi

    log "INFO" "开始清理${RETENTION_DAYS}天前的旧备份"

    # 删除备份目录中超过保留天数的.rdb备份文件
    find "${BACKUP_DIR}" -name "redis_rdb_backup_*.rdb" -type f -mtime +${RETENTION_DAYS} -delete || {
        log "ERROR" "清理旧备份失败"
        # 清理失败不终止脚本，仅记录警告
        return 1
    }

    # 统计剩余备份数量
    REMAIN_BACKUPS=$(find "${BACKUP_DIR}" -name "redis_rdb_backup_*.rdb" -type f | wc -l)
    log "INFO" "旧备份清理完成，当前剩余备份数量：${REMAIN_BACKUPS}"
}

# ========================= 主流程执行 =========================
main() {
    pre_check                # 前置检查
    execute_backup           # 执行BGSAVE备份
    archive_backup           # 归档备份文件
    clean_old_backups        # 清理旧备份
    log "INFO" "Redis RDB手动备份执行完成！"
    exit 0
}

# 启动主流程
main
```

### 脚本核心特性
1. **安全备份**：使用 `BGSAVE` 异步备份，不阻塞Redis服务（生产环境推荐）
2. **完善校验**：
   - 前置检查（redis-cli可用性、Redis连接、目录权限）
   - 备份状态轮询（确保备份完成）
   - 文件大小校验（避免备份损坏）
3. **灵活配置**：支持Redis主机、端口、密码、数据目录、备份目录、保留天数自定义
4. **日志记录**：详细日志输出（控制台+文件），便于问题排查
5. **自动清理**：按保留天数自动删除旧备份，避免磁盘占满
6. **兼容性强**：支持有密码/无密码Redis，适配大多数Linux环境

### 使用说明
#### 1. 前置准备
- 确保Redis已启用RDB持久化（默认启用，`redis.conf` 中 `save` 配置生效）
- 确认 `redis-cli` 已安装且在PATH中（或修改脚本中的 `REDIS_CLI_CMD` 为完整路径）
- 脚本执行用户需具备以下权限：
  - 读取Redis数据目录（`REDIS_DATA_DIR`）的权限
  - 写入备份目录（`BACKUP_DIR`）的权限
  - 执行 `redis-cli` 的权限

#### 2. 配置修改（必做）
根据你的Redis环境修改脚本头部的 **基础配置** ：
```bash
REDIS_HOST="127.0.0.1"          # 你的Redis主机（如远程需填IP）
REDIS_PORT=6379                 # 你的Redis端口
REDIS_PASSWORD="your_password"  # 你的Redis密码（无密码则设为 ""）
REDIS_DATA_DIR="/var/lib/redis" # Redis数据目录（需与redis.conf中dir一致）
BACKUP_DIR="/data/redis/backup" # 备份文件存放目录（自定义）
RETENTION_DAYS=7                # 备份保留7天（可调整）
```

#### 3. 脚本执行
```bash
# 1. 赋予脚本执行权限
chmod +x redis_rdb_backup.sh

# 2. 手动执行备份
./redis_rdb_backup.sh

# 3. （可选）添加到定时任务（如每天凌晨3点执行）
crontab -e
# 添加一行：
0 3 * * * /path/to/redis_rdb_backup.sh
```

#### 4. 验证备份结果
- 查看日志文件：`cat /var/log/redis_backup.log`
- 查看备份文件：`ls -l /data/redis/backup/`（备份文件名为 `redis_rdb_backup_时间戳.rdb`）

### 常见问题排查
1. **Redis连接失败**：
   - 检查Redis主机、端口是否正确
   - 检查密码是否正确（无密码需设为 `""`）
   - 检查Redis是否允许远程连接（如远程需修改 `redis.conf` 的 `bind` 和 `protected-mode`）

2. **BGSAVE执行失败**：
   - 检查Redis是否正在执行其他BGSAVE/FORK操作
   - 检查系统内存是否充足（FORK操作需要足够的空闲内存）
   - 查看Redis日志（`redis.conf` 中 `logfile` 配置）获取详细错误

3. **备份文件复制失败**：
   - 检查执行用户是否有Redis数据目录的读取权限
   - 检查备份目录是否有写入权限

4. **旧备份清理失败**：
   - 检查执行用户是否有备份目录的删除权限
   - 确认备份文件名格式是否为 `redis_rdb_backup_*.rdb`（脚本仅清理该格式文件）

### 注意事项
- RDB备份是全量备份，适用于数据量不大（GB级以下）的场景
- 备份过程中Redis会FORK子进程，可能会短暂占用额外内存，建议在业务低峰期执行
- 定期验证备份文件的可用性（可通过 `redis-server --dbfilename 备份文件 --dir 临时目录` 启动验证）
- 重要数据建议结合AOF持久化（`appendonly yes`），提高数据安全性