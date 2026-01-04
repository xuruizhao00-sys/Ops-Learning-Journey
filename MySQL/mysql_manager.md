# 一、数据库配置与安装
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
在安装时一般选择偶数版本，偶数版本一般是上一个奇数版本的稳定版

==确定内核版本==
```bash
[root rockylinux-1 ~] WORK 0 # uname -a
Linux rockylinux-1 5.14.0-362.8.1.el9_3.x86_64 #1 SMP PREEMPT_DYNAMIC Wed Nov 8 17:36:32 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```
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
###### 1.5.1.2.2.1 操作系统环境准备
```bash
1、关闭防火墙
# Ubuntu system
14:06:44 root@redis02:~# systemctl disable --now ufw
Synchronizing state of ufw.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install disable ufw
14:06:55 root@redis02:~# 
# rocky system
[root rockylinux-1 ~] WORK 3 # systemctl disable --now firewalld
[root rockylinux-1 ~] WORK 0 # systemctl status firewalld
○ firewalld.service - firewalld - dynamic firewall daemon
     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; preset: enabled)
     Active: inactive (dead)
       Docs: man:firewalld(1)
[root rockylinux-1 ~] WORK 3 # 

2、关闭 SELinux
# rocky system
[root rockylinux-1 ~] WORK 0 # sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
    
[root rockylinux-1 ~] WORK 0 # getenforce 
Disabled
[root rockylinux-1 ~] WORK 0 # 

# Ubuntu system
Ubuntu 默认没有启动 SELinux，Ubuntu 使用的是 AppArmor 不是 SELinux

```
###### 1.5.1.2.2.2 安装必要依赖
```bash
# Rocky系统：

[root@rocky9 ~]# yum -y install libaio numactl-libs ncurses-compat-libs

# Ubuntu系统：

root@ubuntu24:~# apt install libaio-dev numactl libnuma-dev libncurses-dev -y
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
###### 1.5.1.2.2.3 用户管理
创建用户组和用户
```bash
15:20:49 root@redis03:~# groupadd -r mysql
15:21:23 root@redis03:~# useradd -r -g mysql -s /sbin/nologin mysql
15:21:38 root@redis03:~# getent passwd mysql
mysql:x:999:988::/home/mysql:/sbin/nologin
15:21:42 root@redis03:~# 
```
###### 1.5.1.2.2.4 MySQL 目录配置
```bash
14:25:25 root@redis02:~# mkdir -pv /lnxguru/apps/mysql/3306/data/
mkdir: created directory '/lnxguru'
mkdir: created directory '/lnxguru/apps'
mkdir: created directory '/lnxguru/apps/mysql'
mkdir: created directory '/lnxguru/apps/mysql/3306'
mkdir: created directory '/lnxguru/apps/mysql/3306/data'
```
###### 1.5.1.2.2.5 MySQL 安装
```bash
14:49:52 root@redis02:~# tar xf mysql-8.4.0-linux-glibc2.28-x86_64.tar.xz -C /usr/local/
14:50:54 root@redis02:~# cd /usr/local/
14:50:58 root@redis02:/usr/local# ln -sv mysql-8.4.0-linux-glibc2.28-x86_64 mysql 
'mysql' -> 'mysql-8.4.0-linux-glibc2.28-x86_64'
14:51:06 root@redis02:/usr/local# ls -l mysql
lrwxrwxrwx 1 root root 34 Jan  3 14:51 mysql -> mysql-8.4.0-linux-glibc2.28-x86_64
14:51:10 root@redis02:/usr/local# ls -l mysql/
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
14:51:12 root@redis02:/usr/local#
```
###### 1.5.1.2.2.6 配置 MySQL 环境变量
```bash
14:52:49 root@redis02:/usr/local# cat /etc/profile.d/mysql.sh
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
PATH=$MYSQL_HOME/bin:$PATH

14:52:50 root@redis02:/usr/local# source /etc/profile.d/mysql.sh
14:53:10 root@redis02:/usr/local# mysql --version
mysql  Ver 8.4.0 for Linux on x86_64 (MySQL Community Server - GPL)
14:53:41 root@redis02:/usr/local# 
```
###### 1.5.1.2.2.7 配置 MySQL 环境
创建主配置文件
注意：配置文件中涉及到的配置目录，必须存在，否则无法运行
```bash
14:58:23 root@redis02:~# cat /etc/my.cnf
[mysqld]
user=mysql
basedir=/usr/local/mysql
datadir=/lnxguru/apps/mysql/3306/data
socket=/tmp/mysql.sock
```
```java
[mysqld]     --配置标签信息（标明 是服务端配置标签 客户端配置标签） 
user=mysql   --数据库进程用户信息
basedir=/usr/local/mysql   -- 加载程序目录  Linux 系统 mysql5.6  mysql5.7 mysql8.0 （多实例）   
datadir=/data/3306/data    -- 加载数据目录
socket=/tmp/mysql.sock     -- 配置连接数据库的 socket（客户端命令可以连接访问服务端）
```
创建数据、日志目录
```bash
15:43:18 root@redis02:~# mkdir /usr/local/mysql/{data,log}
15:44:26 root@redis02:~# chown -R mysql:mysql /usr/local/mysql
```
###### 1.5.1.2.2.8 MySQL 环境初始化
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
14:55:59 root@redis02:/usr/local# mysqld --initialize-insecure --user=mysql --datadir=/lnxguru/apps/mysql/3306/data/  --basedir=/usr/local/mysql
14:56:30 root@redis02:/usr/local# echo $?
0
```
###### 1.5.1.2.2.9 MySQL 服务启动

> [!NOTE] MySQL 自带的脚本启动
> /usr/local/mysql/support-files/mysql.server 
```bash
1、MySQL 数据库程序为我们提供了一个启动 MySQL 的脚本
14:58:25 root@redis02:~# file /usr/local/mysql/support-files/mysql.server 
/usr/local/mysql/support-files/mysql.server: POSIX shell script, ASCII text executable

2、将该脚本移动到 /etc/init.d/ 目录下
15:03:05 root@redis02:~# mv /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
15:03:42 root@redis02:~# ls -l /etc/init.d/mysqld
-rwxr-xr-x 1 7161 31415 10576 Apr 10  2024 /etc/init.d/mysqld

3、利用该脚本启停 MySQL
15:04:17 root@redis02:~# /etc/init.d/mysqld start 
Starting mysqld (via systemctl): mysqld.service.                     
15:04:45 root@redis02:~# ss -tunlp | grep 3306
tcp   LISTEN 0      70                 *:33060            *:*    users:(("mysqld",pid=2689,fd=18))                      
tcp   LISTEN 0      151                *:3306             *:*    users:(("mysqld",pid=2689,fd=30))                      
15:04:49 root@redis02:~# 
# 数据库进程查看，对于数据库进程来说，也是有 master 进程和 worker 进程的
15:05:09 root@redis02:~# ps -ef | grep mysql | grep -v grep 
root        2551       1  0 15:04 ?        00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --datadir=/lnxguru/apps/mysql/3306/data --pid-file=/lnxguru/apps/mysql/3306/data/redis02.pid
mysql       2689    2551  9 15:04 ?        00:00:04 /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/lnxguru/apps/mysql/3306/data --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=redis02.err --pid-file=/lnxguru/apps/mysql/3306/data/redis02.pid --socket=/tmp/mysql.sock
15:05:14 root@redis02:~
15:05:14 root@redis02:~# /etc/init.d/mysqld stop
Stopping mysqld (via systemctl): mysqld.service.
15:05:48 root@redis02:~# ps -ef | grep mysql | grep -v grep 
15:05:49 root@redis02:~#
```

> [!NOTE] service 方式启动
>要想使用 service 方式启动，必须要保证 /etc/init.d/mysqld 存在 
```bash
15:05:49 root@redis02:~# service mysqld start
15:06:37 root@redis02:~# ps -ef | grep mysql | grep -v grep 
root        2820       1  0 15:06 ?        00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --datadir=/lnxguru/apps/mysql/3306/data --pid-file=/lnxguru/apps/mysql/3306/data/redis02.pid
mysql       2960    2820 42 15:06 ?        00:00:03 /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/lnxguru/apps/mysql/3306/data --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=redis02.err --pid-file=/lnxguru/apps/mysql/3306/data/redis02.pid --socket=/tmp/mysql.sock
15:06:40 root@redis02:~#
```

> [!NOTE] systemctl 启动数据库服务
> 默认的我们是没有 mysql.service 文件，有两种解决方式
> 1、先通过 `systemctl enable mysqld`，默认指定从 `/etc/rc.d/init.d/mysqld` 启动
> 2、编写 mysql.service
> 
```bash
方式1
15:09:12 root@redis02:~# systemctl enable mysqld
mysqld.service is not a native service, redirecting to systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable mysqld
16:38:05 root@redis02:~# systemctl status mysqld
○ mysqld.service - LSB: start and stop MySQL
     Loaded: loaded (/etc/init.d/mysqld; generated)
     Active: inactive (dead)
       Docs: man:systemd-sysv-generator(8)

Jan 03 15:06:32 redis02 systemd[1]: Starting mysqld.service - LSB: start and stop MySQL...
Jan 03 15:06:32 redis02 mysqld[2806]: Starting MySQL
Jan 03 15:06:37 redis02 mysqld[2806]: .... *
Jan 03 15:06:37 redis02 systemd[1]: Started mysqld.service - LSB: start and stop MySQL.
Jan 03 15:08:31 redis02 systemd[1]: Stopping mysqld.service - LSB: start and stop MySQL...
Jan 03 15:08:31 redis02 mysqld[3020]: Shutting down MySQL
Jan 03 15:08:32 redis02 mysqld[3020]: . *
Jan 03 15:08:32 redis02 systemd[1]: mysqld.service: Deactivated successfully.
Jan 03 15:08:32 redis02 systemd[1]: Stopped mysqld.service - LSB: start and stop MySQL.
Jan 03 15:08:32 redis02 systemd[1]: mysqld.service: Consumed 6.088s CPU time, 444.2M memory peak, 0B memory swap peak.
16:38:11 root@redis02:~# systemctl start mysqld
16:38:34 root@redis02:~# systemctl status mysqld
● mysqld.service - LSB: start and stop MySQL
     Loaded: loaded (/etc/init.d/mysqld; generated)
     Active: active (running) since Sat 2026-01-03 16:38:33 CST; 2s ago
       Docs: man:systemd-sysv-generator(8)
    Process: 3849 ExecStart=/etc/init.d/mysqld start (code=exited, status=0/SUCCESS)
      Tasks: 37 (limit: 2210)
     Memory: 429.9M (peak: 444.1M)
        CPU: 4.246s
     CGroup: /system.slice/mysqld.service
             ├─3863 /bin/sh /usr/local/mysql/bin/mysqld_safe --datadir=/lnxguru/apps/mysql/3306/data --pid-file=/lnxguru/apps/mysql/3306/data/redis02.pid
             └─4003 /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/lnxguru/apps/mysql/3306/data --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=redis02.err --pid-file=/ln>

Jan 03 16:38:29 redis02 systemd[1]: Starting mysqld.service - LSB: start and stop MySQL...
Jan 03 16:38:29 redis02 mysqld[3849]: Starting MySQL
Jan 03 16:38:33 redis02 mysqld[3849]: .... *
Jan 03 16:38:33 redis02 systemd[1]: Started mysqld.service - LSB: start and stop MySQL.
16:38:38 root@redis02:~# 
```
```shell
方式二
16:42:36 root@redis02:~# cat /lib/systemd/system/mysqld.service
[Unit]
Description=MySQL Server 8.4.0
Documentation=https://dev.mysql.com/doc/
After=network.target
Wants=network.target

[Service]
User=mysql
Group=mysql

# mysqld 本体直接前台运行（推荐）
Type=simple

# 启动命令
ExecStart=/usr/local/mysql/bin/mysqld \
  --defaults-file=/etc/my.cnf \
  --basedir=/usr/local/mysql \
  --datadir=/lnxguru/apps/mysql/3306/data \
  --user=mysql

# 停止命令
ExecStop=/usr/local/mysql/bin/mysqladmin \
  --defaults-file=/usr/local/mysql/etc/my.cnf shutdown

# 资源限制（企业必配）
LimitNOFILE=65535
LimitNPROC=65535

# 异常退出自动拉起
Restart=on-failure
RestartSec=5s

# 超时设置
TimeoutStartSec=300
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target

# 完善配置文件
16:42:57 root@redis02:~# cat /etc/my.cnf 
[mysqld]
basedir=/usr/local/mysql
datadir=/lnxguru/apps/mysql/3306/data
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
pid-file=/lnxguru/apps/mysql/3306/data/mysqld.pid
log-error=/lnxguru/apps/mysql/3306/error.log
# 配置权限
16:42:57 root@redis02:~# chown -R mysql:mysql /usr/local/mysql /lnxguru/apps/mysql/3306
16:42:37 root@redis02:~# systemctl daemon-reload 
16:42:41 root@redis02:~# systemctl start mysqld.service 
16:42:47 root@redis02:~# systemctl status  mysqld.service 
● mysqld.service - MySQL Server 8.4.0
     Loaded: loaded (/usr/lib/systemd/system/mysqld.service; disabled; preset: enabled)
     Active: active (running) since Sat 2026-01-03 16:42:43 CST; 7s ago
       Docs: https://dev.mysql.com/doc/
   Main PID: 4852 (mysqld)
      Tasks: 36 (limit: 2210)
     Memory: 430.1M (peak: 443.5M)
        CPU: 2.784s
     CGroup: /system.slice/mysqld.service
             └─4852 /usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/lnxguru/apps/mysql/3306/data --user=mysql

Jan 03 16:42:43 redis02 systemd[1]: mysqld.service: Scheduled restart job, restart counter is at 10.
Jan 03 16:42:43 redis02 systemd[1]: Started mysqld.service - MySQL Server 8.4.0.
16:42:50 root@redis02:~# ss -tunlp  |grep 3306
tcp   LISTEN 0      70                 *:33060            *:*    users:(("mysqld",pid=4852,fd=18))                      
tcp   LISTEN 0      151                *:3306             *:*    users:(("mysqld",pid=4852,fd=20))                      
16:42:57 root@redis02:~#
```
###### 1.5.1.2.2.10 MySQL 连接测试
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
#### 1.5.1.4 MySQL 安装方式总结

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
### 1.5.2 MySQL 配置文件解析
MySQL 的配置文件通常是 `/etc/my.cnf` 或 `/etc/mysql/my.cnf`，但是可以根据安装方式和操作系统不同而有所不同。该文件包含了 MySQL 的各种设置，分为 **客户端配置** 和 **服务器端配置** 两大部分。
二进制安装默认没有配置文件，需要我们自己编写

#### 1.5.2.1 配置文件生效顺序
MySQL 配置文件的生效顺序如下：

1. **命令行参数**：当 MySQL 启动时，命令行传入的参数会优先于配置文件中的设置生效。
2. **系统默认配置文件**：`/etc/my.cnf` 或 `/etc/mysql/my.cnf`（不同发行版可能略有不同），这是 MySQL 默认的配置文件。
3. **用户自定义配置文件**：有些安装会有用户自定义的配置文件，或者在启动 MySQL 时指定特定的配置文件。
4. **配置文件的优先级**：配置文件的优先级是按加载顺序来的，后加载的配置会覆盖先加载的配置。
```bash
18:03:28 root@redis02:~# mysql --help | grep "/etc"
                      /etc/services, built-in default (3306).
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf 
```
这意味着 MySQL 会按照以下顺序加载配置文件：
1. `/etc/mysql/my.cnf`
2. `/etc/my.cnf`
3. 用户目录下的 `~/.my.cnf`
#### 1.5.2.2 配置文件的客户端配置
客户端配置通常是 `[mysql]` 和 `[client]` 部分的内容，影响的是 MySQL 客户端（如命令行工具 `mysql`）的行为。
[mysql] 和 [client] 部分配置
```bash
[mysql]
port = 3306
socket = /usr/local/mysql/data/mysql.sock
default-character-set = utf8mb4

[client]
port = 3306
socket = /usr/local/mysql/data/mysql.sock
user = root
```

> [!NOTE] Title
> 客户端常见配置解析
- **port = 3306**:
    - 客户端连接 MySQL 服务器时使用的端口号。默认值是 `3306`，与服务器端口一致，除非服务器配置为其他端口。
- **socket = /usr/local/mysql/data/mysql.sock**:
    - 客户端与 MySQL 服务器之间通过 Unix 套接字连接的路径。用于本地连接，避免通过 TCP/IP 协议进行网络连接，提高效率。
- **default-character-set = utf8mb4**:
    - 设置客户端的默认字符集。`utf8mb4` 是 MySQL 推荐的字符集，它支持所有 Unicode 字符（包括 Emoji）。
- **user = root**:
    - 默认登录 MySQL 使用的用户名，通常为 `root`，也可以根据需要修改为其他数据库用户。
#### 1.5.2.3 配置文件的服务端配置
服务端配置通常在 `[mysqld]` 部分进行设置，影响的是 MySQL 服务器的运行方式。
```bash
[mysqld]
port = 3306
socket = /usr/local/mysql/data/mysql.sock
datadir = /usr/local/mysql/data
log-error = /usr/local/mysql/log/error.log
pid-file = /usr/local/mysql/data/mysqld.pid
max_connections = 151
innodb_buffer_pool_size = 2G
default-storage-engine = InnoDB
sql_mode = STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION
log-bin = mysql-bin
server-id = 1
```
> [!NOTE] Title
> 服务端的常见配置解析

- **port = 3306**:
    - 服务器监听的端口，默认为 `3306`。这是外部客户端与 MySQL 服务器建立连接时使用的端口。
- **socket = /usr/local/mysql/data/mysql.sock**:
    - MySQL 服务器监听的 Unix 套接字文件路径，用于本地连接。
- **datadir = /usr/local/mysql/data**:
    - MySQL 数据存储路径。所有数据库文件、表数据、索引和日志等都存储在此目录。
- **log-error = /usr/local/mysql/log/error.log**:
    - 指定 MySQL 错误日志的位置。此日志记录 MySQL 的启动、运行和错误信息。
- **pid-file = /usr/local/mysql/data/mysqld.pid**:
    - 存储 MySQL 进程的 PID 文件位置。系统会根据这个文件来判断 MySQL 是否正在运行。
- **max_connections = 151**:
    - 设置允许的最大连接数。默认值是 `151`，可以根据系统的需求调整这个值。
- **innodb_buffer_pool_size = 2G**:
    - 设置 InnoDB 存储引擎的缓冲池大小。缓冲池用于缓存数据和索引，通常应设置为服务器总内存的 60-70%。
- **default-storage-engine = InnoDB**:
    - 设置默认的存储引擎，InnoDB 是默认的事务性存储引擎，支持 ACID 特性和外键约束。
- **sql_mode = STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION**:
    - 设置 SQL 模式，决定 MySQL 的行为和错误处理方式。例如，`STRICT_TRANS_TABLES` 会在发生数据异常时阻止操作。
- **log-bin = mysql-bin**:
    - 启用二进制日志记录，用于数据库的复制和数据恢复。`mysql-bin` 是二进制日志文件的前缀。
- **server-id = 1**:
    - 设置服务器唯一标识符。在 MySQL 主从复制环境中，每个服务器需要一个唯一的 `server-id`。
`[mysqld_safe] [mysqldump] [mysqladmin] `都属于服务端的配置
#### 1.5.2.4 查看 MySQL 加载的配置项
##### 1.5.2.4.1 MySQL 配置文件的加载顺序如下
1. **命令行参数**：通过命令行启动 MySQL 时使用的参数优先级最高。
2. **配置文件**：MySQL 会依次加载不同位置的配置文件，后加载的配置会覆盖先加载的配置。

具体来说，加载顺序是：
- **全局配置文件**（`--defaults-file`）: 通过命令行指定的配置文件（如果有）。
- **系统默认配置文件**：比如 `/etc/my.cnf` 或 `/etc/mysql/my.cnf`（不同的 Linux 发行版可能有所不同）。
- **用户自定义配置文件**：如 `/etc/mysql/conf.d/` 或 `/usr/local/mysql/etc/my.cnf`（这些路径和文件可能因安装方式而不同）。
- **命令行参数**：如果启动时通过命令行指定了任何参数（例如 `--port` 或 `--socket`），这些会覆盖配置文件中的设置。
##### 1.5.2.4.2 使用 `SHOW VARIABLES` 查看实际生效的配置
如果你想查看 MySQL 当前生效的配置项，可以通过 `SHOW VARIABLES` 命令查询 MySQL 的所有系统变量和它们的当前值。此命令返回的变量是通过 MySQL 配置文件或启动时的命令行参数生效的配置项。
```sql
mysql> show variables \G
mysql> show variables like "port";
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| port          | 3306  |
+---------------+-------+
1 row in set (0.00 sec)

mysql> show variables like "socket";
+---------------+----------------------------------+
| Variable_name | Value                            |
+---------------+----------------------------------+
| socket        | /usr/local/mysql/data/mysql.sock |
+---------------+----------------------------------+
1 row in set (0.00 sec)

mysql>
```
#### 1.5.2.5 企业级最佳实践
##### 1.5.2.5.1 性能优化
- **innodb_buffer_pool_size**：根据服务器的内存配置该参数，一般设置为物理内存的 60%-70%，用于缓存 InnoDB 的数据和索引。
- **max_connections**：根据应用的并发数调整最大连接数，避免过多连接导致资源耗尽。
- **query_cache_size**：如果启用查询缓存，配置适当的大小，但在高并发环境下，查询缓存可能会导致性能下降，建议在高并发环境下禁用。
- **tmp_table_size** 和 **max_heap_table_size**：设置临时表大小的限制，避免临时表使用磁盘
##### 1.5.2.5.2 安全性配置
- **skip-symbolic-links**：禁用符号链接以防止目录遍历攻击。
- **log_bin**：启用二进制日志，用于数据恢复和主从复制。
- **ssl**：启用 SSL 加密连接，确保客户端与 MySQL 服务器之间的通信安全。
##### 1.5.2.5.3 高可用和容灾备份
- **gtid_mode**：启用 GTID（全局事务标识符），简化主从复制管理。
- **replicate-do-db** 和 **replicate-ignore-db**：配置复制时需要包含或忽略的数据库。
- **binlog_format**：选择合适的二进制日志格式（如 ROW 格式适合高并发环境）。
##### 1.5.2.5.4 日志管理
- **log-error**：设置错误日志位置，确保 MySQL 启动、运行和错误信息得到记录。
- **slow_query_log**：启用慢查询日志，记录运行时间超过阈值的查询，帮助定位性能瓶颈。
##### 1.5.2.5.5 备份策略
- 定期使用 `mysqldump`、`mysqlpump` 或 **Percona XtraBackup** 进行全量或增量备份。
- 配置合理的备份保留策略，确保数据的恢复和灾难恢复能力。
#### 1.5.2.6 MySQL 错误日志管理
在数据库启动中出现的问题，我们是可以通过错误日志查找问题，因为在命令行界面，可能很多错误都是相同的提示，我们无法准确定性错误

配置文件虽然有错，但是可以启动数据库服务，但是不能连接数据库服务，例如：修改了 socket 文件位置，这一类错误，不需要去错误日志文件
```bash
1、修改配置文件中的 socket 文件位置
# MySQL 是可以正常启动的
16:46:16 root@redis02:~# cat /etc/my.cnf
[mysqld]
basedir=/usr/local/mysql
datadir=/lnxguru/apps/mysql/3306/data
socket=/lnxguru/apps/mysql/3306/data/mysql.sock.asd
pid-file=/lnxguru/apps/mysql/3306/data/mysqld.pid
log-error=/lnxguru/apps/mysql/3306/error.log
16:46:17 root@redis02:~# systemctl restart mysqld
16:46:25 root@redis02:~# echo $?
0
16:46:28 root@redis02:~#
# 但是无法连接
16:46:28 root@redis02:~# mysql
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)
16:46:43 root@redis02:~#
```
配置文件错误，无法启动数据库服务，这一类错误，需要去查看错误日志文件
```bash
17:04:43 root@redis02:~# cat /etc/my.cnf 
[mysqld]
aaabasedir=/usr/local/mysql
datadir=/lnxguru/apps/mysql/3306/data
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
pid-file=/lnxguru/apps/mysql/3306/data/mysqld.pid
log-error=/lnxguru/apps/mysql/3306/error.log
[mysql]
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
17:02:57 root@redis02:~# systemctl restart mysqld 
17:03:02 root@redis02:~# systemctl status mysqld 
● mysqld.service - MySQL Server 8.4.0
     Loaded: loaded (/usr/lib/systemd/system/mysqld.service; disabled; preset: enabled)
     Active: activating (auto-restart) (Result: exit-code) since Sat 2026-01-03 17:03:06 CST; 4s ago
       Docs: https://dev.mysql.com/doc/
    Process: 6291 ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/lnxguru/apps/mysql/3306/data --user=mysql (code=exited, status=1/FAILURE)
   Main PID: 6291 (code=exited, status=1/FAILURE)
        CPU: 2.945s
# 查看错误日志
17:04:03 root@redis02:~# tail -f /lnxguru/apps/mysql/3306/error.log 
2026-01-03T09:03:57.089813Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
2026-01-03T09:03:57.089924Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.
2026-01-03T09:03:57.121628Z 0 [ERROR] [MY-000067] [Server] unknown variable 'aaabasedir=/usr/local/mysql'.
2026-01-03T09:03:57.123864Z 0 [ERROR] [MY-010119] [Server] Aborting
```
#### 1.5.2.7 socket 文件配置注意事项
##### 1.5.2.7.1 什么是 socket 文件
socket 文件的本质：  
是“本机 MySQL 客户端与 mysqld 之间最高效、最安全、最可靠的通信通道”。
MySQL 客户端连接服务端，只有两条路：

| 方式          | 是否走网络  | 是否需要端口 |
| ----------- | ------ | ------ |
| Unix Socket | ❌ 不走网络 | ❌ 不需要  |
| TCP/IP      | ✅ 走网络栈 | ✅ 需要   |
```ini
本地连接的默认优先级
socket  >  tcp
```
👉 **在连接时只要没写 `-h`，就会尝试 socket**
##### 1.5.2.7.2 为什么要设置 socket 文件
###### 1.5.2.7.2.1 性能原因
Unix Socket：
```ini
进程《----》内核《-----》进程
```
Tcp
```ini
进程 ↔ TCP/IP 协议栈 ↔ 网卡 ↔ 回环接口 ↔ TCP/IP ↔ 进程
```
📌 **socket 少了整套 TCP/IP 协议栈**

| 项目  | Socket | TCP |
| --- | ------ | --- |
| 延迟  | ⭐ 极低   | 较高  |
| CPU | ⭐ 少    | 多   |
| QPS | ⭐ 更高   | 低一些 |
👉 **DBA 本机运维、备份、监控，100% 走 socket**
###### 1.5.2.7.2.2 安全原因
Unix Socket：
- 只能本机访问
- 受 **Linux 文件权限** 控制
- 不能被远程扫描

TCP：
- 端口暴露
- 可能被扫描、爆破
- 依赖防火墙
👉 **socket = 天然“内网+最小暴露”**
##### 1.5.2.7.3 如何设置 socket 文件

> [!NOTE] 结论
> **`[mysqld]` 里的 socket 是“服务端监听用的”，  
`[client] / [mysql]` 里的 socket 是“客户端去找服务端用的”。**
**两边必须一致，但作用完全不同，谁也不能省。**
###### 1.5.2.7.3.1 先看“socket 到底是谁用谁的”
1️⃣ mysqld（服务端）视角
```bash
[mysqld]
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
```
- mysqld **创建** 并 **监听** 这个 socket 文件
- 本地客户端通过这个 socket 才能连进来
- **没有这个配置，mysqld 可能：**
    - 用默认 socket（如 `/tmp/mysql.sock`）
    - 或者根本不创建 socket（只监听 TCP）
📌 **这是“服务端出口”**
2️⃣ mysql（客户端）视角
```bash
[client]
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
```
👉 含义是：
- mysql 客户端 **主动去这个路径找 socket**
- 找不到就报你看到的错误
- 如果没配置：
    - 回退到编译时默认 `/tmp/mysql.sock`
📌 **这是“客户端入口”**
###### 1.5.2.7.3.2 为什么不能“只配一边”
❌ 只在 `[client]` 配 socket（错误）
```ini
[client]
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
```
**后果：**
- 客户端会去这个路径找
- 但 mysqld 可能：
    - 根本没在这监听
    - 或监听在别的地方
- ❌ 连接失败

❌ 只在 `[mysqld]` 配 socket
```ini
[mysqld]
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
```
**后果：**
- mysqld 正常创建 socket
- 客户端不知道
- 客户端回退 `/tmp/mysql.sock`
- ❌ 连接失败
###### 1.5.2.7.3.3 一个非常形象的类比
把 socket 想成：

> 🏢 **服务端（mysqld）开了一扇“后门”**  
> 🚶 **客户端（mysql）要知道这扇门在哪里**

|配置位置|相当于|
|---|---|
|`[mysqld] socket`|“我在这里开门”|
|`[client] socket`|“我从这里进门”|

**门没开 or 人走错门 → 永远进不去**

##### 1.5.2.7.4 为什么 socket 不能放 /tmp
/tmp 的问题

|问题|说明|
|---|---|
|tmpfs|重启可能清空|
|权限|被误删|
|多实例|冲突|
|安全|公共目录|

👉 **生产环境严禁 /tmp/mysql.sock**

## 1.6 数据库启动方式
### 1.6.1 利用脚本启动

```bash
# 数据库程序为我们提供了一个启动 mysql 的脚本
21:22:55 root@redis02:~# file /usr/local/mysql/support-files/mysql.server 
/usr/local/mysql/support-files/mysql.server: POSIX shell script, ASCII text executable
21:28:57 root@redis02:~# 

# 移动该脚本到 ==/etc/init.d/mysqld== 位置
21:22:55 root@redis02:~# cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
21:22:55 root@redis02:~# ll /etc/init.d/mysqld
-rwxr-xr-x 1 root root 10576 Jun 25 09:40 /etc/init.d/mysqld

#  利用脚本文件启停 mysql
21:22:55 root@redis02:~# /etc/init.d/mysqld start
```
### 1.6.2 service 启动
要想使用 service 方式启动，必须要保证 /etc/init.d/mysqld 存在
```bash
21:30:53 root@redis02:~# service mysqld start 
21:31:08 root@redis02:~# ss -tunlp | grep 3306
tcp   LISTEN 0      70                 *:33060            *:*    users:(("mysqld",pid=5986,fd=18))                      
tcp   LISTEN 0      151                *:3306             *:*    users:(("mysqld",pid=5986,fd=20))                      
21:31:16 root@redis02:~# 
```
### 1.6.3 systemctl 管理数据库
```bash
21:33:11 root@redis02:~# cat /usr/lib/systemd/system/mysql.service
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/etc/my.cnf
LimitNOFILE=5000
21:33:14 root@redis02:~# systemctl daemon-reload 
21:33:21 root@redis02:~# systemctl start mysql
21:33:28 root@redis02:~# systemctl status mysql
● mysql.service - MySQL Server
     Loaded: loaded (/usr/lib/systemd/system/mysql.service; disabled; preset: enabled)
     Active: active (running) since Fri 2025-12-19 21:33:28 CST; 5s ago
       Docs: man:mysqld(8)
             http://dev.mysql.com/doc/refman/en/using-systemd.html
   Main PID: 6149 (mysqld)
      Tasks: 36 (limit: 2210)
     Memory: 429.8M (peak: 443.0M)
        CPU: 3.013s
     CGroup: /system.slice/mysql.service
             └─6149 /usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/etc/my.cnf

Dec 19 21:33:28 redis02 systemd[1]: Started mysql.service - MySQL Server.
21:33:33 root@redis02:~# 
```
## 1.7 MySQL 多实例
拿 MySQL 数据库来说明，就是在一台服务器上运行多个 MySQL 服务端进程，每个进程监听一个端口（3306，3307，3308），维护一套属于其自己的配置和数据，客户端使用不同的端口来连接具体服端进程，从而实现对不同的实例的操作。
### 1.7.1 MySQL 多实例优点
- 节约硬件资源：、
	- 在某些场景下（比如说测试，调研，新旧业务并存等），需要配置不同的 MySQL 数据库版本，而又没有足够多的服务器资源，则可以选择在一台服务器上用不同的版本实现多开来满足需求。
- 便于对比：
	- 在一个完全相同的硬件环境中，运行不同的 MySQL 版本，使用相同的参数进行测试，调研时，可以最大程度的减少外部环境因素的影响，便于得出更准确的结论。
- 便于管理：
	- 在一台服务器上运行多个实例，同理，只需要在这一台服务器上配置安全规则，就可以完成对多个实例的访问授权，而且对于数据库的备份，停启等工作，也只需要在这一台服务器上完成。
### 1.7.2 MySQL 多实例缺点
- 资源抢占：
	- 一台服务器上运行多个服务实例，资源总量恒定，一个实例占用的资源无法被另一个实例所使用，在这种情况下，服务性能会受到影响，无法体现 MySQL 服务的实际性能。
- 存在单点风险：
	- 一台服务器上部署多个服务实例，如果该服务器当机，则这多个服务实例都会受影响。
<mark style="background: #ABF7F7A6;">生产环境下，是不要安装多实例方式的。</mark>
### 1.7.3 MySQL 多实例配置
可以用不同的 MySQL 版本实现多实例，也可以用相同的 MySQL 版本实现多实例。
![](assets/mysql_manager/file-20251219210201265.png)
```bash
192.168.121.132   3306   /data/3306/data   /data/3306/my3306.cnf    /tmp/mysql3306.sock 
192.168.121.132   3307   /data/3307/data   /data/3307/my3307.cnf    /tmp/mysql3307.sock 
```
```bash
# 初始化目录
17:47:24 root@redis02:~# mkdir -pv /data/{3306..3307}/data
mkdir: created directory '/data'
mkdir: created directory '/data/3306'
mkdir: created directory '/data/3306/data'
mkdir: created directory '/data/3307'
mkdir: created directory '/data/3307/data'
17:47:35 root@redis02:~# tree /data/
/data/
├── 3306
│   └── data
└── 3307
    └── data

5 directories, 0 files

# 初始化数据库
17:47:41 root@redis02:~# mysqld --initialize-insecure --user=mysql --datadir=/data/3306/data --basedir=/usr/local/mysql
17:48:18 root@redis02:~# mysqld --initialize-insecure --user=mysql --datadir=/data/3307/data --basedir=/usr/local/mysql

# 编写配置文件
17:50:08 root@redis02:~# cat /data/3307/my3307.cnf
[mysqld]
user=mysql
port=3307
basedir=/usr/local/mysql
datadir=/data/3307/data
socket=/tmp/mysql3307.sock
17:50:15 root@redis02:~# cat /data/3306/my3306.cnf
[mysqld]
user=mysql
port=3306
basedir=/usr/local/mysql
datadir=/data/3306/data
socket=/tmp/mysql3306.sock
17:50:20 root@redis02:~# 

# 编写 service 文件
17:52:33 root@redis02:~# cat /lib/systemd/system/mysql330{6..7}.service
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/data/3306/my3306.cnf
LimitNOFILE=5000
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/data/3307/my3307.cnf
LimitNOFILE=5000


# 启动服务
17:52:42 root@redis02:~# systemctl daemon-reload 
17:53:02 root@redis02:~# systemctl start mysql3306
17:53:09 root@redis02:~# systemctl start mysql3307
17:53:19 root@redis02:~# 
17:53:19 root@redis02:~# ss -tunlp  |grep -E "3306|3307"
tcp   LISTEN 0      70                 *:33060            *:*    users:(("mysqld",pid=13045,fd=18))                     
tcp   LISTEN 0      151                *:3306             *:*    users:(("mysqld",pid=13045,fd=30))                     
tcp   LISTEN 0      151                *:3307             *:*    users:(("mysqld",pid=13050,fd=28))                     
17:53:30 root@redis02:~#
```
## 1.8 数据库连接管理
数据库连接方式有两种：

本地连接：利用本地的套接字文件（socket 文件），需要保证客户端连接的 socket 文件和服务端创建的 socket 文件一致

远程连接：利用网络协议（利用TCP/IP协议）
### 1.8.1 本地连接
==mysql -uroot -p012012 -h 数据库服务端地址 -P 数据服务端端口 -S "socket 文件"==
### 1.8.2 客户端工具进行连接
MySQL官方出品远程工具：MySQL workbench 
[https://baijiahao.baidu.com/s?id=1778249322572053063&wfr=spider&for=pc](https://baijiahao.baidu.com/s?id=1778249322572053063&wfr=spider&for=pc)

远程工具安装完毕，建立远程会话连接前，需要创建远程用户信息

```sql
with grant option ：可以对其他用户进行授权

 create user root@'10.0.0.%' identified by '123456';  
 grant all on . to root@'10.0.0.%' with grant option;
```
### 1.8.3 利用程序代码连接数据库

python 连接数据库驱动-pymysql 
golang 连接数据库驱动-gomysql 
java 连接数据库驱动-jar 
php 连接数据库驱动-phpmysql
## 1.9 数据库错误日志管理
错误日志路径 ==/data/3306/data/`hostname`.err==

在数据库启动中出现的问题，我们是可以通过错误日志查找问题，因为在命令行界面，可能很多错误都是相同的提示，我们无法准确定性错误

1.模拟配置文件错误
1.1 配置文件虽然有错，但是可以启动数据库服务，但是不能连接数据库服务，例如：修改了 socket 文件位置，这一类错误，不需要去查看 `hostname`.err文件
~~~bash
 [root@db01 ~]# vim /etc/my.cnf  
 [root@db01 ~]# cat /etc/my.cnf  
 [mysqld]   
 user=mysql  
 basedir=/usr/local/mysql  
 datadir=/data/3306/data  
 socket=/tmp/mysql01.sock  
 [root@db01 ~]#   
 [root@db01 ~]# service mysqld start   
 Starting MySQL... SUCCESS!   
 [root@db01 ~]# mysql   
 ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)  
 [root@db01 ~]# mysql -p123  
 mysql: [Warning] Using a password on the command line interface can be insecure.  
 ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)  
 [root@db01 ~]# 
~~~
1.2 配置文件错误，无法启动数据库服务
~~~bash
[root@db01 ~]# cat /etc/my.cnf  
 [mysqld]   
 use=mysql  
 asedir=/usr/local/mysql  
 datadir=/data/3306/data  
 socket=/tmp/mysql.sock  
 [root@db01 ~]# service mysqld start   
 # 这里无法根据错误提示判断错误位置  
 Starting MySQL..... ERROR! The server quit without updating PID file (/data/3306/data/db01.pid).  
 ​  
 # 这种情况就需要查看错误日志了  
 [root@db01 ~]# cat /data/3306/data/db01.err   
 2025-06-25T03:13:45.768719Z 0 [System] [MY-010116] [Server] /usr/local/mysql/bin/mysqld (mysqld 8.0.36) starting as process 215617  
 2025-06-25T03:13:45.804395Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.  
 2025-06-25T03:13:47.112090Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.  
 2025-06-25T03:13:47.957021Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.  
 2025-06-25T03:13:47.957126Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.  
 2025-06-25T03:13:47.972528Z 0 [ERROR] [MY-000067] [Server] unknown variable 'use=mysql'.  
 2025-06-25T03:13:47.972781Z 0 [ERROR] [MY-010119] [Server] Aborting  
 2025-06-25T03:13:49.539739Z 0 [System] [MY-010910] [Server] /usr/local/mysql/bin/mysqld: Shutdown complete (mysqld 8.0.36)  MySQL Community Server - GPL.  
 [root@db01 ~]#
~~~

## 1.10 MySQL 命令簇
### 1.10.1 MySQL 命令行工具
MySQL 服务基于 C/S 架构，用户主要使用客户端工具来与远程服务端进行连接，从而与 MySQL 服务进行交互。

MySQL 客户端常用选项
```bash
-V|--version #显示客户端版本
-u|--user=name #指定远程连接用户名
-p|--password[=name] #指定密码, 默认为空
-h|--host=host     #指定服务端主机
-P|--port=port #指定端口，默认3306
-S|--socket=name #指定连接时使用的socket文件，该文件在服务端启动后生成
-D|--database=db #指定数据库
-H|--html         #以html格式输出
-X|--xml           #以xml格式输出
-t|--table #以table格式输出，默认项
-E|--vertical #垂直显示执行结果
-v|--verbose #显示详细信息，配合 -t 选项
-C|--compress #启用压缩
-G|--named-commands #启用长命令
-e|--execute=sql #执行完就退出，非交互式运行
--prompt=name #修改命令提示符
--line-numbers     #输出行号
--print-defaults #打印参数列表，放在最前面
--connect-timeout=N #连接超时时长，单位S
--max-allowed-packet=N #一次查交互发送或反回数据的大小，默认16MB，最大值为1GB，最小值为4096字节
```
### 1.10.2 MySQL 客户端命令和服务端命令
MySQL 中的命令分为两类，分别是客户端命令和服务端命令。
客户端命令在本地执行。服务端命令发送到服务端执行，再返回执行结果到客户端上。客户端命令和服务端命令，都是通过 MySQL 客户端工具进行输入输出。
#### 1.10.2.1 客户端命令
```sql
mysql> ?

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
ssl_session_data_print Serializes the current SSL session data to stdout or file

For server side help, type 'help contents'
```
#### 1.10.2.2 服务端命令
```sql
mysql> help Contents
You asked for help about help category: "Contents"
For more information, type 'help <item>', where <item> is one of the following
categories:
   Account Management
   Administration
   Components
   Compound Statements
   Contents
   Data Definition
   Data Manipulation
   Data Types
   Functions
   Geographic Features
   Help Metadata
   Language Structure
   Loadable Functions
   Plugins
   Prepared Statements
   Replication Statements
   Storage Engines
   Table Maintenance
   Transactions
   Utility
```
查看详细帮助  help 服务端命令名，用于查看该部分的常见命令有哪些
##### 1️⃣ **Account Management（账户管理）**

👉 **管用户、管权限**
**包含内容：**
- `CREATE USER`
- `ALTER USER`
- `DROP USER`
- `GRANT`
- `REVOKE`
- `SHOW GRANTS`

**企业使用场景：**
- 创建业务账号
- 最小权限原则
- 多环境账号隔离（dev / test / prod）

---

##### 2️⃣ **Administration（管理）**

👉 **服务器级别管理命令**

**包含内容：**
- `SHOW VARIABLES`
- `SHOW STATUS`
- `SET GLOBAL`
- `SHUTDOWN`
- `RESET MASTER`    
- `FLUSH`  

**企业使用场景：**
- 动态修改参数
- 诊断性能问题
- 主从复制维护

---

##### 3️⃣ **Components（组件）**

👉 **MySQL 8.x 引入的新组件体系**

**包含内容：**
- 安装 / 卸载组件
- 组件状态管理

**企业使用场景：**
- MySQL 内部功能模块化
- 安全、监控类组件

---

##### 4️⃣ **Compound Statements（复合语句）**

👉 **流程控制语句（类似编程语言）**

**包含内容：**
- `BEGIN ... END`
- `IF`
- `CASE`
- `LOOP`
- `WHILE`
- `REPEAT`

**企业使用场景：**
- 存储过程
- 复杂业务逻辑下沉到数据库

---

##### 5️⃣ **Contents**

👉 **当前这个页面本身**

**作用：**
- 帮你“列目录”
- 没有具体 SQL


---

##### 6️⃣ **Data Definition（数据定义 DDL）**

👉 **定义结构，不是数据**

**包含内容：**
- `CREATE DATABASE`
- `CREATE TABLE`
- `ALTER TABLE`
- `DROP TABLE`
- `CREATE INDEX`

**企业使用场景：**
- 表结构设计
- 表结构变更
- 上线、迁移

---

##### 7️⃣ **Data Manipulation（数据操作 DML）**
👉 **真正“操作数据”的 SQL**

**包含内容：**
- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`
- `REPLACE`

**企业使用场景：**
- 所有业务 CRUD
- 报表
- 数据分析


---

##### 8️⃣ **Data Types（数据类型）**
👉 **字段类型说明**

**包含内容：**
- 数值类型（INT / BIGINT）
- 字符类型（VARCHAR / TEXT）
- 时间类型（DATE / DATETIME / TIMESTAMP）
- JSON

**企业使用场景：**
- 表设计
- 性能与存储优化
---

##### 9️⃣ **Functions（函数）**
👉 **内置函数大全**

**包含内容：**
- 字符串函数
- 时间函数
- 数学函数
- 聚合函数

**企业使用场景：**
- SQL 计算
- 报表
- ETL

---

##### 🔟 **Geographic Features（地理信息）**
👉 **GIS / 空间数据**

**包含内容：**
- POINT / LINESTRING
- 空间函数
- 地理索引

**企业使用场景：**

- 地图
    
- 定位
    
- LBS 服务
    

📌 **特定业务才会用**

---

##### 1️⃣1️⃣ **Help Metadata**

👉 **HELP 系统本身的元数据**

**包含内容：**
- help 表结构
- 分类定义

---
##### 1️⃣2️⃣ **Language Structure（语言结构）**
👉 **SQL 语法规则**

**包含内容：**
- 语法关键字
- 表达式
- 运算符

**企业使用场景：**
- 写复杂 SQL
- 理解 SQL 执行逻辑
---

##### 1️⃣3️⃣ **Loadable Functions（可加载函数）**

👉 **用户自定义函数（UDF）**

**包含内容：**
- 自定义 C/C++ 函数
- 函数注册

**企业使用场景：**
- 高性能计算
- 特殊业务逻辑

---

##### 1️⃣4️⃣ **Plugins（插件）**
👉 **MySQL 插件系统**

**包含内容：**
- 认证插件
- 审计插件    
- 密码插件    

**企业使用场景：**
- 安全    
- 合规    
- 扩展功能    
---
##### 1️⃣5️⃣ **Prepared Statements（预处理语句）**

👉 **防 SQL 注入 & 提升性能**

**包含内容：**
- `PREPARE`    
- `EXECUTE`    
- `DEALLOCATE`    

**企业使用场景：**
- 应用程序数据库访问    
- 高并发系统    
---
##### 1️⃣6️⃣ **Replication Statements（复制）**

👉 **主从 / 集群**
**包含内容：**
- `CHANGE MASTER TO`    
- `START SLAVE`    
- `STOP SLAVE`    
- `SHOW SLAVE STATUS`    

**企业使用场景：**

- 读写分离    
- 高可用    
- 容灾    
---
##### 1️⃣7️⃣ **Storage Engines（存储引擎）**

👉 **InnoDB / MyISAM 等**

**包含内容：**
- 引擎特性
- 引擎参数

**企业使用场景：**
- 性能调优
- 架构设计

---

##### 1️⃣8️⃣ **Table Maintenance（表维护）**

👉 **表级运维操作**
**包含内容：**
- `ANALYZE TABLE`
- `OPTIMIZE TABLE`    
- `CHECK TABLE`    
- `REPAIR TABLE`    

**企业使用场景：**
- 性能维护    
- 故障修复    
---

##### 1️⃣9️⃣ **Transactions（事务）**

👉 **ACID / 并发控制**

**包含内容：**
- `BEGIN`    
- `COMMIT`    
- `ROLLBACK`    
- 隔离级别    

**企业使用场景：**
- 金融    
- 订单    
- 强一致性业务    
---
##### 2️⃣0️⃣ **Utility（工具类命令）**

👉 **辅助工具**

**包含内容：**
- `DESCRIBE`
- `EXPLAIN`
- `HELP`

**企业使用场景：**

- 排查 SQL
- 分析执行计划
#### 1.10.2.3 MySQL 客户端常用命令
```bash
#常用命令
?|\?       #显示帮助
help|\h   #显示帮助
clear|\c  #清屏，直接使用无法生效，要配合 system 命令使用，清掉未执行的输入
exit|\q    #退出客户端
quit|\q   #退出客户端
status|\s #显示当前状态
use|\u #切换数据库
system|\! #调用系统命令
prompt|\R #修改提示符
source|\. #执行SQL脚本文件
connect|\r #客户端重新连接，使用之前的参数
tee|\T #设置文件名，将输出结果同时保存一份到指定文件
notee|\t #不保存输出结果至文件
delimiter|\d #自定义SQL语句分隔符
go|\g #将语句送到服务端执行
ego|\G #将语句送到服务端执行，垂直显示
print|\p #输出语句，但不执行
warnings|\W #总是输出告警信息
nowarning|\w #不输出告警信息
charset|\C #设置编码
edit|\e #先编辑SQL语句，再执行
```

```sql
-- 显示当前的服务状态
mysql> \s
--------------
mysql  Ver 8.4.0 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          12                                -- 连接 id
Current database:                                        -- 当前所处的数据库，切换到其他的数据库，会有标识
Current user:           root@localhost                -- 连接时使用的用户名
SSL:                    Not in use                         -- 使用启动 SSL
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.4.0 MySQL Community Server - GPL  -- 服务类型
Protocol version:       10                                                  -- 协议版本
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4                                        -- 服务器编码
Db     characterset:    utf8mb4                                         -- 数据库编码
Client characterset:    utf8mb4                                         -- 客户端编码
Conn.  characterset:    utf8mb4
UNIX socket:            /usr/local/mysql/data/mysql.sock           -- 连接时使用的 socket 文件
Binary data as:         Hexadecimal
Uptime:                 33 min 14 sec                              -- 当前服务器运行时长，每次重启后就会重置

-- 性能负载相关内容
Threads: 2  Questions: 12  Slow queries: 0  Opens: 155  Flush tables: 3  Open tables: 74  Queries per second avg: 0.006
--------------


Threads: 6
这表示数据库当前有6个线程正在运行。这些线程可能是用于处理客户端连接的线程。

Questions: 222
这表示自数据库服务器启动以来，总共收到了222个查询请求。这个数值可以帮助你了解数据库的活跃
度。

Slow queries: 0
这表示没有查询被认为是慢查询。慢查询通常是指执行时间超过某个阈值（如10秒）的查询。这个值为0表明所有查询都在合理的时间内完成，或者可能表示慢查询阈值设置得太高。

Opens: 38
这通常表示数据库表文件被打开的次数。这个数值可以帮助你了解数据库文件I/O的频繁程度。

Flush tables: 1
这表示自数据库服务器启动以来，执行了1次刷新表的操作。刷新表操作可以关闭所有打开的表文件，并重新打开它们，用于清理文件描述符缓存等目的。

Open tables: 31
这表示当前有31个表是打开的。打开的表可以更快地访问，因为它们已经在内存中。

Queries per second avg: 0.072
这表示平均每秒执行的查询数为0.072。这个数值较低，可能表明数据库当前的负载很低，或者服务器的性能没有被充分利用。
```
## 1.11 数据库用户密码管理
### 1.11.1 设置/修改密码
1、Linux 命令修改
格式 `mysqladmin -u用户 -p原密码(如果没有，不用写 -p 参数) password '新密码'`
2、SQL 语句修改
格式：alter user 用户名@'主机域' identified by '新密码'
```bash
17:23:02 root@redis02:~# mysqladmin -uroot password 123
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.
17:23:20 root@redis02:~# mysql -p123
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.4.0 MySQL Community Server - GPL

Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 


######################################################################
mysql> alter user  root@'localhost' identified by "321";
Query OK, 0 rows affected (0.02 sec)

mysql> exit
Bye
17:24:08 root@redis02:~# mysql -p321
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
### 1.11.2 重置密码
![](assets/mysql_manager/file-20260103172452222.png)

```bash
1、关闭数据库服务
17:25:41 root@redis02:~# systemctl stop mysqld

2、采用安全模式启动数据库
--skip-grant-tables 启动数据库不会加载授权表 
--skip-networking 启动数据库只会创建进程信息，不会生成网络端口信息 （可选）
17:31:14 root@redis02:~# /usr/local/mysql/bin/mysqld   --defaults-file=/etc/my.cnf   --skip-grant-tables   --skip-networking   --user=mysql

# 在另一个终端中进行连接
18:03:21 root@redis02:~# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.4.0 MySQL Community Server - GPL

Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

# 刷新授权表，重置密码
mysql> flush privileges;
Query OK, 0 rows affected (0.06 sec)

mysql> alter user root@'localhost' identified by '123';
Query OK, 0 rows affected (0.02 sec)

mysql> exit
Bye

# 终止安全模式数据库，重新启动数据库
18:04:12 root@redis02:~# pkill mysqld

18:04:18 root@redis02:~# systemctl restart mysqld 
18:04:28 root@redis02:~# mysql -p123 
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.4.0 MySQL Community Server - GPL

Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```
# 二、SQL 基本概念
## 2.1 SQL 介绍
SQL（Structured Query Language）是结构化查询语言，是一种用于管理关系型数据库的标准语言。SQL 用于与数据库进行交互，执行数据库的创建、查询、更新和删除等操作。SQL 使得开发人员、数据库管理员和数据分析师能够与数据库系统（如 MySQL、PostgreSQL、SQL Server、Oracle 等）进行通信。
- **1970 年代**：SQL 起源于 IBM 的 **System R 项目**，由 Raymond Boyce 和 Donald Chamberlin 提出，并在 1974 年发布了第一个 SQL 规范。这个版本称为 **SEQUEL（Structured English Query Language）**，它的目标是使用户能通过类似英语的语句查询数据库。
- **1986 年**：SQL 被 ANSI（美国国家标准协会）标准化，并在 1987 年成为 ISO（国际标准化组织）标准。
- **当前**：SQL 是管理关系型数据库的通用标准，几乎所有现代数据库管理系统（DBMS）都支持 SQL。
## 2.2 SQL 分类
SQL 可以分为以下几种主要类别：

- **数据定义语言（DDL，Data Definition Language）**：  
    用于定义数据库结构的语言。它包括创建、修改和删除数据库对象（如表、视图、索引等）的语句。
    - **CREATE**：创建数据库、表、视图等。
    - **ALTER**：修改数据库结构（例如添加列、修改列类型等）。
    - **DROP**：删除数据库、表、列等。
    - **TRUNCATE**：删除表中的所有数据（但保留表结构）。
- **数据操作语言（DML，Data Manipulation Language）**：  
    用于操作数据库中的数据，包括插入、更新、删除和查询数据的语句。
    - **SELECT**：查询数据库中的数据。
    - **INSERT**：向表中插入数据。
    - **UPDATE**：更新表中的现有数据。
    - **DELETE**：删除表中的数据。
- **数据控制语言（DCL，Data Control Language）**：  
    用于定义数据库用户的权限和访问控制。
    - **GRANT**：授予用户对数据库对象的权限。
    - **REVOKE**：撤销用户的权限。
- **事务控制语言（TCL，Transaction Control Language）**：  
    用于管理数据库事务。
    - **COMMIT**：提交事务，使修改生效。
    - **ROLLBACK**：回滚事务，撤销修改。
    - **SAVEPOINT**：设置事务的保存点，允许部分回滚。
https://dev.mysql.com/doc/refman/8.0/en/sql-statements.html

https://dev.mysql.com/doc/refman/5.7/en/sql-statements.html
## 2.3 SQL 规范
SQL 语法规则定义了如何编写合法的 SQL 语句。以下是一些基本的 SQL 语法规范：

- **大小写**：SQL 本身对大小写不敏感（即 `SELECT` 和 `select` 功能相同），但表名、列名等的大小写敏感性取决于数据库系统的设置。例如，在 MySQL 中，表名通常是大小写敏感的，而列名是大小写不敏感的。
- **分号（`;`）**：SQL 语句通常以分号结束，尤其是在多个语句连续执行时（如批处理脚本）。单条语句可以省略分号。
- **空格和换行**：SQL 语句的空格和换行不影响语句的执行，通常使用空格来分隔关键字、表名、列名、值等，换行使代码更易于阅读。
- **注释**：
    - 单行注释：`-- 这是一个单行注释`
    - 多行注释：`/* 这是一个多行注释 */`
## 2.4 @ 符号
### 2.4.1 **用户变量**

在 **MySQL** 中，`@` 符号常用于表示 **用户变量**。用户变量允许你在 SQL 语句中临时存储和使用数据。
- **声明用户变量**：  
    用户变量以 `@` 开头，并且不需要显式的声明或初始化。可以直接使用赋值语句进行初始化。
    `SET @my_var = 10; SELECT @my_var;`
    这将在查询中返回值 `10`。
- **在查询中使用用户变量**：  
    用户变量在查询中可以像列一样使用，它们在整个会话中有效，直到连接关闭或显式清除。
    `SET @sum = 0; SELECT @sum := @sum + amount FROM orders;`
    在这个例子中，`@sum` 是一个用户变量，它会累加 `orders` 表中的 `amount` 列的值。
    

### 2.4.2 **系统变量**

在 MySQL 中，`@` 符号也可以用于引用 **系统变量**，这些变量控制数据库的行为。
- **查询系统变量**：
    `SELECT @global.max_connections;`
    这将返回当前全局最大连接数的值。MySQL 的系统变量通常使用 `@` 符号进行访问。

# 三、MySQL 字符集设置
## 3.1 查看 MySQL 支持的字符集
```sql
mysql> show charset;
...
| gb2312   | GB2312 Simplified Chinese       | gb2312_chinese_ci   |      2 |
| gbk      | GBK Simplified Chinese          | gbk_chinese_ci      |      2 |
| utf8mb3  | UTF-8 Unicode                   | utf8mb3_general_ci  |      3 |  
| utf8mb4  | UTF-8 Unicode                   | utf8mb4_0900_ai_ci  |      4 |  
...
```
utf8mb3 等价于早期的 utf8 字符编码 可以识别中文信息 每个字符占用3字节 
utf8mb4 支持emoji 每个字符占用4字节
## 3.2 设置字符集
### 3.2.1 查看数据库使用的字符集
默认使用的是 utf8mb4
```sql
mysql> show create database mysql \G
*************************** 1. row ***************************
       Database: mysql
Create Database: CREATE DATABASE `mysql` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */
1 row in set (0.00 sec)

mysql> 
mysql> select @@character_set_server;
+------------------------+
| @@character_set_server |
+------------------------+
| utf8mb4                |
+------------------------+
1 row in set (0.00 sec)

mysql> 
```
### 3.2.2 修改数据库使用的字符集
mysqld 配置项有一个参数 character-set-server ，该值默认是 utf8mb4
```bash
13:58:53 root@redis02:~# mysqld --help --verbose | grep character-set-server
  -C, --character-set-server=name 
character-set-server                                         utf8mb4
13:59:05 root@redis02:~# 

8:27:55 root@redis02:~# cat /etc/my.cnf
[mysqld]
basedir=/usr/local/mysql
datadir=/lnxguru/apps/mysql/3306/data
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
pid-file=/lnxguru/apps/mysql/3306/data/mysqld.pid
log-error=/lnxguru/apps/mysql/3306/error.log
character-set-server=utf8mb3
[client]
socket=/lnxguru/apps/mysql/3306/data/mysql.sock
18:27:56 root@redis02:~# systemctl restart mysqld
18:28:04 root@redis02:~# mysql -p123
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.4.0 MySQL Community Server - GPL

Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select @@character-set-server;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'character-set-server' at line 1
mysql> select @@character_set_server;
+------------------------+
| @@character_set_server |
+------------------------+
| utf8mb3                |
+------------------------+
1 row in set (0.00 sec)
```
# 四、MySQL 校对规则/排序规则
## 4.1 MySQL 校对规则
可以实现区分大小写查询数据  test TEST  select ... where name='test'
可以影响数据显示的默认排序  abc abd abe ABC ABD ABE   abc ABC abd ABD abe ABE  abc abd abe ABC ABD ABE 
```sql
1、查看所有的校对规则
mysql> show collation;
...
utf8mb4_0900_ai_ci          | utf8mb4  | 255 | Yes     | Yes      |       0 | NO PAD        |
...
```
ai 不区分重音
as 区分重音
ci 不区分大小写，Case-insensitive的缩写 utf8mb4_0900_ai_ci 
cs 区分大小写，Case-sensitive的缩写 utf8mb4_0900_as_cs 
\_bin 采用二进制方式存储，影响数据排序
## 4.2 测试校对规则
```sql
1、创建三个测试数据表，并设置不同校对规则
mysql> create database test01;
Query OK, 1 row affected (0.01 sec)

mysql> use test01;
Database changed
mysql> create table t1(info char(3)) charset utf8mb4 collate utf8mb4_0900_ai_ci;
Query OK, 0 rows affected (0.03 sec)

mysql> create table t2(info char(3)) charset utf8mb4 collate utf8mb4_0900_as_cs;
Query OK, 0 rows affected (0.03 sec)

mysql> create table t3(info char(3)) charset utf8mb4 collate utf8mb4_bin;
Query OK, 0 rows affected (0.03 sec)

mysql> show tables;
+------------------+
| Tables_in_test01 |
+------------------+
| t1               |
| t2               |
| t3               |
+------------------+
3 rows in set (0.00 sec)

mysql> 


2、在三张表中插入相同数据
mysql> insert into t1 values('a'),('A'),('b'),('B'),('c'),('C');
Query OK, 6 rows affected (0.03 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> insert into t2 values('a'),('A'),('b'),('B'),('c'),('C');
Query OK, 6 rows affected (0.00 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> insert into t3 values('a'),('A'),('b'),('B'),('c'),('C');
Query OK, 6 rows affected (0.01 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> 

3、测试不同校对规则的区分字母大小写功能
-- ci 不具备区分大小功能；cs 和 bin 具备区分大小写功能
mysql> select * from t1 where info="A";
+------+
| info |
+------+
| a    |
| A    |
+------+
2 rows in set (0.00 sec)

mysql> select * from t2 where info="A";
+------+
| info |
+------+
| A    |
+------+
1 row in set (0.01 sec)

mysql> select * from t3 where info="A";
+------+
| info |
+------+
| A    |
+------+
1 row in set (0.00 sec)

4、测试数据信息排序规则
-- ci 和 cs 在排序时不具备区分大小写功能；bin 在排序时具备区分大小写功能
mysql> select * from t1 order by info;
+------+
| info |
+------+
| a    |
| A    |
| b    |
| B    |
| c    |
| C    |
+------+
6 rows in set (0.00 sec)

mysql> select * from t2 order by info;
+------+
| info |
+------+
| a    |
| A    |
| b    |
| B    |
| c    |
| C    |
+------+
6 rows in set (0.01 sec)

mysql> select * from t3 order by info;
+------+
| info |
+------+
| A    |
| B    |
| C    |
| a    |
| b    |
| c    |
+------+
6 rows in set (0.00 sec)
```
# 五、MySQL 数据类型
## 5.1 数据类型作用
在 MySQL 中，**数据类型决定了：**
- 占用多少磁盘空间
- 能不能用索引、索引效率
- 比较、排序规则
- 是否容易出 BUG
- 将来扩展是否痛苦
> **类型选错，后期几乎必然返工。**

## 5.2 数据类型总览
MySQL 数据类型主要分为 5 大类：

|大类|说明|
|---|---|
|数值类型|整数、小数|
|字符串类型|文本、二进制|
|日期时间类型|时间、日期|
|JSON 类型|半结构化数据|
|空间类型|GIS（了解即可）|
## 5.3 数值类型（Numeric Types）
### 5.3.1 整数类型
|类型|字节|有符号范围|无符号范围|
|---|---|---|---|
|TINYINT|1|-128 ~ 127|0 ~ 255|
|SMALLINT|2|-32K ~ 32K|0 ~ 65K|
|MEDIUMINT|3|-8M ~ 8M|0 ~ 16M|
|INT|4|-21亿 ~ 21亿|0 ~ 42亿|
|BIGINT|8|±9e18|0 ~ 18e18|
常见用法

|场景|推荐|
|---|---|
|状态位（0/1/2）|TINYINT|
|数量、小 ID|INT UNSIGNED|
|分布式 ID|BIGINT|
|是否字段|TINYINT(1)（本质仍是 TINYINT）|
 ❗ 常见误区
- ❌ `INT(11)` 不是长度（只是显示宽度，已废弃）
- ❌ 所有 ID 都用 BIGINT（浪费）
```sql
mysql> create table t4 (id tinyint);
Query OK, 0 rows affected (0.04 sec)

mysql> insert into t4 values (-127),(126);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t4;
+------+
| id   |
+------+
| -127 |
|  126 |
+------+
2 rows in set (0.00 sec)

mysql> insert into t4 values (128);
ERROR 1264 (22003): Out of range value for column 'id' at row 1
mysql> 
```

### 5.3.2 浮点类型
| 类型          | 名称      | 含义                        |
| ----------- | ------- | ------------------------- |
| float(m,d)  | 单精度浮点类型 | 可以保留的小数位最多 6 m 总个数 d 小数位  |
| double(m,d) | 双精度浮点类型 | 可以保留的小数位最多 17 m 总个数 d 小数位 |
| decimal     | 定点数类型   | 可以自定义                     |
DECIMAL 从 [MySQL](https://cloud.tencent.com/product/cdb?from_column=20065&from=20065) 5.1引入，列的声明语法是 DECIMAL(M,D)
对于声明语法 DECIMAL(M,D)，自变量的值范围如下：
- M是最大位数（精度），范围是1到65。可不指定，默认值是10。
- D是小数点右边的位数（小数位）。范围是0到30，并且不能大于M，可不指定，默认值是0。

|类型|是否精确|场景|
|---|---|---|
|FLOAT / DOUBLE|❌|统计、计算|
|DECIMAL|✅|金额、财务|
📌 **金额字段永远不要用 FLOAT / DOUBLE**

float 存储小数情况，最多保留6位小数，多出的部分截断，double 也一样
```sql
mysql> create table t5 (id float);
Query OK, 0 rows affected (0.04 sec)

mysql> insert into t5 values (1.123456),(2.1234567);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t5;
+---------+
| id      |
+---------+
| 1.12346 |
| 2.12346 |
+---------+
2 rows in set (0.00 sec)
```
float(m,d) 测试，如果小数位不够3位，会自动补全；总位数不能超过6位，小数点不算位数。
```sql
mysql> create table t6 (id float(6,3));
Query OK, 0 rows affected, 1 warning (0.04 sec)

mysql> insert into t6 values (1.123456),(2.123);
Query OK, 2 rows affected (0.01 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t6;
+-------+
| id    |
+-------+
| 1.123 |
| 2.123 |
+-------+
2 rows in set (0.01 sec)

mysql> insert into t6 values (1234567.123);
ERROR 1264 (22003): Out of range value for column 'id' at row 1
mysql> insert into t6 values (1234567);
ERROR 1264 (22003): Out of range value for column 'id' at row 1
mysql> insert into t6 values (123456);
ERROR 1264 (22003): Out of range value for column 'id' at row 1
mysql> insert into t6 values (123);
Query OK, 1 row affected (0.00 sec)

mysql> select * from t6;
+---------+
| id      |
+---------+
|   1.123 |
|   2.123 |
| 123.000 |
+---------+
3 rows in set (0.00 sec)

mysql>
```
decimal 存储情况
```sql
mysql> create table decimal01 (num decimal(20,19));
Query OK, 0 rows affected (0.04 sec)

mysql> insert into decimal01 values (0.1234567812345678123);
Query OK, 1 row affected (0.00 sec)

mysql> select * from decimal01;
+-----------------------+
| num                   |
+-----------------------+
| 0.1234567812345678123 |
+-----------------------+
1 row in set (0.00 sec)

mysql> insert into decimal01 values (0.12345678123456781234);
Query OK, 1 row affected, 1 warning (0.00 sec)

mysql> select * from decimal01;
+-----------------------+
| num                   |
+-----------------------+
| 0.1234567812345678123 |
| 0.1234567812345678123 |
+-----------------------+
2 rows in set (0.00 sec)
```
## 5.4 字符串类型（String Types）
### 5.4.1 CHAR vs VARCHAR
张三 char(10) 2个字符 --> 磁盘 10个字符 利用空格符补全剩余字符 "张三 空格 空格 ... " 10个字符，本身没有那么多字符，浪费磁盘使用率。
李四 varchar(10) 2个字符 --> 磁盘 "李四+结束字符" 3个字符

| 类型         | 特性                 | 含义                |
| ---------- | ------------------ | ----------------- |
| char(n)    | 固定长度字符类型（提高数据检索效率） | 存储字符范围 最多255个字符   |
| varchar(n) | 可变长度字符类型（提高磁盘利用率）  | 存储字符范围 最多65535个字符 |
使用建议

|场景|推荐|
|---|---|
|性别、国家码|CHAR|
|用户名、标题|VARCHAR|
|变长字段|VARCHAR|
❗ 坑点
- CHAR 会自动填充空格
- VARCHAR 最大 65535（受字符集影响）
```sql
mysql> create table t7 (name01 char(3),name02 varchar(10));
Query OK, 0 rows affected (0.04 sec)

mysql> insert into t7 values ("李五","王九");
Query OK, 1 row affected (0.01 sec)

mysql> insert into t7 values ("李五六七","王九");
ERROR 1406 (22001): Data too long for column 'name01' at row 1
mysql> select * from t7;
+--------+--------+
| name01 | name02 |
+--------+--------+
| 李五   | 王九   |
+--------+--------+
1 row in set (0.00 sec)

mysql>
```
### 5.4.2 TEXT 系列（大文本）
|类型|最大长度|
|---|---|
|TINYTEXT|255|
|TEXT|64K|
|MEDIUMTEXT|16M|
|LONGTEXT|4G|
企业建议
- ❌ 能不用 TEXT 就不用
- ❌ TEXT 列不适合做索引
- ✅ 大文本单独拆表
### 5.4.3 BINARY / VARBINARY（二进制）

|类型|场景|
|---|---|
|BINARY|固定二进制|
|VARBINARY|变长二进制|

常见用途：
- 哈希值
- token
- 加密数据
## 5.5 日期和时间类型（Time & Date）
| 类型        | 字节  | 范围        | 是否带时区 |
| --------- | --- | --------- | ----- |
| DATE      | 3   | 日期        | ❌     |
| DATETIME  | 8   | 日期+时间     | ❌     |
| TIMESTAMP | 4   | 1970~2038 | ✅     |
| TIME      | 3   | 时间        | ❌     |
| YEAR      | 1   | 年         | ❌     |
DATETIME vs TIMESTAMP（必会）

|项目|DATETIME|TIMESTAMP|
|---|---|---|
|是否存时区|❌ 不存|❌（但会转换）|
|是否受时区影响|❌|✅|
|存储方式|原值存储|UTC 存储|
|读取时|原样返回|按会话时区转换|
|自动维护|❌|✅（CURRENT_TIMESTAMP）|
📌 **生产建议**
- 业务时间：`DATETIME`
- 创建/更新时间：`TIMESTAMP`
```sql
mysql> create table t8 (d1 date,d2 time,d3 datetime,d4 timestamp);
Query OK, 0 rows affected (0.04 sec)

mysql> insert into t8 values (20200203,121212,20231212032536,19770203123223);
Query OK, 1 row affected (0.01 sec)

mysql> select * from t8;
+------------+----------+---------------------+---------------------+
| d1         | d2       | d3                  | d4                  |
+------------+----------+---------------------+---------------------+
| 2020-02-03 | 12:12:12 | 2023-12-12 03:25:36 | 1977-02-03 12:32:23 |
+------------+----------+---------------------+---------------------+
1 row in set (0.00 sec)

mysql>
```
## 5.6 枚举类型
ENUM 枚举类型（插入单个合理数据） -- SET 集合类型（插入多个合理数据）

1.enum 类型测试
```sql
mysql> create table t9 (gender enum("女","男"));
Query OK, 0 rows affected (0.04 sec)

mysql> insert into t9 values ("女");
Query OK, 1 row affected (0.01 sec)

mysql> select * from t9;
+--------+
| gender |
+--------+
| 女     |
+--------+
1 row in set (0.00 sec)

mysql> insert into t9 values ("sad");
ERROR 1265 (01000): Data truncated for column 'gender' at row 1
mysql>
```
2.set 类型测试输入
```sql
mysql> create table t10 (hobby set("乒乓球","游泳","篮球"));
Query OK, 0 rows affected (0.03 sec)

mysql> insert into t10 values ("乒乓球,游泳");
Query OK, 1 row affected (0.01 sec)

mysql> select * from t10;
+------------------+
| hobby            |
+------------------+
| 乒乓球,游泳      |
+------------------+
1 row in set (0.00 sec)
```
# 六、数据库的约束和属性
## 6.1 什么是「约束」和「属性」
### 6.1.1 约束是什么
> **约束是数据库层面对数据“合法性、唯一性、完整性”的强制规则**

📌 特点：
- 由 **数据库强制执行**
- 不依赖应用代码
- 防止“脏数据”进入数据库
### 6.1.2 字段属性（Attribute）是什么
> **字段属性是字段本身的行为和特性描述**

📌 特点：
- 决定字段是否可为空、默认值、是否自增等
- 更多是“字段自身规则”
## 6.2 MySQL 常见约束（Constraints）
|约束|作用|
|---|---|
|PRIMARY KEY|主键|
|UNIQUE|唯一约束|
|NOT NULL|非空|
|FOREIGN KEY|外键|
|CHECK|检查约束（8.0+）|
### 6.2.1 PRIMARY KEY（主键约束）
主键约束（PK primary key）： 限制列信息非空 且唯一 主键索引
作用
- 唯一标识一行数据
- 不能为 NULL
- 一个表只能有一个
```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY
);

-- 复合主键
PRIMARY KEY (user_id, role_id)
```
- 自动创建唯一索引
- InnoDB 使用主键作为聚簇索引
### 6.2.2 UNIQUE（唯一约束）
- 保证字段或字段组合唯一
- 允许多个 NULL（MySQL 特性）
唯一约束（UQ Unique）：限制列的信息不能重复，但可以输入空值 唯一索引
```sql
email VARCHAR(100) UNIQUE
```
📌 **常见场景**
- 用户名
- 邮箱
- 订单号
### 6.2.3 NOT NULL（非空约束）
禁止 NULL 值
```sql
username VARCHAR(50) NOT NULL

ALTER TABLE `x`.`test01` 
ADD COLUMN `gender` ENUM('男', '女') NOT NULL AFTER `name`;
```
📌 **生产建议**
> 能 NOT NULL 就 NOT NULL，配默认值

### 6.2.4 FOREIGN KEY（外键约束）
外键约束：当业务功能需要操作多张数据表时，需要控制操作表的顺序

当多张表插入数据和删除数据都会有合理顺序 
```sql
mysql> create table class(
       id int primary key auto_increment, 
       name varchar(10) not null comment "班级名字，不能为空",
       room varchar(10) comment '教室：允许为空',    
       ) charset utf8;
Query OK, 0 rows affected, 1 warning (0.03 sec)

mysql> create table student(
       id int primary key auto_increment,
       number char(10) not null unique comment "学号：不能重复",
       name varchar(10) not null comment "姓名", 
       c_id int, 
       foreign key(c_id) references class(id) 
       ) charset utf8;
Query OK, 0 rows affected, 1 warning (0.04 sec)

mysql> show tables;
+------------------+
| Tables_in_test02 |
+------------------+
| class            |
| student          |
+------------------+
2 rows in set (0.00 sec)

mysql> 

mysql> insert into class values (01,'class01','03');
Query OK, 1 row affected (0.01 sec)

mysql> insert into student values (01,'20252213','李四',01);
Query OK, 1 row affected (0.01 sec)
mysql> select * from class;
+----+---------+------+
| id | name    | room |
+----+---------+------+
|  1 | class01 | 03   |
+----+---------+------+
1 row in set (0.00 sec)

mysql> select * from student;
+----+----------+--------+------+
| id | number   | name   | c_id |
+----+----------+--------+------+
|  1 | 20252213 | 李四   |    1 |
+----+----------+--------+------+
1 row in set (0.00 sec)

mysql> delete from student where id=1;
Query OK, 1 row affected (0.01 sec)

mysql> delete from class  where id=01;
Query OK, 1 row affected (0.01 sec)

mysql> 
```

当设置外键约束，插入数据信息时，需要先在主表中插入数据，然后才能在子表中插入对应数据;

当设置外键约束，删除数据信息时，需要先在子表中删除数据，然后才能在主表中删除对应数据;

🎟以上4种约束信息，其中 PK UQ NN 约束需要创建表时进行设置，FK约束可以创建表后进行设置
## 6.3 字段属性（Column Attributes）
### 6.3.1 DEFAULT（默认值）
设定默认数据信息，可以实现自动填充
📌 建议：
- 所有 NOT NULL 字段尽量有 DEFAULT
```sql
mysql> create table t1 (id int ,sex char(3) default "未知");
Query OK, 0 rows affected (0.59 sec)

mysql> insert into t1 values (1,'男');
Query OK, 1 row affected (0.04 sec)

mysql> insert into t1(id) values (2);
Query OK, 1 row affected (0.02 sec)

mysql> select * from t1;
+------+--------+
| id   | sex    |
+------+--------+
|    1 | 男     |
|    2 | 未知   |
+------+--------+
2 rows in set (0.00 sec)
```
### 6.3.2 AUTO_INCREMENT（自增）
在 MySQL（InnoDB）中：
- `AUTO_INCREMENT` **不是简单的“当前最大值 + 1”**
- MySQL 会维护一个 **自增计数器**
- 每次插入时：
    - 如果未显式指定该列 → 使用计数器值
    - 如果显式插入了更大的值 → **计数器会被推进**
👉 **起始值 = 计数器的初始值**
规则
- 必须是索引
- 一个表只能有一个
设定数值信息自增，可以实现数值编号自增填充（一般配合主键使用）
📌 **生产建议**
- 自增主键只适合单库或非分布式系统
```sql
mysql> create table t2 (id int auto_increment unique,name varchar(5));
Query OK, 0 rows affected (0.20 sec)

mysql> insert into t2 values (1,'sss');
Query OK, 1 row affected (0.04 sec)

mysql> insert into t2(name) values('aaa');
Query OK, 1 row affected (0.02 sec)

mysql> select * from t2;
+----+------+
| id | name |
+----+------+
|  1 | sss  |
|  2 | aaa  |
+----+------+
2 rows in set (0.01 sec)
```
#### 6.3.2.1 自增列自定义起始值
##### 6.3.2.1.1 建表时指定
```sql
mysql> CREATE TABLE users (   id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,   username VARCHAR(50) NOT NULL ) AUTO_INCREMENT = 1000;
Query OK, 0 rows affected (0.23 sec)

mysql> INSERT INTO users (username) VALUES ('alice');
Query OK, 1 row affected (0.04 sec)

mysql> select * from users;
+------+----------+
| id   | username |
+------+----------+
| 1000 | alice    |
+------+----------+
1 row in set (0.01 sec)

mysql>
```
##### 6.3.2.1.2 建表后修改（常用）
```sql
mysql> alter table users AUTO_INCREMENT = 5000;
Query OK, 0 rows affected (0.10 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> INSERT INTO users (username) VALUES ('alice02');
Query OK, 1 row affected (0.03 sec)

mysql> select * from users;
+------+----------+
| id   | username |
+------+----------+
| 1000 | alice    |
| 5002 | alice02  |
+------+----------+
2 rows in set (0.01 sec)
```
📌 **生效条件（重要）：**
- 只有当 `5000 > 当前最大 id` 才会生效
- 否则 MySQL 会忽略该设置
```sql
mysql> INSERT INTO users (id,username) VALUES (10000,'alice02');
Query OK, 1 row affected (0.03 sec)

mysql> select * from users;
+-------+----------+
| id    | username |
+-------+----------+
|  1000 | alice    |
|  5002 | alice02  |
| 10000 | alice02  |
+-------+----------+
3 rows in set (0.00 sec)

mysql> alter table users AUTO_INCREMENT = 8000;
Query OK, 0 rows affected (0.11 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> INSERT INTO users (username) VALUES ('alice03');
Query OK, 1 row affected (0.02 sec)

mysql> select * from users;
+-------+----------+
| id    | username |
+-------+----------+
|  1000 | alice    |
|  5002 | alice02  |
| 10000 | alice02  |
| 10003 | alice03  |
+-------+----------+
4 rows in set (0.01 sec)
```
此时表中已经存在 MAX(id) = 200

##### 6.3.2.1.3 插入一个大值“推进”自增
```sql
mysql> insert into users values (20000,"tom");
Query OK, 1 row affected (0.04 sec)

mysql> delete from users where id=20000;
Query OK, 1 row affected (0.04 sec)

mysql> INSERT INTO users (username) VALUES ('alice04');
Query OK, 1 row affected (0.04 sec)

mysql> select * from users;
+-------+----------+
| id    | username |
+-------+----------+
|  1000 | alice    |
|  5002 | alice02  |
| 10000 | alice02  |
| 10003 | alice03  |
| 20002 | alice04  |
+-------+----------+
5 rows in set (0.00 sec)

mysql> 
```
##### 6.3.2.1.4 查看当前自增值的方法
```sql
mysql> show table status like 'users' \G
*************************** 1. row ***************************
           Name: users
         Engine: InnoDB
        Version: 10
     Row_format: Dynamic
           Rows: 5
 Avg_row_length: 3276
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: 20005
    Create_time: 2026-01-04 11:22:23
    Update_time: 2026-01-04 11:24:13
     Check_time: NULL
      Collation: utf8mb3_general_ci
       Checksum: NULL
 Create_options: 
        Comment: 
1 row in set (0.02 sec)
```
关注：Auto_increment: 
##### 6.3.2.1.5 自增起始值的关键规则
- MySQL 不允许把 AUTO_INCREMENT 设置为小于或等于当前最大值
- 删除数据 ≠ 回收自增值
	- `DELETE FROM users;` 自增值 **不会重置**
- TRUNCATE 会重置自增值
	- 自增值回到
		- 1（默认）
		- 或建表时指定的 AUTO_INCREMENT
##### 6.3.2.1.6 重启 MySQL 会不会影响？
|情况|结果|
|---|---|
|InnoDB|❌ 不会|
|MyISAM|可能变化|

📌 **InnoDB 是持久化的**

#### 6.3.2.2 设置自增列的步长
##### 6.3.2.2.1 什么是“自增步长”？
自增步长 = 每次生成 AUTO_INCREMENT 值时递增的幅度
```sql
-- 默认情况下
auto_increment_increment = 1

-- 也就是说
1, 2, 3, 4, 5 ...
```
##### 6.3.2.2.2 控制自增步长的两个核心参数
|参数|含义|
|---|---|
|`auto_increment_increment`|自增步长|
|`auto_increment_offset`|起始偏移量|

👉 **increment 决定“跳多远”，offset 决定“从哪开始”**
```sql
mysql> SET GLOBAL auto_increment_increment = 5;
Query OK, 0 rows affected (0.00 sec)

mysql> SET GLOBAL auto_increment_offset = 1;
Query OK, 0 rows affected (0.00 sec)

mysql> create table t6 (id int primary key auto_increment,name varchar(10));
Query OK, 0 rows affected (0.18 sec)

mysql> insert into t6(name) values ('ccc'),('ddd');
Query OK, 2 rows affected (0.05 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t6;
+----+------+
| id | name |
+----+------+
|  1 | ccc  |
|  6 | ddd  |
+----+------+
2 rows in set (0.00 sec)
```


### 6.3.3 COMMENT
```sql
mysql> create table stu (id int primary key auto_increment not null comment '学号',name varchar(10) comment '学生姓名');
Query OK, 0 rows affected (0.28 sec)

mysql>
```
### 6.3.4 UNSIGNED（无符号）
📌 适用场景：
- ID
- 数量
- 计数器
```sql
mysql> create table stu01 (id int unsigned primary key auto_increment not null   comment '学号',name varchar(10) comment '学生姓名');
Query OK, 0 rows affected (0.40 sec)

mysql> insert into stu01 values(-1,'aaa');
ERROR 1264 (22003): Out of range value for column 'id' at row 1
mysql>
```
## 6.4 约束 vs 属性：对比总结
|项目|约束|属性|
|---|---|---|
|关注点|数据关系/合法性|字段行为|
|是否跨字段|可以|一般不|
|是否强制|是|是|
|示例|PRIMARY KEY|DEFAULT|
# 七、数据库语句
SQL语句（Structured Query Language）具有循环语句 判断语句功能 -- 数据库存储过程（数据库中的脚本）

DDL语句（数据定义语句 Data Definition Language） create：创建数据库 创建数据表 创建索引信息 alter ：修改数据库属性信息（字符集 校对规则） 修改数据表属性信息（字符集 校对规则 表结构-列名 数据类型 约束属性 索引 引擎 名称） drop ：删除数据库 删除数据表（**磁盘层面删除数据**） 慎用 show ：做以上操作的查看确认

DCL语句（数据控制语句 Data Control Language） grant： 授权权限信息 revoke：回收权限信息 create user：创建用户 alter user： 修改用户 commit： 操作提交语句 -- 数据库事务知识 rollback：操作回滚语句 -- 数据库事务知识

DML语句（数据操作语句 Data Manipulation Language） 操作数据表中的数据内容 insert：在表中插入数据信息 delete：在表中删除数据信息 update：在表中修改数据信息

DQL语句（数据查询语句 Data Query Language） 查看表中的数据 select 查看单表数据信息 select + from + where + group by + having + order by + limit 查看多表数据信息 select + join on + union all 其他信息查看 查看数据库变量信息（内置变量-状态变量 功能变量） 查看数据库函数信息（获取特定数据） [https://dev.mysql.com/doc/refman/8.4/en/indexes.html](https://dev.mysql.com/doc/refman/8.4/en/indexes.html)

## 7.1 DDL 语句
> DDL（数据定义语言）用于定义和管理数据库对象的结构

操作对象包括：
- 数据库（DATABASE）
- 表（TABLE）
- 字段（COLUMN）
- 索引（INDEX）
- 视图（VIEW）
### 7.1.1 DDL 的核心特征
|特性|说明|
|---|---|
|自动提交|❌ 不能回滚|
|影响结构|✅|
|风险等级|⚠️ 高|
|执行频率|低（但重要）|

📌 **DDL = 架构级操作，不是业务操作**

### 7.1.2 数据库级 DDL
#### 7.1.2.1 创建数据库
基本语法
```sql
create database db_name;
create database db_name character set charset_name collate collation_name;

-- 生产中推荐写法
CREATE DATABASE db1
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
  
-- 查看数据库
show databases;
```
示例
```sql
mysql> create database test03;
Query OK, 1 row affected (0.06 sec)

mysql> create database test04 character set utf8mb4 collate utf8mb4_0900_ai_ci;
Query OK, 1 row affected (0.05 sec)
```
#### 7.1.2.2 删除数据库
```sql
drop database db_name;
```
示例
```sql
mysql> drop database test05;
Query OK, 0 rows affected (0.24 sec)
```
#### 7.1.2.3 修改数据库
```sql
alter database db_name character set charset_name collate collation_name;
```
示例
```bash
mysql> show create database test04 \G
*************************** 1. row ***************************
       Database: test04
Create Database: CREATE DATABASE `test04` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */
1 row in set (0.01 sec)


mysql> alter database test04 character set utf8mb3 collate utf8mb3_general_ci;
Query OK, 1 row affected, 2 warnings (0.04 sec)

mysql> show create database test04 \G
*************************** 1. row ***************************
       Database: test04
Create Database: CREATE DATABASE `test04` /*!40100 DEFAULT CHARACTER SET utf8mb3 */ /*!80016 DEFAULT ENCRYPTION='N' */
1 row in set (0.01 sec)
```
#### 7.1.2.4 使用/切换数据库
```sql
use db_name;
```
示例
```sql
mysql> use test03;
Database changed
mysql> 
```
### 7.1.3 表级 DDL
#### 7.1.3.1 创建表（CREATE TABLE）
```sql
create table 表名 (字段名 数据类型 约束 属性,字段名 数据类型 约束 属性,索引设置) 引擎设置 字符集 校对规则;


mysql> create table t11  (id int primary key not null,name char(10) comment "姓名");
Query OK, 0 rows affected (0.24 sec)

mysql> show   create table t11 \G
*************************** 1. row ***************************
       Table: t11
Create Table: CREATE TABLE `t11` (
  `id` int NOT NULL,
  `name` char(10) DEFAULT NULL COMMENT '姓名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
1 row in set (0.01 sec)

mysql> 
```
==生产规范示例==
```sql
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
  username VARCHAR(50) NOT NULL COMMENT '用户名',
  email VARCHAR(100) NOT NULL COMMENT '邮箱',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '0禁用 1启用',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COMMENT='用户表';
```

| 项       | 原因       |
| ------- | -------- |
| InnoDB  | 支持事务     |
| utf8mb4 | 支持 emoji |
| COMMENT | 企业必备     |
| BIGINT  | 扩展性      |
#### 7.1.3.2 查看表结构
`desc table_name;` （可以获取表结构 数据类型 约束属性设置）

`show create table table_name;` （可以获取创建表语句 从而了解表的结构 表的引擎和字符集/校对规则 还有注释信息）

`show index from t111;` （可以查看表的详细索引设置）
```sql
mysql> show   create table t11 \G
*************************** 1. row ***************************
       Table: t11
Create Table: CREATE TABLE `t11` (
  `id` int NOT NULL,
  `name` char(10) DEFAULT NULL COMMENT '姓名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
1 row in set (0.01 sec)

mysql> desc t11;
+-------+----------+------+-----+---------+-------+
| Field | Type     | Null | Key | Default | Extra |
+-------+----------+------+-----+---------+-------+
| id    | int      | NO   | PRI | NULL    |       |
| name  | char(10) | YES  |     | NULL    |       |
+-------+----------+------+-----+---------+-------+
2 rows in set (0.04 sec)

mysql> show index from t11;
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| t11   |          0 | PRIMARY  |            1 | id          | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
1 row in set (0.04 sec)

mysql>
```
#### 7.1.3.3 修改表
##### 7.1.3.3.1 修改表名
```sql
alter table table_old_name rename to table_new_name;

mysql> alter table t11 rename to t12;
Query OK, 0 rows affected (0.18 sec)

mysql> show tables;
+------------------+
| Tables_in_test03 |
+------------------+
| t12              |
+------------------+
1 row in set (0.01 sec)

mysql>
```
##### 7.1.3.3.2 修改字符集/校对规则
```sql
alter table t111 character set charset_new_name , collate collation_new_name;

mysql> alter table t12 character set gbk,collate gbk_chinese_ci;
Query OK, 0 rows affected (0.17 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show create table t12;
+-------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table | Create Table                                                                                                                                                              |
+-------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| t12   | CREATE TABLE `t12` (
  `id` int NOT NULL,
  `name` char(10) CHARACTER SET utf8mb3 DEFAULT NULL COMMENT '姓名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk   |
+-------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```
##### 7.1.3.3.3 修改表字段信息
###### 7.1.3.3.3.1 添加新的字段
**添加的列在表中所有字段最后面**
```sql
alter table table_name add column new_column_name enum("男","女","未知") not null default "未知";

mysql> alter table t12 add column sex enum("男","女","未知") not null default "未知";
Query OK, 0 rows affected (0.21 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc t12;
+-------+----------------------------+------+-----+---------+-------+
| Field | Type                       | Null | Key | Default | Extra |
+-------+----------------------------+------+-----+---------+-------+
| id    | int                        | NO   | PRI | NULL    |       |
| name  | char(10)                   | YES  |     | NULL    |       |
| sex   | enum('男','女','未知')     | NO   |     | 未知    |       |
+-------+----------------------------+------+-----+---------+-------+
3 rows in set (0.02 sec)

mysql>

```
**添加的列在表中指定列后面**
```sql
alter table test03.t111 add column age tinyint not null default 18 after name;

mysql> alter table t12 add column age int unsigned after name;
Query OK, 0 rows affected (0.36 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc t12;
+-------+----------------------------+------+-----+---------+-------+
| Field | Type                       | Null | Key | Default | Extra |
+-------+----------------------------+------+-----+---------+-------+
| id    | int                        | NO   | PRI | NULL    |       |
| name  | char(10)                   | YES  |     | NULL    |       |
| age   | int unsigned               | YES  |     | NULL    |       |
| sex   | enum('男','女','未知')     | NO   |     | 未知    |       |
+-------+----------------------------+------+-----+---------+-------+
4 rows in set (0.01 sec
```
**添加的列在表中首行**
```sql
alter table table_name address char(20) not null default "未知" first;

mysql> alter table t12 add column school_name varchar(20)  first;
Query OK, 0 rows affected (0.37 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc t12;
+-------------+----------------------------+------+-----+---------+-------+
| Field       | Type                       | Null | Key | Default | Extra |
+-------------+----------------------------+------+-----+---------+-------+
| school_name | varchar(20)                | YES  |     | NULL    |       |
| id          | int                        | NO   | PRI | NULL    |       |
| name        | char(10)                   | YES  |     | NULL    |       |
| age         | int unsigned               | YES  |     | NULL    |       |
| sex         | enum('男','女','未知')     | NO   |     | 未知    |       |
+-------------+----------------------------+------+-----+---------+-------+
5 rows in set (0.01 sec)

mysql> 
```
###### 7.1.3.3.3.2 修改原有字段
`alter table t111 modify column ...` 只修改列的数据类型、约束，不能修改列名

`alter table t111 change column ...` 同时修改列名和列的数据类型

```sql
-- 修改原有字段名称
alter table table_name column_old_name column_new_name char(3) not null default "18" comment "年龄";


mysql> alter table t12 change column name mingcheng varchar(20) ;
Query OK, 0 rows affected (0.85 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc t12;
+-------------+----------------------------+------+-----+---------+-------+
| Field       | Type                       | Null | Key | Default | Extra |
+-------------+----------------------------+------+-----+---------+-------+
| school_name | varchar(20)                | YES  |     | NULL    |       |
| id          | int                        | NO   | PRI | NULL    |       |
| mingcheng   | varchar(20)                | YES  |     | NULL    |       |
| age         | int unsigned               | YES  |     | NULL    |       |
| sex         | enum('男','女','未知')     | NO   |     | 未知    |       |
+-------------+----------------------------+------+-----+---------+-------+
5 rows in set (0.01 sec)


mysql> alter table t12 modify column mingcheng varchar(30) not null;
Query OK, 0 rows affected (0.82 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc t12;
+-------------+----------------------------+------+-----+---------+-------+
| Field       | Type                       | Null | Key | Default | Extra |
+-------------+----------------------------+------+-----+---------+-------+
| school_name | varchar(20)                | YES  |     | NULL    |       |
| id          | int                        | NO   | PRI | NULL    |       |
| mingcheng   | varchar(30)                | NO   |     | NULL    |       |
| age         | int unsigned               | YES  |     | NULL    |       |
| sex         | enum('男','女','未知')     | NO   |     | 未知    |       |
+-------------+----------------------------+------+-----+---------+-------+
5 rows in set (0.01 sec)


-- 删除已有字段
alter table t111 drop column_name ;
mysql> alter table t12 drop school_name;
Query OK, 0 rows affected (0.25 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc t12;
+-----------+----------------------------+------+-----+---------+-------+
| Field     | Type                       | Null | Key | Default | Extra |
+-----------+----------------------------+------+-----+---------+-------+
| id        | int                        | NO   | PRI | NULL    |       |
| mingcheng | varchar(30)                | NO   |     | NULL    |       |
| age       | int unsigned               | YES  |     | NULL    |       |
| sex       | enum('男','女','未知')     | NO   |     | 未知    |       |
+-----------+----------------------------+------+-----+---------+-------+
4 rows in set (0.02 sec)
```
#### 7.1.3.4 删除表
##### 7.1.3.4.1 表和数据都删除
**将磁盘中的表文件删除，删除后会释放磁盘空间**
```sql
mysql> drop table t12;
Query OK, 0 rows affected (0.21 sec)
```
##### 7.1.3.4.2 清空表
`truncate t111 ;` 会清除自增序列，效率快，可以释放磁盘空间

`delete from t111;` 不会清除自增序列，效率慢，无法释放磁盘空间（标记删除）
```sql
mysql> create table t111 (id int primary key not null auto_increment,name char(10));
Query OK, 0 rows affected (0.24 sec)

mysql> insert into t111(name) values ("aaa"),("bbb");
Query OK, 2 rows affected (0.05 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t111;
+----+------+
| id | name |
+----+------+
|  4 | aaa  |
|  9 | bbb  |
+----+------+
2 rows in set (0.01 sec)

-- truncate 
mysql> truncate t111;
Query OK, 0 rows affected (0.28 sec)

mysql> select * from t111;
Empty set (0.02 sec)

mysql> insert into t111(name) values ("aaa"),("bbb");
Query OK, 2 rows affected (0.03 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t111;
+----+------+
| id | name |
+----+------+
|  4 | aaa  |
|  9 | bbb  |
+----+------+
2 rows in set (0.02 sec)


-- delete
mysql> delete from t111;
Query OK, 2 rows affected (0.05 sec)

mysql> select * from t111;
Empty set (0.00 sec)

mysql> insert into t111(name) values ("aaa"),("bbb");
Query OK, 2 rows affected (0.03 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t111;
+----+------+
| id | name |
+----+------+
| 25 | aaa  |
| 30 | bbb  |
+----+------+
2 rows in set (0.01 sec)
```
#### 7.1.3.5 练习

> [!NOTE] 表级 DDL 练习
> 01 创建一个school数据库，字符集设置设置为utf8mb3 
> 
> 02 在数据库中创建student(学生表) 
> 	- 包含sno(学号 整数类型 非空 非负 主键约束 自增属性) 
> 	- 包含sname(姓名 字符串类型 非空) 
> 	- 包含sage(年龄 整数类型 非负 非空) 
> 	- 包含ssex(性别 枚举类型 非空 默认为男) 
> 
> 03 在数据库中创建course(课程表) 
> 	- 包含cno(课程编号 整数类型 非空 主键约束) 
> 	- 包含cname(课程名称 字符串类型 非空) 
> 	- 包含tno(教师编号 整数类型 非空) 
> 	
> 04 在数据库中创建sc(成绩表) 
> 	- 包含sno(学号 整数类型 非空) 
> 	- 包含cno(课程编号 整数类型 非空) 
> 	- 包含score(成绩 整数类型 非空 默认值0) 
> 	
> 05 在数据库中创建teacher(教师表) 
> 	- 包含tno(教师编号 整数类型 非负 主键约束) 
> 	- 包含tname(教师名称 字符串类型 非空)

```sql
1、
mysql> create database school character set utf8mb4;
Query OK, 1 row affected (0.06 sec)

mysql> show create database school;
+----------+----------------------------------------------------------------------------------------------------------------------------------+
| Database | Create Database                                                                                                                  |
+----------+----------------------------------------------------------------------------------------------------------------------------------+
| school   | CREATE DATABASE `school` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */ |
+----------+----------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)


mysql> create table student (sno int unsigned not null primary key auto_increment,sname varchar(10) not null,sage int unsigned not null,ssex enum("男","女") default "男");
Query OK, 0 rows affected (0.35 sec)

mysql> create table course (cno int not null primary key,cname varchar(10) not null,tno int not null);
Query OK, 0 rows affected (0.25 sec)

mysql> create table sc (sno int not null,cno int not null,score int not null default 0);
Query OK, 0 rows affected (0.30 sec)

mysql> create table teacher (tno int not null primary key,tname varchar(10) not null);
Query OK, 0 rows affected (0.27 sec)
```
## 7.2 DML 语句
### 7.2.1 什么是 DML 语句
> **DML 用于对表中的数据进行操作**

包括四大核心语句：

|类型|关键字|
|---|---|
|查询|SELECT|
|插入|INSERT|
|更新|UPDATE|
|删除|DELETE|
📌 **注意**
- DML 作用的是 **数据**
- DML **可以回滚（在事务中）**
- DML 是生产事故高发区
数据表相关数据管理 运维人员：插入数据 修改数据 删除数据 查询数据 开发人员：CRUD(create=创建数据-注册 read=读取数据-登录 update=修改数据-信息调整 delete=删除数据-订单信息删除)
### 7.2.2 插入数据
#### 7.2.2.1 标准插入语句
column1 和 value1 要对应
```sql
insert into table_name (column1,column2,...) values (value1,value2,...)
```
```sql
mysql> desc t111;
+-------+--------------+------+-----+---------+----------------+
| Field | Type         | Null | Key | Default | Extra          |
+-------+--------------+------+-----+---------+----------------+
| id    | int          | NO   | PRI | NULL    | auto_increment |
| age   | int unsigned | NO   |     | 18      |                |
| name  | char(10)     | YES  |     | NULL    |                |
+-------+--------------+------+-----+---------+----------------+
3 rows in set (0.01 sec)

mysql> insert into  t111(id,age,name) values (1,12,"aaa"),(2,44,"sss");
Query OK, 2 rows affected (0.03 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t111;
+----+-----+------+
| id | age | name |
+----+-----+------+
|  1 |  12 | aaa  |
|  2 |  44 | sss  |
+----+-----+------+
2 rows in set (0.01 sec)
```
#### 7.2.2.2 简单插入方式
表中具有自增列 默认值的列 可以为空的列 都可以忽略插入
```sql
mysql> insert into t111(name) values ("rrr"),("yyy");
Query OK, 2 rows affected (0.03 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from t111;
+----+-----+------+
| id | age | name |
+----+-----+------+
|  1 |  12 | aaa  |
|  2 |  44 | sss  |
| 35 |  18 | rrr  |
| 36 |  18 | yyy  |
+----+-----+------+
4 rows in set (0.00 sec)
```
可以省略字段列信息
⚠️**在省略字段信息后，后面的 values 中就不能省略了，不管是自增还是可以为空都不被允许省略**
```sql
mysql> insert into t111 values(5,123,"asd");
Query OK, 1 row affected (0.02 sec)

mysql> select * from t111;
+----+-----+------+
| id | age | name |
+----+-----+------+
|  1 |  12 | aaa  |
|  2 |  44 | sss  |
|  5 | 123 | asd  |
| 35 |  18 | rrr  |
| 36 |  18 | yyy  |
+----+-----+------+
5 rows in set (0.00 sec)
```
### 7.2.3 修改数据
```sql
update table_name column01=value,column02=value where 条件;

mysql> select * from t111;
+----+-----+------+
| id | age | name |
+----+-----+------+
|  1 |  12 | aaa  |
|  2 |  44 | sss  |
|  5 | 123 | asd  |
| 35 |  18 | rrr  |
| 36 |  18 | yyy  |
+----+-----+------+
5 rows in set (0.01 sec)

mysql> update t111 set name="bbb" where id=1;
Query OK, 1 row affected (0.04 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from t111;
+----+-----+------+
| id | age | name |
+----+-----+------+
|  1 |  12 | bbb  |
|  2 |  44 | sss  |
|  5 | 123 | asd  |
| 35 |  18 | rrr  |
| 36 |  18 | yyy  |
+----+-----+------+
5 rows in set (0.01 sec)

-- 一次性修改多个数据
mysql> update t111 set name="zzz",age=34 where id=2 and name="sss";
Query OK, 1 row affected (0.04 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from t111;
+----+-----+------+
| id | age | name |
+----+-----+------+
|  1 |  12 | bbb  |
|  2 |  34 | zzz  |
|  5 | 123 | asd  |
| 35 |  18 | rrr  |
| 36 |  18 | yyy  |
+----+-----+------+
5 rows in set (0.00 sec)
```
### 7.2.4 删除数据
如果不指定条件就是清空数据表
```sql
delete from table_name where 条件;

mysql> delete from t111 where id>=35;
Query OK, 2 rows affected (0.04 sec)

mysql> select * from t111;
+----+-----+------+
| id | age | name |
+----+-----+------+
|  1 |  12 | bbb  |
|  2 |  34 | zzz  |
|  5 | 123 | asd  |
+----+-----+------+
3 rows in set (0.01 sec)


-- 清空数据表
mysql> delete from t111;
Query OK, 3 rows affected (0.06 sec)

mysql> select * from t111;
Empty set (0.01 sec)
```
## 7.3 DCL
> **DCL 用于管理数据库用户、权限和访问控制**

它解决的核心问题只有一个：

> **谁（User）可以在什么地方（DB / Table）做什么事情（Privilege）**

|分类|语句|
|---|---|
|用户管理|`CREATE USER`、`DROP USER`、`ALTER USER`|
|权限控制|`GRANT`、`REVOKE`|
|权限查看|`SHOW GRANTS`|
📌 **DCL 不操作数据、不操作表结构，只操作“权限体系”**
### 7.3.1 MySQL 的用户模型
#### 7.3.1.1 MySQL 用户的完整形式
👉 **同一个用户名，不同 host，是完全不同的账号**
```sql
'用户名'@'来源主机'

'root'@'localhost'
'app'@'%'
'app'@'10.0.0.%'
```
#### 7.3.1.2 host 的匹配规则
|host 写法|含义|
|---|---|
|localhost|仅本机|
|%|任意主机|
|10.0.0.%|一个网段|
|10.0.0.5|指定 IP|

📌 **连接时 MySQL 会优先匹配“最精确”的 host**
### 7.3.2 CREATE USER —— 创建用户
```sql
CREATE USER 'user1'@'localhost' IDENTIFIED BY 'StrongPass123!';
```
📌 MySQL 8.x 默认认证插件是：caching_sha2_password
```sql
-- 指定插件创建用户
CREATE USER 'user2'@'%'
IDENTIFIED WITH caching_sha2_password
BY 'StrongPass123!';
```
示例：
```sql
mysql> create user mysql01@'localhost';  -- 此用户登录是免密登录
Query OK, 0 rows affected (0.04 sec)     

mysql> create user mysql02@'127.0.0.1' identified by '111';  -- 完整创建用户信息
Query OK, 0 rows affected (0.01 sec)

mysql> create user mysql03@'192.168.121.52' identified by '111';  -- 远程用户登录
Query OK, 0 rows affected (0.03 sec)

mysql> create user mysql04@'192.168.121.%' identified by '111';  -- 指定一个网段登录
Query OK, 0 rows affected (0.01 sec)
```
### 7.3.3 查看用户
1.通过 user() 函数查询

2.在 mysql.user 表中查询，authentication_string 列是加密显示的，如果该用户没有密码，则该列为空
```sql
mysql> select user();
+----------------+
| user()         |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.01 sec)

mysql> 

mysql> select user,host,authentication_string from mysql.user;
```
### 7.3.4 删除用户
1.`drop user`

2.`delete from mysql.user where ....`
```sql
mysql> drop user mysql01@'localhost';
Query OK, 0 rows affected (0.04 sec)

mysql> delete from mysql.user where user='mysql03' and host='192.168.121.52';
Query OK, 1 row affected (0.01 sec)
```
### 7.3.5 权限管理
数据库系统环境中都有什么权限可以设置？
```sql
show privileges;
Alter                 Tables                       To alter the table                   -- 修改表的属性信息 
Create                Databases,Tables,Indexes     To create new databases and tables   -- 创建数据库和数据表权限
Create user           Server Admin                 To create new users                  -- 可以创建新用户
Delete                Tables                       To delete existing rows              -- 可以删除表中数据  	*****
Drop                  Databases,Tables             To drop databases, tables, and views -- 可以删除库，可以删除表
Grant option          Databases,Tables             To give to other users those privileges you possess  -- 可以给别人进行授权的权限
Insert                Tables                       To insert data into tables           -- 可以插入数据权限  	*****
Select                Tables                       To retrieve rows from table          -- 可以查询表数据信息	*****
Show databases        Server Admin                 To see all databases with SHOW DATABASES    -- 可以查看所有数据库信息
Update                Tables                       To update existing rows              -- 可以修改表数据信息 	*****
Usage                 Server Admin                 No privileges - allow connect only   -- 只能登录数据库权限

....
```
#### 7.3.5.1 设置用户权限
权限操作对象： 
_._ -- 可以管理所有库，以及库中的所有表 
库名.* -- 可以管理指定库，以及库中的所有表 
库名.表名 -- 可以管理指定库，以及库中的指定表

grant 权限01,权限02 on database.table to 用户;
```sql
mysql> create user dba@'localhost' identified by '111';
Query OK, 0 rows affected (0.01 sec)

mysql> grant all on *.* to dba@'localhost';
Query OK, 0 rows affected (0.01 sec)

mysql> 


mysql> create database xixi;
Query OK, 1 row affected (0.01 sec)

mysql> grant Alter,Create,Delete,Drop,Insert,Select,Update on xixi.* to ops@'localhost';
Query OK, 0 rows affected (0.00 sec)
```
🗒mysql 8.0之前版本：可以利用授权命令进行授权 并创建用户 
grant select on _._ xiaoA@'localhost' identified by '123456'; 
mysql 8.0之后版本：授权和用户创建要分开执行 
create user ... 
grant 权限 ...
#### 7.3.5.2 查看用户权限
show grants for 用户信息
```sql
mysql> show grants for ops@'localhost';
+--------------------------------------------------------------------------------------------+
| Grants for ops@localhost                                                                   |
+--------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `ops`@`localhost`                                                    |
| GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER ON `xixi`.* TO `ops`@`localhost` |
+--------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> 
```
#### 7.3.5.3 撤销用户权限
revoke 权限 on database.table from 用户信息;
```sql
mysql> revoke DROP on xixi.* from ops@'localhost';
Query OK, 0 rows affected (0.01 sec)

mysql> show grants for ops@'localhost';
+--------------------------------------------------------------------------------------+
| Grants for ops@localhost                                                             |
+--------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `ops`@`localhost`                                              |
| GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER ON `xixi`.* TO `ops`@`localhost` |
+--------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)
```
#### 7.3.5.4 权限存储位置
user -- 用户授权表 全局授权信息 
db -- 用户授权表 数据库授权信息 
tables_priv -- 用户授权表 数据表授权信息

1.创建测试用户，并授予权限

test01@'%' create,alter,drop _._ 
test02@'%' select,update,insert xixi.* 
test03@'%' delete xixi.t1
```sql
mysql> create user test01@'%' ;
Query OK, 0 rows affected (0.01 sec)

mysql> create user test02@'%' ;
Query OK, 0 rows affected (0.00 sec)

mysql> create user test03@'%' ;
Query OK, 0 rows affected (0.01 sec)

mysql> grant create,alter,drop on *.* to test01@'%';
Query OK, 0 rows affected (0.00 sec)

mysql> grant select,update,insert  on xixi.* to test02@'%';
Query OK, 0 rows affected (0.00 sec)

mysql> create table xixi.t1(id int);
Query OK, 0 rows affected (0.05 sec)

mysql> grant delete on xixi.t1 to test03@'%';
Query OK, 0 rows affected (0.01 sec)
```
2.查看授权表中的信息

test01 用户是对所有库、表的权限，所以保存在了 mysql.user 表中，在 mysql.db 和 mysql.tables_priv 表中没有保存

test02 用户是对一个库及这个库下的所有表设置权限，所以权限保存在 mysql.db 表中，在 mysql.user 和 mysql.tables_priv 表中没有保存

test03 用户是对某一个表设置权限，所以权限保存在 mysql.tables_priv 表中，在 mysql.db 和 mysql.user 表中没有保存
```sql
mysql> select * from mysql.user where user='test01' \G
*************************** 1. row ***************************
                    Host: %
                    User: test01
             Select_priv: N
             Insert_priv: N
             Update_priv: N
             Delete_priv: N
             Create_priv: Y
               Drop_priv: Y
             Reload_priv: N
           Shutdown_priv: N
            Process_priv: N
               File_priv: N
              Grant_priv: N
         References_priv: N
              Index_priv: N
              Alter_priv: Y
            Show_db_priv: N
              Super_priv: N
   Create_tmp_table_priv: N
        Lock_tables_priv: N
            Execute_priv: N
         Repl_slave_priv: N
        Repl_client_priv: N
        Create_view_priv: N
          Show_view_priv: N
     Create_routine_priv: N
      Alter_routine_priv: N
        Create_user_priv: N
              Event_priv: N
            Trigger_priv: N
  Create_tablespace_priv: N
                ssl_type: 
              ssl_cipher: 0x
             x509_issuer: 0x
            x509_subject: 0x
           max_questions: 0
             max_updates: 0
         max_connections: 0
    max_user_connections: 0
                  plugin: caching_sha2_password
   authentication_string: 
        password_expired: N
   password_last_changed: 2025-06-25 16:46:43
       password_lifetime: NULL
          account_locked: N
        Create_role_priv: N
          Drop_role_priv: N
  Password_reuse_history: NULL
     Password_reuse_time: NULL
Password_require_current: NULL
         User_attributes: NULL
1 row in set (0.00 sec)

mysql> select * from mysql.db  where user='test01' \G
Empty set (0.00 sec)

mysql> select * from mysql.tables_priv  where user='test01' \G
Empty set (0.00 sec)


mysql> select * from mysql.db  where user='test02' \G
*************************** 1. row ***************************
                 Host: %
                   Db: xixi
                 User: test02
          Select_priv: Y
          Insert_priv: Y
          Update_priv: Y
          Delete_priv: N
          Create_priv: N
            Drop_priv: N
           Grant_priv: N
      References_priv: N
           Index_priv: N
           Alter_priv: N
Create_tmp_table_priv: N
     Lock_tables_priv: N
     Create_view_priv: N
       Show_view_priv: N
  Create_routine_priv: N
   Alter_routine_priv: N
         Execute_priv: N
           Event_priv: N
         Trigger_priv: N
1 row in set (0.00 sec)



mysql> select * from mysql.tables_priv  where user='test03' \G
*************************** 1. row ***************************
       Host: %
         Db: xixi
       User: test03
 Table_name: t1
    Grantor: root@localhost
  Timestamp: 2025-06-25 16:52:02
 Table_priv: Delete
Column_priv: 
1 row in set (0.00 sec)


mysql> select * from mysql.db  where user='test03' \G
Empty set (0.00 sec)

mysql> 

```
## 7.4 DQL
