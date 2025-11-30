```bash
11:30:52 root@redis02:~# cat /usr/lib/systemd/system/redis.service
[Unit]
Description=Redis In-Memory Data Store (v8.2.1)
After=network.target
Documentation=https://redis.io/documentation/
# 依赖 tmpfs 目录（可选，优化内存使用）
RequiresMountsFor=/var/run/redis

[Service]
# 核心：指定运行用户和组（redis 专用用户）
User=redis
Group=redis

# 工作目录（与 redis.conf 中的 dir 一致）
WorkingDirectory=/var/lib/redis

# 启动命令：指定 redis-server 路径和配置文件（必须是绝对路径）
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf

# 停止命令：通过 redis-cli 发送 shutdown 指令（需匹配密码和端口）
# 若未启用 TLS，用以下命令：
ExecStop=/usr/local/bin/redis-cli -h 127.0.0.1 -p 6379 -a 123456  shutdown
# 若启用 TLS，替换为（需指定证书）：
# ExecStop=/usr/local/bin/redis-cli -h 127.0.0.1 -p 6380 -a StrongPass@2025 --tls --cacert /etc/redis/ca-cert.pem shutdown

# 进程异常退出时自动重启（高可用）
Restart=always
RestartSec=3

# PID 文件路径（与 redis.conf 中的 pidfile 一致）
PIDFile=/var/run/redis/redis_6379.pid

# 优化参数：提高文件描述符限制（Redis 并发连接需要）
LimitNOFILE=65536

# 禁用核心转储（避免敏感信息泄露）
LimitCORE=0

# 环境变量（可选，指定 Redis 日志编码）
Environment=LC_ALL=C.UTF-8

[Install]
WantedBy=multi-user.target

```