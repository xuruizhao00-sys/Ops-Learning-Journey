# 一、数据库简介与安装
## 1.1 什么是数据库
数据库是一个系统化的、结构化的数据集合，旨在帮助我们存储、管理和查询数据。数据库通过数据表来组织数据，而表中有若干列（字段），每一行表示一条记录。数据库通常包括数据库管理系统（DBMS）用于管理数据库的操作，如查询、更新、备份等。
## 1.2 MySQL 发展历史
MySQL 是由瑞典 MySQL AB 公司开发的开源关系型数据库管理系统（RDBMS）。MySQL 于1995年首次发布，并成为最受欢迎的开源数据库之一。

- **1995年**：MySQL由 Michael "Monty" Widenius 和 David Axmark 开发，最初的目的是为了提供一个轻量级的数据库系统，满足快速数据存取的需求。
- **2008年**：Sun Microsystems 收购 MySQL。
- **2009年**：Oracle Corporation 收购了 Sun Microsystems，因此 MySQL 归属于 Oracle。
## 1.3 MySQL 与其他数据库（如 PostgreSQL、SQLite）比较
MySQL、PostgreSQL 和 SQLite 是常见的三种关系型数据库，它们各自有不同的特性。

|特性|MySQL|PostgreSQL|SQLite|
|---|---|---|---|
|**许可协议**|开源（GPL）|开源（PostgreSQL许可）|公共领域|
|**事务支持**|支持（通过 InnoDB 引擎）|支持（ACID 完整支持）|支持（ACID 完整支持）|
|**查询优化**|通过索引优化、查询缓存等|强大的查询优化器|优化较少|
|**扩展性**|支持水平扩展，支持复制|支持高级扩展、数据类型扩展|非常有限，适用于轻量级应用|
|**性能**|适合高并发、读密集型应用|适合复杂查询、写密集型应用|适合单机、小型应用|
|**存储引擎**|支持多种引擎（如 InnoDB、MyISAM）|单一引擎（堆栈存储）|无多引擎概念|
<mark style="background: #FF5582A6;">总结</mark>
- **MySQL** 适合高并发、读密集型应用，支持灵活的存储引擎。
- **PostgreSQL** 是功能最全的关系型数据库，适用于复杂查询、事务处理。
- **SQLite** 是轻量级数据库，适合嵌入式应用或小型项目。
## 1.4 MySQL 架构概述
### 1.4.1 客户端/服务器架构（c/s）
MySQL 是基于 **客户端/服务器架构** 设计的，这意味着 MySQL 的客户端和服务器是分离的，客户端发起请求，而服务器处理请求并返回结果。这个架构允许用户和应用程序通过网络连接到数据库，而不需要直接访问数据库的本地文件。
#### 1.4.1.1 客户端/服务器架构流程
- **客户端**：客户端可以是命令行工具、图形化工具（如 MySQL Workbench）、应用程序等，主要负责：
    - 向服务器发起查询请求
    - 接收查询结果并展示给用户
- **服务器**：MySQL 服务器接收客户端的请求并执行以下任务：
    - 解析查询请求
    - 执行 SQL 语句
    - 返回结果给客户端
- **连接与协议**：MySQL 使用一个专用的协议（MySQL Protocol）来实现客户端和服务器之间的通信，常用的协议是 TCP/IP，当然也支持 UNIX 套接字连接。
```bash
      +-----------------------+
      |    MySQL Client       |
      |-----------------------|
      |   - Command Line      |
      |   - MySQL Workbench   |
      |   - Application       |
      +-----------------------+
                |
                | 发送查询请求 (SQL)
                v
      +-----------------------+
      |   MySQL Server        |
      |-----------------------|
      |   - 查询解析器        |
      |   - 优化器            |
      |   - 执行引擎          |
      |   - 存储引擎          |
      +-----------------------+
                |
                | 返回查询结果
                v
      +-----------------------+
      |    MySQL Client       |
      +-----------------------+

```
#### 1.4.1.2 主要组成部分
- **MySQL 客户端**：负责发送 SQL 查询给 MySQL 服务器，接收结果并展示给用户。客户端可以通过命令行、应用程序或图形化工具来执行查询。
- **MySQL 服务器**：接收客户端请求并执行以下工作：
    - **查询解析器**：解析 SQL 查询，检查语法是否正确。
    - **查询优化器**：优化查询，决定查询的执行计划（如选择合适的索引）。
    - **执行引擎**：执行 SQL 语句的具体操作。
    - **存储引擎**：执行数据的存储与检索操作（如 InnoDB、MyISAM 等）
### 1.4.2 存储引擎
MySQL 的存储引擎是 MySQL 服务器处理数据存储的核心组件。每个存储引擎有不同的特性和优化方式，常见的存储引擎包括 **InnoDB** 和 **MyISAM**。
#### 1.4.2.1 InnoDB 存储引擎
- **事务支持**：InnoDB 支持 ACID 事务（原子性、一致性、隔离性、持久性）。
- **行级锁**：InnoDB 支持行级锁，能在并发环境下提高性能。
- **外键约束**：InnoDB 支持外键约束，保证数据的完整性。
- **数据存储**：InnoDB 使用聚簇索引（Clustered Index），数据行存储在索引中。
#### 1.4.2.2 MyISAM 存储引擎
- **表级锁**：MyISAM 只支持表级锁，在高并发环境下可能导致性能问题。
- **没有事务支持**：MyISAM 不支持事务处理，不适用于需要事务支持的应用。
- **快速读取**：MyISAM 适用于读密集型应用，查询速度较快。
#### 1.4.2.3 其他存储引擎
除了 InnoDB 和 MyISAM，MySQL 还支持其他存储引擎，如 MEMORY（用于内存中的临时数据存储）、CSV（用于导入和导出数据）等。
```bash
      +---------------------------+
      |     MySQL Server          |
      |---------------------------|
      |  - 查询解析器             |
      |  - 查询优化器             |
      |  - 执行引擎               |
      +---------------------------+
                |
                | 
        +---------------+           +---------------+
        |  InnoDB       |          |  MyISAM       |
        |  存储引擎     |           |  存储引擎     |
        |  支持事务、行级锁 |    |  表级锁、无事务 |
        +---------------+           +---------------+
                |
                | 
        +----------------------+
        | 数据存储与索引管理    |
        +----------------------+

```
#### 1.4.2.3 存储引擎的选择
- **InnoDB**：如果应用程序需要支持事务处理、外键约束以及高并发写操作，选择 InnoDB 引擎。
- **MyISAM**：适用于需要快速读取的应用，如日志数据存储等不需要事务支持的场景。
### 1.4.3 MySQL 的查询处理流程
MySQL 的查询处理流程可以分为以下几个步骤：

1. **解析**：当客户端发送一个查询请求时，MySQL 会首先检查 SQL 语法，确保 SQL 查询合法。
2. **优化**：查询优化器生成查询执行计划，选择最有效的查询方式和索引。
3. **执行**：执行引擎根据优化器提供的执行计划进行数据操作。
4. **存储引擎**：执行引擎将请求传递给存储引擎，存储引擎负责实际的数据存储与检索。
```bash
    +-------------------+
    |   SQL 查询请求    |
    +-------------------+
              |
              v
    +-------------------+
    |   解析器（Parser） |
    +-------------------+
              |
              v
    +-------------------+
    | 查询优化器（Optimizer）|
    +-------------------+
              |
              v
    +-------------------+
    | 执行引擎（Executor）  |
    +-------------------+
              |
              v
    +-------------------+
    | 存储引擎（Storage Engine） |
    +-------------------+
              |
              v
    +-------------------+
    | 数据存储与检索    |
    +-------------------+

```
### 1.4.4 MySQL 网络协议流程
MySQL 服务器与客户端之间的通信通过 **MySQL 网络协议** 进行。默认情况下，MySQL 通过 TCP/IP 协议进行通信，端口号为 **3306**。

#### 1.4.4.1 MySQL 网络协议流程

1. **连接建立**：客户端通过 TCP/IP 协议连接到 MySQL 服务器，服务器验证客户端的身份。
2. **数据交换**：客户端发送 SQL 查询请求，服务器返回执行结果。
3. **连接关闭**：数据交换完成后，客户端与服务器关闭连接。
#### 1.4.4.2 MySQL 协议流程
```bash
    +---------------------+ 
    |   MySQL Client      |
    +---------------------+
               |
               | 通过 TCP/IP 连接
               v
    +---------------------+
    |    MySQL Server     |
    +---------------------+
               |
               | 数据交互
               v
    +---------------------+
    |   MySQL Client      |
    +---------------------+

```
## 1.5 MySQL 安装与配置
### 1.5.1 MySQL 安装
MySQL 可以通过多种方式进行安装，具体的安装方式取决于操作系统和用户的需求。常见的安装方式包括 **包管理器安装**、**二进制安装**、以及 **源码编译安装**
#### 1.5.1.1 包管理安装（适用于 Linux）
##### 1.5.1.1.1 在 Ubuntu/Debian 上安装 MySQL
使用包管理工具 `apt` 来安装 MySQL。
```bash
# 更新软件源
14:14:22 root@redis02:~# apt update

# 安装 MySQL 服务器
14:15:59 root@redis02:~# apt install mysql-server -y

# 启动 MySQL 服务器
14:41:04 root@redis02:~# systemctl start mysql
14:41:11 root@redis02:~# systemctl status  mysql
● mysql.service - MySQL Community Server
     Loaded: loaded (/usr/lib/systemd/system/mysql.service; enabled; preset: enabled)
     Active: active (running) since Fri 2025-12-19 14:28:29 CST; 12min ago
    Process: 40016 ExecStartPre=/usr/share/mysql/mysql-systemd-start pre (code=exited, status=0/SUCCESS)
   Main PID: 40030 (mysqld)
     Status: "Server is operational"
      Tasks: 37 (limit: 2210)
     Memory: 361.6M (peak: 378.7M)
        CPU: 1min 21.826s
     CGroup: /system.slice/mysql.service
             └─40030 /usr/sbin/mysqld

Dec 19 14:27:46 redis02 systemd[1]: Starting mysql.service - MySQL Community Server...
Dec 19 14:28:29 redis02 systemd[1]: Started mysql.service - MySQL Community Server.

# 安全配置（可选）
mysql_secure_installation

# 登录 MySQL
14:48:41 root@redis02:~# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 8.0.44-0ubuntu0.24.04.2 (Ubuntu)

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select version();
+-------------------------+
| version()               |
+-------------------------+
| 8.0.44-0ubuntu0.24.04.2 |
+-------------------------+
1 row in set (0.01 sec)

mysql> 
```
##### 1.5.1.1.2 在 CentOS/RHEL 上安装 MySQL
```bash
# 添加 MySQL 官方仓库
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

# 安装 MySQL 服务器
yum install mysql-server -y

# 启动 MySQL
systemctl start mysqld
systemctl status mysqld

# 安全配置
mysql_secure_installation

# 登录 MySQL
mysql
```
#### 1.5.1.2 二进制安装（适用于 Linux / macOS / Windows）
如果你不想使用包管理器安装，或者你想手动控制安装过程，可以选择 **二进制安装**。这种方法适用于所有操作系统，尤其适合需要定制化安装的用户。

传统的二进制包安装需要进行三步：configure --- make  --- make install
而mysql的二进制包是指己经编译完成【也就是说，make 已经做过了】，以压缩包提供下载的文件，下载到本地之后释放到自定义目录，再进行配置即可。
##### 1.5.1.2.1 如何获取二进制包
关于二进制包的下载位置 -- Download Archives
https://downloads.mysql.com/archives/community/
![](assets/mysql_manager/file-20251219150929263.png)
![](assets/mysql_manager/file-20251219150952447.png)
##### 1.5.1.2.2 在 Ubuntu 中安装 MySQL8.4.0
###### 1.5.1.2.2.1 安装必要依赖
```bash
# Rocky系统：

[root@rocky9 ~]# yum -y install libaio numactl-libs ncurses-compat-libs

# Ubuntu系统：

root@ubuntu24:~# apt install libaio-dev numactl libnuma-dev libncurses-dev
```
注意：ubuntu24 系统没有 libaio1 的包，需要单独去下载安装
```bash
15:17:59 root@redis02:~# curl -O http://launchpadlibrarian.net/646633572/libaio1_0.3.113-4_amd64.deb
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6520  100  6520    0     0   2829      0  0:00:02  0:00:02 --:--:--  2831
15:20:17 root@redis02:~# ls
aa.sh  init.sh  libaio1_0.3.113-4_amd64.deb  test.sh
15:20:19 root@redis02:~# dpkg -i libaio1_0.3.113-4_amd64.deb 
Selecting previously unselected package libaio1:amd64.
(Reading database ... 88359 files and directories currently installed.)
Preparing to unpack libaio1_0.3.113-4_amd64.deb ...
Unpacking libaio1:amd64 (0.3.113-4) ...
Setting up libaio1:amd64 (0.3.113-4) ...
Processing triggers for libc-bin (2.39-0ubuntu8.6) ...
```
###### 1.5.1.2.2.2 用户管理
创建用户组和用户
```bash
15:20:49 root@redis03:~# groupadd -r mysql
15:21:23 root@redis03:~# useradd -r -g mysql -s /sbin/nologin mysql
15:21:38 root@redis03:~# getent passwd mysql
mysql:x:999:988::/home/mysql:/sbin/nologin
15:21:42 root@redis03:~# 
```
###### 1.5.1.2.2.3 MySQL 目录配置
```bash
15:23:03 root@redis02:~# mkdir /xuruizhao/apps/mysql -pv
mkdir: created directory '/xuruizhao'
mkdir: created directory '/xuruizhao/apps'
mkdir: created directory '/xuruizhao/apps/mysql'
```
###### 1.5.1.2.2.4 MySQL 安装
```bash
15:37:10 root@redis02:/xuruizhao/apps/mysql# tar xf mysql-8.4.0-linux-glibc2.28-x86_64.tar.xz 
15:38:33 root@redis02:/xuruizhao/apps/mysql# ls
mysql-8.4.0-linux-glibc2.28-x86_64  mysql-8.4.0-linux-glibc2.28-x86_64.tar.xz
15:38:49 root@redis02:/xuruizhao/apps/mysql# ls -l 
total 469892
drwxr-xr-x 9 root root      4096 Dec 19 15:38 mysql-8.4.0-linux-glibc2.28-x86_64
-rw-r--r-- 1 root root 481157440 Dec 19 15:24 mysql-8.4.0-linux-glibc2.28-x86_64.tar.xz
15:38:52 root@redis02:/xuruizhao/apps/mysql# mv mysql-8.4.0-linux-glibc2.28-x86_64 /usr/local/mysql
15:39:13 root@redis02:/xuruizhao/apps/mysql# ls -l /usr/local/mysql
total 308
drwxr-xr-x  2 7161 31415   4096 Apr 10  2024 bin
drwxr-xr-x  2 7161 31415   4096 Apr 10  2024 docs
drwxr-xr-x  3 7161 31415   4096 Apr 10  2024 include
drwxr-xr-x  6 7161 31415   4096 Apr 10  2024 lib
-rw-r--r--  1 7161 31415 282183 Apr 10  2024 LICENSE
drwxr-xr-x  4 7161 31415   4096 Apr 10  2024 man
-rw-r--r--  1 7161 31415    666 Apr 10  2024 README
drwxr-xr-x 28 7161 31415   4096 Apr 10  2024 share
drwxr-xr-x  2 7161 31415   4096 Apr 10  2024 support-files
```
###### 1.5.1.2.2.5 配置 MySQL 环境变量
```bash
15:40:25 root@redis02:~# vim /etc/profile.d/mysql.sh
15:41:04 root@redis02:~# cat /etc/profile.d/mysql.sh
#!/bin/bash
# ==============================================================================
# 脚本基础信息
# filename: mysql.sh
# name: xuruizhao
# email: xuruizhao00@163.com
# v: LnxGuru
# GitHub: xuruizhao00-sys
# ==============================================================================
MYSQL_HOME=/usr/local/mysql
PATH=$PATH:$MYSQL_HOME/bin

15:41:05 root@redis02:~# source /etc/profile.d/mysql.sh
15:41:09 root@redis02:~# mysql --version
mysql  Ver 8.4.0 for Linux on x86_64 (MySQL Community Server - GPL)
15:41:18 root@redis02:~#
```
###### 1.5.1.2.2.6 配置 MySQL 环境
创建主配置文件
注意：配置文件中涉及到的配置目录，必须存在，否则无法运行
```bash
15:43:16 root@redis02:~# cat /usr/local/mysql/etc/my.cnf
[mysql]
port=3306
socket=/usr/local/mysql/data/mysql.sock
[mysqld]
port = 3306
mysqlx_port = 33060
mysqlx_socket = /usr/local/mysql/data/mysqlx.sock
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
socket = /usr/local/mysql/data/mysql.sock
pid-file = /usr/local/mysql/data/mysqld.pid
log-error = /usr/local/mysql/log/error.log
15:43:18 root@redis02:~# 
```
创建数据、日志目录
```bash
15:43:18 root@redis02:~# mkdir /usr/local/mysql/{data,log}
15:44:26 root@redis02:~# chown -R mysql:mysql /usr/local/mysql
```
###### 1.5.1.2.2.7 MySQL 环境初始化
需要保证 MySQL 的数据目录是空的
> [!NOTE] MySQL 安全初始化
> 如果使用 --initialize 选项会生成随机密码，要去 /data/mysql/mysql.log中查看

```bash
15:47:22 root@redis02:~# mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
15:48:23 root@redis02:~# tail -f /usr/local/mysql/log/error.log 
2025-12-19T07:48:10.669253Z 0 [System] [MY-015017] [Server] MySQL Server Initialization - start.
2025-12-19T07:48:10.676478Z 0 [System] [MY-013169] [Server] /usr/local/mysql/bin/mysqld (mysqld 8.4.0) initializing of server in progress as process 1986
2025-12-19T07:48:10.707882Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
2025-12-19T07:48:11.856225Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
2025-12-19T07:48:17.647986Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: yG:7W*/ic/k;   # 这是初始化的随机密码
2025-12-19T07:48:23.432212Z 0 [System] [MY-015018] [Server] MySQL Server Initialization - end.
```

> [!NOTE] MySQL 空密码初始化
> 如果使用 --initialize-insecure -选项会生成空密码
```bash
15:48:39 root@redis02:~# rm -rf /usr/local/mysql/data/*
15:50:13 root@redis02:~# mysqld --initialize-insecure  --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
```
###### 1.5.1.2.2.8 MySQL 服务脚本
```bash
# 该脚本不是 systemd 风格的脚本，但是可以被 systemd 兼容
15:50:40 root@redis02:~# cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
15:52:28 root@redis02:~# systemctl daemon-reload 
15:52:39 root@redis02:~# /etc/init.d/mysqld start 
Starting mysqld (via systemctl): mysqld.service.


# 查看自动生成的服务管理文件
15:52:57 root@redis02:~# systemctl cat mysqld
# /run/systemd/generator.late/mysqld.service
# Automatically generated by systemd-sysv-generator

[Unit]
Documentation=man:systemd-sysv-generator(8)
SourcePath=/etc/init.d/mysqld
Description=LSB: start and stop MySQL
After=network-online.target
After=remote-fs.target
After=ypbind.service
After=nscd.service
After=ldap.service
After=ntpd.service
After=xntpd.service
Wants=network-online.target

[Service]
Type=forking
Restart=no
TimeoutSec=5min
IgnoreSIGPIPE=no
KillMode=process
GuessMainPID=no
RemainAfterExit=yes
SuccessExitStatus=5 6
ExecStart=/etc/init.d/mysqld start
ExecStop=/etc/init.d/mysqld stop
ExecReload=/etc/init.d/mysqld reload
```
###### 1.5.1.2.2.9 MySQL 连接测试
```bash
15:53:12 root@redis02:~# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.4.0 MySQL Community Server - GPL

Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select version();
+-----------+
| version() |
+-----------+
| 8.4.0     |
+-----------+
1 row in set (0.00 sec)

mysql> 

# 修改密码
mysql> alter user root@"localhost" identified by "123";
Query OK, 0 rows affected (0.02 sec)

mysql> exit
Bye
15:54:48 root@redis02:~# mysql
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
15:54:49 root@redis02:~# mysql -p123
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.4.0 MySQL Community Server - GPL

Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```
##### 1.5.1.2.3 在 Ubuntu 中安装 MySQL9.4.0
同 MySQL8.4.0 安装过程
#### MySQL 安装方式总结

| **安装方式**      | **适用场景**                                           | **优点**                                                                                  | **缺点**                                                                                          | **安装难度**  |
|-------------------|------------------------------------------------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|---------------|
| **包管理器安装**   | 适用于大多数 Linux 用户，系统使用包管理器（如 `apt`、`yum`）。   | - 安装过程简单，依赖自动处理。<br>- 快速安装与升级。<br>- 适合大多数生产环境。                    | - 包含的版本可能不是最新版本。<br>- 无法完全定制 MySQL 配置。                                          | **低**        |
| **二进制安装**     | 适用于需要手动控制安装位置与配置的用户，支持跨平台。         | - 安装简便，无需编译。<br>- 可定制安装目录，适合需要特定配置的用户。                            | - 需要手动配置一些依赖项。<br>- 无法通过包管理器轻松管理升级。                                         | **中**        |
| **源码编译安装**   | 高级用户，特别是在定制化需求较多的环境下，如开发、测试等。      | - 完全定制化，支持所有编译选项。<br>- 可以选择最新版本。<br>- 可控制编译过程，定制 MySQL 特性。      | - 安装过程复杂，可能需要手动解决依赖问题。<br>- 升级和维护比较麻烦。<br>- 需要更多的系统资源和时间。     | **高**        |
- **包管理器安装**：
    - **适用场景**：适合大多数 Linux 用户，特别是那些使用 Debian、Ubuntu（`apt`）或 CentOS、RHEL（`yum`）的用户。
    - **优点**：安装过程非常简便，系统会自动处理依赖问题，用户不需要手动干预。
    - **缺点**：可能没有最新版本的 MySQL，并且无法根据个人需求对 MySQL 进行高度定制。
- **二进制安装**：
    - **适用场景**：适用于那些需要手动选择安装目录的用户，或是跨平台（如在 Windows 或 macOS 上）的安装。
    - **优点**：安装过程简单，避免了源代码编译的复杂性。用户可以定制安装路径并进行一定程度的配置。
    - **缺点**：需要手动配置和解决一些依赖项，且无法通过包管理器进行自动升级和管理。
- **源码编译安装**：
    - **适用场景**：适合那些需要完全控制 MySQL 配置或需要定制功能的高级用户，特别是在开发和测试环境中。
    - **优点**：用户可以选择最新版本的 MySQL，完全自定义编译选项，优化性能或增加特殊功能。
    - **缺点**：安装过程复杂，可能需要手动处理依赖问题，并且升级和维护变得更加困难。
#### 1.5.1.3 源码编译安装
如果你希望从源代码编译 MySQL，或者需要自定义编译选项，可以选择 **源码编译安装**。
##### 1.5.1.3.1 安装依赖
```bash
apt-get install cmake gcc g++ libncurses5-dev bison
```
##### 1.5.1.3.2 下载 MySQL 源码
![](assets/mysql_manager/file-20251219171958168.png)
##### 1.5.1.3.3 解压源码包
```bash
tar -xvzf mysql-<version>.tar.gz
cd mysql-<version>
cmake .
make
sudo make install
```
##### 1.5.1.3.4 创建用户和用户组
```bash
groupadd mysql
useradd -r -g mysql mysql
```
##### 1.5.1.3.5 初始化数据库
```bash
/usr/local/mysql/bin/mysqld --initialize --user=mysql
/usr/local/mysql/bin/mysqld_safe --user=mysql &
```
### 1.5.2 MySQL 配置