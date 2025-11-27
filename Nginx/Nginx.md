[TOC]



# 一、Nginx 基础

## 1.1 Nginx 介绍

Nginx 是一个强大而灵活的服务器软件，适用于处理高流量、高并发的Web应用程序，同时具有反向代理、负载均衡、静态文件服务等多种功能。由于其性能和可配置性，NGINX被广泛应用于许多大型网站和应用，NGINX 由伊戈尔·赛索耶夫为俄罗斯访问量第二的Rambler.ru 站点开发的，开发工作最早从2002年开始，第一版发公开发布时间是 2004 年 10月4日，版本号为 0.1.0

2019 年 3 月份，F5 公司与 Nginx 达成协议，F5 将收购 Nginx 所有的己发行股票，总价值约为 6.7 亿美金，合约人民币 44.97 亿人民币， Nginx 的核心模块代码总量约为 198430 行（包括空格，注释），所以我们可以认为 Nginx 项目的一行代码的值约为 2.2万人民币

Nginx 经历了十几年的迭代更新（nginx.org/en/CHANGES）,目前功能己经非常完善且运行稳定，当前该项目分为社区版和商业版，社区版里面又分为开发版（版本号为奇数），最新稳定版（版本号为偶数）和过期版，Nginx 功能丰富，可以作为 WEB 服务器使用，也可以作为反向代理服务器或者邮件服务器，能够快速的响应静态网页请求，支持 FastCGI/SSL/Virtual Host/URL Rwrite/Gzip/HTTP Basic Auth/HTTP 或 TCP 负载均衡（v1.9版本以上且开启 stream 模块）等功能，并且支持第三方的功能扩展

另外，还有一些基于 Nginx 做二次开发的项目，其中比较著名的有 Tengine，OpenResty 等

~~~shell
http://nginx.org/ 			#开源项目网站
https://nginx.com/ 			#商业化项目网站
https://www.nginx-cn.net/ 	#中文商业化项目网站
https://tengine.taobao.org/ #Tengine 官网
~~~

## 1.2 Nginx 架构和工作模型

**Nginx 整体架构**

![image-20250906131817849](Nginx.assets/image-20250906131817849.png)

**Nginx 工作模型**

![image-20250906131844778](Nginx.assets/image-20250906131844778.png)

在Nginx中，Master进程和Worker进程分别承担不同的角色，共同协作以提供高性能的服务

**Master** **进程**

启动过程： 当你启动Nginx时，Master进程首先启动。它会读取配置文件，初始化全局资源，并创建指定数量的Worker进程

- 创建 Worker 进程： Master进程会创建Worker进程来处理实际的客户端请求。每个Worker进程
- 都是一个独立的进程，它们之间相互独立，互不影响
- 管理 Worker 进程： Master进程负责监控Worker进程的状态。如果某个Worker进程异常退出（比如发生错误），Master进程会重新启动一个新的Worker进程，以确保服务的可用性

**Worker** **进程**

- 处理客户端请求： Worker进程是实际处理客户端请求的进程。每个Worker进程是单线程的，但通过多进程的方式，Nginx能够同时处理多个请求，实现高并发
- 事件驱动和异步处理： Worker进程采用事件驱动的异步模型。它使用事件循环和非阻塞I/O操作，允许在不同的连接之间高效切换，以处理大量并发请求
- 负载均衡： 如果配置了负载均衡，多个Worker进程可以分担负载，均衡地分配请求，提高系统的整体性能

**Master** **进程与** **Worker** **进程的联系**

在运行时，Master 进程负责监控 Worker 进程的状态，如果某个 Worker 进程异常退出，Master 进程会重新启动一个新的 Worker 进程，确保服务的稳定性。Master 进程和 Worker 进程之间通过信号进行通信，例如在重新加载配置时，Master 进程会向 Worker 进程发送信号，通知它们重新加载配置而无需停止服务

这种Master-Worker模型使Nginx在高并发环境下表现出色，同时能够保持稳定性和可扩展性。Master进程和Worker进程之间的协同工作是Nginx架构的关键之一

~~~shell
root@ubuntu2204:~ 13:48:55 # ps -ef | grep nginx  | grep -v grep
root        1882       1  0 13:48 ?        00:00:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data    1884    1882  0 13:48 ?        00:00:00 nginx: worker process
www-data    1885    1882  0 13:48 ?        00:00:00 nginx: worker process
www-data    1886    1882  0 13:48 ?        00:00:00 nginx: worker process
www-data    1887    1882  0 13:48 ?        00:00:00 nginx: worker process
root@ubuntu2204:~ 13:49:02 # pstree -p | grep nginx
       |-nginx(1882)-+-nginx(1884)
       |             |-nginx(1885)
       |             |-nginx(1886)
       |             `-nginx(1887)

~~~



## 1.3 Nginx 模块

Nginx的模块化设计使得用户可以根据需求选择并集成不同类型的模块，从而定制化地配置和扩展Nginx服务器的功能

Nginx 模块可以分为两大类：核心模块和第三方模块

**核心模块（Core Modules）**

Nginx 的核心模块主要有三部份，分别是

- Events Module： 处理与事件相关的操作，如连接的接受和关闭。包括事件驱动机制等
- HTTP Module： 处理 HTTP 请求和响应，包括配置 HTTP 服务器、反向代理和负载均衡等
- Mail Module：提供邮件代理服务顺的功能，支持 IMAP，POP3等协议

基中 HTTP 模块又包含以下几部份

- Core Module： 包含基本的 HTTP 功能，如配置服务器块、location 块等
- Access Module： 处理访问控制，包括允许或拒绝特定的 IP 地址或用户
- FastCGI Module： 支持 FastCGI 协议，用于与 FastCGI 进程通信
- Proxy Module： 提供反向代理功能，用于将请求代理到后端服务器
- Upstream Module： 用于定义负载均衡的后端服务器组

**第三方模块（HTTP Modules）**

Nginx提供了一套模块化的架构，允许开发者编写自定义的模块来扩展功能。这些第三方模块可以包括但不限于以下几类

- HTTP 模块： 扩展HTTP模块的功能，添加自定义的处理逻辑
- Filter 模块： 提供对HTTP请求和响应进行过滤的功能
- Load Balancer 模块： 实现负载均衡策略
- Access Control 模块： 控制对资源的访问权限
- Security 模块： 提供安全性增强的功能，如防火墙、DDoS防护等
- Authentication 模块： 处理用户认证逻辑

~~~shell
https://nginx.org/en/docs/   #nginx 模块列表
~~~

## 1.4 Nginx 版本和安装

### 1.4.1 Nginx 版本

Nginx 官方将 Nginx 分为三个类型的版本，分别是 Mainline，Stable，Legacy

**Mainline（主线版）**

- Mainline 版本是 Nginx 的主要开发版本，包含最新的功能和改进，这个版本通常包含最新的实验性功能和性能优化，但相对较新，可能存在一些未经广泛测试的特性
- Mainline 版本是面向那些希望尝试最新功能并能够接受一些潜在风险的用户和开发者
- Mainline 版在完成充分的测试和功能迭代之后会变成 Stable 版，然后官方会开一个新的 Mainline 版
- Mainline 版的版本号一般为奇数

**Stable（稳定版）**

- Stable 版本是相对于 Mainline 版本更为稳定和经过充分测试的版本，它包含了经过验证的功能和修复了已知问题的代码
- Stable 版本是面向那些更注重稳定性和可靠性的生产环境用户的选择，该版本可能不包含最新的功能，但在生产环境中更为安全可靠
- Stable 版的版本号一般为偶数

**Legacy** **（历史版本）**

- 己经归档的稳定版，版本号一般为偶数

可以根据其需求选择使用 Mainline 版本或 Stable 版本，在开发和测试阶段，可以选择 Mainline 版本以获得最新的功能和改进。而在生产环境中，通常建议选择 Stable 版本，以确保系统的稳定性和可靠性

~~~shell
https://nginx.org/en/download.html 			#下载页面
https://nginx.org/en/linux_packages.html 	#安装源配置页面
~~~

### 1.4.2 Nginx 安装

#### 1.4.2.1 Nginx 二进制包安装

Nginx 一般可以使用 apt/yum 来安装二进制包，如果需要使用特定的功能模块，也可以使用源码安装，使用 yum/apt 安装的时候，只能安装操作系统发行版厂商己经提交到仓库中的版本，如果需要安装更新的版本或历史版本，可自行配置官方仓库，然后进行安装

~~~shell
# Ubuntu 中的可用版本
root@ubuntu2204:~ 14:00:41 # apt list nginx -a
Listing... Done
nginx/jammy-security,jammy-updates,now 1.18.0-6ubuntu14.7 amd64 [installed]
nginx/jammy 1.18.0-6ubuntu14 amd64

root@ubuntu2204:~ 14:00:45 # 

# Rocky Linux 中的可用版本
yum list nginx
~~~

~~~shell
root@ubuntu2204:~ 14:00:45 # apt install -y nginx
root@ubuntu2204:~ 14:00:45 # dpkg -L nginx
/.
/usr
/usr/share
/usr/share/doc
/usr/share/doc/nginx
/usr/share/doc/nginx/copyright
/usr/share/doc/nginx/changelog.Debian.gz


root@ubuntu2204:~ 14:03:48 #  dpkg -L nginx-core
/.
/usr
/usr/sbin
/usr/sbin/nginx
/usr/share
/usr/share/doc
/usr/share/doc/nginx-core
/usr/share/doc/nginx-core/copyright
/usr/share/man
/usr/share/man/man8
/usr/share/man/man8/nginx.8.gz
/usr/share/doc/nginx-core/changelog.Debian.gz
root@ubuntu2204:~ 14:03:59 # 

# 配置文件目录
root@ubuntu2204:~ 14:03:59 # tree /etc/nginx
/etc/nginx
├── conf.d
├── fastcgi.conf
├── fastcgi_params
├── koi-utf
├── koi-win
├── mime.types
├── modules-available
├── modules-enabled
│   ├── 50-mod-http-geoip2.conf -> /usr/share/nginx/modules-available/mod-http-geoip2.conf
│   ├── 50-mod-http-image-filter.conf -> /usr/share/nginx/modules-available/mod-http-image-filter.conf
│   ├── 50-mod-http-xslt-filter.conf -> /usr/share/nginx/modules-available/mod-http-xslt-filter.conf
│   ├── 50-mod-mail.conf -> /usr/share/nginx/modules-available/mod-mail.conf
│   ├── 50-mod-stream.conf -> /usr/share/nginx/modules-available/mod-stream.conf
│   └── 70-mod-stream-geoip2.conf -> /usr/share/nginx/modules-available/mod-stream-geoip2.conf
├── nginx.conf
├── proxy_params
├── scgi_params
├── sites-available
│   └── default
├── sites-enabled
│   └── default -> /etc/nginx/sites-available/default
├── snippets
│   ├── fastcgi-php.conf
│   └── snakeoil.conf
├── uwsgi_params
└── win-utf

6 directories, 20 files

# 网站根目录
root@ubuntu2204:~ 14:04:35 # ll /var/www/html/index.nginx-debian.html 
-rw-r--r-- 1 root root 612 Sep  6 13:48 /var/www/html/index.nginx-debian.html
root@ubuntu2204:~ 14:04:43 # 

# 查看版本
root@ubuntu2204:~ 14:05:27 # nginx -v
nginx version: nginx/1.18.0 (Ubuntu)

# 查看版本和编译选项
root@ubuntu2204:~ 14:05:40 # nginx -V
nginx version: nginx/1.18.0 (Ubuntu)
built with OpenSSL 3.0.2 15 Mar 2022
TLS SNI support enabled
configure arguments: --with-cc-opt='-g -O2 -ffile-prefix-map=/build/nginx-aSXKE0/nginx-1.18.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --add-dynamic-module=/build/nginx-aSXKE0/nginx-1.18.0/debian/modules/http-geoip2 --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module
root@ubuntu2204:~ 14:05:50 # 

~~~

#### 1.4.2.2 Nginx 源码编译安装

| 编译选项                                                     | 作用                                |
| ------------------------------------------------------------ | ----------------------------------- |
| --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log        --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock | 程序安装目录和路径                  |
| --http-client-body-temp-path=/var/cache/nginx/client_tem --http-proxy-temp-<br/>path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-<br/>path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-<br/>path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp | 临时缓存文件                        |
| --user=nginx --group=nginx                                   | 设定Nginx进程启动⽤户和组(安全)     |
| --with-cc-opt                                                | 设置额外的参数将被添加到CFLAGS 变量 |
| --with-ld-opt                                                | 设置附件的参数，链接到系统库        |

**Nginx 常用模块**

| Nginx 编译选项             | 模块作用                                                   |
| -------------------------- | ---------------------------------------------------------- |
| ngx_http_core_module       | 包含⼀些核⼼的http参数配置，对应Nginx的配置区块部分        |
| ngx_http_access_module     | 访问控制模块，⽤来控制⽹站⽤户对Nginx的访问                |
| ngx_http_gzip_module       | 压缩模块，对Nginx返回的数据压缩，属于性能优化模块          |
| ngx_http_fastcgi_module    | fastci模块，和动态应⽤相关的模块，例如PHP                  |
| ngx_http_proxy_module      | proxy代理模块                                              |
| ngx_http_upstream_module   | 负载均衡模块，可以实现⽹站的负载均衡功能及节点的健康检查。 |
| ngx_http_rewrite_module    | URL地址重写模块                                            |
| ngx_http_limit_conn_module | 限制⽤户并发连接数及请求数模块                             |
| ngx_http_limit_req_module  | 限制Nginx request processing rate根据定义的key             |
| ngx_http_log_module        | 访问⽇志模块，以指定的格式记录Nginx客户访问⽇志等信息      |
| ngx_http_auth_basic_module | Web认证模块，设置Web⽤户通过账号密码访问Nginx              |
| nginx_http_ssl_module      | ssl模块，⽤于加密的http连接，如https                       |



~~~shell
# 安装编译工具链
root@ubuntu2204:~ 14:13:46 #  apt update
root@ubuntu2204:~ 14:13:46 #  apt install -y make gcc libpcre3 libpcre3-dev openssl libssl-dev zlib1g-dev

# 创建运行用户
root@ubuntu2204:~ 14:15:18 # useradd -r -s /sbin/nologin nginx
root@ubuntu2204:~ 14:15:37 # getent passwd nginx 
nginx:x:998:998::/home/nginx:/sbin/nologin
root@ubuntu2204:~ 14:15:43 # 


# 下载最新版源码并解压
root@ubuntu2204:~ 14:15:43 #  wget https://nginx.org/download/nginx-1.22.1.tar.gz
root@ubuntu2204:~ 14:16:25 # ls nginx-1.22.1.tar.gz 
nginx-1.22.1.tar.gz
root@ubuntu2204:~ 14:16:27 # tar xf nginx-1.22.1.tar.gz 
root@ubuntu2204:~ 14:16:37 # cd nginx-1.22.1/
root@ubuntu2204:~/nginx-1.22.1 14:16:39 # ls
auto  CHANGES  CHANGES.ru  conf  configure  contrib  html  LICENSE  man  README  src
root@ubuntu2204:~/nginx-1.22.1 14:16:40 # 


# 编译安装
root@ubuntu2204:~/nginx-1.22.1 14:17:14 # ./configure --prefix=/apps/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module  --with-pcre --with-stream --with-stream_ssl_module --with-stream_realip_module
root@ubuntu2204:~/nginx-1.22.1 14:22:06 # make && make install

# 修改目录属主属组并查看
root@ubuntu2204:~ 14:25:37 # chown -R nginx:nginx /apps/nginx/
root@ubuntu2204:~ 14:25:45 # ls -l /apps/nginx/
total 16
drwxr-xr-x 2 nginx nginx 4096 Sep  6 14:24 conf
drwxr-xr-x 2 nginx nginx 4096 Sep  6 14:24 html
drwxr-xr-x 2 nginx nginx 4096 Sep  6 14:24 logs
drwxr-xr-x 2 nginx nginx 4096 Sep  6 14:24 sbin
root@ubuntu2204:~ 14:25:47 # 

# 创建软链接
root@ubuntu2204:~ 14:25:47 # ln -sv /apps/nginx/sbin/nginx /usr/sbin/nginx 
'/usr/sbin/nginx' -> '/apps/nginx/sbin/nginx'
root@ubuntu2204:~ 14:26:35 # ls -l /usr/sbin/nginx
lrwxrwxrwx 1 root root 22 Sep  6 14:26 /usr/sbin/nginx -> /apps/nginx/sbin/nginx
root@ubuntu2204:~ 14:26:39 # 


# 查看版本
root@ubuntu2204:~ 14:26:39 # nginx -v
nginx version: nginx/1.22.1
root@ubuntu2204:~ 14:26:57 # nginx -V
nginx version: nginx/1.22.1
built by gcc 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04.2) 
built with OpenSSL 3.0.2 15 Mar 2022
TLS SNI support enabled
configure arguments: --prefix=/apps/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre --with-stream --with-stream_ssl_module --with-stream_realip_module
root@ubuntu2204:~ 14:26:59 # 

root@ubuntu2204:~ 14:26:59 # which nginx
/usr/sbin/nginx
root@ubuntu2204:~ 14:27:12 # 


# 默认没有服务脚本
root@ubuntu2204:~ 14:26:59 # which nginx
/usr/sbin/nginx
root@ubuntu2204:~ 14:27:12 # 


# 直接通过 nginx 命令启动 nginx
root@ubuntu2204:~ 14:28:12 # nginx 
root@ubuntu2204:~ 14:28:14 # ps -ef  | grep nginx | grep -v grep 
root        5841       1  0 14:28 ?        00:00:00 nginx: master process nginx
nginx       5842    5841  0 14:28 ?        00:00:00 nginx: worker process
~~~

**配置 systemctl 管理**

~~~shell
# 先停止，直接启动不能用systemctl 管理
root@ubuntu2204:~ 14:28:29 # nginx -s stop
root@ubuntu2204:~ 14:29:24 # ps -ef  | grep nginx | grep -v grep 
root@ubuntu2204:~ 14:29:28 # 


# 创建 PID 目录
root@ubuntu2204:~ 14:29:28 #  mkdir /apps/nginx/run
root@ubuntu2204:~ 14:29:54 #  chown -R nginx.nginx /apps/nginx/run


# 编写 service 文件
    root@ubuntu2204:~ 14:29:58 # vim /usr/lib/systemd/system/nginx.service
root@ubuntu2204:~ 14:31:18 # cat /lib/systemd/system/nginx.service 
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/apps/nginx/run/nginx.pid
ExecStart=/apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
root@ubuntu2204:~ 14:31:50 # 

# 修改配置文件，设置 pid 文件路径
root@ubuntu2204:~ 14:30:37 # vim /apps/nginx/conf/nginx.conf
root@ubuntu2204:~ 14:31:11 # grep "^pid" /apps/nginx/conf/nginx.conf
pid        /apps/nginx/run/nginx.pid;
root@ubuntu2204:~ 14:31:18 # 


# 重载服务脚本
root@ubuntu2204:~ 14:31:50 # systemctl daemon-reload

# 启动服务
root@ubuntu2204:~ 14:32:33 # systemctl enable --now  nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /lib/systemd/system/nginx.service.
root@ubuntu2204:~ 14:32:58 # systemctl status nginx
● nginx.service - nginx - high performance web server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-09-06 14:32:58 CST; 3s ago
       Docs: http://nginx.org/en/docs/
    Process: 6018 ExecStart=/apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf (code=exited, status=0/SUCCESS)
   Main PID: 6021 (nginx)
      Tasks: 2 (limit: 4514)
     Memory: 1.7M
        CPU: 26ms
     CGroup: /system.slice/nginx.service
             ├─6021 "nginx: master process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf"
             └─6022 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""

Sep 06 14:32:58 ubuntu2204 systemd[1]: Starting nginx - high performance web server...
Sep 06 14:32:58 ubuntu2204 systemd[1]: Started nginx - high performance web server.
root@ubuntu2204:~ 14:33:01 # 

root@ubuntu2204:~ 14:37:43 # cat /apps/nginx/run/nginx.pid 
6021
root@ubuntu2204:~ 14:37:51 # 

~~~

**导入 man 手册**

~~~shell
root@ubuntu2204:~ 14:33:01 # man nginx
No manual entry for nginx
    
root@ubuntu2204:~ 14:33:32 # cp nginx-1.22.1/man/nginx.8  /usr/share/man/man8/
root@ubuntu2204:~ 14:34:03 # mandb

root@ubuntu2204:~ 14:34:11 # whereis nginx
nginx: /usr/sbin/nginx /usr/share/man/man8/nginx.8

~~~

## 1.5 Nginx 命令和信号

~~~shell
root@ubuntu2204:~ 14:37:51 # nginx -h
nginx version: nginx/1.22.1
Usage: nginx [-?hvVtTq] [-s signal] [-p prefix]
             [-e filename] [-c filename] [-g directives]
             
#常用选项
?|-h   		#显示帮助信息
v         	#显示版本信息
V         	#显示版本信息和编译项
t         	#检查并测试配置文件
T         	#检查并测试配置文件，且输出配置文件内容
q         	#在配置文件测试期间禁止显示非错误消息
s signal   	#发送信号 stop|quit|reopen|reload
p prefix   	#指定运行目录，默认是 /usr/share/nginx/
c filename 	#指定配置文件，默认是 /etc/nginx/nginx.conf
g directive #启动时指定一些全局配置项，而不用修改配置文件，格式为 k v

#信号说明
stop 		#立即停止，没处理完的请求也会被立即断开，相当于信号 SIGTERM,SIGINT
quit 		#优雅退出，不再接收新的请求，但己建立的连接不受影响，相当于信号 SIGQUIT
reopen 		#重开一个新的日志文件，日志内容写新文件，相当于信号 SIGUSR1 
reload 		#重新加载配置文件，重新生成worker 进程，不中断正在处理的请求，己建立的连接按旧配置处理，新连接用新配置处理
			# 同 systemctl reload nginx
SIGUSR2 	#平滑升级二进制文件，适用于版本升级 
SIGWINCH 	#优雅的停止工作进程，适用于版本升级
~~~

范例：配置文件检测

~~~shell
root@ubuntu2204:~ 16:53:11 # nginx -t 
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:~ 16:53:18 # echo $?
0
root@ubuntu2204:~ 16:53:20 # 


# 检查配置文件语法，仅仅输出错误信息
root@ubuntu2204:~ 16:53:20 # nginx -t -q
root@ubuntu2204:~ 16:54:00 # echo $?
0
root@ubuntu2204:~ 16:54:03 # 

~~~

范例：在配置文件外指定配置项

~~~shell
root@ubuntu2204:~ 16:54:46 # cat /apps/nginx/conf/nginx.conf

#user  nobody;
#worker_processes  1;  # 注释此项

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;


# 在命令行中指定配置启动
root@ubuntu2204:~ 16:55:46 # nginx -g "worker_processes 1;"
# 查看，一个 master 一个worker
root@ubuntu2204:~ 16:55:52 # ps -ef | grep nginx | grep -v grep
root        6717       1  0 16:55 ?        00:00:00 nginx: master process nginx -g worker_processes 1;
nginx       6718    6717  0 16:55 ?        00:00:00 nginx: worker process
root@ubuntu2204:~ 16:56:04 # 

~~~

范例：发送信号

~~~shell
# 在服务端创建一个100M的文件
root@ubuntu2204:~ 16:57:28 # dd if=/dev/zero of=/apps/nginx/html/test.img bs=1M count=100
100+0 records in
100+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 0.300802 s, 349 MB/s
root@ubuntu2204:~ 16:57:49 # ls -lh /apps/nginx/html/test.img 
-rw-r--r-- 1 root root 100M Sep  6 16:57 /apps/nginx/html/test.img
root@ubuntu2204:~ 16:57:52 # 

# 客户端限速下载，每秒下1M，所以需要100s
root@ubuntu2204:~ 16:57:52 # wget --limit-rate=1024000 http://192.168.121.112/test.img
--2025-09-06 16:58:48--  http://192.168.121.112/test.img
Connecting to 192.168.121.112:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 104857600 (100M) [application/octet-stream]
Saving to: ‘test.img’

test.img       8%[======>                                                              ]   8.22M  1000KB/s    eta 94s


# 在客户端下载的过程中服务端发送 stop 信号，客户端会立即断开
root@ubuntu2204:/xuruizhao 14:21:00 # nginx  -s stop

# 再次测试发送 quit 信号
# 当前一个master，两个 worker
root@ubuntu2204:~ 17:00:24 # nginx -s quit 
root@ubuntu2204:~ 17:00:35 # ps -ef | grep nginx | grep -v grep 
root        6799       1  0 17:00 ?        00:00:00 nginx: master process nginx
nginx       6800    6799  0 17:00 ?        00:00:00 nginx: worker process is shutting down
root@ubuntu2204:~ 17:00:53 # 

#但无法建立新连接
root@ubuntu2204:~ 17:00:24 # curl 127.1
curl: (7) Failed to connect to 127.0.0.1 port 80 after 0 ms: Connection refused


# 下载请求完成后，就没有进程，彻底退出
root@ubuntu2204:~ 17:00:24 # ps aux | grep nginx




# reload 信号
root@ubuntu2204:~ 17:01:32 # nginx 
root@ubuntu2204:~ 17:02:11 # vim /apps/nginx/conf/nginx.conf
worker_processes 3; #将工作进程数改为3

root@ubuntu2204:~ 17:02:30 # nginx -s reload 
root@ubuntu2204:~ 17:02:35 # 
#发送reload,并查看
#可以看到 master 6810 进程号没有变化， worker 6811 没有变化，因为 6811 维持着旧的下载连接#新的配置生成了6855，6856，6857 三个 worker 进程
root@ubuntu2204:~ 17:02:35 # ps -ef | grep nginx | grep -v grep 
root        6810       1  0 17:02 ?        00:00:00 nginx: master process nginx
nginx       6811    6810  0 17:02 ?        00:00:00 nginx: worker process is shutting down
nginx       6855    6810  0 17:02 ?        00:00:00 nginx: worker process
nginx       6856    6810  0 17:02 ?        00:00:00 nginx: worker process
nginx       6857    6810  0 17:02 ?        00:00:00 nginx: worker process

# 下载完成后，再次查看进程 6811 消失
root@ubuntu2204:~ 17:03:13 # ps -ef | grep nginx | grep -v grep 
root        6810       1  0 17:02 ?        00:00:00 nginx: master process nginx
nginx       6855    6810  0 17:02 ?        00:00:00 nginx: worker process
nginx       6856    6810  0 17:02 ?        00:00:00 nginx: worker process
nginx       6857    6810  0 17:02 ?        00:00:00 nginx: worker process
root@ubuntu2204:~ 17:04:40 # 





# reopen 信号
root@ubuntu2204:/apps/nginx/logs 17:10:11 # ls -lh /apps/nginx/logs/
total 8.0K
-rw-r--r-- 1 root root 624 Sep  6 17:03 access.log
-rw-r--r-- 1 root root 588 Sep  6 17:02 error.log
root@ubuntu2204:/apps/nginx/logs 17:10:22 # 
# 移走日志文件
root@ubuntu2204:/apps/nginx/logs 17:10:22 # mv access.log access.log.bak
root@ubuntu2204:/apps/nginx/logs 17:10:44 # ls -lh
total 8.0K
-rw-r--r-- 1 root root 624 Sep  6 17:03 access.log.bak
-rw-r--r-- 1 root root 588 Sep  6 17:02 error.log
root@ubuntu2204:/apps/nginx/logs 17:10:53 # 
# 发送请求测试，发现日志还是记录到了旧日志中
root@ubuntu2204:/apps/nginx/logs 17:11:46 # curl -s 127.1 > /dev/null
root@ubuntu2204:/apps/nginx/logs 17:11:48 # curl -s 127.1 > /dev/null
root@ubuntu2204:/apps/nginx/logs 17:11:48 # ls -lh
total 8.0K
-rw-r--r-- 1 root root 1.2K Sep  6 17:11 access.log.bak
-rw-r--r-- 1 root root  774 Sep  6 17:11 error.log
root@ubuntu2204:/apps/nginx/logs 17:11:50 # 
# 发送信号，并查看日志，会发现生成了新日志
root@ubuntu2204:/apps/nginx/logs 17:11:50 # nginx -s reopen
root@ubuntu2204:/apps/nginx/logs 17:12:43 # ls -lh
total 8.0K
-rw-r--r-- 1 nginx root    0 Sep  6 17:11 access.log
-rw-r--r-- 1 root  root 1.2K Sep  6 17:11 access.log.bak
-rw-r--r-- 1 nginx root  834 Sep  6 17:12 error.log
root@ubuntu2204:/apps/nginx/logs 17:12:44 # curl -s 127.1 > /dev/null
root@ubuntu2204:/apps/nginx/logs 17:12:46 # curl -s 127.1 > /dev/null
root@ubuntu2204:/apps/nginx/logs 17:12:47 # curl -s 127.1 > /dev/null
root@ubuntu2204:/apps/nginx/logs 17:12:47 # curl -s 127.1 > /dev/null
root@ubuntu2204:/apps/nginx/logs 17:12:47 # curl -s 127.1 > /dev/null
root@ubuntu2204:/apps/nginx/logs 17:12:48 # ls -lh
total 12K
-rw-r--r-- 1 nginx root  430 Sep  6 17:12 access.log
-rw-r--r-- 1 root  root 1.2K Sep  6 17:11 access.log.bak
-rw-r--r-- 1 nginx root  834 Sep  6 17:12 error.log
root@ubuntu2204:/apps/nginx/logs 17:12:49 # 

~~~

## 1.6 Nginx 平滑升级和回滚

Nginx 的平滑升级是指在不中断服务的情况下进行软件版本或配置文件的更新。通过平滑升级，Nginx 能够在运行时应用新的配置或软件版本，继续处理请求，而不影响现有的连接

平滑升级的主要优势在于，它允许 Nginx 在更新时保持对服务的连续响应，避免中断用户的请求，这对于具有高可用性要求的生产环境非常重要，然而，需要注意的是，平滑升级并不适用于所有场景，特别是在某些配置或软件更改可能导致不兼容性问题的情况下，在进行平滑升级之前，建议先在测试环境中进行充分的测试

平滑升级通常包括以下步骤：

- 新版本或配置准备：准备好新版本的 Nginx 可执行文件或配置文件，并确保它们没有问题
- 新版本资源替换旧版本资源：进行资源替换，此步骤要备份旧版本资源，可以用作回滚
- 发送信号：使用 nginx -s SIGUSR2，nginx -s reload 等方式向 Nginx 主进程发送重新加载的信号
- 新的工作进程启动：Nginx 主进程接收到重新加载信号后，会启动新的工作进程，并使用新的配置文件或软件版本
- 平滑过渡：新的工作进程逐渐接管现有的连接。现有的连接会在旧的工作进程中继续处理，而新的连接会由新的工作进程处理
- 旧的进程退出：当旧的工作进程不再有活动连接时，它会被关闭

~~~shell
# 查看当前使用的版本和编译选项
root@ubuntu2204:/apps/nginx/logs 17:12:49 # nginx -v
nginx version: nginx/1.22.1
root@ubuntu2204:/apps/nginx/logs 17:36:56 # 

# 修改当前配置文件，至少保证两个worker进程，便于测试
root@ubuntu2204:/apps/nginx/logs 17:12:49 # cat /apps/nginx/conf/nginx.conf
worker_processes  2;


# 编译新版本
root@ubuntu2204:~ 17:38:17 #  wget https://nginx.org/download/nginx-1.24.0.tar.gz
root@ubuntu2204:~ 17:38:22 # tar xf nginx-1.24.0.tar.gz 
root@ubuntu2204:~ 17:38:35 # cd nginx-1.24.0/
root@ubuntu2204:~/nginx-1.24.0 17:38:38 # 
root@ubuntu2204:~/nginx-1.24.0 17:38:38 # ./configure --prefix=/apps/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module  --with-pcre --with-stream --with-stream_ssl_module --with-stream_realip_module

# 只需要执行 make，会在 objs 目录中生成新的二进制文件
root@ubuntu2204:~/nginx-1.24.0 17:42:19 # ls -l objs/nginx
-rwxr-xr-x 1 root root 5929488 Sep  6 17:42 objs/nginx


# 新版的二进制文件
root@ubuntu2204:~/nginx-1.24.0 17:42:30 # ls -lh objs/nginx /apps/nginx/sbin/nginx
-rwxr-xr-x 1 nginx nginx 5.7M Sep  6 14:24 /apps/nginx/sbin/nginx
-rwxr-xr-x 1 root  root  5.7M Sep  6 17:42 objs/nginx
root@ubuntu2204:~/nginx-1.24.0 17:42:45 # 


# 新版二进制文件和旧的二进制文件进行对比
root@ubuntu2204:~/nginx-1.24.0 17:43:23 # /apps/nginx/sbin/nginx -v
nginx version: nginx/1.22.1
root@ubuntu2204:~/nginx-1.24.0 17:43:25 # objs/nginx -v
nginx version: nginx/1.24.0
root@ubuntu2204:~/nginx-1.24.0 17:43:27 # 


# 保留旧版二进制文件备份
root@ubuntu2204:~/nginx-1.24.0 17:43:27 # mv /apps/nginx/sbin/nginx{,.122}

root@ubuntu2204:~/nginx-1.24.0 17:44:08 # ls /apps/nginx/sbin/nginx*
/apps/nginx/sbin/nginx.122
root@ubuntu2204:~/nginx-1.24.0 17:44:11 # 

# 复制新的二进制文件
root@ubuntu2204:~/nginx-1.24.0 17:44:11 # cp objs/nginx /apps/nginx/sbin/
root@ubuntu2204:~/nginx-1.24.0 17:44:45 # nginx -v
nginx version: nginx/1.24.0
root@ubuntu2204:~/nginx-1.24.0 17:44:47 # 
# 检测，配置文件可用，版本己更新
root@ubuntu2204:~/nginx-1.24.0 17:44:47 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:~/nginx-1.24.0 17:44:57 # 

# 当前进程是旧版本的进程
root@ubuntu2204:~/nginx-1.24.0 17:44:57 # ps -ef | grep nginx | grep -v grep 
root        6810       1  0 17:02 ?        00:00:00 nginx: master process nginx
nginx       6855    6810  0 17:02 ?        00:00:00 nginx: worker process
nginx       6856    6810  0 17:02 ?        00:00:00 nginx: worker process
nginx       6857    6810  0 17:02 ?        00:00:00 nginx: worker process
root@ubuntu2204:~/nginx-1.24.0 17:45:28 # 
root@ubuntu2204:~/nginx-1.24.0 17:45:28 # curl -I 127.1
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Sat, 06 Sep 2025 09:45:43 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Sat, 06 Sep 2025 06:24:59 GMT
Connection: keep-alive
ETag: "68bbd3bb-267"
Accept-Ranges: bytes

root@ubuntu2204:~/nginx-1.24.0 17:45:43 # 

# 在服务端创建文件
root@ubuntu2204:~/nginx-1.24.0 17:45:43 #  dd if=/dev/zero of=/apps/nginx/html/test.img bs=1M count=100
100+0 records in
100+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 0.504583 s, 208 MB/s
root@ubuntu2204:~/nginx-1.24.0 17:46:15 # 

# 向master 进程发送信号
[root@ubuntu nginx-1.24.0]# kill -USR2 6757

# 生成了新的master 进程 88856，该进程下有两个 worker 进程，分别是 88857,88858
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
root        6757  0.0  0.1  10164  3116 ?       Ss   21:50   0:00 nginx: master 
process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88774  0.0  0.1  10916  3688 ?       S    22:30   0:00 \_ nginx: 
worker process
nginx      88775  0.0  0.1  10916  3688 ?       S    22:30   0:00 \_ nginx: 
worker process
root       88856  0.0  0.3  10176  6404 ?       S    23:00   0:00 \_ nginx: 
master process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88857  0.0  0.1  10912  3688 ?       S    23:00   0:00     \_ 
nginx: worker process
nginx      88858  0.0  0.1  10912  3688 ?       S    23:00   0:00     \_ 
nginx: worker process


#生成了新的PID文件
[root@ubuntu nginx-1.24.0]# ls -lh /apps/nginx/run/
total 8.0K
-rw-r--r-- 1 root root 6 Jan 20 23:00 nginx.pid
-rw-r--r-- 1 root root 5 Jan 20 21:50 nginx.pid.oldbin
[root@ubuntu nginx-1.24.0]# cat /apps/nginx/run/nginx.pid #新的 master 进程 PID
88856
[root@ubuntu nginx-1.24.0]# cat /apps/nginx/run/nginx.pid.oldbin #旧的 master 进程 PID
6757


#现在访问还是旧版本提供服务
[root@ubuntu nginx-1.24.0]# curl 127.1 -I
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Sat, 20 Jan 2024 15:03:24 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Sat, 20 Jan 2024 13:43:25 GMT
Connection: keep-alive
ETag: "65abcdfd-267"
Accept-Ranges: bytes
~~~



![image-20250906173330266](Nginx.assets/image-20250906173330266.png)

**此时不关机保存一份快照，用于后续测试回滚**

~~~shell
#客户端限速下载
[root@ubuntu ~]# wget --limit-rate=102400 http://10.0.0.208/test.img
#服务端继续发送信号，此信号会关闭旧的 woker 进程，新请求交由新的 worker 进程处理
[root@ubuntu nginx-1.24.0]# kill -WINCH 6757
#查看进程，旧的 master 进程下还有一个 worker 进程，用于维持下载连接
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
root        6757  0.0  0.1  10164  3116 ?       Ss   21:50   0:00 nginx: master 
process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88774  0.0  0.1  10916  3688 ?       S    22:30   0:00 \_ nginx: 
worker process is shutting down
root       88856  0.0  0.3  10176  6404 ?       S    23:00   0:00 \_ nginx: 
master process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88857  0.0  0.1  10912  3688 ?       S    23:00   0:00     \_ 
nginx: worker process
nginx      88858  0.0  0.1  10912  3688 ?       S    23:00   0:00     \_ 
nginx: worker process


#新的连接己经由新版本来响应了
[root@ubuntu nginx-1.24.0]# curl 127.1 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Sat, 20 Jan 2024 15:32:23 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Sat, 20 Jan 2024 13:43:25 GMT
Connection: keep-alive
ETag: "65abcdfd-267"
Accept-Ranges: bytes

#下载请求结束后，旧的 woker 进程全部退出
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
root        6757  0.0  0.1  10164  3116 ?       Ss   21:50   0:00 nginx: master 
process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
root       88856  0.0  0.3  10176  6404 ?       S    23:00   0:00 \_ nginx: 
master process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88857  0.0  0.2  10912  4248 ?       S    23:00   0:00     \_ 
nginx: worker process
nginx      88858  0.0  0.1  10912  3688 ?       S    23:00   0:00     \_ 
nginx: worker process


#观察一段时间后，如果业务没有问题，则可以继续发送信号，退出旧的 master 进程，至此升级完成
[root@ubuntu nginx-1.24.0]# kill -QUIT 6757
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
root       88856  0.0  0.3  10176  6404 ?       S    23:00   0:00 nginx: master 
process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88857  0.0  0.2  10912  4248 ?       S    23:00   0:00 \_ nginx: 
worker process
nginx      88858  0.0  0.1  10912  3688 ?       S    23:00   0:00 \_ nginx: 
worker process
~~~

~~~shell
#还原快照，测试回滚
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
root        6757  0.0  0.1  10164  3116 ?       Ss   22:00   0:00 nginx: master 
process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88774  0.0  0.1  10916  3688 ?       S    22:39   0:00 \_ nginx: 
worker process
inx      88775  0.0  0.1  10916  3688 ?       S    22:39   0:00 \_ nginx: 
worker process
root       88856  0.0  0.3  10176  6404 ?       S    23:10   0:00 \_ nginx: 
master process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88857  0.0  0.1  10912  3688 ?       S    23:10   0:00     \_ 
nginx: worker process
nginx      88858  0.0  0.1  10912  3688 ?       S    23:10   0:00     \_ 
nginx: worker process

#发送信号，将新请求交由新版 worker 进程处理
[root@ubuntu nginx-1.24.0]# kill -WINCH 6757
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
root        6757  0.0  0.1  10164  3116 ?       Ss   22:00   0:00 nginx: master 
process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
root       88856  0.0  0.3  10176  6404 ?       S    23:10   0:00 \_ nginx: 
master process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88857  0.0  0.1  10912  3688 ?       S    23:10   0:00     \_ 
nginx: worker process
nginx      88858  0.0  0.1  10912  3688 ?       S    23:10   0:00     \_ 
nginx: worker process


#新版响应请求
[root@ubuntu nginx-1.24.0]# curl 127.1 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Sat, 20 Jan 2024 15:49:05 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Sat, 20 Jan 2024 13:43:25 GMT
Connection: keep-alive
ETag: "65abcdfd-267"
Accept-Ranges: bytes


#观察业务，需要回滚
#先还原二进制文件
[root@ubuntu nginx-1.24.0]# ls -l /apps/nginx/sbin/
total 11540
-rwxr-xr-x  1 root root  5929488 Jan 20 22:51 nginx*
-rwxr-xr-x  1 nginx nginx 5884528 Jan 20 21:43 nginx.122*
[root@ubuntu nginx-1.24.0]# mv /apps/nginx/sbin/nginx{,.124} #备份当前使用的
[root@ubuntu nginx-1.24.0]# mv /apps/nginx/sbin/nginx{.122,} #还原旧版


#还原回来了
[root@ubuntu nginx-1.24.0]# nginx -v
nginx version: nginx/1.22.1
[root@ubuntu nginx-1.24.0]# nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful

#发送信号，拉起旧的 worker 进程
[root@ubuntu nginx-1.24.0]# kill -HUP 6757
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
root        6757  0.0  0.1  10164  3116 ?       Ss   22:15   0:00 nginx: master 
process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
root       88856  0.0  0.3  10176  6404 ?       S    23:25   0:00 \_ nginx: 
master process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      88857  0.0  0.2  10912  4248 ?       S    23:25   0:00 |   \_ 
nginx: worker process
nginx      88858  0.0  0.1  10912  3688 ?       S    23:25   0:00 |   \_ 
nginx: worker process
nginx      89179  0.0  0.1  10916  3680 ?       S    23:58   0:00 \_ nginx: 
worker process
nginx      89180  0.0  0.1  10916  3632 ?       S    23:58   0:00 \_ nginx: 
worker process


#此时请求还是由新的 worker 进程响应
[root@ubuntu nginx-1.24.0]# curl 127.1 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Sat, 20 Jan 2024 16:00:01 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Sat, 20 Jan 2024 13:43:25 GMT
Connection: keep-alive
ETag: "65abcdfd-267"
Accept-Ranges: bytes
#继续发送信号，优雅的退出新版的 master 进程
[root@ubuntu nginx-1.24.0]# kill -QUIT 88856


#己经还原回去了
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
root        6757  0.0  0.1  10164  3116 ?       Ss   Jan20   0:00 nginx: master 
process /apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
nginx      89179  0.0  0.1  10916  3680 ?       S   Jan20   0:00 \_ nginx: 
worker process
nginx      89180  0.0  0.1  10916  3632 ?       S   Jan20   0:00 \_ nginx: 
worker process


#测试
[root@ubuntu nginx-1.24.0]# curl 127.1 -I
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Sat, 20 Jan 2024 16:05:18 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Sat, 20 Jan 2024 13:43:25 GMT
Connection: keep-alive
ETag: "65abcdfd-267"
Accept-Ranges: bytes
~~~



如果是用 yum/apt 安装的nginx ，使用 yum/apt 升级时，无法实现平滑升级，但可以在一台新的机器上安装新版，然后再平移新版的二进制文件到原机器，但要注意依赖库的兼容性和配置文件的兼容性

# 二、Nginx 配置

## 2.1 配置文件说明

~~~shell
# ubuntu2204 中使用 apt 安装的 nginx 的配置文件
root@ubuntu2204:~ 19:10:25 # ls -l /etc/nginx
total 64
drwxr-xr-x 2 root root 4096 May 31  2023 conf.d 				# 子配置文件目录，在主配置文件中被包含，默认为空
-rw-r--r-- 1 root root 1125 May 31  2023 fastcgi.conf 			# FastCGI配置文件，定义相关配置项，被引用
-rw-r--r-- 1 root root 1055 May 31  2023 fastcgi_params 		# FastCGI配置文件，定义相关配置项，被引用
-rw-r--r-- 1 root root 2837 May 31  2023 koi-utf 				# 用于转换KOI8-R编码的字符集到UTF-8
-rw-r--r-- 1 root root 2223 May 31  2023 koi-win 				# 用于转换KOI8-U编码的字符集到UTF-8
-rw-r--r-- 1 root root 3957 May 31  2023 mime.types 			# 包含文件扩展名和相应MIME类型的映射
drwxr-xr-x 2 root root 4096 May 31  2023 modules-available 		# 模块配置文件目录
drwxr-xr-x 2 root root 4096 Jan 21 00:36 modules-enabled 		# 当前生效的模块配置文件目录，用软链接指向真正的文件
-rw-r--r-- 1 root root 1447 May 31  2023 nginx.conf 			# 主配置文件
-rw-r--r-- 1 root root  180 May 31  2023 proxy_params 			# 反向代理配置文件
-rw-r--r-- 1 root root  636 May 31  2023 scgi_params 			# SCGI配置文件，SCGI和FastCGI类似，都是一种协议
drwxr-xr-x 2 root root 4096 Jan 21 00:36 sites-available 		# 所有域名配置文件
drwxr-xr-x 2 root root 4096 Jan 21 00:36 sites-enabled 			# 生效的域名配置文件，用软连接指向site-available中的文件
drwxr-xr-x 2 root root 4096 Jan 21 00:36 snippets 				# 通用的配置片段目录，需要时被引用
-rw-r--r-- 1 root root  664 May 31  2023 uwsgi_params 			# 配置 Nginx uWSGI 模块的默认参数的文件
-rw-r--r-- 1 root root 3071 May 31  2023 win-utf 				# 编码转换映射转化文件
root@ubuntu2204:~ 19:10:37 # 

~~~

**Nginx 配置文件格式说明**

- 配置文件由指令与指令块构成
- 每条指令以 ; 分号结尾，指令与值之间以空格符号分隔
- 可以将多条指令放在同一行，用分号分隔即可，但可读性差，不推荐
- 指令块以{ }大括号将多条指令组织在一起，且可以嵌套指令块
- include 语句允许组合多个配置文件以提升可维护性
- 使用 # 号添加注释，提高可读性
- 使用 $ 符号使用变量
- 变量分为 Nginx 内置变量和自定义变量，自定义变量用 set 指令定义
- 部分指令的参数支持正则表达式

~~~shell
https://nginx.org/en/docs/ 				#官方文档
https://nginx.org/en/docs/dirindex.html #所有指令说明
https://nginx.org/en/docs/varindex.html #所有变量查询索引
~~~

## 2.2 全局配置

查看默认主配置文件内容

~~~shell
root@ubuntu2204:~ 19:38:15 #  cat /etc/nginx/nginx.conf | grep -Ev "#|^$"
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
	worker_connections 768;
}
http {
	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	ssl_prefer_server_ciphers on;
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	gzip on;
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}

~~~

~~~shell
#主配置文件有以下几部份组成
[root@ubuntu ~]# cat /etc/nginx/nginx.conf
#全局配置
......
......
#事件驱动相关的配置
events {
 ......
 ......
}
#http/https 协议相关配置段
http {
 ......
 ......
}
#mail 协议相关配置段， 此部份默认被注释
mail {
 
 ......
 ...... 
 server {
 ......
 ......
 }
}

# stream 协议相关配置，默认无此部份
stream {
 ......
 ......
}
~~~

**全局配置**

全局配置段常见的配置指令分类

- 正常运行必备的配置
- 优化性能相关的配置
- 用于调试及定位问题相关的配置
- 事件驱动相关的配置

~~~shell
#全局配置常用配置项

user user [group]; 					# 指定 worker 进程运行时的用户和组，默认值为 nobody nobody
worker_processes auto|N; 			# 指定启动的 worker 进程数量，N 表示具体数字，auto 表示有几个CPU核心就开启几个进程
worker_cpu_affinity auto|cpumask; 	# 将 worker 进程绑定到指定的CPU核心，提升性能，默认不绑定，
 									# auto 表示自动绑定，nginx 1.9.10 版本开始支持
 									# cpumask 写法
 									# 有几颗 CPU 核就写几个数字，默认是0，表示占位符，从右往左数，如果占位符值为1，则表示绑定
 									# worker_processes 4;
 									# worker_cpu_affinity 0001 0010 0100 1000;
 									# 上述写法表示4个工作进程分别绑定到 0，1，2，3 这4个CPU核心上
 									
 									# worker_processes 2;
 									# worker_cpu_affinity 0101 1010;
 									# 上述写法表示2个工作进程分别绑定到 0/2，1/3 CPU核心上
 
pid /path/file; 		# pid 文件路径，该文件中保存的是 master 进程号，服务启动时自动生成该文件
worker_priority N; 		# worker 进程优先级，默认值为0，此处设定的是 nice 值，取值为 -20 到 19
worker_rlimit_nofile N; # 所有worker进程可以打开的文件描述符数量之和，默认不限制
 						# 此值并不仅仅是指nginx 与客户端的连接数，也包括与后端服务的连接数
 						# 比如一个客户端请求一个PHP资源，Nginx要维持与客户端连接，也要维持后端FastCGI连接
daemon on|off; 			# 默认值为on, 表示以后台守护进程方式运行，off 表示前台运行
master_process on|off; 	# 默认值为on, 表示以 master-worker 模式运行，off 只有 master 进程，用于开发调试
include /path/file; 	# 文件包含,指定要包含的文件路径及规则，可以使用通配符
~~~

~~~shell
# evnets 配置项
events {
       worker_connections N; 	# 默认值512，单个worker进程所支持的最大并发连接数，总的并发数用此值乘以worker 进程数
       multi_accept on|off; 	# 默认值 off，on 表示worker 进程一次可以接收多个新的连接请求，off 表示 worker 进程 
       							# 一次只能接收一个新连接，建议设置为 on
         
       accept_mutex on|off; # 默认值 off，表示master 进程获得客户端请求后，会通知所有的 worker 进程，由当前状态 
       						# 最佳的worker 进程处理请求，此过程也被称为 惊群，on 表示 master 进程论流给 worker 
  							# 进程分配要处理的连接，此处建议设置为 on
        
       use method; 	# 指定事件驱动模型,默认不设置此项，nginx 会根据当前系统自行选择
       				# 可用值 select|pool|kqueue|epoll|/dev/poll|eventport
}
https://nginx.org/en/docs/events.html # 事件驱动模型说明文档
~~~

范例：设置 worker 进程数量

~~~shell
root@ubuntu2204:~ 19:53:00 # cat /proc/cpuinfo | grep processor
processor	: 0
processor	: 1
processor	: 2
processor	: 3
root@ubuntu2204:~ 19:53:03 # 

# 此项值为 auto，则应该启动四个 worker 进程
root@ubuntu2204:~ 19:54:41 # grep "^worker_process" /etc/nginx/nginx.conf
worker_processes auto;
root@ubuntu2204:~ 19:54:54 # ps -ef | grep nginx | grep -v grep 
root        1882       1  0 13:48 ?        00:00:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data    1884    1882  0 13:48 ?        00:00:00 nginx: worker process
www-data    1885    1882  0 13:48 ?        00:00:00 nginx: worker process
www-data    1886    1882  0 13:48 ?        00:00:00 nginx: worker process
www-data    1887    1882  0 13:48 ?        00:00:00 nginx: worker process
root@ubuntu2204:~ 19:54:57 # 


# 修改配置值为 5，重启后再次查看
root@ubuntu2204:~ 19:54:57 # vim /etc/nginx/nginx.conf 
root@ubuntu2204:~ 19:55:40 # grep "^worker_process" /etc/nginx/nginx.conf
worker_processes 5;
root@ubuntu2204:~ 19:55:44 # systemctl restart nginx
root@ubuntu2204:~ 19:55:50 # ps -ef | grep nginx | grep -v grep 
root        3108       1  0 19:55 ?        00:00:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data    3109    3108  0 19:55 ?        00:00:00 nginx: worker process
www-data    3110    3108  0 19:55 ?        00:00:00 nginx: worker process
www-data    3111    3108  0 19:55 ?        00:00:00 nginx: worker process
www-data    3112    3108  0 19:55 ?        00:00:00 nginx: worker process
www-data    3113    3108  0 19:55 ?        00:00:00 nginx: worker process
root@ubuntu2204:~ 19:55:53 # 

~~~

范例：worker 进程与 cpu 核心绑定

~~~shell
# 将 worker_processes 值改回 auto，查看当前 worker 进程与 CPU 核心的绑定关系
root@ubuntu2204:~ 19:57:49 # ps axo pid,cmd,psr | grep nginx | grep -v grep
   3108 nginx: master process /usr/   2
   3109 nginx: worker process         3
   3110 nginx: worker process         0
   3111 nginx: worker process         0
   3112 nginx: worker process         1
   3113 nginx: worker process         2
root@ubuntu2204:~ 19:59:20 # 

root@ubuntu2204:~ 20:02:29 # grep "^worker" /etc/nginx/nginx.conf
worker_processes 4;
worker_cpu_affinity 0001 0010 0100 1000;
root@ubuntu2204:~ 20:02:35 # 
root@ubuntu2204:~ 20:02:28 # systemctl restart nginx

root@ubuntu2204:~ 20:02:47 # ps axo pid,cmd,psr | grep nginx | grep -v grep
   3166 nginx: master process /usr/   3
   3167 nginx: worker process         0
   3168 nginx: worker process         1
   3169 nginx: worker process         2
   3170 nginx: worker process         3
~~~

范例：设置 pid 文件

~~~shell
#查看pid文件
[root@ubuntu ~]# ps aux | grep nginx
root       28470  0.0  0.3  55356  6252 ?       Ss   14:40   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data   28646  1.0  0.3  55964  6680 ?       S    15:21   0:05 nginx: worker process
www-data   28647  1.0  0.3  56052  6636 ?       S    15:21   0:05 nginx: worker process
[root@ubuntu ~]# cat /etc/nginx/nginx.conf | grep pid
pid /run/nginx.pid;
[root@ubuntu ~]# cat /run/nginx.pid
28470
#停止服务，pid 文件消失
[root@ubuntu ~]# systemctl stop nginx.service 
[root@ubuntu ~]# cat /run/nginx.pid 
cat: /run/nginx.pid: No such file or directory
#启动服务，重新生成
[root@ubuntu ~]# systemctl start nginx.service 
[root@ubuntu ~]# cat /run/nginx.pid 
28765
~~~

范例：设置 worker 进程优先级

~~~shell
[root@ubuntu ~]# ps axo pid,cmd,ni | grep nginx
  28765 nginx: master process /usr/   0
  28766 nginx: worker process         0
  28767 nginx: worker process         0
  
#调整 worker 进程优先级，值越小，优先级越高  
[root@ubuntu ~]# cat /etc/nginx/nginx.conf | grep worker_priority
worker_priority -20;
[root@ubuntu ~]# systemctl reload nginx.service 
[root@ubuntu ~]# ps axo pid,cmd,ni | grep nginx
  28765 nginx: master process /usr/   0
  28828 nginx: worker process       -20
  28829 nginx: worker process       -20
~~~

范例：设置 worker 进程文件描述符数量

~~~shell
#先将 worker 进程数调整为 1 ，便于观察
[root@ubuntu ~]# ps aux | grep nginx
root       29959  0.0  0.0  55224  1680 ?       Ss   20:02   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data   29960  0.0  0.2  55856  5452 ?       S    20:02   0:00 nginx: worker process

root@ubuntu2204:~ 21:01:28 # ls -l  /proc/3166/fd
total 0
lrwx------ 1 root root 64 Sep  6 21:01 0 -> /dev/null
lrwx------ 1 root root 64 Sep  6 21:01 1 -> /dev/null
l-wx------ 1 root root 64 Sep  6 21:01 15 -> /var/log/nginx/access.log
l-wx------ 1 root root 64 Sep  6 21:01 16 -> /var/log/nginx/error.log
lrwx------ 1 root root 64 Sep  6 21:01 17 -> 'socket:[68191]'
lrwx------ 1 root root 64 Sep  6 21:01 18 -> 'socket:[68192]'
lrwx------ 1 root root 64 Sep  6 21:01 19 -> 'socket:[68193]'
l-wx------ 1 root root 64 Sep  6 21:01 2 -> /var/log/nginx/error.log
lrwx------ 1 root root 64 Sep  6 21:01 20 -> 'socket:[68194]'
lrwx------ 1 root root 64 Sep  6 21:01 21 -> 'socket:[68195]'
lrwx------ 1 root root 64 Sep  6 21:01 22 -> 'socket:[68196]'
lrwx------ 1 root root 64 Sep  6 21:01 4 -> 'socket:[68189]'
lrwx------ 1 root root 64 Sep  6 21:01 5 -> 'socket:[68190]'
lrwx------ 1 root root 64 Sep  6 21:01 6 -> 'socket:[70149]'
lrwx------ 1 root root 64 Sep  6 21:01 7 -> 'socket:[70150]'
root@ubuntu2204:~ 21:01:32 # 


# 如果在 nginx 的配置文件中没有设置的话，则使用的是 Linux 系统级别的设置
root@ubuntu2204:~ 21:01:32 # cat /proc/3166/limits | grep files
Max open files            1024                 524288               files

# 查看 systemd 的默认限制
root@ubuntu2204:~ 21:03:06 # systemctl show| grep FILE
DefaultLimitNOFILE=524288     # 默认硬限制
DefaultLimitNOFILESoft=1024	  # 默认软限制
root@ubuntu2204:~ 21:03:11 # 
root@ubuntu2204:~ 21:03:11 # cat /etc/systemd/system.conf  | grep FILE
#DefaultLimitNOFILE=1024:524288


# 在 service 文件中设置对应值
root@ubuntu2204:~ 21:03:50 # vim /lib/systemd/system/nginx.service
......
......
[Unit]
......
[Service]
......
LimitNOFILE=10000:50000 #soft 10000， hard 50000

# 重载 service，重启 nginx
root@ubuntu2204:~ 21:05:01 # systemctl daemon-reload 
root@ubuntu2204:~ 21:05:44 # systemctl restart nginx


# 查看限制
root@ubuntu2204:~ 21:06:22 # cat /proc/3439/limits | grep files
Max open files            10000                50000                files     
root@ubuntu2204:~ 21:06:23 #


# 在 nginx 配置文件中进行配置
root@ubuntu2204:~ 21:07:29 # vim /etc/nginx/nginx.conf 
root@ubuntu2204:~ 21:07:49 # grep "worker_rlimit_nofile" /etc/nginx/nginx.conf
worker_rlimit_nofile 60000;
root@ubuntu2204:~ 21:07:58 # 
root@ubuntu2204:~ 21:08:15 # ps -ef | grep nginx
root        3559       1  0 21:07 ?        00:00:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data    3603    3559  0 21:08 ?        00:00:00 nginx: worker process
www-data    3604    3559  0 21:08 ?        00:00:00 nginx: worker process
www-data    3605    3559  0 21:08 ?        00:00:00 nginx: worker process
www-data    3606    3559  0 21:08 ?        00:00:00 nginx: worker process
root        3610    2940  0 21:08 pts/0    00:00:00 grep --color=auto nginx
# master 进程中的限制没有发生变化
root@ubuntu2204:~ 21:08:20 # cat /proc/3559/limits | grep files
Max open files            1024                 524288               files     

# worker 进程中的限制发生了变化
root@ubuntu2204:~ 21:08:47 # cat /proc/3603/limits | grep files
Max open files            60000                60000                files     
root@ubuntu2204:~ 21:08:51 # 


#如果不是用 systemd 来管理 nginx 服务，而是直接用二进制命令启动

#那么，全局文件描述符要在 /etc/security/limits.conf 中进行设置

~~~

## 2.3 http 配置

### 2.3.1 http 配置

在 Nginx 的配置文件中， http 指令用来配置 HTTP 服务器的全局设置和参数， http 配置段中包括http 的全局配置，多个 location 配置，多个 server 配置等，其中 server 用来配置虚拟主机

~~~shell
# http 配置中的常用配置项
charset charset|off; 	#是否在响应头 Content-Type 行中添加字符集，默认 off
sendfile on|off; 		#默认值 off，on表示使用 sendfile 函数来传送数据,即零拷贝
tcp_nopush on|off; 		#默认值 off，表示有tcp数据了立即发送，on 表示等到数据包满载了再发送
 						#on 要配合 sendfile on 一起使用
 						
tcp_nodelay on|off; #此选项生效前提是开启了 keepalived，默认值 on 表示立即发送数据,off 表示延时 0.2S发送数据
keepalive_timeout timeout [header_timeout]; #会话保持的时长，单位为秒，第二个值会出现在响应头中，可以和第一个值不一样
 
types_hash_max_size N; 	#默认值1024，用于设置 MIME 类型哈希表大小，
 						#Nginx 使用 MIME 类型哈希表来加速 MIME 类型的查找过程，提高性能
 
server_tokens on|off|build|string; 	#默认值on，表示在响应头中显示 nginx 版本信息，off 表示不显示
 									#build 表示显示的是编译时设置的值 --build=name， 1.11.10 版本开始支持
 									#string 指自定义字符串，商业版中支持
 
server_names_hash_bucket_size N; 	#默认值32|64|128，默认值具体取决于服务器缓存大小，
 									#此项用于设置服务器名哈希桶大小，当配置了大量虚拟主机时，此项可用来提升性能
 
server_name_in_redirect on|off; 	#默认值off,表示在重定向时响应头中不包含 Server 行，on 表示显示 Server 头
include /etc/nginx/mime.types; 		#规定了各种后缀的文件在响应报文中的 ContentType 对应的值
default_type application/octet-stream; #除了上述映射外，其它类型文件都用此值
ssl_protocols [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]; #当前nginx 可支持的 ssl协议版本TLSv1.1 TLSv1.2 TLSv1.3，默认值 TLSv1.1
ssl_prefer_server_ciphers on|off; 	#默认off，表示在 SSL/TLS 握手时优先使用客户端加密套件，on表示优先使用服务端套件


access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
 						#访问日志的文件路径、格式以及其他一些选项
 						#默认值 logs/access.log combined， 禁用访问日志写成 access_log off;
 						#path 指定文件路径
 						#format 指定日志格式，不指定格式则使用预定义的combined
 						#buffer=size 设置缓冲区大小，可以异步写
 						#gzip[=level] 启用gzip压缩，可以指定压缩比
 						#if=condition 设置条件，仅在满足时记录日志
 
 
error_log file [level]; #指定错误日志路径和错误级别，默认值 error_log logs/error.log error;
						#可用级别包括 ebug|info|notice|warn|error|crit|alert|emerg

error_page code ... [=[response]] uri; 	#定义指定状态码的错误页面，可以多个状态码共用一个资源
gzip on|off; 							#是否使用gzip 压缩数据后再传输，默认off
gzip_vary on|off; 						#在启用了压缩的情况下，是否在响应头中添加 Vary: Accept-Encoding 行，默认off
gzip_proxied off|expired|no-cache|no-store|private|no_last_modified|no_etag|auth|any ...;
 										#是否对后端服务器的返回结果进行压缩，默认 off
 
gzip_comp_level N; 			#设置压缩比，取值1-9，默认 1
gzip_buffers number size; 	#设置用于gzip压缩的缓存空间大小，用 number * size，默认值 32 4k|16 8k
							#size 取值为系统内存页大小，与当前操作系统和平台有关
 
gzip_http_version N; 		#用于设置开启gzip 压缩的http 协议的早小版本，默认值 1.1，因为有些客户端或浏览器不支持gzip压缩
gzip_types mime-type ...; 	#根据响应资源的 MIME 来决定是否对数据进行压缩,默认值 text/html
~~~

~~~ini
https://nginx.org/en/docs/http/ngx_http_log_module.html #日志配置文档，可自定义日志格式
~~~

范例：设置字符编码

~~~shell
# 添加两个页面，都有中文内容
root@ubuntu2204:/apps/nginx/html 17:31:23 # cat a.html
hello world 
你好 世界
root@ubuntu2204:/apps/nginx/html 17:31:25 # vim b.html
root@ubuntu2204:/apps/nginx/html 17:33:32 # cat b.html
<html>
    <head>
        <meta charset="UTF-8" />
    </head>
    <body>
        hello world
        你好 世界
    </body>
</html>

# 在浏览器中测试，a.html 的中文内容会乱码， b.html 的中文件内容不会乱码
# 因为 b.html 在 源码中指定了 <meta charset="UTF-8" />，明确告诉了客户端要用 utf-8字符集编码解析
# 但在响应头 Content-Type 行中都没有字符集内容
root@ubuntu2204:/apps/nginx/html 17:33:33 #  curl -I 127.1/a.html
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Sun, 07 Sep 2025 09:33:50 GMT
Content-Type: text/html
Content-Length: 27
Last-Modified: Sun, 07 Sep 2025 09:31:23 GMT
Connection: keep-alive
ETag: "68bd50eb-1b"
Accept-Ranges: bytes

root@ubuntu2204:/apps/nginx/html 17:33:50 #  curl -I 127.1/b.html
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Sun, 07 Sep 2025 09:33:55 GMT
Content-Type: text/html
Content-Length: 136
Last-Modified: Sun, 07 Sep 2025 09:33:31 GMT
Connection: keep-alive
ETag: "68bd516b-88"
Accept-Ranges: bytes

root@ubuntu2204:/apps/nginx/html 17:33:55 # 

# 修改 Nginx 配置文件，指定字符集
root@ubuntu2204:/apps/nginx 17:35:47 # vim /apps/nginx/conf/nginx.conf
http {
	charset utf8;
	...
}
root@ubuntu2204:/apps/nginx 17:36:11 # systemctl reload nginx
root@ubuntu2204:/apps/nginx 17:36:21 # curl -I 127.1/a.html
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Sun, 07 Sep 2025 09:37:19 GMT
Content-Type: text/html; charset=utf8   # 此处多了字符集的内容
Content-Length: 27
Last-Modified: Sun, 07 Sep 2025 09:31:23 GMT
Connection: keep-alive
ETag: "68bd50eb-1b"
Accept-Ranges: bytes

root@ubuntu2204:/apps/nginx 17:37:19 # curl -I 127.1/b.html
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Sun, 07 Sep 2025 09:37:24 GMT
Content-Type: text/html; charset=utf8
Content-Length: 136
Last-Modified: Sun, 07 Sep 2025 09:33:31 GMT
Connection: keep-alive
ETag: "68bd516b-88"
Accept-Ranges: byt
~~~

范例：设置隐藏 Nginx 版本信息和服务器系统信息

~~~shell
# 当前会响应 Nginx 版本信息
root@ubuntu2204:/apps/nginx 17:38:04 # curl -I 127.1
HTTP/1.1 200 OK
Server: nginx/1.22.1   #此处有 Nginx 版本信息
Date: Sun, 07 Sep 2025 09:38:51 GMT
Content-Type: text/html; charset=utf8
Content-Length: 615
Last-Modified: Sat, 06 Sep 2025 11:19:41 GMT
Connection: keep-alive
ETag: "68bc18cd-267"
Accept-Ranges: bytes


# 默认的错误页面中也有
root@ubuntu2204:/apps/nginx 17:39:20 # curl  127.1/asfagsdf
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.22.1</center>
</body>
</html>


# 修改配置文件，设置 server_tokens off
root@ubuntu2204:/apps/nginx 17:39:24 # vim conf/nginx.conf
http{
	server_tokens off;
	...
}
root@ubuntu2204:/apps/nginx 17:39:55 # systemctl reload nginx


# 再次查看
# 均不再显示 Nginx 版本信息
root@ubuntu2204:/apps/nginx 17:40:03 # curl -I 127.1
HTTP/1.1 200 OK
Server: nginx
Date: Sun, 07 Sep 2025 09:40:38 GMT
Content-Type: text/html; charset=utf8
Content-Length: 615
Last-Modified: Sat, 06 Sep 2025 11:19:41 GMT
Connection: keep-alive
ETag: "68bc18cd-267"
Accept-Ranges: bytes

root@ubuntu2204:/apps/nginx 17:40:48 # curl  127.1/asfagsdf
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
root@ubuntu2204:/apps/nginx 17:40:52 # 

~~~

### 2.3.2 server 配置

server 主要用来配置虚拟主机，可以在一台 web 服务器上支持多个域名

~~~shell
root@ubuntu2204:~ 17:43:38 # cat /etc/nginx/sites-enabled/default
listen address[:port] [default_server] [ssl]; 
listen port [default_server] [ssl];
listen unix:path [default_server] [ssl]; 	#当前虚以主机监听的 ip,port，是否是 default_server，是否支持ssl 等
 											#默认值 *:80|*:8000; 可以写多条，完全说明请参考官方文档
 
ssl_certificate file; 		#当前虚拟主机证书和CA机构证书，放在一个文件中，默认值为空
ssl_certificate_key file; 	#私钥文件路径，默认为空
ssl_session_cache off|none|[builtin[:size]] [shared:name:size];
 							#是否启用 ssl 缓存，默认none
 							#off 不使用 ssl 缓存
 							#none 通知客户端，当前支持 ssl session cache
                            #builtin[:size] 使用 openssl 内建缓存,为每个worker 进程私有
                            #shared:name:size woker 进程共享缓存
ssl_session_timeout N; 		#客户端连接可以复用 ssl session cache 中缓存的有效时长，默认5m
ssl_ciphers ciphers; 		#指定 SSL/TLS 加密算法，默认值 HIGH:!aNULL:!MD5;
 							#默认值表示加密优先级高，排除匿名加密算法，排除 MD5 加密算法
 
ssl_prefer_server_ciphers on|off; #默认off，表示在SSL/TLS握手时优先使用客户端加密套，on表示优先使用服务端套件
    
root path; 					#当前虚拟主机网页文件目录，写在 location 中，文件路径是 root+location
index file ...; 			#当前虚拟主机的默认页面，可以写多个，按顺序生效，默认 index.html
server_name name ...; 		#虚拟主机域名，可以写多个值，客户端请求头中的 Host 字段会与此处匹配
 							#默认值是""，用来匹配请求头中 Host 字段值为空的请求
 							#还可以写成 _,@ 等用来表示无效域名，和 listen 中的default_server配合
location / {
 ......
 ......
} 							
~~~

### 2.3.3 location 配置

一个 server 配置段中可以有多个 locatio 配置，用于实现从 uri 到文件系统的路径映射，Ngnix 会根据用户请求的 uri 来检查定义的所有location，按一定的优先级找出一个最佳匹配，而后应用其配置

location 指令作用于 server 配置段中，也可以嵌套

~~~shell
https://nginx.org/en/docs/http/ngx_http_core_module.html#location
~~~

~~~shell
location [ = | ~ | ~* | ^~ ] uri { ... }
location @name { ... }

# 配置段匹配规则
= 		#用于标准uri前，需要请求字串与uri精确匹配，区分大小写
^~ 		#用于标准uri前，表示包含正则表达式，匹配以特定字符串开始，区分大小写
~ 		#用于标准uri前，表示包含正则表达式，区分大小写
~* 		#用于标准uri前，表示包含正则表达式，不区分大写
/str 	#不带符号 匹配以 str 开头的 uri，/ 也是一个字符
\ 		#用于标准uri前，表示包含正则表达式并且转义字符，可以将 . * ?等转义为普通符号
@name 	#定义

#匹配规则优先级
=, ^~, ~/~*, /str


#常用配置项
alias path; #定义路径别名，把访问路径重新映射到其它目录，此指令仅用于 location 中，与 root 有本质区别
root path; #定义网站在文件系统上的家目录，写在 location 中，文件的绝对路径等于外层 server 中定义的 root+location
index file ...; #当前配置段的默认页面，可以写多个，依次生效，默认 index.html
return code [text]|code URL|URL; #直接给客户端返回状态码+字符串或URL，此指令后的其它指令都不再生效
proxy_pass URL; #设置反向代理，将符合规则的请求转发到后端服务器进行处理
fastcgi_pass address; #通过fastCGI协议将请求转发到后端服务器进行处理，可以写在 ip:port 或 unix:/socekt
fastcgi_index name; #fastCGI协议的默认资源，默认为空
fastcgi_param parameter value [if_not_empty]; #设置传给fastCGI服务器的参数 key val 格式
deny address|CIDR|unix:|all; #拒绝访问的客户端，黑名单，可以是具体IP，网段，socket(1.5.1版本以上)，所有
allow address|CIDR|unix:|all; #允许访问的客户端，白名单，可以是具体IP，网段，socket(1.5.1版本以上)，所有
 #deny 和 allow 指令同时存在时，按加载顺序生效 
                                
try_files file ... uri|file ... =code; #按顺序查询文件是否存在，返回第一个匹配到的，如果没有匹配到，
 #会内部重定向到最后一个参数
~~~

## 2.4 多虚拟主机实现

多虚拟主机是指在一台 Nginx 服务器上配置多个网站

在 Nginx 中，多虚拟主机有三种实现方式：

- 基于IP地址实现多虚拟主机
- 基于端口号实现多虚拟主机
- 基于域名实现多虚拟主机

### 2.4.1 基于域名实现多虚拟主机

在 Nginx 中配置多个 server 段，每个 server 中设置一个虚拟主机配置，客户端访问服务器时，会根据客户端请求头中的 Host 字段值来匹配 server 段中的配置，从而访问不同的网站

~~~shell
root@ubuntu2204:/etc/nginx 21:24:07 # grep -E "include" nginx.conf 
include /etc/nginx/modules-enabled/*.conf;
	include /etc/nginx/mime.types;
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;

# 设置两个域名配置文件
root@ubuntu2204:/etc/nginx 21:28:38 # cat sites-enabled/www.test01.com.conf sites-enabled/www.test02.com.conf 
server{
    listen 80;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
}
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
}
root@ubuntu2204:/etc/nginx 21:28:53 # 


# 修改默认页面，创建网站目录和首页
root@ubuntu2204:/etc/nginx 21:28:53 # mv /var/www/html/index.nginx-debian.html /tmp
root@ubuntu2204:/etc/nginx 21:29:35 # echo "welcome to nginx"  > /var/www/html/index.html
root@ubuntu2204:/etc/nginx 21:29:55 # mkdir  /var/www/html/www.test{01,02}.com -pv 
mkdir: created directory '/var/www/html/www.test01.com'
mkdir: created directory '/var/www/html/www.test02.com'
root@ubuntu2204:/etc/nginx 21:30:16 #  echo "this page from test01" > /var/www/html/www.test01.com/index.html
root@ubuntu2204:/etc/nginx 21:30:41 # echo "this page from test02" > /var/www/html/www.test02.com/index.html
root@ubuntu2204:/etc/nginx 21:30:54 # tree /var/www/html/
/var/www/html/
├── index.html
├── www.test01.com
│   └── index.html
└── www.test02.com
    └── index.html

2 directories, 3 files

# 检测配置文件
root@ubuntu2204:/etc/nginx 21:31:05 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

# 重载 Nginx
root@ubuntu2204:/etc/nginx 21:31:12 # systemctl reload nginx

# 进行域名解析
root@ubuntu2204:/etc/nginx 21:31:25 # vim /etc/hosts

# 访问测试
root@ubuntu2204:/etc/nginx 21:31:51 # curl www.test01.com
this page from test01
root@ubuntu2204:/etc/nginx 21:31:56 # curl www.test02.com
this page from test02
root@ubuntu2204:/etc/nginx 21:31:58 # 

~~~

### 2.4.2 设置虚拟主机的默认主页

~~~shell
# 当前没有设置 index，使用默认index配置
root@ubuntu2204:/etc/nginx 21:33:57 # cat sites-enabled/www.test01.com.conf 
server{
    listen 80;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
}
root@ubuntu2204:/etc/nginx 21:34:03 # 

root@ubuntu2204:/etc/nginx 21:34:03 # ls -l /var/www/html/www.test01.com/
total 4
-rw-r--r-- 1 root root 22 Sep  7 21:30 index.html
root@ubuntu2204:/etc/nginx 21:34:20 #


# 测试，默认 index.html 生效
root@ubuntu2204:/etc/nginx 21:34:26 # curl www.test01.com
this page from test01

# 在 Nginx 配置文件中修改配置
root@ubuntu2204:/etc/nginx 21:41:45 # cat sites-enabled/www.test01.com.conf
server{
    listen 80;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
}
root@ubuntu2204:/etc/nginx 21:41:47 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/etc/nginx 21:41:49 # systemctl reload nginx
root@ubuntu2204:/etc/nginx 21:41:56 # 


# 访问测试
root@ubuntu2204:/etc/nginx 21:42:27 # echo "defautl page" > /var/www/html/www.test01.com/default.html
root@ubuntu2204:/etc/nginx 21:42:48 # echo "a.txt page" > /var/www/html/www.test01.com/a.txt

# index.html 
root@ubuntu2204:/etc/nginx 21:43:04 # curl www.test01.com
this page from test01

# 没有 index.html 后，访问 default.html
root@ubuntu2204:/etc/nginx 21:43:16 # rm -f /var/www/html/www.test01.com/index.html 
root@ubuntu2204:/etc/nginx 21:43:31 # curl www.test01.com
defautl page

# 没有 index.html 和 default.html 后，访问 a.txt
root@ubuntu2204:/etc/nginx 21:43:39 # rm -f /var/www/html/www.test01.com/default.html 
root@ubuntu2204:/etc/nginx 21:43:42 # curl www.test01.com
a.txt page

# 当 nginx 配置文件中设定的 index 都没有了后，再次访问就会报错
root@ubuntu2204:/etc/nginx 21:43:54 # rm -f /var/www/html/www.test01.com/a.txt
root@ubuntu2204:/etc/nginx 21:44:03 # curl www.test01.com
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>

# 就算有别的文件，也不是 index 规定的文件，也不能访问
root@ubuntu2204:/etc/nginx 21:44:05 # echo "b.txt page" > /var/www/html/www.test01.com/b.txt
root@ubuntu2204:/etc/nginx 21:44:18 # curl www.test01.com
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
root@ubuntu2204:/etc/nginx 21:44:19 # 

~~~

### 2.4.3 设置服务器的默认虚拟主机

用 http 协议访问服务器 IP 或没有在服务器上配置的域名时，会被默认虚拟主机命中

~~~shell
# 如果此时，客户端直接访问服务器 IP 地址，能访问到默认界面
root@ubuntu2204:/etc/nginx 21:44:19 # curl 127.1
welcome to nginx
root@ubuntu2204:/etc/nginx 21:48:48 # 


# 在主配置文件 /etc/nginx.conf 中，包含了虚拟主机配置文件
root@ubuntu2204:/etc/nginx 21:44:19 # cat /etc/nginx/nginx.conf
include /etc/nginx/sites-enabled/*;

root@ubuntu2204:/etc/nginx 21:52:59 # ls -l sites-enabled/
total 8
lrwxrwxrwx 1 root root  34 Sep  6 13:48 default -> /etc/nginx/sites-available/default
-rw-r--r-- 1 root root 137 Sep  7 21:41 www.test01.com.conf
-rw-r--r-- 1 root root  96 Sep  7 21:28 www.test02.com.conf


# 查看当前的虚拟主机配置
root@ubuntu2204:/etc/nginx 21:50:32 # cat sites-enabled/default  | egrep -v "#|^$"
server {
	listen 80 default_server; # default_server 表示默认虚拟主机配置
	listen [::]:80 default_server; # default_server 表示默认虚拟主机配置
	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	server_name _;
	location / {
		try_files $uri $uri/ =404;
	}
}
root@ubuntu2204:/etc/nginx 21:50:44 # 

# 客户端增加 www.test03.com www.test04.com 的解析
# 但服务端没有该域名的配置
# 测试，被服务端兜底的配置命中
root@ubuntu2204:/etc/nginx 21:51:49 # curl www.test03.com
welcome to nginx
root@ubuntu2204:/etc/nginx 21:51:59 # curl www.test04.com
welcome to nginx
root@ubuntu2204:/etc/nginx 21:52:01 # 

~~~

~~~shell
# 修改服务端配置,新增域名解析
root@ubuntu2204:/etc/nginx 21:56:32 # cat sites-enabled/www.test03.com.conf
server{
    listen 80;
    server_name www.test03.com;
    root /var/www/html/www.test03.com;
}

root@ubuntu2204:/etc/nginx 21:56:52 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/etc/nginx 21:56:55 # systemctl reload nginx
root@ubuntu2204:/etc/nginx 21:57:02 # 
root@ubuntu2204:/etc/nginx 21:57:02 # mkdir -pv /var/www/html/www.test03.com
mkdir: created directory '/var/www/html/www.test03.com'
root@ubuntu2204:/etc/nginx 21:57:28 # echo "this page from test03" > /var/www/html/www.test03.com/index.html

# 客户端测试-命中域名配置
root@ubuntu2204:/etc/nginx 21:57:52 # curl www.test03.com
this page from test03
root@ubuntu2204:/etc/nginx 21:57:58 # 

# 客户端测试-命中默认配置
root@ubuntu2204:/etc/nginx 21:57:58 # curl www.test04.com
welcome to nginx
root@ubuntu2204:/etc/nginx 21:58:18 #

# 去掉默认配置中的 default_server
root@ubuntu2204:/etc/nginx 21:57:58 #  cat /etc/nginx/sites-enabled/default
server {
 #listen 80 default_server;
 #listen [::]:80 default_server;
 listen 80;
 
 ......
 ......


# 重载服务并测试
# 还是被 default 配置命中
root@ubuntu2204:/etc/nginx 22:00:39 # curl www.test03.com
this page from test03
root@ubuntu2204:/etc/nginx 22:00:45 # curl www.test04.com
welcome to nginx


# 在没有定义 default_server 的情况下，默认会被第一个配置文件命中
# 主配置文件中会按此顺序引用文件
root@ubuntu2204:/etc/nginx 22:01:06 # ls -il sites-enabled/
total 12
525993 lrwxrwxrwx 1 root root  34 Sep  6 13:48 default -> /etc/nginx/sites-available/default
525613 -rw-r--r-- 1 root root 137 Sep  7 21:41 www.test01.com.conf
525661 -rw-r--r-- 1 root root  96 Sep  7 21:28 www.test02.com.conf
525615 -rw-r--r-- 1 root root  96 Sep  7 21:56 www.test03.com.conf


# 将别的文件设置为 default_server
# www.test01.com.conf 虽然不是第一个引用，但是设置了 default_server
root@ubuntu2204:/etc/nginx 22:03:10 # cat sites-enabled/www.test01.com.conf
server{
    listen 80 default_server;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
}
root@ubuntu2204:/etc/nginx 22:03:15 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/etc/nginx 22:03:20 # systemctl reload nginx 
root@ubuntu2204:/etc/nginx 22:04:32 # curl www.test04.com
a.txt page

~~~

### 2.4.4 基于 IP 地址实现多虚拟主机

~~~shell
# 添加 IP
root@ubuntu2204:/etc/nginx/sites-enabled 13:55:55 # ip address add 191.168.121.11/24 dev ens33 
root@ubuntu2204:/etc/nginx/sites-enabled 13:56:22 # ip address add 191.168.121.12/24 dev ens33 
root@ubuntu2204:/etc/nginx/sites-enabled 13:56:29 # ip address add 191.168.121.13/24 dev ens33 
root@ubuntu2204:/etc/nginx/sites-enabled 13:56:32 # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:3a:bf:dc brd ff:ff:ff:ff:ff:ff
    altname enp2s1
    inet 192.168.121.111/24 brd 192.168.121.255 scope global ens33
       valid_lft forever preferred_lft forever
    inet 191.168.121.11/24 scope global ens33
       valid_lft forever preferred_lft forever
    inet 191.168.121.12/24 scope global secondary ens33
       valid_lft forever preferred_lft forever
    inet 191.168.121.13/24 scope global secondary ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe3a:bfdc/64 scope link 
       valid_lft forever preferred_lft forever
root@ubuntu2204:/etc/nginx/sites-enabled 13:56:37 # 


# 恢复 default_server ，为域名绑定不同的IP
root@ubuntu2204:/etc/nginx/sites-enabled 13:58:20 # cat www.test01.com.conf
server{
    listen 192.168.121.11:80;
    listen 192.168.121.12:80;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
}
root@ubuntu2204:/etc/nginx/sites-enabled 13:58:27 # 
root@ubuntu2204:/etc/nginx/sites-enabled 13:58:53 # cat www.test02.com.conf
server{
    listen 192.168.121.13:80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
}
root@ubuntu2204:/etc/nginx/sites-enabled 13:58:54 # 


# 客户端修改hosts,并测试
root@ubuntu2204:/etc/nginx/sites-enabled 14:00:18 # cat /etc/hosts
127.0.0.1 localhost
127.0.1.1 ubuntu2204

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
192.168.121.11 www.test01.com
192.168.121.12 www.test02.com
192.168.121.13 www.test03.com
root@ubuntu2204:/etc/nginx/sites-enabled 14:00:20 # 
root@ubuntu2204:/etc/nginx/sites-enabled 14:08:21 # curl 192.168.121.11
root@ubuntu2204:/etc/nginx/sites-enabled 14:08:21 # curl 192.168.121.12
root@ubuntu2204:/etc/nginx/sites-enabled 14:08:21 # curl 192.168.121.13
~~~

### 2.4.5 基于端口号实现多虚拟主机

~~~shell
# 服务器上所有IP 的81，82，88端口都会被此规则匹配
root@ubuntu2204:/etc/nginx/sites-enabled 14:12:31 # cat www.test01.com.conf www.test02.com.conf 
server{
    listen 81;
    listen 82;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
}
server{
    listen 88;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
}
root@ubuntu2204:/etc/nginx/sites-enabled 14:12:35 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/etc/nginx/sites-enabled 14:12:39 # systemctl restart nginx
root@ubuntu2204:/etc/nginx/sites-enabled 14:12:44 # ss -tunlp  |grep "81|82|88"
root@ubuntu2204:/etc/nginx/sites-enabled 14:13:00 # ss -tunlp  |egrep "81|82|88"
tcp   LISTEN 0      511          0.0.0.0:88        0.0.0.0:*    users:(("nginx",pid=59234,fd=9),("nginx",pid=59233,fd=9),("nginx",pid=59232,fd=9),("nginx",pid=59231,fd=9),("nginx",pid=59230,fd=9))
tcp   LISTEN 0      511          0.0.0.0:81        0.0.0.0:*    users:(("nginx",pid=59234,fd=7),("nginx",pid=59233,fd=7),("nginx",pid=59232,fd=7),("nginx",pid=59231,fd=7),("nginx",pid=59230,fd=7))
tcp   LISTEN 0      511          0.0.0.0:82        0.0.0.0:*    users:(("nginx",pid=59234,fd=8),("nginx",pid=59233,fd=8),("nginx",pid=59232,fd=8),("nginx",pid=59231,fd=8),("nginx",pid=59230,fd=8))
root@ubuntu2204:/etc/nginx/sites-enabled 14:13:02 #

# 访问测试
root@ubuntu2204:/etc/nginx/sites-enabled 14:13:02 # curl 127.1
welcome to nginx
root@ubuntu2204:/etc/nginx/sites-enabled 14:14:00 # curl 127.1:81
a.txt page
root@ubuntu2204:/etc/nginx/sites-enabled 14:14:06 # curl 127.1:82
a.txt page
root@ubuntu2204:/etc/nginx/sites-enabled 14:14:08 # curl 127.1:88
this page from test02
root@ubuntu2204:/etc/nginx/sites-enabled 14:14:10 # 

~~~

## 2.5 location 指令使用

### 2.5.1 root 和 alias

~~~shell
# root 用于指定网站的根目录位置
root@ubuntu2204:/etc/nginx 14:31:21 # cat sites-enabled/www.test02.com.conf 
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
}
root@ubuntu2204:/etc/nginx 14:31:54 # 

# alias 定义路径别名，将访问请求映射到其它路径，只能写在 location 中
root@ubuntu2204:/etc/nginx/sites-enabled 14:28:59 # cat www.test01.com.conf
server{
    listen 80;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
    location /about {
        alias /data/about;  # 访问 http://www.m99-magedu.com/about 被此规则命中，其它目录不受此规则影响
    }
}

# 查看文件系统
root@ubuntu2204:/etc/nginx 14:31:54 # tree /data/
/data/
└── about
    └── test.html

1 directory, 1 file
root@ubuntu2204:/etc/nginx 14:33:50 # tree /var/www/html/
/var/www/html/
├── index.html
├── www.test01.com
│   ├── about
│   │   └── test.html
│   └── a.txt
├── www.test02.com
│   └── index.html
└── www.test03.com
    └── index.html

4 directories, 5 files
root@ubuntu2204:/etc/nginx 14:33:57 # 


# 测试
root@ubuntu2204:/etc/nginx 14:31:16 # curl www.test01.com/about/test.html
data about

~~~

~~~shell
# location 中的 root
root@ubuntu2204:/etc/nginx 14:42:16 # cat sites-enabled/www.test01.com.conf
server{
    listen 80;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
    location /about {
        root /data;
    }
}
root@ubuntu2204:/etc/nginx 14:42:18 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

root@ubuntu2204:/etc/nginx 14:42:25 # systemctl restart nginx
root@ubuntu2204:/etc/nginx 14:42:42 # curl www.test01.com/about/test.html
data about
root@ubuntu2204:/etc/nginx 14:42:51 # 

~~~

~~~ini
location 中 root 和 alias 的区别
访问 http://www.test01.com/about/*
被定向到文件系统   /data/about/*
把 uri www.test01.com/about 中的 /about 换成 alias 的值 即 /data/about ----> www.test01.com/data/about
server_name www.test01.com;
root /var/www/html/www.test01.com;
location /about { 
   alias /data/about; 
}


访问 http://www.test01.com/about/* 
被定向到文件系统   /data/about/*
把 uri www.test01.com/about 中的 www.test01.com 的根目录映射成文件路径 /data，然后再访问 /data/about 
如果 uri 中没有 about，则不会被此规则匹配
server_name www.m99-magedu.com;
root /var/www/html/www.m99-magedu.com;
location /about{
 root /data;
}
~~~

### 2.5.2 location 规则优先级

~~~shell
# 匹配规则优先级
=, ^~, ~/~*, /str

# 配置
root@ubuntu2204:/etc/nginx 15:40:38 # cat sites-enabled/www.test01.com.conf 
server{
    listen 80;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
    location / {					# 精确匹配 /
        default_type text/html;
        return 200 'location /';   
    }
    location =/ {					# 匹配以 / 开始
        default_type text/html;
        return 200 'location =/';  
    }
    location /about/ {				# 匹配以 /about/ 开始，区分大小写
        default_type text/html;
        return 200 'location /about/';
    }
    location ^~ /image/ {			# 匹配以 /image/ 开始，不区分大小写
        default_type text/html;
        return 200 '^~ /image/';
    }
    location ~* \.(gif|png|jpg)$ {	# 匹配以 .gif|.png|.jpg 结尾的
        default_type text/html;
        return 200 'location ~* \.(gif|jpg|jpeg)';
    }
}
root@ubuntu2204:/etc/nginx 15:40:45 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/etc/nginx 15:40:48 # nginx -s reload 
root@ubuntu2204:/etc/nginx 15:40:54 # curl www.test01.com/
location =


root@ubuntu2204:/etc/nginx 15:41:11 # curl www.test01.com/about
location 
/root@ubuntu2204:/etc/nginx 15:41:19 # curl www.test01.com/about/
location /about/
root@ubuntu2204:/etc/nginx 15:41:32 # 
root@ubuntu2204:/etc/nginx 15:41:40 # curl www.test01.com/image.
location /
root@ubuntu2204:/etc/nginx 15:41:45 # curl www.test01.com/image/
^~ /image/
root@ubuntu2204:/etc/nginx 15:41:47 # curl www.test01.com/text.png
location ~* \.(gif|jpg|jpeg)
root@ubuntu2204:/etc/nginx 15:41:57 # 

~~~

### 2.5.3 location 匹配范例

#### ==2.5.3.1 精准匹配==

~~~shell
root@ubuntu2204:/etc/nginx 15:50:22 # cat sites-enabled/www.test02.com.conf 
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location =/logo {
        default_type image/png;
        alias /data/image/logo.png;
    }
    location =/logo.png {
        default_type image/png;
        root /data/image;
    }
}
root@ubuntu2204:/etc/nginx 15:50:32 # systemctl restart nginx

~~~

#### ==2.5.3.2 区分大小写 和不区分大小写==

~~~shell
# 区分大小写
# 编写 nginx 配置文件
root@ubuntu2204:/data/image 17:00:38 # cat /etc/nginx/sites-enabled/www.test02.com.conf 
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location ~ /A.?\.png {
        root /data/image;
    }
}
root@ubuntu2204:/data/image 17:01:11 # 
root@ubuntu2204:/data/image 16:59:13 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 16:59:24 # systemctl restart nginx

# 创建测试文件
root@ubuntu2204:/data/image 16:58:23 # echo "Ab.png" > Ab.png
root@ubuntu2204:/data/image 16:58:42 # echo "AC.png" > AC.png
root@ubuntu2204:/data/image 16:58:49 # echo "a.png" > a.png
root@ubuntu2204:/data/image 16:58:59 # echo "A.png" > A.png
root@ubuntu2204:/data/image 17:00:09 # tree 
.
├── Ab.png
├── AC.png
├── a.png
└── A.png

0 directories, 4 files
root@ubuntu2204:/data/image 17:00:38 # 


root@ubuntu2204:/data/image 16:59:29 # curl www.test02.com/Ab.png
Ab.png
root@ubuntu2204:/data/image 17:00:02 # curl www.test02.com/a.png
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
root@ubuntu2204:/data/image 17:00:06 # curl www.test02.com/A.png
A.png
root@ubuntu2204:/data/image 17:00:09 # 

~~~

~~~shell
# 不区分大小写
root@ubuntu2204:/data/image 17:02:22 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location ~* /A.?\.png {
        root /data/image;
    }
}
root@ubuntu2204:/data/image 17:02:23 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 17:02:28 # systemctl restart nginx 

# 测试访问
root@ubuntu2204:/data/image 17:02:32 # curl www.test02.com/a.png
a.png
root@ubuntu2204:/data/image 17:02:41 # curl www.test02.com/A.png
A.png
root@ubuntu2204:/data/image 17:02:43 # 

~~~

#### ==2.5.3.4 匹配访问路径==

~~~shell
root@ubuntu2204:/data/image 17:07:30 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location ~* /image {
        root /data;
    }
    location ~* /test {
        return 200 'test\n';
    }
}
root@ubuntu2204:/data/image 17:07:32 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 17:07:36 # systemctl reload nginx 
root@ubuntu2204:/data/image 17:07:41 # curl www.test02.com/image/A.png
A.png
root@ubuntu2204:/data/image 17:07:51 # curl www.test02.com/test
test
root@ubuntu2204:/data/image 17:07:58 # 

~~~

#### ==2.5.3.5 文件名后缀匹配==

~~~shell
root@ubuntu2204:/data/image 17:10:05 # cat   /etc/nginx/sites-enabled/www.test02.com.conf 
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location ~* \.(gif|jpg|jpeg|bmp|png|ico)$ {  # 以 .(gif|jpg|jpeg|bmp|png|ico) 结尾的资源都定位到 /data/images 中
        root /data/image;
    }
    location ~* \.(css|js)$ {					#以 .(css|js) 结尾的资源都定位到 /data/static 中
        root /data/static;
    }
}
root@ubuntu2204:/data/image 17:10:10 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 17:10:12 # systemctl restart nginx

# 文件系统查看
oot@ubuntu2204:/data/image 17:12:14 # tree /data/
/data/
├── about
│   └── test.html
├── image
│   ├── Ab.png
│   ├── AC.png
│   ├── a.png
│   ├── A.png
│   └── index.html
└── static
    └── a.css

3 directories, 8 files
root@ubuntu2204:/data/image 17:12:17 # 


# 访问测试
root@ubuntu2204:/data/image 17:10:16 # curl www.test02.com/A.png
A.png
root@ubuntu2204:/data/image 17:11:32 # curl www.test02.com/a.css
/data/static/

~~~

#### ==2.5.3.6 @local 重定向==

~~~shell
root@ubuntu2204:/data/image 17:15:58 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    error_page 404 @error;
    location @error {
        default_type text/html;
        return 200 'page not found\n';
    }
}
root@ubuntu2204:/data/image 17:16:00 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 17:16:07 # systemctl restart nginx.service 
root@ubuntu2204:/data/image 17:16:11 # curl www.test02.com/asdas
page not found
root@ubuntu2204:/data/image 17:16:19 # curl www.test02.com/asdas -I
HTTP/1.1 404 Not Found
Server: nginx/1.18.0 (Ubuntu)
Date: Mon, 08 Sep 2025 09:16:22 GMT
Content-Type: text/html
Content-Length: 15
Connection: keep-alive

root@ubuntu2204:/data/image 17:16:22 # 

~~~

# 三、Nginx 常用功能

## 3.1 Nginx 四层访问控制

Nginx 中的访问控制功能基于 ngx_http_access_module 模块实现，可以通过匹配客户端源 IP 地址进行限制

该模块是默认模块，在使用 apt/yum 安装的环境中默认存在，如果想要禁用，需要自行编译，然后显式声明禁用该模块

https://nginx.org/en/docs/http/ngx_http_access_module.html

~~~shell
deny address|CIDR|unix:|all; 	#拒绝访问的客户端，黑名单，可以是具体IP，网段，socket(1.5.1版本以上)，所有
allow address|CIDR|unix:|all; 	#允许访问的客户端，白名单，可以是具体IP，网段，socket(1.5.1版本以上)，所有
 								#deny 和 allow 指令同时存在时，按加载顺序生效 
 								#作用域 http, server, location, limit_except
~~~

~~~shell
root@ubuntu2204:/data/image 19:39:06 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location = /a.html {  # a.html 只允许 127.0.0.1 访问，但实际上不起作用，因为在 server 和 location 中都没有 deny。还是所有人都可以访问
        allow 127.0.0.1;
    }
}
root@ubuntu2204:/data/image 19:39:08 # 
root@ubuntu2204:/data/image 19:40:24 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location = /a.html {
        deny all;   # 所有人都不能访问 a.html 但当前 server 中其它资源不受影响
        allow 127.0.0.1;  # 此处放行了127.1，但 deny 写在前面了，所以 127.1 也同样无法访问
    }
}
root@ubuntu2204:/data/image 19:40:26 # 
root@ubuntu2204:/data/image 19:41:46 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location = /a.html {
        allow 127.0.0.1;   		# 放行 127.1
        deny 192.168.121.112;  	# 拒绝 192.168.121.112
        allow 192.168.122.0/24; # 放行 192.168.122.0/24 网段
        deny all;  				# 拒绝所有，兜底规则
    }
}
root@ubuntu2204:/data/image 19:41:48 # 

~~~

## 3.2 Nginx 账户认证

Nginx 中的账户认证功能由 ngx_http_auth_basic_module 模块提供，该模块也是默认模块

此种认证方式并不安全，如果服务端是 http 协议，而非 https 协议，则用户名和密码在网络中是明文传输的，可以被抓包工具截获

https://nginx.org/en/docs/http/ngx_http_auth_basic_module.html

~~~shell
auth_basic string|off; 		#身份验证时对话框上的提示信息，新版浏览器几乎不支持,默认off，即不启用验证功能
auth_basic_user_file file; 	#指定身份认证的用户名和密码的文件路径，密码要使用 htpasswd 命令生成
 							#作用域 http, server, location, limit_except
~~~

~~~shell
# 安装密码工具
root@ubuntu2204:/data/image 19:41:48 # apt install apache2-utils -y
[root@rocky ~]# yum -y install httpd-tools


# 创建用户名和密码
# 首次使用需要使用 -c 选项指定文件路径
root@ubuntu2204:/data/image 19:44:35 # htpasswd -c /etc/nginx/conf.d/httpuser tom
New password: 
Re-type new password: 
Adding password for user tom
# 新增用户，非交互式设置密码
root@ubuntu2204:/data/image 19:45:09 # htpasswd -b /etc/nginx/conf.d/httpuser jerry 123
Adding password for user jerry
root@ubuntu2204:/data/image 19:45:13 # 

# 查看文件，在生产环境中，基于安全考虑，可以将文件设为隐藏文件，修改属主属组，并配置读写权限
root@ubuntu2204:/data/image 19:45:13 # cat /etc/nginx/conf.d/httpuser 
tom:$apr1$U5Twm24w$Rel38xgy/jD2MgS67YPBa1
jerry:$apr1$gGyMQ9C1$.lM7YOTT0b2RBqpSKRUiH/
root@ubuntu2204:/data/image 19:46:08 # 


# nginx 配置验证
root@ubuntu2204:/data/image 19:47:21 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location = /a.html {
        auth_basic "pls input your name";    # 访问 www.test02.com/a.html 时需要验证
        auth_basic_user_file conf.d/httpuser; # 同域名下其它资源不用验证
    }
}
root@ubuntu2204:/data/image 19:47:24 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful


# 测试
# 在浏览器中会直接弹出结话框
# 命令行测试
root@ubuntu2204:/data/image 19:48:18 # curl www.test02.com/a.html
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
root@ubuntu2204:/data/image 19:48:34 # 
root@ubuntu2204:/data/image 19:49:18 # curl -u tom:123  www.test02.com/a.html
a.html
root@ubuntu2204:/data/image 19:49:20 # 
root@ubuntu2204:/data/image 19:49:37 # curl http://jerry:123@www.test02.com/a.html
a.html
root@ubuntu2204:/data/image 19:50:16 # 

~~~

## 3.3 自定义错误页面

在没有配置错误处理页面的情况下，非 200 状态码的响应请求返回的都是 Nginx 默认页面，我们可以通过指令设置自定义的错误页面，不同的虚拟主机，不同的错误都可以设置成不同的错误页面

https://nginx.org/en/docs/http/ngx_http_core_module.html#error_page

~~~shell
error_page code ... [=[response]] uri; 		#定义指定状态码的错误页面，可以多个状态码共用一个资源
										 	#作用域 http, server, location, if in location
~~~

~~~shell
server{
       listen 80;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
        
       error_page 400 404 502 503 504 error.html; # 自定义指定状态码的错误页面
        
       location = /error.html {
               root /data/errors;
       }
}

server{
       listen 80;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
       error_page 400 404 =302 http://www.baidu.com; # 临时重定向
       error_page 402 503 =301 http://www.baidu.com; # 永久重定向
}

root@ubuntu2204:/data/image 20:05:20 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    error_page 400 404 =302 /index.html;   # 通过 302 重定向到 index.html
}
root@ubuntu2204:/data/image 20:05:21 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 20:05:24 # systemctl restart nginx.service 
root@ubuntu2204:/data/image 20:05:31 # curl www.test02.com/asd
this page from test02
root@ubuntu2204:/data/image 20:05:37 # 

~~~

## 3.4 自定义错误日志

默认没有为每个 server 配置单独日志的情况下，所有错误日志和访问日志都是写在相同的文件中，我们可以单独为每个 server 或 location 设置日志

https://nginx.org/en/docs/ngx_core_module.html#error_log

~~~shell
# 全局配置
root@ubuntu2204:/data/image 20:05:37 #  cat /etc/nginx/nginx.conf | grep log
 access_log /var/log/nginx/access.log;
 error_log /var/log/nginx/error.log;
~~~

~~~shell
error_log file [level]; #指定保存错误日志的文件和记录级别，错误级别可参考syslog那一课的内容
 						#如果不需要记录日志，值可以写在 /dev/null
 						#默认值 error_log logs/error.log error
 						#作用域 main, http, mail, stream, server, location
~~~

~~~shell
root@ubuntu2204:/data/image 20:13:31 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    error_log /var/log/nginx/www.test02.com.error.log;
    location =/abc {
        error_log /dev/null;
    }
}
root@ubuntu2204:/data/image 20:13:33 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 20:13:35 # systemctl restart nginx.service 
root@ubuntu2204:/data/image 20:13:39 # ll /var/log/nginx/www.test02.com.error.log 
-rw-r--r-- 1 root root 0 Sep  8 20:13 /var/log/nginx/www.test02.com.error.log
root@ubuntu2204:/data/image 20:13:49 # 

# 访问测试
root@ubuntu2204:/data/image 20:13:49 # curl www.test02.com/adfdfsag
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
root@ubuntu2204:/data/image 20:14:09 # ll /var/log/nginx/www.test02.com.error.log 
-rw-r--r-- 1 root root 237 Sep  8 20:14 /var/log/nginx/www.test02.com.error.log
root@ubuntu2204:/data/image 20:14:11 # 

# 访问 /abc 不写入错误日志，重定向到 /dev/null 中
root@ubuntu2204:/data/image 20:14:11 # curl www.test02.com/abc
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
root@ubuntu2204:/data/image 20:14:35 # ll /var/log/nginx/www.test02.com.error.log
-rw-r--r-- 1 root root 237 Sep  8 20:14 /var/log/nginx/www.test02.com.error.log
root@ubuntu2204:/data/image 20:14:39 # 

~~~



## 3.5 检测资源文件是否存在

~~~shell
try_files file ... uri; 	# 按顺序查询资源是否存在，返回第一个匹配到的，如果没有匹配到，会内部重定向到最后一个资源
try_files file ... =code; 	# 最后还可以加一个状态码
~~~

~~~shell
# 默认虚拟主机中的 try_files
root@ubuntu2204:/data/image 20:14:39 # cat /etc/nginx/sites-enabled/default  | grep try_files
		try_files $uri $uri/ =404;
#		try_files $uri $uri/ =404;
root@ubuntu2204:/data/image 20:16:02 # 


# 修改配置文件
root@ubuntu2204:/data/image 20:19:28 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    try_files $uri $uri.html $uri/index.html /index.html;
    location /a {
        try_files $uri $uri.html;
    }
    location /b {
        try_files $uri $uri.html =418;
    }
}
root@ubuntu2204:/data/image 20:19:30 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 20:19:32 # systemctl restart nginx.service 
root@ubuntu2204:/data/image 20:19:37 # 

# 测试
root@ubuntu2204:/data/image 22:16:04 # curl www.test02.com/c
this page from test02
root@ubuntu2204:/data/image 22:16:28 # 


root@ubuntu2204:/data/image 22:15:38 # curl www.test02.com/a
a.html
root@ubuntu2204:/data/image 22:15:48 # curl www.test02.com/b
root@ubuntu2204:/data/image 22:15:55 # curl www.test02.com/b -I
HTTP/1.1 418 
Server: nginx/1.18.0 (Ubuntu)
Date: Mon, 08 Sep 2025 14:15:58 GMT
Content-Length: 0
Connection: keep-alive

root@ubuntu2204:/data/image 22:15:58 # curl www.test02.com/b -v
*   Trying 192.168.121.111:80...
* Connected to www.test02.com (192.168.121.111) port 80 (#0)
> GET /b HTTP/1.1
> Host: www.test02.com
> User-Agent: curl/7.81.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 418 
< Server: nginx/1.18.0 (Ubuntu)
< Date: Mon, 08 Sep 2025 14:16:04 GMT
< Content-Length: 0
< Connection: keep-alive
< 
* Connection #0 to host www.test02.com left intact
root@ubuntu2204:/data/image 22:16:04 # 

~~~

## 3.6 长连接配置

~~~shell
keepalive_timeout timeout [header_timeout]; 	# TCP握手建立连接后，会话可以保持多长时间，
 												# 在此时间内，可以继续传送数据，而不用再次握手
 												# 默认值 keepalive_timeout 75s
 												# header_timeout 用作响应头中显示，可以与前一个值不一样
                                                # 作用域 http, server, location
                                                 
keepalive_requests number; 					 	# 一次请求不断开连接的情况下最多可以传送多少个资源
 												# 默认值 keepalive_requests 1000;
 												# 作用域 http, server, location
 												# 在请求过程中以上两项达到一项阀值，连接就会断开
~~~

~~~shell
root@ubuntu2204:/data/image 22:15:55 # curl www.test02.com/b -I
HTTP/1.1 418 
Server: nginx/1.18.0 (Ubuntu)
Date: Mon, 08 Sep 2025 14:15:58 GMT
Content-Length: 0
Connection: keep-alive   # 默认有长连接
~~~

~~~shell
root@ubuntu2204:/data/image 22:21:16 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    keepalive_timeout 15 30;		# 在当前 server 中修改配置，服务端真实时长是 15s，响应头中显示30s
}
root@ubuntu2204:/data/image 22:21:18 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/data/image 22:21:20 # systemctl restart nginx.service 
root@ubuntu2204:/data/image 22:21:26 # 
root@ubuntu2204:/data/image 22:21:41 # curl -I www.test02.com 
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Mon, 08 Sep 2025 14:21:51 GMT
Content-Type: text/html
Content-Length: 22
Last-Modified: Sun, 07 Sep 2025 13:30:54 GMT
Connection: keep-alive
Keep-Alive: timeout=30		# 此处显示 30
ETag: "68bd890e-16"
Accept-Ranges: bytes

root@ubuntu2204:/data/image 22:21:51 # 


# 配置一次连接可以传输多少资源
server{
       listen 80;
       server_name www.test02.com;
       root /var/www/html/www.test02.com;
       keepalive_requests 2; #一个连接中可以获取两个资源
}
~~~

## 3.7 作为下载服务器配置

Nginx 的 ngx_http_autoindex_module 模块可以将目录内容按指定格式生成目录内容列表，常用作配置下载服务器

https://nginx.org/en/docs/http/ngx_http_autoindex_module.html

~~~shell
autoindex on|off; 						#是否显示目录内容列表,默认 off
autoindex_exact_size on|off; 			#是否以友好的方式显示文件大小，默认 on，表示显示文件具体字节数
autoindex_format html|xml|json|jsonp; 	#数据显示格式，默认 html
autoindex_localtime on|off 				#是否以本地时区显示文件时间属性，默认off，以UTC时区显示



#以上指令作用域均为 http, server, location
~~~

~~~shell
# 目录内容
root@ubuntu2204:/var/www/html/www.test02.com 22:29:37 # tree 
.
├── 100M.img
├── 500M.img
├── dir1
│   ├── dirX
│   │   └── syslog
│   └── dirY
├── dir2
│   ├── dirX
│   │   └── syslog
│   └── dirY
├── dir3
└── test.html

7 directories, 5 files
root@ubuntu2204:/var/www/html/www.test02.com 22:29:39 # 

# 配置 Nginx ，开启 autoindex
root@ubuntu2204:/var/www/html/www.test02.com 22:30:31 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    autoindex on;
    charset utf8;
}
root@ubuntu2204:/var/www/html/www.test02.com 22:30:35 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/var/www/html/www.test02.com 22:30:39 # systemctl restart nginx.service 
root@ubuntu2204:/var/www/html/www.test02.com 22:30:43 #
~~~

**浏览器访问**

![image-20250908223247804](Nginx.assets/image-20250908223247804.png)

~~~shell
root@ubuntu2204:/var/www/html/www.test02.com 22:33:25 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    autoindex on;
    autoindex_exact_size off;		# 以友好格式显示文件大小
    autoindex_localtime on;			# 以服务器时区显示文件时间
    charset utf8;
}
root@ubuntu2204:/var/www/html/www.test02.com 22:33:28 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/var/www/html/www.test02.com 22:33:29 # systemctl restart nginx.service 

~~~

**再次测试**

![image-20250908223440830](Nginx.assets/image-20250908223440830.png)

## 3.8 作为上传服务器

~~~shell
client_max_body_size size; #设置允许客户端上传单个文件最大值，超过此值会响应403，默认1m
client_body_buffer_size size #用于接收每个客户端请求报文的body部分的缓冲区大小，默认16k，超过此大小时，
 #数据将被缓存到由 client_body_temp_path 指令所指定的位置
 
client_body_temp_path path [level1 [level2 [level3]]]; 
 #设定存储客户端请求报文的body部分的临时存储路径及子目录结构和数量
                                #子目录最多可以设三级，数字表示当前级别创建几个子目录，16进制
~~~

~~~shell
server{
       listen 80;
       server_name www.test02.com;
       root /var/www/html/www.test02.com;
       client_max_body_size 10m;
       client_body_buffer_size 1024k;
       client_body_temp_path /tmp/client_body_temp/ 1 2; 
}
# client_body_temp_path /tmp/client_body_temp/ 1 2;
# 表示会在 /tmp/client_body_temp/ 创建 16个一级子目录 0-f, 256 个二级子目录，00-ff，这些目录在上传时才会创建
~~~

## 3.9 限流限速

### 3.9.1 限流限速背景

限速（rate limiting）是 Nginx 中一个非常有用但是经常被误解且误用的功能特性。我们可以用它来限制在一段时间内的 HTTP 请求的数量，这些请求可以是如 GET 这样的简单请求又或者是用来填充登录表单的 POST 请求

限速还可以用于安全防护用途，例如限制密码撞库暴力破解等操作的频率，也可以通过把请求频率限制在一个正常范围来抵御 DDoS 攻击，更常见的使用情况是通过限制请求的数量来确保后端的 upstream 服务器不会在短时间内遭受到大量的流量访问从而导致服务异常

目前 Nginx 中主要的三种限速操作分别是：限制请求数（request），限制连接数（connection），限制响应速度（rate），对应在 Nginx 中的模块指令分别是 limit_req，limit_conn 和 limit_rate 三部份

Nginx 中限速（rate limiting）的主要算法原理就是基于在计算机网络中当带宽有限时十分常用的漏桶算法，其基本原理是：以漏桶为例，水从顶部倒入，从底下漏出

- 漏桶对应我们服务器的带宽或者是处理请求的能力或者是一个队列
- 水表示客户端发送过来的请求
- 倒入的水则代表客户端发送给服务器但尚未进行处理的请求，此时请求仍在队列（在桶内）
- 漏出的水则代表从队列中出来即将发送给服务器端处理的请求，此时请求已经离开了队列（在桶外）

漏桶在一定程度上可以代表服务器的处理能力，请求根据先进先出（FIFO）调度算法等待处理，如果倒入水的速度小于漏水的速度，可以理解为服务器能够处理完所有的请求，此时整体服务表现正常。如果倒入水的速度大于漏水的速度，那么水桶内的水会不断增加直到最后溢出，这种情况下在水桶中的水可以理解为在队列中等待的请求，而溢出的水则表示直接被丢弃不处理的请求

### 3.9.2 限制单一连接下载速度

~~~shell
limit_rate rate; #对单个客户端连接限速，默认单位为字节，其它单位需要显式指定，表示每秒的下载速度
 #限速只对单一连接而言，同一客户端两个连接，总速率为限速2倍，默认值0，表示不限制
 
limit_rate_after size; #在传输了多少数据之后开始限速，默认值0，表示一开始就限速
 #作用域 http, server, location, if in location
~~~

~~~shell
# 配置 Nginx 
root@ubuntu2204:/var/www/html/www.test02.com 23:05:36 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    limit_rate 10k;				# 每秒下载速度为 10k
    limit_rate_after 1m;		# 前 1m，不限速
}
root@ubuntu2204:/var/www/html/www.test02.com 23:05:41 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/var/www/html/www.test02.com 23:05:43 # systemctl restart nginx.service 

# 测试
root@ubuntu2204:/var/www/html/www.test02.com 23:07:45 # wget http://www.test02.com/100M.img
~~~

### 3.9.3 限制客户端请求数

标记不同的客户端取决于我们在定义规则时的字段，取到相同的值，就可以认为是相同客户端，进而可以根据此值进行限制

https://nginx.org/en/docs/http/ngx_http_limit_req_module.html

~~~shell
limit_req_zone key zone=name:size rate=rate [sync]; # 定义一个限速规则，供limit_req 指令调用
 # key 定义用于限速的关键字，表示以什么为依据来限速
 # zone=name:size name 表示规则名称
 # size 表示使用多大内存空间存储 key 对应的内容，指桶大小
 # 数据会在多个 worker 进程共享
 # 空间耗尽后会使用 LRU 算法淘汰旧的数据
 
 # rate=rate 限制请求速率，
 # 同一个key 每秒可以请求多少次或每分钟可以请求多少次
 # [sync] 实现共享内存的区域同步，商业版支持
 # 作用域 http，定义好后需要在其它地方进行调用才生效
 

limit_req zone=name [burst=number] [nodelay|delay=number]
 
 # zone=name 表示调用哪个 limit_req_zone
 # [burst=number] 表示超过 rate 之后还能接收多少个请求，这些请求会被放到队列慢慢处理
 # [nodelay|delay=number] 
 # nodelay 表示 rate 匹配到的请求不会被放到队列而是直接处理，但后续请求返回 503
 # delay=number 表示有多少个请求直接处理，剩下的加队列慢慢处理
 # 作用域 http, server, location
 
 
limit_req_status code; # 因为 limit_req 配置被拒绝处理的请求的返回状态码，默认503, nginx 1.3.15 版本后可用
 # 作用域 http, server, location
 
 
 
 limit_req_log_level info|notice|warn|error
 # 定义因 limit_req 配置被拒绝处理的请求的日志级别，默认error
 # 作用域 http, server, location
 
limit_req_dry_run on|off; # on 表示 rate 参数无效，但共享内存中的数据还是有效，默认 off
 # 作用域 http, server, location
~~~

~~~shell
#定义一个limit_req_zone，以 $binary_remote_addr 值来标记客户端，zone 名称为 mylimit，存储空间为 10m
#同一客户端每秒能同时建立2个连接，2r/s 完整写法是 2requests/secends
#但是 nginx 是毫秒级别的控制粒度，2r/s 意味着对同一客户端在 500ms 只能处理一个请求
root@ubuntu2204:/var/www/html/www.test02.com 23:13:33 # cat /etc/nginx/sites-enabled/www.test02.com.conf
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=2r/s;  # 写在 http 中
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    limit_req zone=mylimit;  # 调用
}
root@ubuntu2204:/var/www/html/www.test02.com 23:13:34 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:/var/www/html/www.test02.com 23:15:51 # systemctl restart nginx.service 
root@ubuntu2204:/var/www/html/www.test02.com 23:15:55 # 
# 测试，同一客户端每0.4S 发起一个请求，服务端配置是500ms 内只能处理一个请求，所以第二次请求返回503
root@ubuntu2204:/var/www/html/www.test02.com 23:17:11 #  for i in {1..2};do curl http://www.test02.com;sleep 0.4;done
index
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
root@ubuntu2204:/var/www/html/www.test02.com 23:18:03 # 

# 查看服务端日志
root@ubuntu2204:/var/www/html/www.test02.com 23:18:03 # tail -n 2 /var/log/nginx/access.log
192.168.121.111 - - [08/Sep/2025:23:18:02 +0800] "GET / HTTP/1.1" 200 6 "-" "curl/7.81.0"
192.168.121.111 - - [08/Sep/2025:23:18:02 +0800] "GET / HTTP/1.1" 503 206 "-" "curl/7.81.0"
root@ubuntu2204:/var/www/html/www.test02.com 23:18:35 # 

# 再次测试，每个请求间隔0.5S，都能成功处理
root@ubuntu2204:/var/www/html/www.test02.com 23:18:35 # for i in {1..2};do curl http://www.test02.com;sleep 0.5;done
index
index
root@ubuntu2204:/var/www/html/www.test02.com 23:19:06 # 
root@ubuntu2204:/var/www/html/www.test02.com 23:19:06 # tail -n 2 /var/log/nginx/access.log
192.168.121.111 - - [08/Sep/2025:23:19:05 +0800] "GET / HTTP/1.1" 200 6 "-" "curl/7.81.0"
192.168.121.111 - - [08/Sep/2025:23:19:06 +0800] "GET / HTTP/1.1" 200 6 "-" "curl/7.81.0"
root@ubuntu2204:/var/www/html/www.test02.com 23:19:14 # 

~~~

~~~shell
# 当前配置，如果服务端在 500ms 内收到同一个客户端2个以上的请求，除了第一个请求会被处理之外，其它请求都返回503
# 并发是程序的天然属性，可能存在这个500ms 内有大量的请求，后续时间内没有任何请求的情况，
# 我们应该尽量 均匀平滑 的处理所有请求而不是直接拒绝
root@ubuntu2204:~ 11:19:53 # cat /etc/nginx/sites-enabled/www.test02.com.conf 
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=2r/s;
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    limit_req zone=mylimit burst=3;
}
root@ubuntu2204:~ 11:23:20 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 11:23:27 # systemctl restart nginx

# 编写测试脚本
root@ubuntu2204:~ 11:23:51 # cat test.sh 
############################
# File Name: test.sh
# Author: LnxGuru
# mail: xuruizhao00@163.com
# Created Time: Tue 09 Sep 2025 11:23:07 AM CST
############################
#!/bin/bash

for i in {1..5};do
 curl http://www.test02.com &
done
wait
root@ubuntu2204:~ 11:24:51 # 

root@ubuntu2204:~ 11:23:48 # bash test.sh 
# 同一客户端同时发起5个请求，第一个被处理，后续3个加队列，还有一个503拒绝
# 由于是并发执行，所以观察现象，第一个200和503同时返回，后续3个请求都有延时，说明加队列了
index
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
index
index
index
root@ubuntu2204:~ 11:23:51 # 

# 串行都能返回，但是是一个个返回，不是一下子返回所有
root@ubuntu2204:~ 11:24:51 #  for i in {1..5};do curl http://www.test02.com;done
index
index
index
index
index
root@ubuntu2204:~ 11:26:32 # 

~~~

~~~shell
#  burst=3 虽然使得客户端的请求变得 均匀平滑，但增加了响应时间，排在队列越后面的请求等待时间越久，如果请求数过多，可能会等到超时也不会被处理

# nodelay 表示无延时对列
# 当服务端在500ms 内收到同一客户端 5个请求的时候，第1个到第4个请求会被直接处理，同时标记队列中己占满，第5个返回503
# 后续每过500ms 释放出一个队列中的空间让新的请求进来


root@ubuntu2204:~ 11:29:12 # cat /etc/nginx/sites-enabled/www.test02.com.conf
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=2r/s;
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    limit_req zone=mylimit burst=3 nodelay;
}
root@ubuntu2204:~ 11:29:14 # nginx  -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 11:29:19 # systemctl restart nginx.service 
root@ubuntu2204:~ 11:29:23 # 

# 测试，同时返回，因为同时处理了4个请求和拒绝了1个请求
root@ubuntu2204:~ 11:29:23 # for i in {1..5};do curl http://www.test02.com;done
index
index
index
index
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
~~~

### 3.9.4 限制客户端并发连接数

https://nginx.org/en/docs/http/ngx_http_limit_conn_module.html

~~~shell
limit_conn_zone key zone=name:size; # 定义一个限速规则，供 limit_req 指令调用
 # key 定义用于限速的关键字，表示以什么为依据来限制并发连接数
 # zone=name:size name 表示规则名称
 # size 表示使用多大内存空间存储 key 对应的内容，指桶大小
 # 数据会在多个worker 进程共享，空间耗尽后会使用LRU算法淘汰旧的数据
 # 作用域 http
 
limit_zone name $variable size; # 在1.1.8版本后被弃用，改用 limit_conn_zone
limit_conn zone number; # zone 表示要调用的规则，number 表示要限制的连接数，不能写变量
 # 作用域 http, server, location
 
limit_conn_dry_run on|off; # on 表示 limit_conn 不生效，默认 off
 # 作用域 http, server, location
limit_conn_log_level info|notice|warn|error; # 因 limit_conn 被拒绝连接的日志的级别，默认 error
 # 作用域 http, server, location
 
limit_conn_status code; # 因 limit_conn 被拒绝连接的返回状态码，默认503
 # 作用域 http, server, location
~~~

~~~shell
root@ubuntu2204:~ 14:13:50 # cat /etc/nginx/sites-enabled/www.test02.com.conf
limit_conn_zone $binary_remote_addr zone=mylimit:10m;
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    limit_rate 10k;
    limit_conn mylimit 2;
}
root@ubuntu2204:~ 14:13:51 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

root@ubuntu2204:~ 14:06:58 # systemctl restart nginx.service 
root@ubuntu2204:~ 14:07:02 # 
root@ubuntu2204:~ 14:07:02 # tree /var/www/html/www.test02.com/
/var/www/html/www.test02.com/
├── 100M.img
├── 100M.img.1
├── 500M.img
├── dir1
│   ├── dirX
│   │   └── syslog
│   └── dirY
├── dir2
│   ├── dirX
│   │   └── syslog
│   └── dirY
├── dir3
├── index.html
└── test.html


# 测试，同一客户端在己有两个下载的情况下，不能再建立新连接
root@ubuntu2204:~ 14:10:19 # wget www.test02.com/500M.img
--2025-09-09 14:14:12--  http://www.test02.com/500M.img
Resolving www.test02.com (www.test02.com)... 192.168.121.111
Connecting to www.test02.com (www.test02.com)|192.168.121.111|:80... connected.
HTTP request sent, awaiting response... 503 Service Temporarily Unavailable
2025-09-09 14:14:12 ERROR 503: Service Temporarily Unavailable.

~~~

## 3.10 Nginx 状态页

https://nginx.org/en/docs/http/ngx_http_stub_status_module.html

~~~shell
stub_status; #添加此指令后可开启 Nginx 状态页，作用域 server, location
~~~

~~~shell
root@ubuntu2204:~ 14:16:16 # cat /etc/nginx/sites-enabled/www.test02.com.conf
limit_conn_zone $binary_remote_addr zone=mylimit:10m;
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location /status {
        stub_status;
    }
}
root@ubuntu2204:~ 14:16:18 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 14:16:19 # systemctl reload nginx.service 
root@ubuntu2204:~ 14:16:24 # 
# 浏览器访问 www.test02.com/status
~~~

![image-20250909141704139](Nginx.assets/image-20250909141704139.png)

~~~shell
Active connections: 2
server accepts handled requests 
8 8 55
Reading: 0 Writing: 1 Waiting: 1

# Active connections   当前处于活动状态的客户端连接数，=reading+writing+waiting
# accepts 总数，自 Nginx 启动到当前己接收的客户端请求总数
# handled 总数，自 Nginx 启动到当前己处理完成的连接数，通常等于 accepts，如果有失败连接，则要去掉失败连接
# requests 总数，自 Nginx 启动到当前客户端己发送的请求总数
# Reading 状态，当前正在读取请求报文的连接数，值越大，说明排队现象严重，性能不足
# Writing 状态，正在向客户端发送响应报文过程中的连接数，值越大，说明访问量越大
# Waiting 状态，己建立连接，但没有数据传输的空闲连接数，开启 keep-alive，Reading+Writing+Waiting=Active connections
~~~

## 3.11 Nginx 第三方模块使用

第三方模块是对 Nginx 的功能扩展，需要在编译的时候用 --add-module=PATH 指定路径，所以在使用前要先获得第三方模块的源码，当然，我们也可以自行编写第三方模块

相同的功能，如果Nginx 有官方模块实现，则尽量使用官方模块实现，如果官方没有该功能，我们才考虑使用第三方模块，一般可以去 github 上搜索我们需要扩展模块

~~~shell
https://github.com/vozlt/nginx-module-vts 		# 第三方流量监控模块
https://github.com/openresty/echo-nginx-module 	# echo 模块，可以直接输出
~~~

==重新编译安装 Nginx==

~~~shell
# 安装必备工具
root@ubuntu2204:~ 14:36:02 #  apt update && apt install -y make gcc libpcre3 libpcre3-dev openssl libssl-dev zlib1g-dev

# 创建 Nginx 运行用户
root@ubuntu2204:~ 14:36:54 # useradd -r -s /sbin/nologin nginx 

# 下载最新版源码并解压
root@ubuntu2204:~ 14:37:16 #  wget https://nginx.org/download/nginx-1.22.1.tar.gz
root@ubuntu2204:~ 14:37:42 # tar xf nginx-1.22.1.tar.gz 
root@ubuntu2204:~ 14:37:46 # cd nginx-1.22.1/
root@ubuntu2204:~/nginx-1.22.1 14:37:47 # 


# 下载第三方模块 使用 --add-module 参数指定第三方模块位置
root@ubuntu2204:~/nginx-1.22.1 14:47:33 # ./configure --prefix=/apps/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module  --with-pcre --with-stream --with-stream_ssl_module --with-stream_realip_module --add-module=/root/echo-nginx-module-0.63 --add-module=/root/nginx-module-vts-0.2.2
root@ubuntu2204:~/nginx-1.22.1 14:50:16 # make && make install

# 修改目录的属主和属组
root@ubuntu2204:~ 14:54:45 # chown -R nginx:nginx /apps/nginx/

# 创建软链接
root@ubuntu2204:~ 14:54:54 # ln -sv /apps/nginx/sbin/nginx /usr/sbin/nginx
'/usr/sbin/nginx' -> '/apps/nginx/sbin/nginx'
root@ubuntu2204:~ 14:55:33 # ls -l /usr/sbin/nginx
lrwxrwxrwx 1 root root 22 Sep  9 14:55 /usr/sbin/nginx -> /apps/nginx/sbin/nginx
root@ubuntu2204:~ 14:55:38 # 


# 查看版本
root@ubuntu2204:~ 14:55:38 # nginx -v
nginx version: nginx/1.22.1
root@ubuntu2204:~ 14:55:52 # nginx -V
nginx version: nginx/1.22.1
built by gcc 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04.2) 
built with OpenSSL 3.0.2 15 Mar 2022
TLS SNI support enabled
configure arguments: --prefix=/apps/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre --with-stream --with-stream_ssl_module --with-stream_realip_module --add-module=/root/echo-nginx-module-0.63 --add-module=/root/nginx-module-vts-0.2.2
root@ubuntu2204:~ 14:55:54 # 



# 测试
root@ubuntu2204:~ 14:55:54 # cat nginx.conf
......
......
 vhost_traffic_status_zone; #写在 http 中
 
     server {
       listen 80;
       server_name www.test02.com;
       root /apps/nginx/html/www.test02.com;
       location /status{ #自带 status
               stub_status;
       }
       location /vts{ #第三方status
               vhost_traffic_status_display;
               vhost_traffic_status_display_format html; #可以写成 josn ，方便数
据采集
       }
       location /echo{ #第三方 echo 模块
               default_type text/html;
                echo "hello world<br />";
                echo "$request_uri<br />";
                echo "$uri<br />";
                echo "$remote_addr<br />";
       }
   }
   
root@ubuntu2204:/apps/nginx/html/www.test02.com 15:07:47 # mkdir  -pv /apps/nginx/html/www.test02.com
root@ubuntu2204:/apps/nginx/html/www.test02.com 15:07:47 # echo index  > /apps/nginx/html/www.test02.com/index.html

# 在物理机中加 hosts 域名解析，然后在浏览器中查看效果，对比第三方status和官方status 区别
~~~

![image-20250909151045380](Nginx.assets/image-20250909151045380.png)

## 3.12 Nginx 中的变量

Nginx 变量可以在配置文件中使用，用作判断或定义日志格式等场景，Nginx 变量可以分为内置变量和自定义变量两种

### 3.11.1 内置变量

Nginx 内置变量是 Nginx 自行定义的，可以直接调用

https://nginx.org/en/docs/varindex.html

~~~shell
$remote_addr # 客户端公网IP，如果经多层Nginx代理，那最后的Nginx 通过此变量无法获取客户端IP
$proxy_add_x_forwarded_for # 代理IP和真实客户端IP
$args # URL中的所有参数
$is_args # 是否有参数，有参数该变量值为 ?，没有参数值为空
$document_root # 当前资源的文件系统路径
$document_uri # 当前资源不包含参数的URI
$host # 请求头中的host值
$remote_port # 客户端随机问口
$remote_user # 经过 auth basic 验证过的用户名
$request_body_file # 作为反向代理发给后端服务器的本地资源名称
$request_method # 当前资源的请求方式 GET/PUT/DELETE 等
$request_filename # 当前资源在文件系统上的绝对路径
$request_uri # 不包含的主机名的URI，包含请求的资源和参数
$scheme # 请求协议， HTTP/HTTPS/FTP 等
$server_protocol # 客户端请求的协议版本 HTTP/1.0， HTTP/1.1， HTTP/2.0 等
$server_addr # 服务器IP
$server_name # 服务器主机名
$server_port # 服务器端口号
$http_user_agent # 客户端UA
$http_cookie # 客户端所有COOKIE
$cookie_<name> # 获取指定COOKIE
$http_<name> # 获取指定的请求头中的字段，如果字段有中划线要替换成下划线，大写转成小写
$sent_http_<name> # 获取指定的响应头中的字段，如果字段有中划线要替换成下划线，大写转成小写
$arg_<name> # 获取指定参数
~~~

~~~shell
# 配置 Nginx
server {
    listen 80;
    server_name www.test02.com;
    root /apps/nginx/html/www.test02.com;
    location /vars {
        default_type text/html;
        echo "request: " $request; 
        echo "\nproxy_add_x_forwarded_for: " $proxy_add_x_forwarded_for;
        echo "\nargs: " $args;
        echo "\ndocument_uri: " $document_uri;
        echo "\ndocument_root: " $document_root;
        echo "\nhost: " $host;
        echo "\nrequest_uri: " $request_uri;
        echo "\nrequest_method: " $request_method;
        echo "\nscheme: " $scheme
        echo "\nUA: " $http_User_Agent;
        echo "\ncookie_name: " $cookie_uname;
        echo "\nall_cookies: " $http_cookie;
    }
}

# 访问测试结果
root@ubuntu2204:/apps/nginx/html/www.test02.com 15:25:22 # curl --cookie "age=10,uname=jerry" "http://www.test02.com/vars?id=123&name=tom"
request:  GET /vars?id=123&name=tom HTTP/1.1

proxy_add_x_forwarded_for:  192.168.121.112

args:  id=123&name=tom

document_uri:  /vars

document_root:  /apps/nginx/html/www.test02.com

host:  www.test02.com

request_uri:  /vars?id=123&name=tom

request_method:  GET

scheme:  http echo 
UA:  curl/7.81.0

cookie_name:  jerry

all_cookies:  age=10,uname=jerry
root@ubuntu2204:/apps/nginx/html/www.test02.com 15:25:27 # 

~~~

### 3.11.2 用户自定义变量

在 Nginx 中，除了内置变量外，我们还可以使用 set 指令来自定义变量

~~~shell
set $variable value; # 自定义变量，变量名以$开头，变量值可以从其它变量中获取，也可以直接指定
 # 作用域 server, location, if
~~~

~~~shell
root@ubuntu2204:~ 15:27:31 # vim /apps/nginx/conf/nginx.conf
...
server {
    listen 80;
    server_name www.test02.com;
    root /apps/nginx/html/www.test02.com;
    set $var1 123;
    set $var2 "hello world";
    set $var3 $host;
    location /vars {
        set $var4 $var1;
        echo $var1;
        echo $var2;
        echo $var3;
        echo $var4;
    }
}

...
root@ubuntu2204:~ 15:28:58 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:~ 15:42:18 # nginx -s reload 
root@ubuntu2204:~ 15:42:25 # curl www.test02.com/vars
123
hello world
www.test02.com
123
root@ubuntu2204:~ 15:42:35 # 

~~~

## 3.13 自定义访问日志

访问日志是记录客户端访问服务器资源的记录，我们可以通过分析访问日志来统计当前网站的日请求量，热点资源，热点时间段，平时响应时长，错误状态码占比，客户端IP分布，客户端所使用的浏览器等信息，用好访问日志可以帮助网站所有者了解网站的具体运营情况，此日志作用重大

https://nginx.org/en/docs/http/ngx_http_log_module.html

~~~shell
access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
access_log off;
 # path 日志路径
 # format 日志格式
 # buffer=size 定义 buffer 表示启用缓冲区，会异步落盘
 # gzip[=level] 启用gzip 压缩，此参数会自动启用buffer，默认缓冲区大小为64k，默认压缩级别为1
 # flush=time 强制落盘时间频率，在缓冲区满了，或者此参数规定的时间到了都会定磁盘
 # [if=condition] 条件判断，返回true 才会记日志
 # off 表示不启用日志
 # 默认值 access_log logs/access.log combined;
 # 作用域 http, server, location, if in location, limit_except
 
 
log_format name [escape=default|json|none] string ...;
 # name 日志格式名称，供 access_log 指令调用
 # [escape=default|json|none] 设置变量的字符转义，默认default
 # string ... 当前定义的日志格式要记录的具体内容
 # 默认值 log_format combined "...";
 # 作用域 http
~~~

~~~shell
 # 二进制包安装的nginx 默认 access_log 配置
root@ubuntu2204:~ 15:28:58 # cat /etc/nginx/nginx.conf | grep access_log
 access_log /var/log/nginx/access.log;
 
 #默认 log_format 内容
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
 # 测试
[root@ubuntu ~]# curl http://www.test02.com
index
[root@ubuntu ~]# cat /var/log/nginx/access.log
127.0.0.1 - - [31/Jan/2024:23:20:01 +0800] "GET / HTTP/1.1" 200 6 "-""curl/7.81.0"
~~~

~~~shell
# 定义日志格式常用的变量
$remote_addr 				#客户端的IP地址
$remote_user 				#使用 HTTP 基本身份验证时的远程用户
$time_local 				#服务器本地时间
$request 					#客户端请求的 HTTP 方法、URI 和协议
$status 					#服务器响应的状态码
$body_bytes_sent 			#发送给客户端的字节数，不包括响应头的大小
$http_referer 				#客户端跳转前的来源页面
$http_user_agent 			#客户端的用户代理字符串
$http_x_forwarded_for 		#通过代理服务器传递的客户端真实 IP 地址
$host 						#请求的主机头字段
$server_name 				#服务器名称
$request_time 				#请求处理时间
$upstream_response_time 	#从上游服务器接收响应的时间
$upstream_status 			#上游服务器的响应状态码
$time_iso8601 				#ISO 8601 格式的本地时间
$request_id 				#用于唯一标识请求的 ID
$ssl_protocol 				#使用的 SSL 协议
$ssl_cipher 				#使用的 SSL 加密算法
~~~

~~~shell
root@ubuntu2204:~ 16:03:59 # cat /etc/nginx/sites-enabled/www.test02.com.conf 
# 自定义访问日志格式  字符串
log_format basic '$remote_addr - $remote_user [$time_local] "$request" '
                 '$status $body_bytes_sent "$http_referer" '
                 '"$http_user_agent" "$http_x_forwarded_for" ';
# # 自定义访问日志格式  json 格式
log_format json_basic '{"remote_addr": "$remote_addr",'
                      '"remote_user": "$remote_user",'
                      '"time_local": "$time_local",'
                      '"request": "$request",'
                      '"status": "$status",'
                      '"body_bytes_sent": "$body_bytes_sent",'
                      '"http_referer": "$http_referer",'
                      '"http_user_agent": "$http_user_agent",'
                      '"http_x_forwarded_for": "$http_x_forwarded_for"}';
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    access_log /var/log/nginx/${host}_access.log basic;

    location /json {
        access_log /var/log/nginx/${host}_json_access.log json_basic;
        return 200 "json";
    }
    location /test {
        access_log off;
        return 200 "test";
    }
}
root@ubuntu2204:~ 16:04:20 # 
root@ubuntu2204:~ 15:58:12 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 15:58:23 # systemctl restart nginx.service
root@ubuntu2204:~ 14:14:26 # curl http://www.test02.com/json
json
root@ubuntu2204:~ 16:06:25 # cat /var/log/nginx/www.test02.com_json_access.log  | jq
{
  "remote_addr": "192.168.121.111",
  "remote_user": "-",
  "time_local": "09/Sep/2025:16:03:07 +0800",
  "request": "GET /json HTTP/1.1",
  "status": "200",
  "body_bytes_sent": "4",
  "http_referer": "-",
  "http_user_agent": "curl/7.81.0",
  "http_x_forwarded_for": "-"
}


root@ubuntu2204:~ 16:03:51 # cat /var/log/nginx/www.test02.com_access.log 
192.168.121.111 - - [09/Sep/2025:16:03:43 +0800] "GET / HTTP/1.1" 200 6 "-" "curl/7.81.0" "-"
~~~

## 3.14 Nginx 压缩功能

Nginx 中可以启用压缩功能，在服务端将要传输的的资源进行压缩后再发送给客户端，此设置可以有效减小传送资源的大小，从而节约网络资源，但压缩会占用服务端的CPU资源

https://nginx.org/en/docs/http/ngx_http_gzip_module.html

https://nginx.org/en/docs/http/ngx_http_gzip_static_module.html

~~~shell
gzip on|off; #启用或禁用压缩功能，默认off，作用域 http, server, location, if in location
gzip_buffers number size; #Nginx在压缩时要向服务器申请的缓存空间个数和每个缓存大小，默认 32 4k 或 16 8k
 #作用域 http, server, location
 
gzip_comp_level level; #压缩比，默认 1，作用域 http, server, location
gzip_disable regex ...; #根据客户端请求头中的UA字段内容来确定在某些情况下禁用压缩，可以支持正则表达式
#gzip_disable "MSIE [1-6]\."; 这种写法就表示 IE6 浏览器禁用压缩，默认为空
 #作用域 http, server, location
 
 
gzip_http_version 1.0|1.1; #启用gzip 压缩的最小版本，默认 1.1，即http/1.1 及更高版本才使用压缩
 #作用域 http, server, location
 
 
gzip_min_length length; #资源体积多大才启用压缩，默认20，作用域 http, server, location

gzip_proxied off|expired|no-cache|no-store|private|no_last_modified|no_etag|auth|any ...;
 #nginx作为反向代理时是否压缩后端返回数据，根据请求头中的 Via 字段来判断
 #默认值 off，不压缩
 #expired 如果请求头中包含 Expires，则压缩
 #no-cache 如果请求头中包含 Cache-Control:no-cache 则压缩
 #no-store 如果请求头中包含 Cache-Control:no-store 则压缩
 #private 如果请求头中包含 Cache-Control:private 则压缩
 #no_last_modified 如果请求头中不包含 Last-Modified 则压缩
 #no_etag 如果请求头中不包含 ETag 则压缩
 #auth 如果请求头中包含 Authorization 则压缩
 #any 任何情况都压缩
 #作用域 http, server, location
 
gzip_types mime-type ...; #指定要压缩的资源类型，默认 text/html，text/html 类型只要开启gzip 都会被压缩
 # * 表示所有类型，作用域 http, server, location
 
gzip_vary on|off; #是否在响应头中添加 Vary: Accept-Encoding，默认 off
 #作用域 http, server, location
~~~

~~~shell
# 命令行工具默认不会发送压缩请求头，响应头中显示 Content-Length: 277
root@ubuntu2204:~ 16:10:01 # curl -I  www.baidu.com
HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
Connection: keep-alive
Content-Length: 277
Content-Type: text/html
Date: Tue, 09 Sep 2025 08:10:03 GMT
Etag: "575e1f59-115"
Last-Modified: Mon, 13 Jun 2016 02:50:01 GMT
Pragma: no-cache
Server: bfe/1.0.8.18
Tr_id: bfe_10665867230198278565

# 显式指定压缩，响应头中能看到 Content-Encoding: gzip 内容，但看不到传输内容长度
# 这是因为启用压缩后，传输的内容要进行压缩，大小会改变，但 header 又先于 body 传输，
# 所以 header 在传输前并不知道 body 会被压成多大，所以无法给出body 大小
# 如果又要压缩，又要返因 content-length，则需要 ngx_http_gzip_static_module 模块支持
# 但可以在客户端统计，在浏览器中打开页面，通过开发者工具可以查看大小
root@ubuntu2204:~ 16:10:04 #  curl -H "Accept-Encoding: gzip" -I https://www.baidu.com
HTTP/1.1 200 OK
Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
Connection: keep-alive
Content-Encoding: gzip
Content-Type: text/html
Date: Tue, 09 Sep 2025 08:10:59 GMT
Last-Modified: Mon, 13 Jun 2016 02:50:01 GMT
Pragma: no-cache
Server: bfe/1.0.8.18
Tr_id: bfe_11254994764578072076

root@ubuntu2204:~ 16:10:59 # 
root@ubuntu2204:~ 16:10:59 #  curl --compressed -I https://www.baidu.com
HTTP/1.1 200 OK
Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
Connection: keep-alive
Content-Encoding: gzip
Content-Type: text/html
Date: Tue, 09 Sep 2025 08:11:18 GMT
Last-Modified: Mon, 13 Jun 2016 02:50:01 GMT
Pragma: no-cache
Server: bfe/1.0.8.18
Tr_id: bfe_10827824571229944190
~~~

~~~shell
root@ubuntu2204:/var 21:02:00 # cat /etc/nginx/sites-enabled/www.test02.com.conf 
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    gzip on;
    gzip_types  text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-phpimage/gif image/png;
    gzip_vary on;
    location =/b.html {
        gzip_comp_level 5;
    }
    location =/c.html {
        gzip off;
    }
}
root@ubuntu2204:/var/www/html/www.test02.com 18:06:44 # cp /var/log/syslog ./a.html
root@ubuntu2204:/var/www/html/www.test02.com 18:06:54 # cp /var/log/syslog ./b.html
root@ubuntu2204:/var/www/html/www.test02.com 18:06:57 # cp /var/log/syslog ./c.html
root@ubuntu2204:/var/www/html/www.test02.com 18:06:59 # ls
100M.img  100M.img.1  500M.img  a.html  b.html  c.html  dir1  dir2  dir3  index.html  test.html
root@ubuntu2204:/var/www/html/www.test02.com 18:07:04 # ls -l
total 615736
-rw-r--r-- 1 root root 104857600 Sep  8 22:27 100M.img
-rw-r--r-- 1 root root   1069056 Sep  8 23:07 100M.img.1
-rw-r--r-- 1 root root 524288000 Sep  8 22:28 500M.img
-rw-r----- 1 root root     87574 Sep  9 18:06 a.html
-rw-r----- 1 root root     87574 Sep  9 18:06 b.html
-rw-r----- 1 root root     87574 Sep  9 18:06 c.html
drwxr-xr-x 4 root root      4096 Sep  8 22:28 dir1
drwxr-xr-x 4 root root      4096 Sep  8 22:28 dir2
drwxr-xr-x 2 root root      4096 Sep  8 22:28 dir3
-rw-r--r-- 1 root root         6 Sep  8 23:17 index.html
-rw-r--r-- 1 root root         5 Sep  8 22:29 test.html
root@ubuntu2204:/var/www/html/www.test02.com 18:07:07 # chmod +r {a..c}.html
root@ubuntu2204:/var/www/html/www.test02.com 18:07:18 # ls -l
total 615736
-rw-r--r-- 1 root root 104857600 Sep  8 22:27 100M.img
-rw-r--r-- 1 root root   1069056 Sep  8 23:07 100M.img.1
-rw-r--r-- 1 root root 524288000 Sep  8 22:28 500M.img
-rw-r--r-- 1 root root     87574 Sep  9 18:06 a.html
-rw-r--r-- 1 root root     87574 Sep  9 18:06 b.html
-rw-r--r-- 1 root root     87574 Sep  9 18:06 c.html
drwxr-xr-x 4 root root      4096 Sep  8 22:28 dir1
drwxr-xr-x 4 root root      4096 Sep  8 22:28 dir2
drwxr-xr-x 2 root root      4096 Sep  8 22:28 dir3
-rw-r--r-- 1 root root         6 Sep  8 23:17 index.html
-rw-r--r-- 1 root root         5 Sep  8 22:29 test.html

# 在浏览器中分别访问 a.html，b.html，c.html，打开开发者工具查看并对比
~~~

## 3.15 favicon 图标设置

favicon.ico 文件是浏览器收藏网址时显示的图标，当客户端使用浏览器问页面时，浏览器会自己主动发起请求获取页面的 favicon.ico文件，但是当浏览器请求的favicon.ico文件不存在时，服务器会记录 404 日志，而且浏览器也会显示404报错

~~~shell
root@ubuntu2204:~ 21:07:15 # tail /var/log/nginx/access.log | grep favicon
192.168.121.1 - - [09/Sep/2025:14:16:55 +0800] "GET /favicon.ico HTTP/1.1" 404 197 "http://www.test02.com/status" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36"
root@ubuntu2204:~ 21:07:20 # 

~~~

~~~shell
# 解决办法 服务器不记录访问日志
root@ubuntu2204:~ 21:09:15 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location /favicon.ico {
        log_not_found off;
        access_log off;
    }
}
root@ubuntu2204:~ 21:09:16 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful


# 解决办法 给出文件，并设置有效期
root@ubuntu2204:~ 21:10:18 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    location /favicon.ico {
        root /var/www/html/www.test02.com/static;
        access_log off;
        expires 7d;
        #首次请求缓存后，7天内不再发起请求，但服务端更新后客户端有可能要7天后才更新
    }
}
root@ubuntu2204:~ 21:10:20 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

~~~

## 3.16 Nginx 实现 https

Nginx 中的 Https 功能需要 ngx_http_ssl_module 模块支持，使用 Yum/apt 安装的 Nginx 中己经包含了该模块的功能，如果使用的是自行通过源码编译安装的 Nginx，需要在编译的时候指定相关编译项

https://nginx.org/en/docs/http/ngx_http_ssl_module.html

~~~shell
ssl on|off; #是否启用SSL，1.15版本中被弃用，1.25.1版本中被删除，后续不使用此参数 
ssl_buffer_size size; #Nginx在读取和写入SSL/TLS握手数据时使用的缓冲区大小，无关数据发送，默认值 16k
 #作用域 http, server
 
ssl_certificate file; #当前虚拟主机的证书文件，通常是PEM格式,
 #该文件中有两部份，分别是虚拟主机的证书和CA机构的证书，作用域http, server
 
ssl_certificate_key file; #当前虚拟主机的私钥文件路径，作用域 http, server
ssl_protocols [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3];
 #当前支持的SSL协议版本，默认值 TLSv1 TLSv1.1 TLSv1.2 TLSv1.3
 #作用域 http, server
 
ssl_session_cache off|none|[builtin[:size]] [shared:name:size];
 #配置SSL缓存，作用域 http, server
 #off 禁用SSL/TLS会话缓存
 #none 通知客户端可以重用会话，但并没有缓存相关数据,默认值
 #builtin[:size] 使用OpenSSL内建缓存，可指定大小，每个worker 进程独享
 #[shared:name:size] 使用共享缓存，每个worker进程共享该缓存中的数据，可指定name和大小
 
ssl_session_timeout time; #配置SSL/TLS会话缓存的超时时间，默认值 5m，作用域 http, server
#使用SSL/TLS会话缓存有助于减少服务器的加密和解密负担，提高HTTPS连接的响应速度，启用缓存需要ssl_session_cache，ssl_session_timeout 两个选项一起使用
#SSL/TLS会话缓存存储的是SSL/TLS握手过程中生成的会话数据。在SSL/TLS握手过程中，服务器和客户端会交换一系列数据，其中包括协商的密钥、加密算法、会话标识符等信息。这些信息用于确保安全通信，并在建立连接后用于加密和解密通信的数据
#SSL/TLS会话缓存中存储的主要数据包括 会话标识符（Session Identifier）,主密钥（Master Secret）,加密算法和参数
#通过存储这些会话数据，SSL/TLS会话缓存允许服务器在处理新连接时，如果客户端提供了先前使用过的会话标识符，就可以重用这些数据，避免重新执行完整的SSL/TLS握手。这样可以大幅度减少握手过程中的计算和通信开销，提高性能和响应速度。同时，它还有助于减少服务器的负担，因为不需要重新生成新的密钥和协商参数


#安装软件
root@ubuntu2204:~ 21:10:21 # apt install easy-rsa -y
root@ubuntu2204:~ 21:14:00 # cd /usr/share/easy-rsa/
root@ubuntu2204:/usr/share/easy-rsa 21:14:01 # 

# 初始化证书目录
root@ubuntu2204:/usr/share/easy-rsa 21:14:01 # ./easyrsa init-pki

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /usr/share/easy-rsa/pki


root@ubuntu2204:/usr/share/easy-rsa 21:14:25 # 

# 生成 CA 机构证书，不使用密码
root@ubuntu2204:/usr/share/easy-rsa 21:14:43 # ./easyrsa build-ca nopass
Using SSL: openssl OpenSSL 3.0.2 15 Mar 2022 (Library: OpenSSL 3.0.2 15 Mar 2022)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:asd

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/usr/share/easy-rsa/pki/ca.crt

# 生成私钥和证书申请文件
root@ubuntu2204:/usr/share/easy-rsa 21:17:18 # ./easyrsa gen-req www.test02.com nopass
...
Keypair and certificate request completed. Your files are:
req: /usr/share/easy-rsa/pki/reqs/www.test02.com.req
key: /usr/share/easy-rsa/pki/private/www.test02.com.key

# 签发证书
root@ubuntu2204:/usr/share/easy-rsa 21:18:17 # ./easyrsa sign-req server www.test02.com

# 合并服务器证书，签发机构证书为一个文件，注意顺序
root@ubuntu2204:/usr/share/easy-rsa 21:21:08 # cd /usr/share/easy-rsa/pki/issued/
root@ubuntu2204:/usr/share/easy-rsa/pki/issued 21:21:19 # ls
www.test02.com.crt
root@ubuntu2204:/usr/share/easy-rsa/pki/issued 21:21:28 # cat www.test02.com.crt  ../ca.crt  > ../www.test02.com.pem
root@ubuntu2204:/usr/share/easy-rsa/pki/issued 21:22:01 # cd /usr/share/easy-rsa/

# 给私钥加读权限
root@ubuntu2204:/usr/share/easy-rsa 21:22:09 # chmod +r pki/private/www.test02.com.key 

~~~

### 3.15.1 配置 https

~~~shell
# 配置 https
root@ubuntu2204:~ 21:28:09 # cat /etc/nginx/sites-enabled/www.test02.com.conf 
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
}
server{
    listen 443 ssl;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    ssl_certificate /usr/share/easy-rsa/pki/www.test02.com.pem;
    ssl_certificate_key /usr/share/easy-rsa/pki/private/www.test02.com.key;
    ssl_session_cache shared:sslcache:20m;
    ssl_session_timeout 10m;
}
root@ubuntu2204:~ 21:28:44 # 
root@ubuntu2204:~ 21:28:03 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 21:28:06 # systemctl restart nginx.service 

~~~

![image-20250909212830702](Nginx.assets/image-20250909212830702.png)

### 3.15.2 配置http 强制跳转 https

~~~shell
root@ubuntu2204:~ 21:34:45 # cat  /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    return 301 https://$host$request_uri;  # 301 重定向
    # rewrite ^(.*) https://$server_name$1 permanent;  # rewrite 重定向二选一

}

~~~

### 3.15.2 http 和 https 写在同一个配置中

~~~shell
root@ubuntu2204:~ 21:32:05 # cat /etc/nginx/sites-enabled/www.test02.com.conf
server{
    listen 80;
    listen 443 ssl;
    server_name www.test02.com;
    root /var/www/html/www.test02.com;
    return 301 https://$host$request_uri;
    ssl_certificate /usr/share/easy-rsa/pki/www.test02.com.pem;
    ssl_certificate_key /usr/share/easy-rsa/pki/private/www.test02.com.key;
    ssl_session_cache shared:sslcache:20m;
    ssl_session_timeout 10m;

}

~~~

~~~shell
# 同一个配置中自动跳转
server{
       listen 80;
       listen 443 ssl;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
       ssl_certificate /usr/share/easy-rsa/pki/www.test02.com.pem;
       ssl_certificate_key /usr/share/easy-rsa/pki/private/www.test02.com.key;
       ssl_session_cache shared:sslcache:20m;
       ssl_session_timeout 10m;
        if ($scheme = http){
               return 301 https://$host$request_uri;
               rewrite ^(.*) https://$server_name$1 permanent; #二选一
       }
}
~~~

## 3.17 Nginx 防盗链

盗链是指某站点未经允许引用其它站点上的资源，

基于访问安全考虑，Nginx 支持通过 ngx_http_referer_module 模块，检查和过滤 Referer 字段的值，来达到防盗链的效果

HTTP Referer是Header的一部分，当浏览器向Web服务器发送请求的时候，一般会带上Referer，告诉服务器我是从哪个页面链接过来的，服务器借此可以获得一些信息用于处理，例如校验加载图片、文件等来源是否是指定域名，如不是则禁止访问。因此HTTP Referer头信息是可以通过程序来伪装生成的，所以通过Referer信息防盗链并非100%可靠，但是，它能够限制大部分的盗链情况。

https://nginx.org/en/docs/http/ngx_http_referer_module.html

~~~shell
valid_referers none |blocked|server_names|string ...; 
#Nginx 会使用请求头中的 referer 字段值和 valid_referers 指定的规则进行对比，如果不匹配，会将 $invalid_referer 变量的值设为 1，默认该变量值为空字符串，作用域 server, location

# none 如果请求头中没有 referer 字段，则 $invalid_referer 变量值为空
# blocked 如果请求头中有 referer 字段，但其值不合法(不是以 http 或 https 开头)，则$invalid_referer 变量为空
# server_names 具体主机名，可以写一个或多个，支持正则和通配符，如果请求头中的 referer 字段值与定义的server_names 匹配，则$invalid_referer 变量为空
~~~

### 3.17.1 模拟实现盗链

~~~shell
root@ubuntu2204:/var/www/html/www.test03.com 17:01:31 # cat /etc/nginx/sites-enabled/www.test03.com.conf 
server{
    listen 80;
    server_name www.test03.com;
    root /var/www/html/www.test03.com;
}
root@ubuntu2204:/var/www/html/www.test03.com 17:01:40 # 

# 当我访问 www.test03.com/test.html 时，会访问 www.test04.com/cat.png
root@ubuntu2204:/var/www/html/www.test03.com 17:01:40 # cat /var/www/html/www.test03.com/test.html 
aaaa
<img src="http://www.test04.com/cat.png" />
root@ubuntu2204:/var/www/html/www.test03.com 17:01:59 #
~~~

![image-20250910170321939](Nginx.assets/image-20250910170321939.png)

### 3.17.2 配置防盗链

~~~shell
# 在 www.test04.com 上配置防盗链
#对于 http://www.test04.com/test.jpg 而言，此次请求是从 http://www.test03.com 来的
#则只需要根据 referer 字段值禁用未经允许的访问即可
server {
    listen 80;
    server_name www.test04.com;
    root html/www.test04.com;
    
    valid_referers none blocked server_names *.test.com ~\.baidu\. ~\.bing\. ~\.so\.;
    # if 指令后面要有空格， 如果不是上述 referer，就返回403
    if ($invalid_referer){
        return 403 "Forbidden Access";
    }
}
root@ubuntu2204:/apps/nginx/html/www.test04.com 17:06:03 # nginx -t
root@ubuntu2204:/apps/nginx/html/www.test04.com 17:06:13 # nginx -s reload
# 再次访问 www.test03.com/test.html 图片就刷新不出来了
~~~



![image-20250910170649728](Nginx.assets/image-20250910170649728.png)

## 3.18 Nginx Rewrite

在 Nginx 中，rewrite 指令用于重写 URI，允许 Nginx 修改客户端请求的 URI，基于此，可用该指令实现 URL 重定向，修改请求参数，改变请求含义，改变 URL 结构等，该指令来自于ngx_http_rewrite_module 模块

ngx_http_rewrite_module 模块是 Nginx 中的一个核心模块，不管是 yum/apt 安装还是编译安装，默认都己经包含在 Nginx 中了，它提供了强大的 URL 重写和重定向功能。主要作用是允许管理员通过配置文件来修改客户端请求的 URI，从而实现重写 URL、重定向请求、更改请求参数等操作

 https://nginx.org/en/docs/http/ngx_http_rewrite_module.html

~~~shell
break; #中断当前相同作用域(location)中的其它 ngx_http_rewrite_module 模块的配置和指令，返回到上一作用域继续执行
 #该指令后的其它指令和配置还会执行，只中断 ngx_http_rewrite_module 指令，作用域 server, location, if
 
 
if (condition) { ... }
 # 允许在配置中使用条件判断，使用正则表达式(pcre风格)对变量进行匹配，匹配成功返回true，执行后续指令
 # if指令仅能做单次判断，不支持 if else 多分支
 # if ($var){ } 这种写法，如果变量对应的值是空字符串或0，就返回false
 # nginx 1.0.1之前$变量的值如果以0开头的任意字符串会返回false
 # 作用域 server, location
 # 支持的运算符
 # = 比较变量和字符串是否相等
 # != 比较变量和字符串是否不相等
 # ~ 区分大小写，是否匹配正则，包含
 # !~ 区分大小写，是否不匹配正则，包含
 # ~* 不区分大小写，是否匹配正则，包含
 # !~* 不区分大小写，是否不匹配正则，不包含
 # -f|!-f 判断文件是否存在|不存在 
 # -d|!-d 判断目录是否存在|不存在
 # -x|!-x 判断文件是否可执行|不可执行
 # -e|!-e 判断文件(包括文件，目录，软链接)是否存在|不存在
 
return code [text]; 
return code URL;
return URL; # 不写code ，默认值为302 
 # 直接向客户端返回状态码，字符串，或者URL，如果返回的字符串中包含空格，要加引号，如果返回URL，要写完整
 # 此指令后的其它指令或配置将不再执行，作用域 server, location, if
 

rewrite regex replacement [flag]; 
 # 通过正则表达式匹配来改变URI，在一个配置段中可以有一条或多条，按照顺序从上下往下匹配
 # 作用域 server, location, if
 # 如果有多条规则，被某一条规则命中并替换后，会用新的URI再从头开始逐一匹配，直到没有被命中为止，
 # 但是重复匹配次数不能超过 10次，否则会报500
 # regex PCRE 风格的正则表达式，表示要查找的内容
 # replacement 用于替换的字符串
 # [flag] 标志位，用于控制 rewrite 指令的行为last|break|redirect|permanent
 #   last   如果被当前 rewrite 规则匹配上，替换后结束本轮替换，开始下一轮替换
 # break   如果被当前 rewrite 规则匹配上，替换后结束当前代码段的重写替换，后续所有 rewrite 都不执行
 # redirect   如果被当前 rewrite 规则匹配上，替换后执行 302 临时重定向
 # permanent 如果被当前 rewrite 规则匹配上，替换后执行 301 永久重定向
 # last 和 break 在服务器内部实现跳转，客户端浏览器地址栏中的信息不会发生变化
 # redirect 和 permanent 在客户端实现跳转，客户端浏览器地址栏中的信息会发生变化
 

rewrite_log on|off; #是否记录 ngx_http_rewrite_module 模块产生的日志到 error_log 中，默认值 off
 #如果开启，需要将 error_log 的级别设为 notice，作用域 http, server, location, if
set $variable value; #设置变量，给变量赋值，作用域 server, location, if
~~~

last 和 break

相同点：

- 无论是 break 还是 last，它们都会中止当前 location 块的处理，并跳出该块，客户端浏览器地址
- 栏中的信息不会发生变化

不同点：

- break：终止当前代码段中的所有 rewrite 匹配
- last：中止当前 location 中的 rewrite 匹配，用替换后的 RUI 继续从第一条规则开始执行下一轮 rewrite

### 3.18.1 PCRE 风格正则表达式

PCRE（Perl Compatible Regular Expressions）风格的正则表达式在设计上兼容Perl语言的正则表达式语法，具有灵活且功能强大的特点。下面是一些 PCRE 风格正则表达式中常见的元字符和功能

~~~shell
#元字符
. #匹配除换行符外的任意字符
\w #匹配字母数字下划线中文字
\s #匹配任意空白字符
\d #匹配任意数字，相当于[0-9]
\b #匹配单词开始或结束
[] #匹配括号内的任意一个字符 [abc] 表示abc中的任意一个字符
[^] #匹配除了括号内字符之外的任意一个字符 [^abc] 表示任意一个除 abc 之外的字符
^ #匹配内容的开始位置
$ #匹配内容的结束位置
* #匹配前面的字符零次或多次
+ #匹配前面的字符一次或多次
? #匹配前面的字符零次或一次
{n} #匹配前面的字符n次
{n,} #匹配前面的字符至少n次
{n,m} #匹配前面的字符n次到m次
{,m} #匹配前面的字符最多m次
| #或，用于在模式中指定多个备选项
() #分组，用于将多个模式组合在一起，并捕获匹配的文本 $1 $2 $n 后向引用
\ #转义字符，用于取消元字符的特殊意义，或引入某些特殊字符
~~~

### 3.18.2 相关指令测试

**配置子配置文件位置**

~~~shell
root@ubuntu2204:/apps/nginx 20:55:27 # grep include  conf/nginx.conf
    include /apps/nginx/conf.d/*.conf;

~~~

#### 3.18.2.1 break 指令测试

~~~shell
root@ubuntu2204:/apps/nginx 20:56:15 # cat conf.d/www.test04.com.conf 
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location /break {
    set $var1 test03;
    echo $var1;
    break;
    set $var2 xixi;  
    # set 是属于 ngx_http_rewrite_module 模块指令，此句在 break 之后，不生效
    echo $var2;
    # 不会输出 var2
    return 200 "hello break";
    # return 是属于 ngx_http_rewrite_module 模块指令，此句在 break 之后，不生效
    }
}
root@ubuntu2204:/apps/nginx 20:56:29 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 20:56:32 # nginx -s reload 

# 测试
root@ubuntu2204:/apps/nginx 20:55:18 # curl www.test04.com/break
test03

root@ubuntu2204:/apps/nginx 20:55:27 #
~~~

#### 3.18.2.2 if 指令测试

~~~shell
root@ubuntu2204:/apps/nginx 21:01:58 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location /test {
        return 200 $scheme;
    }
    location /file {
        if (!-e $request_filename){
            return 200 "$request_filename file not exists";
        }
    }
}
root@ubuntu2204:/apps/nginx 21:01:59 # nginx -t 
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:02:00 # nginx -s reload 
root@ubuntu2204:/apps/nginx 21:02:05 # echo xixixi  > www.test04.com/test
root@ubuntu2204:/apps/nginx 21:02:20 # curl www.test04.com/test
httproot@ubuntu2204:/apps/nginx 21:02:27 # 
root@ubuntu2204:/apps/nginx 21:02:37 # 
root@ubuntu2204:/apps/nginx 21:02:37 # curl www.test04.com/file
/apps/nginx/www.test04.com/file file not exists
~~~

#### 3.18.2.3 set 结合 if

~~~shell
root@ubuntu2204:/apps/nginx 21:05:35 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    set $var 1;
    location =/test.img {
        if ($var){
            limit_rate 10k;
        }
    }
}
root@ubuntu2204:/apps/nginx 21:05:41 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:05:43 # nginx -s reload 
root@ubuntu2204:/apps/nginx 21:05:48 # dd if=/dev/zero of=www.test04.com/test.img count=1M bs=100
1048576+0 records in
1048576+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 8.05335 s, 13.0 MB/s
root@ubuntu2204:/apps/nginx 21:06:21 # ls -lh www.test04.com/test.img 
-rw-r--r-- 1 root root 100M Sep 11 21:06 www.test04.com/test.img
root@ubuntu2204:/apps/nginx 21:06:27 # wget www.test04.com/test.img
--2025-09-11 21:06:42--  http://www.test04.com/test.img
Resolving www.test04.com (www.test04.com)... 192.168.121.112
Connecting to www.test04.com (www.test04.com)|192.168.121.112|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 104857600 (100M) [application/octet-stream]
Saving to: ‘test.img’

test.img                                0%[                                                                          ]  32.00K  10.2KB/s    eta 2h 46m
~~~

#### 3.18.2.4 return 指令测试

~~~shell
root@ubuntu2204:/apps/nginx 21:24:40 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location /return {
        if ($http_user_agent ~* curl|wget|ApacheBench){
            return 403 "agent error!!\n";
        }
        return 200 "success\n";
    }
}
root@ubuntu2204:/apps/nginx 21:24:42 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:24:45 # nginx -s reload 
root@ubuntu2204:/apps/nginx 21:24:50 # curl www.test04.com/return
agent error!!
root@ubuntu2204:/apps/nginx 21:25:08 # curl www.test04.com/return -I
HTTP/1.1 403 Forbidden
Server: nginx/1.22.1
Date: Thu, 11 Sep 2025 13:25:29 GMT
Content-Type: application/octet-stream
Content-Length: 14
Connection: keep-alive

root@ubuntu2204:/apps/nginx 21:25:29 # 


# 指定 agent 访问
root@ubuntu2204:/apps/nginx 21:25:29 # curl -A "chrome" www.test04.com/return
success
root@ubuntu2204:/apps/nginx 21:26:05 # 

~~~

**return 指令返回网址**

~~~shell
root@ubuntu2204:/apps/nginx 21:28:01 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location /return {
        return http://www.baidu.com;
    }
}
root@ubuntu2204:/apps/nginx 21:28:05 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:28:07 # nginx -s reload 
root@ubuntu2204:/apps/nginx 21:28:09 # curl www.test04.com/return -I
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.22.1
Date: Thu, 11 Sep 2025 13:28:12 GMT
Content-Type: text/html
Content-Length: 145
Connection: keep-alive
Location: http://www.baidu.com

# 加选项跟踪跳转，能访问到 www.baidu.com
root@ubuntu2204:/apps/nginx 21:28:12 # curl www.test04.com/return -IL
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.22.1
Date: Thu, 11 Sep 2025 13:28:16 GMT
Content-Type: text/html
Content-Length: 145
Connection: keep-alive
Location: http://www.baidu.com

HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
Connection: keep-alive
Content-Length: 277
Content-Type: text/html
Date: Thu, 11 Sep 2025 13:28:17 GMT
Etag: "575e1f6f-115"
Last-Modified: Mon, 13 Jun 2016 02:50:23 GMT
Pragma: no-cache
Server: bfe/1.0.8.18
Tr_id: bfe_13265188529852633657

# 自动跳转页面效果要在浏览器中测试
~~~

#### 3.18.2.5 rewrite 指令测试

~~~shell
root@ubuntu2204:/apps/nginx/www.test04.com 21:29:20 #  echo "11111" > 1.html
root@ubuntu2204:/apps/nginx/www.test04.com 21:29:31 # echo "22222" > 2.html
root@ubuntu2204:/apps/nginx/www.test04.com 21:29:42 # echo "33333" > 3.html
root@ubuntu2204:/apps/nginx/www.test04.com 21:29:48 # echo "aaaaa" > a.html
root@ubuntu2204:/apps/nginx/www.test04.com 21:29:57 # echo "bbbbb" > b.html
root@ubuntu2204:/apps/nginx/www.test04.com 21:30:04 # echo "ccccc" > c.html


root@ubuntu2204:/apps/nginx 21:32:02 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location / {
        rewrite /1.html /2.html;
        rewrite /2.html /3.html;
    }
    location /2.html {
        rewrite /2.html /a.html;
    }
    location /3.html {
        rewrite /3.html /b.html;
    }
}
root@ubuntu2204:/apps/nginx 21:32:03 # nginx -t 
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:32:06 # nginx -s reload 
# 1.html ----> 2.html
# 2.html ----> 3.html
# 3.html ----> b.html
root@ubuntu2204:/apps/nginx 21:32:12 # curl www.test04.com/1.html
bbbbb
root@ubuntu2204:/apps/nginx 21:32:41 # 



root@ubuntu2204:/apps/nginx 21:33:24 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location / {
        rewrite /1.html /2.html;
        rewrite /2.html /3.html;
        rewrite /b.html /c.html;
    }
    location /2.html {
        rewrite /2.html /a.html;
    }
    location /3.html {
        rewrite /3.html /b.html;
    }
}
root@ubuntu2204:/apps/nginx 21:33:26 # nginx -t 
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:33:28 # nginx -s reload 
# 1.html ----> 2.thml
# 2.html ----> 3.html
# 3.html ----> b.html
# b.html ----> c.html
root@ubuntu2204:/apps/nginx 21:33:45 # curl www.test04.com/1.html
ccccc
root@ubuntu2204:/apps/nginx 21:33:46 # 

~~~

##### 3.18.2.5.1 rewrite 结合 break

~~~shell
root@ubuntu2204:/apps/nginx 21:47:36 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location / {
        rewrite /1.html /2.html break;
        rewrite /2.html /3.html;
    }
    location /2.html {
        rewrite /2.html /a.html;
    }
    location /3.html {
        rewrite /3.html /b.html;
    }
}
root@ubuntu2204:/apps/nginx 21:47:40 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:47:45 # nginx -s reload
# 1.html ----> 2.thml   
# break 结束当前 server 配置段中的所有 rewrite
root@ubuntu2204:/apps/nginx 21:47:48 # curl www.test04.com/1.html
22222

~~~

##### 3.18.2.5.2 rewrite 结合 last

~~~shell
root@ubuntu2204:/apps/nginx 21:50:40 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location / {
        rewrite /1.html /2.html last;
        rewrite /2.html /3.html;
    }
    location /2.html {
        rewrite /2.html /a.html;
    }
    location /3.html {
        rewrite /3.html /b.html;
    }
}
root@ubuntu2204:/apps/nginx 21:50:41 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:50:44 # nginx -s reload 
root@ubuntu2204:/apps/nginx 21:50:47 # curl www.test04.com/1.html
aaaaa
# 1.html ----> 2.thml last 结束当前 location 中的本轮 rewrite，继续执行下一轮rewrite
# 2.html ----> a.thml 一下轮 location /2.html 的优先级更高
~~~

~~~shell
root@ubuntu2204:/apps/nginx 21:52:19 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location / {
        rewrite /1.html /2.html last;
        rewrite /2.html /3.html;
    }
    location /2.html {
        rewrite /2.html /1.html;
    }
    location /3.html {
        rewrite /3.html /b.html;
    }
}
root@ubuntu2204:/apps/nginx 21:52:21 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:52:24 # nginx -s reload 
# 1.html ----> 2.thml last 
# 2.html ----> 1.thml
# 1.html ----> 2.thml last 
# ... 无限循环，最终返回 500 服务器内部错误
root@ubuntu2204:/apps/nginx 21:52:29 # curl www.test04.com/1.html
<html>
<head><title>500 Internal Server Error</title></head>
<body>
<center><h1>500 Internal Server Error</h1></center>
<hr><center>nginx/1.22.1</center>
</body>
</html>
root@ubuntu2204:/apps/nginx 21:52:36 # 

~~~

##### 3.18.2.5.3 rewrite 集合 redirect

~~~shell
root@ubuntu2204:/apps/nginx 21:53:38 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location / {
        rewrite /1.html /2.html redirect;
        rewrite /2.html /3.html;
    }
    location /2.html {
        rewrite /2.html /a.html;
    }
    location /3.html {
        rewrite /3.html /b.html;
    }
}
root@ubuntu2204:/apps/nginx 21:53:40 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:53:42 # nginx -s reload 
root@ubuntu2204:/apps/nginx 21:53:44 # curl www.test04.com/1.html
<html>
<head><title>302 Found</title></head>
<body>
<center><h1>302 Found</h1></center>
<hr><center>nginx/1.22.1</center>
</body>
</html>
# 1.html ----> 2.thml redirect 返回客户端让客户端去请求 2.html 
# 2.html ----> a.thml 客户端请求 2.html 被 rewrite 1.html 
# 用浏览器访问 http://www.test04.com/1.html 最后地址栏会变成 http://www.test04.com/2.html
# 但是显示的是 aaaaa
~~~

~~~shell
root@ubuntu2204:/apps/nginx 21:53:38 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location / {
        rewrite /1.html /2.html redirect;
        rewrite /2.html /3.html;
    }
    location /2.html {
        rewrite /2.html /a.html redirect;
    }
    location /3.html {
        rewrite /3.html /b.html;
    }
}
root@ubuntu2204:/apps/nginx 21:53:40 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:53:42 # nginx -s reload 
root@ubuntu2204:/apps/nginx 21:53:44 # curl www.test04.com/1.html
<html>
<head><title>302 Found</title></head>
<body>
<center><h1>302 Found</h1></center>
<hr><center>nginx/1.22.1</center>
</body>
</html>
# 1.html ----> 2.thml redirect 返回客户端让客户端去请求 2.html 
# 2.html ----> a.thml redirect 客户端请求 2.html 被 rewrite 1.html 
# 用浏览器访问 http://www.test04.com/1.html 最后地址栏会变成 http://www.test04.com/a.html
# 显示的是 aaaaa
~~~

##### 3.18.2.5.4 rewrite 结合 permanent

permanent 和 redirect 除了在状态码上有区别之外，在流程上没有本质区别

~~~shell
root@ubuntu2204:/apps/nginx 21:53:38 # cat conf.d/www.test04.com.conf
server {
    listen 80;
    server_name www.test04.com;
    root /apps/nginx/www.test04.com;
    location / {
        rewrite /1.html /2.html permanent;
        rewrite /2.html /3.html;
    }
    location /2.html {
        rewrite /2.html /a.html permanent;
    }
    location /3.html {
        rewrite /3.html /b.html;
    }
}
root@ubuntu2204:/apps/nginx 21:53:40 # nginx -t
nginx: the configuration file /apps/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /apps/nginx/conf/nginx.conf test is successful
root@ubuntu2204:/apps/nginx 21:53:42 # nginx -s reload 
root@ubuntu2204:/apps/nginx 21:53:44 # curl www.test04.com/1.html -I
# 但是在浏览器中，会缓存此次重定向的流程，在得到最终结果之前，不会访问服务器，通过开发者工具可以看到 disk cache 相关提示
~~~

### 3.18.3 相关案例

~~~shell
# 访问不存在的资源，跳转到首页
server{
       listen 80;
       server_name www.test04.com;
       root /apps/nginx/www.test04.com;
            if (!-e $request_filename){
           rewrite .* /index.html redirect;
           return 302 http://$host; #二选一
           }
}
~~~

~~~shell
# 根据不同的设备适配不同的项目
server{
       listen 80;
       server_name www.test04.com;
       root /apps/nginx/www.test04.com;
 		if ($http_user_agent ~* "android|iphone|ipad"){
 			rewrite ^(.*)$ http://m.test04.com/$1 redirect; #用 return 指令也可以
 		}
}
~~~

~~~shell
# 网站维护，只有特定客户端IP能访问，其它客户端重定向到提示页面
server{
       listen 80;
       server_name www.test04.com;
       root /apps/nginx/www.test04.com;
 		if ($remote_addr != "192.168.121.1"){
 			rewrite ^(.*)$ /msg.html break;
 		}
}

~~~



# 四、Nginx 反向代理

## 4.1 代理基本知识 

代理分为两种，分别是正向代理和反向代理

正向代理（Forward Proxy） 和 反向代理（Reverse Proxy） 是两种常见的代理服务器，它们用于处理网络通信中的不同方向和用途

**正向代理（Forward Proxy）**

特点

- 代理服务器位于客户端和目标服务器之间
- 客户端向代理服务器发送请求，代理服务器将请求发送到目标服务器，并将目标服务器的响应返回给客户端
- 目标服务器不知道客户端的存在，它只知道有一个代理服务器向其发送请求
- 客户端通过正向代理访问互联网资源时，通常需要配置客户端来使用代理

用途

- 突破访问限制：用于绕过网络访问限制，访问受限制的资源
- 隐藏客户端身份：客户端可以通过正向代理隐藏其真实 IP 地址

**反向代理（Reverse Proxy）**

特点

- 代理服务器位于目标服务器和客户端之间
- 客户端向代理服务器发送请求，代理服务器将请求转发给一个或多个目标服务器，并将其中一个目标服务器的响应返回给客户端
- 目标服务器不知道最终客户端的身份，只知道有一个代理服务器向其发送请求
- 用于将客户端的请求分发给多个服务器，实现负载均衡

用途

- 负载均衡：通过将流量分发到多个服务器，确保服务器的负载均匀分布
- 缓存和加速：反向代理可以缓存静态内容，减轻目标服务器的负载，并提高访问速度
- 安全性：隐藏真实服务器的信息，提高安全性，同时可以进行 SSL 终止（SSL Termination）

**相同和不同**

相同点

- 中间层：正向代理和反向代理都是位于客户端和目标服务器之间的中间层。
- 代理功能：它们都充当了代理的角色，处理请求和响应，使得通信更加灵活和安全

不同点

- 方向：正向代理代理客户端，反向代理代理服务器
- 目的：正向代理主要用于访问控制和隐藏客户端身份，反向代理主要用于负载均衡、缓存和提高安全性
- 配置：客户端需要配置使用正向代理，而反向代理是对服务器透明的，客户端无需感知

![image-20250912155215915](Nginx.assets/image-20250912155215915.png)

## 4.2 Nginx 和 LVS

Nginx 和 LVS（Linux Virtual Server） 都是流行的代理和负载均衡解决方案，但它们有一些不同的特点和应用场景

选择使用 Nginx 还是 LVS 取决于具体的应用需求和复杂度。Nginx 更适合作为 Web 服务器和应用层负载均衡器，而 LVS 更适用于传输层负载均衡

相同点

- 负载均衡：Nginx 和 LVS 都可以作为负载均衡器，将流量分发到多个后端服务器，提高系统的可用性和性能。
- 性能：Nginx 和 LVS 都具有高性能的特点，能够处理大量并发连接和请求

不同点

- 层次：Nginx 在应用层进行负载均衡和反向代理，而 LVS 在传输层进行负载均衡
- 功能：Nginx 除了负载均衡外，还可以作为反向代理和静态文件服务器；而 LVS 主要专注于负载均衡，实现简单而高效的四层分发
- 配置和管理：Nginx 配置相对简单，易于管理，适用于各种规模的应用；LVS 需要深入了解 Linux 内核和相关配置，适用于大规模和对性能有更高要求的场景

LVS 不监听端口，不处理请求数据，不参与握手流程，只会在内核层转发数据报文

Nginx 需要在应用层接收请求，根据客户端的请求参数和Nginx中配置的规则，再重新作为客户端向后端服务器发起请求

<img src="Nginx.assets/image-20250912155329679.png" alt="image-20250912155329679" style="zoom: 150%;" />

==LVS 通常做四层代理，Nginx 做七层代理==

![image-20250912155417495](Nginx.assets/image-20250912155417495.png)

## 4.3 实现 http 协议反向代理

Nginx 可以基于 ngx_http_proxy_module 模块提供 http 协议的反向代理服务，该模块 Nginx 的默认模块

http://nginx.org/en/docs/http/ngx_http_proxy_module.html

### 4.3.1 相关指令和参数

~~~shell
proxy_pass URL; # 转发的后端服务器地址，可以写主机名,域名，IP地址，也可以额外指定端口
# 作用域 location, if in location, limit_except
proxy_hide_header field; # Nginx 默认不会将后端服务器的 Date,Server,X-Pad,X-Accel-... 这些响应头信息传给客户端，除了这些之外的响应头字段会回传
		# 可以使用 proxy_hide_header 显式指定不回传的响应头字段
		# 作用域 http, server, location
 
proxy_pass_header field; # 显式指定要回传给客户端的后端服务器响应头中的字段，作用域 http, server, location

proxy_pass_request_body on|off; # 是否向后端服务器发送客户端 http 请求的 body 部份，默认 on，
 # 作用域 http, server, location
 
proxy_pass_request_headers on|off; # 是否向后端服务器发送客户端 http 请求的头部信息，默认 on
 # 作用域 http, server, location
 
proxy_connect_timeout time; # Nginx与后端服务器建立连接超时时长，默认60S，超时会向客户端返回504
 # 作用域 http, server, location
 
proxy_read_timeout time; # Nginx 等待后端服务器返回数据的超时时长，默认60S，超时会向客户端返回504
 # 作用域 http, server, location
 
proxy_send_timeout time; # Nginx 向后端服务器发送请求的超时时长，默认60S，超时会向客户端返回408
 # 作用域 http, server, location
 
proxy_set_body value; # 重新定义传给后端服务器的请求的正文，可以包含文本，变量等，
 # 作用域 http, server, location
 
proxy_set_header field value; # 更改或添加请求头字段并发送到后端服务器，作用域http, server, location

proxy_http_version 1.0|1.1; # 设置向后端服务器发送请求时的 http 协议版本，默认值1.0，
 # 作用域http, server, location
 
proxy_ignore_client_abort on|off; # 客户端中断连接，Nginx 是否继续执行与后端的连接，默认值 off，客户端中断，Nginx 也 # 会中断后端连接， on 表示 客户端中断，nginx 还会继续处理与后端在连接
 # 作用域 http, server, location
proxy_headers_hash_bucket_size size; # 当配置了 proxy_hide_header和proxy_set_header的时候，
 # 用于设置nginx保存HTTP报文头的hash表的大小，默认值 64
 # 作用域 http, server, location
 
proxy_headers_hash_max_size size; # 上一个参数的上限，默认值 512，作用域 http, server, location

proxy_next_upstream 
error|timeout|invalid_header|http_500|http_502|http_503|http_504|http_403|http_404|http_429|non_idempotent| off ...; 
# 当前配置的后端服务器无法提供服务时，因为何种错误而去请求下一个后端服务器
# 默认值 error timeout， 表示当前后端服务器因为error 和 timeout 错误时，去请求 另一个后端服务器，作用域 http, server, location
 
proxy_cache zone|off; # 是否启用代理缓存，默认 off,不启用，zone 指缓存名称，
 # 作用域 http, server, location
 
proxy_cache_path path [levels=levels] [use_temp_path=on|off] keys_zone=name:size [inactive=time] [max_size=size] [min_free=size] [manager_files=number] 
[manager_sleep=time] [manager_threshold=time] [loader_files=number] 
[loader_sleep=time] [loader_threshold=time] [purger=on|off] 
[purger_files=number] [purger_sleep=time] [purger_threshold=time];
 # 开启代理缓存后指定缓存数据的存放路径，作用域http，默认没有设置
 # path 表示缓存数据存放路径，要保证nginx 有写权限
 # levels 表示缓存数据目录层级,16进制表示，levels=1:2 表示第一级有16个目录，0-f,第一级中每个目录下有16*16个子目录，00-ff
 # keys_zone=name:size zone 表示缓存名称，先定义后使用，size 表示该 zone 空间大小
 # inactive 表示缓存数据生命周期，默认值10分钟
 # max_size 表示缓存占用的磁盘空间最大能有多大


proxy_cache_key string; # 指定缓存数据的key，不同的key 对应不同的缓存文件，作用域 http, server, location
 # 默认值 $scheme$proxy_host$request_uri
                                    
proxy_cache_valid [code ...] time;  # 为不同响应状态码的数据设置不同的缓存时长，可设置多条，默认不设置,
 # 作用域 http, server, location
 
proxy_cache_use_stale 
error|timeout|invalid_header|updating|http_500|http_502|http_503|http_504|http_403|http_404|http_429|off ...; 
	# 在后端服务器报哪些错误的情况下，直接使用过期缓存数据响应客户端请求
    # 默认off，作用域 http, server, location
   
proxy_cache_methods GET|HEAD|POST ...; # 缓存哪些请求类型的数据，默认值 GET HEAD，作用域 http, server, location
~~~

### 4.3.2 基本配置

#### 4.3.2.1 转发到指定 IP

~~~shell
root@ubuntu2204:~ 16:06:23 # cat  /etc/nginx/sites-enabled/www.test03.com.conf 
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://192.168.121.112;
        # 192.168.121.112要开启 WEB 服务，请求的是默认 default_Serve 配置
    }
}
root@ubuntu2204:~ 16:06:33 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 16:06:36 # systemctl restart nginx 
# 被转发到后端的 192.168.121.112
root@ubuntu2204:~ 16:06:41 # curl www.test04.com
i am 192.168.121.112
root@ubuntu2204:~ 16:07:19 # 

~~~

#### 4.3.2.2 转发到指定 IP 和 port

~~~shell
# 前端服务配置
root@ubuntu2204:~ 16:09:49 # cat /etc/nginx/sites-enabled/www.test03.com.conf
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://192.168.121.112:8080;
    }
}
root@ubuntu2204:~ 16:11:53 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 16:11:55 # systemctl reload nginx 


# 后端服务配置
server {
    listen 8080;
    root /apps/nginx/8080-html;
}

# 前端测试
root@ubuntu2204:~ 16:12:02 # curl www.test03.com
i am 192.168.121.112 8080
root@ubuntu2204:~ 16:12:06 # 
~~~

#### 4.3.2.3 转发到指定域名

~~~shell
root@ubuntu2204:~ 16:13:54 # cat /etc/nginx/sites-enabled/www.test03.com.conf
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://www.test04.com;
    }
}
root@ubuntu2204:~ 16:13:56 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 16:13:58 # systemctl restart nginx.service 
root@ubuntu2204:~ 16:14:06 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 16:14:18 # 

~~~

#### 4.3.2.4 透传指定参数

~~~shell
# 在上述请求中，客户端访问 http://www.test03.com，该主机收到请求后作为客户端去请求http://www.test04.com
# 代理服务器配置
root@ubuntu2204:~ 16:40:48 # cat /etc/nginx/sites-enabled/www.test03.com.conf 
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://192.168.121.112;
        proxy_set_header Host $http_host;
    }
}


# 后端服务器配置
server {
    server_name www.test04,com;
    listen 80;
    root /apps/nginx/8080-html;
}

# 客户端访问 www.test03.com
~~~

![image-20250912164853354](Nginx.assets/image-20250912164853354-17576669343661.png)

~~~shell
# 如果后端服务不可用，从客户端访问会返回502
# 停止后端的 nginx
root@ubuntu2204:/apps/nginx 16:35:32 # nginx -s stop 

# 客户端再次访问

~~~

![image-20250912165539805](Nginx.assets/image-20250912165539805.png)

~~~shell
# 如果连接后端服务器超时，会报504
root@ubuntu2204:/apps/nginx 16:55:33 # nginx 
root@ubuntu2204:/apps/nginx 16:56:02 #  iptables -A INPUT -s 192.168.121.111 -j DROP


# 客户端测试，60S 后超时，显示504
~~~

![image-20250912165745368](Nginx.assets/image-20250912165745368.png)

~~~shell
# 把超时时间改为 10s
root@ubuntu2204:~ 16:58:34 # cat /etc/nginx/sites-enabled/www.test03.com.conf
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://192.168.121.112;
        proxy_set_header Host $http_host;
        proxy_connect_timeout 10s;
    }
}
root@ubuntu2204:~ 16:58:36 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 16:58:39 # systemctl restart nginx 

# 客户端再次测试

~~~

![image-20250912165919456](Nginx.assets/image-20250912165919456.png)

### 4.3.3 实现动静分离

根据条件进行调度，实现动静分离

| 角色          | os system   | IP              |
| ------------- | ----------- | --------------- |
| client        | Windows     | 192.168.121.2   |
| proxy server  | Ubuntu 2204 | 192.168.121.111 |
| API server    | Ubuntu 2204 | 192.168.121.112 |
| Static Server | Ubuntu 2204 | 192.168.121.113 |

~~~shell
# 客户端需要配置 hosts 文件



# proxy server 配置
root@ubuntu2204:~ 18:54:30 # cat /etc/nginx/sites-enabled/www.test03.com.conf
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /static{
        proxy_pass http://192.168.121.113;
        proxy_set_header Host "static.test.com";
        proxy_connect_timeout 10s;
    }
    location /api{
        proxy_pass http://192.168.121.112;
        proxy_set_header Host "api.test.com";
        proxy_connect_timeout 10s;
    }
}
root@ubuntu2204:~ 18:54:32 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 18:54:35 # systemctl restart nginx



# API Server 配置
server {
    server_name api.test,com;
    listen 80;
    root /apps/nginx/html/api-html;
    index index.html;
}
root@ubuntu2204:/apps/nginx 19:11:37 # cat /apps/nginx/html/api-html/api/index.html 
api.test.com
root@ubuntu2204:/apps/nginx 19:12:30 # 


# Static Server 配置
server{
    server_name static.test.com;
    root /var/www/html/static-html;
    listen 80;
}
root@ubuntu2204:/var/www/html/static-html 19:12:06 # cat /var/www/html/static-html/static/index.html 
static.test.com
root@ubuntu2204:/var/www/html/static-html 19:12:48 # 


# 客户端访问测试
~~~

![image-20250912191319585](Nginx.assets/image-20250912191319585.png)

![image-20250912191327146](Nginx.assets/image-20250912191327146.png)

proxy_pass 后面加斜线和不加斜线的区别

~~~shell
#没有斜线是追加
# http://www.test03.com/api/index.html ----> http://api.test.com/api/index.html
location /api{
   proxy_pass http://192.168.121.112;
   proxy_set_header Host "api.test.com"; 
}


#有斜线是替换
# http://www.test03.com/api/index.html -----> http://api.test.com/index.html
location /api{
   proxy_pass http://192.168.121.112/;
   proxy_set_header Host "api.test.com"; 
}
~~~

实现对特定资源的代理

~~~shell
location ~ \.(jpg|png|bmp|gif)$ {
   proxy_pass http://192.168.121.113;
   proxy_set_header Host "static.test.com"; 
}
~~~

### 4.3.4 代理服务器实现数据缓存

前置条件：各服务器时间和时区先统一，方便测试

~~~shell
# proxy server 设置
root@ubuntu2204:~ 19:25:22 # cat /etc/nginx/sites-enabled/www.test03.com.conf 
proxy_cache_path /tmp/proxycache levels=1:2 keys_zone=proxycache:20m inactive=60s max_size=1g;
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /static{
        proxy_pass http://192.168.121.113;
        proxy_set_header Host "static.test.com";
        proxy_cache proxycache;
        proxy_cache_key $request_uri;
        proxy_cache_valid 200 302 301 90s;
        proxy_cache_valid any 2m;
        proxy_connect_timeout 10s;
    }
}
root@ubuntu2204:~ 19:33:13 # 

# 重载 nginx 生成缓存目录，是空目录
root@ubuntu2204:~ 19:20:37 # nginx -t
]nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 19:20:39 # systemctl reload nginx
root@ubuntu2204:~ 19:22:34 # ls -l /tmp/proxycache/
total 0
root@ubuntu2204:~ 19:22:42 # ls -l /tmp/proxycache/ -d
drwx------ 2 www-data root 4096 Sep 12 19:20 /tmp/proxycache/
root@ubuntu2204:~ 19:22:52 # ls -l /tmp/proxycache/ -d
drwx------ 3 www-data root 4096 Sep 12 19:23 /tmp/proxycache/

~~~

~~~shell
# static server 配置
server{
    server_name static.test.com;
    root /var/www/html/static-html;
    listen 80;
}


# 客户端测试

# 查看 Proxy Server 上的缓存数据，文件名就是key 的 hash 值
root@ubuntu2204:~ 19:23:17 # tree /tmp/proxycache/
/tmp/proxycache/
└── e
    └── 50
        └── 319432ef3663735a9d3cb4e0c1d9950e

2 directories, 1 file
# 并不是一个文本文件
root@ubuntu2204:~ 19:23:21 # file /tmp/proxycache/e/50/319432ef3663735a9d3cb4e0c1d9950e 
/tmp/proxycache/e/50/319432ef3663735a9d3cb4e0c1d9950e: data


# 查看当前时间和缓存文件时间
root@ubuntu2204:~ 19:23:40 # date
Fri Sep 12 07:23:50 PM CST 2025
root@ubuntu2204:~ 19:23:50 # stat /tmp/proxycache/e/50/319432ef3663735a9d3cb4e0c1d9950e 
  File: /tmp/proxycache/e/50/319432ef3663735a9d3cb4e0c1d9950e
  Size: 617       	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 5901210     Links: 1
Access: (0600/-rw-------)  Uid: (   33/www-data)   Gid: (   33/www-data)
Access: 2025-09-12 19:23:40.617081717 +0800
Modify: 2025-09-12 19:23:11.265206177 +0800
Change: 2025-09-12 19:23:11.265206177 +0800
 Birth: 2025-09-12 19:23:11.265206177 +0800

# 缓存文件，除了文件内容外，还有头部信息
root@ubuntu2204:~ 19:23:56 # cat /tmp/proxycache/e/50/319432ef3663735a9d3cb4e0c1d9950e
"68c3fcb8-10"
KEY: /static/index.html
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Fri, 12 Sep 2025 11:23:11 GMT
Content-Type: text/html
Content-Length: 16
Last-Modified: Fri, 12 Sep 2025 10:58:00 GMT
Connection: close
ETag: "68c3fcb8-10"
Accept-Ranges: bytes

static.test.com


# 生命周期结束后文件被删除
root@ubuntu2204:~ 19:24:22 # tree /tmp/proxycache/
/tmp/proxycache/
└── e
    └── 50

2 directories, 0 files



# 但是在缓存有效期内，后端服务器内容发生了更新，客户端获取的还是缓存数据
# 后端真实数据删除，客户端还能拿到缓存数据
root@ubuntu2204:~ 19:40:50 # rm -f /var/www/html/static-html/static/index.html

# 客户端依旧可以拿到数据

~~~

~~~shell
# 在Proxy Server 中添加响应头字段
root@ubuntu2204:~ 19:42:00 # cat /etc/nginx/sites-enabled/www.test03.com.conf
proxy_cache_path /tmp/proxycache levels=1:2 keys_zone=proxycache:20m inactive=60s max_size=1g;
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /static{
        proxy_pass http://192.168.121.113;
        proxy_set_header Host "static.test.com";
        proxy_cache proxycache;
        proxy_cache_key $request_uri;
        proxy_cache_valid 200 302 301 90s;
        proxy_cache_valid any 2m;
        proxy_connect_timeout 10s;
        add_header X-Cache $upstream_cache_status;
        # 添加响应头，可以用来查看是否命中缓存
    }
}
root@ubuntu2204:~ 19:42:01 # nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 19:42:03 # systemctl restart nginx 
root@ubuntu2204:~ 19:42:11 # 
# 客户端访问
~~~

![image-20250912194336849](Nginx.assets/image-20250912194336849.png)

当有了缓存后再次访问

![image-20250912194402010](Nginx.assets/image-20250912194402010.png)

### 4.3.5 实现客户端 IP 地址透传

在使用Nginx 做代理的情况下，默认后端服务器无法获取客户端真实IP地址

#### 4.3.5.1 单级代理客户端 IP 地址透传

| role         | os system   | IP              |
| ------------ | ----------- | --------------- |
| client       | Ubuntu 2204 | 192.168.121.112 |
| proxy server | Ubuntu 2204 | 192.168.121.111 |
| real server  | Ubuntu 2204 | 192.168.121.113 |

~~~shell
# Proxy server 配置
root@ubuntu2204:~ 22:47:19 # cat  /etc/nginx/sites-enabled/www.test03.com.conf 
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://192.168.121.113;
    }
}


# Real Server 配置

root@ubuntu2204:~ 22:54:00 # cat /etc/nginx/sites-enabled/default  | egrep -v "#|^$"
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	server_name _;
	location / {
        return 200 ${remote_addr}---${http_x_real_ip}---${http_x_forwarded_for};
	}
}
root@ubuntu2204:~ 22:54:02 #


# 客户端测试，只能拿到代理服务器的IP
root@ubuntu2204:/apps/nginx 22:44:39 # curl www.test03.com/
192.168.121.111------
~~~

修改代理服务器配置，透传真实客户端IP

~~~shell
# proxy server


# $
root@ubuntu2204:~ 22:55:18 # cat  /etc/nginx/sites-enabled/www.test03.com.conf 
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://192.168.121.113;
        proxy_set_header X-Real-IP $remote_addr;
        # $remote_addr 获取客户端IP
        # 将请求头中的 X-Real-IP 设置为 $remote_addr 的值
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # $proxy_add_x_forwarded_for 记录路由的顺序
        # 将请求头中的 X-Forwarded-For 设置为 $proxy_add_x_forwarded_for 的值
    }
}
root@ubuntu2204:~ 22:55:21 # 


#表示将客户端IP追加请求报文中X-Forwarded-For首部字段,多个IP之间用逗号分隔,如果请求中没有X-Forwarded-For,就使用$remote_addr
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for


#客户端测试 $remote_addr 获取代理 IP，$http_x_real_ip 获取真实客户端 IP，$http_x_forwarded_for 获取真实客户端 IP
root@ubuntu2204:/apps/nginx 22:55:59 # curl www.test03.com/
192.168.121.111---192.168.121.112---192.168.121.112


~~~

#### 4.5.3.2 多级代理客户端 IP 地址透传

| role                | os system   | IP              |
| ------------------- | ----------- | --------------- |
| client              | Windows     | 192.168.121.1   |
| proxy-server-first  | Ubuntu 2204 | 192.168.121.111 |
| proxy-server-second | Ubuntu 2204 | 192.168.121.112 |
| real server         | Ubuntu 2204 | 192.168.121.113 |

~~~shell
# proxy-server-first 设置
root@ubuntu2204:~ 10:56:26 # cat  /etc/nginx/sites-enabled/www.test03.com.conf 
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://192.168.121.112:8080;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}


# proxy-server-second 设置
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    root   html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;
    location / {
        proxy_pass http://192.168.121.113;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

# real server 设置
root@ubuntu2204:/etc/nginx 11:12:49 # grep -vE  "#|^$" sites-enabled/default 
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	server_name _;
	location / {
        return 200 ${remote_addr}---${http_x_real_ip}---${http_x_forwarded_for};
	}
}
root@ubuntu2204:/etc/nginx 11:13:04 #
#客户端测试
# $remote_addr 获取上一级代理IP
# $http_x_real_ip 获取上上一级代理IP
# $http_x_forwarded_for 累加了第一级代理的 X-Forwarded-For 和第二级代理的 X-Forwarded-For
192.168.121.112---192.168.121.111---192.168.121.1, 192.168.121.111
~~~

## 4.4 实现 http 协议反向代理的负载均衡

### 4.4.1 相关指令和参数

在实现 Nginx 反向代理的基础上，可以基于 ngx_http_upstream_module 模块实现后端服务器的分组，权重分配，状态监测，调度算法等高级功能

https://nginx.org/en/docs/http/ngx_http_upstream_module.html

~~~shell
upstream name { server address [parameters]; } # 定义一个后端服务器组，可以包含一台或多台服务器，
 # 定义好后在 proxy_pass 指令中引用，作用域 http
 
server address [parameters]; # 在 upstream 中定义一个具体的后端服务器，作用域 upstream
 # address 指定后端服务器 可以是IP地址，主机名，或UNIX Socket，可以加端口号
 # parameters 是可选掺数，具体有以下几个属性
 # weight=number 指定该 server 的权重，默认值都是1
 # max_conns=number 该 Server 的最大活动连接数，达到后将不再给该 Server 发送请求，默认值0，表示不限制
 # max_fails=number 后端服务器的下线条件,当客户端访问时,对本次调度选中的后端服务器连续进行检测多少次，如果都失   败就标记为不可用，默认为1次，当客户端访问时，才会利用TCP触发对探测后端服务器健康性检查，而非周期性的探测
 # fail_timeout=time 后端服务器的上线条件,对已经检测到处于不可用的后端服务器,每隔此时间间隔再次进行检测是否恢   复可用，如果发现可用,则将后端服务器参与调度,默认为10秒 
 # backup 标记该 Server 为备用，当所有后端服务器不可用时，才使用此服务器
 # down 标记该 Server 临时不可用，可用于平滑下线后端服务器，新请求不再调度到此服务器，原有连接不受影响
 
 
hash key [consistent]; # 使用自行指定的 Key 做 hash 运算后进行调度，Key 可以是变量，比如请求头中的字段，URI等，如果对应的 server 条目配置发生了变化，会导致相同的 key 被重新hash
 # consistent 表示使用一致性 hash，此参数确保该upstream 中的 server 条目发生变化时，尽可能少的重新 hash，适用于做缓存服务的场景，提高缓存命中率
 # 作用域 upstream
 
ip_hash; # 源地址hash调度方法，基于的客户端的remote_addr(源地址IPv4的前24位或整个IPv6地址)做hash计算，以实现会话保持，作用域 upstream、
least_conn; # 最少连接调度算法，优先将客户端请求调度到当前连接最少的后端服务器,相当于LVS中的 LC 算法
 # 配合权重，能实现类似于 LVS 中的 WLC 算法
 # 作用域 upstream
 
keepalive connections; # 为每个 worker 进程保留最多多少个空闲保活连接数，超过此值，最近最少使用的连接将被关闭
 # 默认不设置，作用域 upstream
 
keepalive_time time; # 空闲连接保持的时长，超过该时间，一直没使用的空闲连接将被销毁
 # 默认值 1h，作用域 upstream
~~~

### 4.4.2 基本配置

#### 4.4.2.1 一个 proxy 对应一个 upstream

| role          | os syste    | IP              |
| ------------- | ----------- | --------------- |
| client        | Windows     | 192.168.121.1   |
| proxy-server  | Ubuntu 2204 | 192.168.121.111 |
| real server-1 | Ubuntu 2204 | 192.168.121.112 |
| real server-2 | Ubuntu 2204 | 192.168.121.113 |

~~~shell
# proxy-server 配置
root@ubuntu2204:~ 13:52:19 # cat /etc/nginx/sites-enabled/www.test03.com.conf 
upstream g1 {
    server 192.168.121.112:8080;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
root@ubuntu2204:~ 13:52:20 #


# real-server1 配置
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    server_name _;
    root   html;
    index index.html index.htm index.nginx-debian.html;
}


# real-server2 设置
root@ubuntu2204:/etc/nginx 13:48:45 # grep -vE  "#|^$" sites-enabled/default 
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	server_name _;
	location / {
	    try_files $uri $uri/ =404;
	}
}
root@ubuntu2204:/etc/nginx 13:53:21 #

# 轮询测试
root@ubuntu2204:~ 13:53:37 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 13:53:38 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 13:53:38 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 13:53:38 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 13:53:39 #
~~~

#### 4.4.2.2 一个 proxy 对应多个 upstream



| role          | os syste    | IP              | 所属 upstream |
| ------------- | ----------- | --------------- | ------------- |
| client        | Windows     | 192.168.121.1   |               |
| proxy-server  | Ubuntu 2204 | 192.168.121.111 |               |
| real server-1 | Ubuntu 2204 | 192.168.121.112 | g1            |
| real server-2 | Ubuntu 2204 | 192.168.121.113 | g1            |
| real server-3 | Ubuntu 2204 | 192.168.121.232 | g2            |
| real server-4 | Ubuntu 2204 | 192.168.121.233 | g2            |

~~~shell
# Proxy server 设置
root@ubuntu2204:~ 14:01:51 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    server 192.168.121.112:8080;
    server 192.168.121.113;
}
upstream g2 {
    server 192.168.121.232;
    server 192.168.121.233;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
server{
    listen 80;
    server_name www.test03.net;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g2;
        proxy_set_header Host $http_host;
    }
}


root@ubuntu2204:~ 14:02:13 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 14:02:22 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 14:02:23 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 14:02:23 # curl www.test03.net
i am 192.168.121.232
root@ubuntu2204:~ 14:40:33 # curl www.test03.net
version2
root@ubuntu2204:~ 14:40:34 # curl www.test03.net
i am 192.168.121.232
root@ubuntu2204:~ 14:40:35 # curl www.test03.net
version2
root@ubuntu2204:~ 14:40:36 # curl www.test03.net
i am 192.168.121.232
root@ubuntu2204:~ 14:40:36 # curl www.test03.net
version2

~~~

#### 4.4.2.3 设置权重

~~~shell
# 每个 server 配置的默认权重是1，这种写法，两个 server 被调度的比例为 3:1
root@ubuntu2204:~ 17:06:57 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    server 192.168.121.112:8080 weight=3;
    server 192.168.121.113;
}
upstream g2 {
    server 192.168.121.232;
    server 192.168.121.233;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
server{
    listen 80;
    server_name www.test03.net;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g2;
        proxy_set_header Host $http_host;
    }
}
root@ubuntu2204:~ 17:06:59 # systemctl restart nginx 
root@ubuntu2204:~ 17:07:06 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 17:07:14 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 17:07:15 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 17:07:15 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 17:07:16 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 17:07:17 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 17:07:17 # curl www.test03.com
i am 192.168.121.113

~~~

#### 4.4.2.4 限制最大活动连接数

~~~shell
# proxy server 设置
root@ubuntu2204:~ 17:17:29 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    server 192.168.121.112:8080 max_conns=2;
    server 192.168.121.113;
}
upstream g2 {
    server 192.168.121.232;
    server 192.168.121.233;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
server{
    listen 80;
    server_name www.test03.net;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g2;
        proxy_set_header Host $http_host;
    }
}


# 后端服务器设置
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    server_name _;
    root   html;
    index index.html index.htm index.nginx-debian.html;
    limit_rate 10k;
}



# 客户端测试，开 6 个窗口下载文件
root@ubuntu2204:~ 21:18:59 # wget http://www.test03.com/test.img


# 查看 192.168.121.112 上的连接
root@ubuntu2204:/apps/nginx/html 17:25:09 #  ss -tnpe | grep 80
ESTAB 0      0      192.168.121.112:8080 192.168.121.111:37366 users:(("nginx",pid=61958,fd=9)) uid:998 ino:272864 sk:1004 cgroup:/user.slice/user-0.slice/session-17.scope <-> 
ESTAB 0      0      192.168.121.112:8080 192.168.121.111:43548 users:(("nginx",pid=61958,fd=3)) uid:998 ino:272863 sk:1006 cgroup:/user.slice/user-0.slice/session-17.scope <-> 


# 查看 192.168.121.113 上的连接
root@ubuntu2204:~ 21:20:02 #  ss -tnep | grep 80
ESTAB 0      0      192.168.121.113:80   192.168.121.111:40760 users:(("nginx",pid=58014,fd=17)) uid:33 ino:268755 sk:9 cgroup:/system.slice/nginx.service <->                        
ESTAB 0      952    192.168.121.113:80   192.168.121.111:59918 users:(("nginx",pid=58014,fd=13)) timer:(persist,104ms,0) uid:33 ino:268753 sk:a cgroup:/system.slice/nginx.service <->
ESTAB 0      0      192.168.121.113:80   192.168.121.111:59922 users:(("nginx",pid=58014,fd=15)) uid:33 ino:268754 sk:b cgroup:/system.slice/nginx.service <->                        
ESTAB 0      0      192.168.121.113:80   192.168.121.111:44160 users:(("nginx",pid=58014,fd=19)) uid:33 ino:268756 sk:c cgroup:/system.slice/nginx.service <->                        
root@ubuntu2204:~ 21:20:06 # 


# 客户端继续测试，新的请求都不会调度给 192.168.121.112

~~~

#### 4.4.2.5 后端服务器健康检查

Nginx 的 upstream 指令对于后端服务器的健康性检查是被动检查，当有客户端请求被调度到该服务器上时，会在TCP协议层的三次握手时检查该服务器是否可用，如果不可用就调度到别的服务器，当不可用的次数达到指定次数时（默认是1次，由 Server 配置中的 max_fails 选项决定），在规定时间内（默认是10S，由 Server 配置中的 fail_timeout 选项决定），不会再向该服务器调度请求，直到超过规定时间后再次向该服务器调度请求，如果再次调度该服务器还是不可用，则继续等待一个时间段，如果再次调度该服务器可用，则恢复该服务器到调度列表中

~~~shell
# proxy server 配置
root@ubuntu2204:~ 21:28:29 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    server 192.168.121.112:8080;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
# 停止 192.168.121.112 上的 Nginx 服务
root@ubuntu2204:/apps/nginx/html 21:29:29 # nginx -s stop


# 客户端测试，检测到 192.168.121.112不可用，将请求都调度到 192.168.121.113
root@ubuntu2204:~ 21:28:36 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:29:46 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:29:47 # curl www.test03.com
i am 192.168.121.113


# 启用 192.168.121.112 上的 Nginx 服务，客户端需要在距离上次检测该服务器不可用 10S 后才能调度到该服务器
root@ubuntu2204:~ 21:29:47 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:30:59 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:30:59 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 21:31:00 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:31:00 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 21:31:01 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:31:01 # 


~~~

#### 4.4.2.6 设置备用服务器

~~~shell
# 设置 backup，当 192.168.121.112 和 192.168.121.113 都不可用时，请求会被调度到 192.168.121.232
root@ubuntu2204:~ 21:33:00 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    server 192.168.121.112:8080;
    server 192.168.121.113;
    server 192.168.121.232 backup;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}

# 当前 112 和 113 可用，客户端测试
root@ubuntu2204:~ 21:33:50 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 21:33:52 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:33:53 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 21:33:54 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:33:54 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 21:33:55 # 



# 停止 112 和 113 的 nginx 服务
root@ubuntu2204:~ 21:33:55 # curl www.test03.com
192.168.121.232  --- 网站正在维护
root@ubuntu2204:~ 21:35:54 # curl www.test03.com
192.168.121.232  --- 网站正在维护
root@ubuntu2204:~ 21:35:55 # 

~~~

#### 4.4.2.7 设置后端服务平滑下线

~~~shell
# proxy server
root@ubuntu2204:~ 21:37:11 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    server 192.168.121.112:8080;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}

# 后端服务器配置
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    server_name _;
    root   html;
    index index.html index.htm index.nginx-debian.html;
    limit_rate 10k;
}

# 客户端测试 - 开启两个窗口下载文件
root@ubuntu2204:/apps/nginx/html 21:36:47 # ss -tnep | grep 80
ESTAB 0      0      192.168.121.112:8080 192.168.121.111:42672 users:(("nginx",pid=62199,fd=3)) uid:998 ino:271620 sk:2008 cgroup:/user.slice/user-0.slice/session-17.scope <-> 
root@ubuntu2204:/apps/nginx/html 21:38:48 # 
root@ubuntu2204:~ 21:36:50 # ss -tnep | grep 80
ESTAB 0      0      192.168.121.113:80   192.168.121.111:42308 users:(("nginx",pid=58205,fd=13)) uid:33 ino:272828 sk:e cgroup:/user.slice/user-0.slice/session-16.scope <->
root@ubuntu2204:~ 21:38:50 # 


# 修改Proxy Server 配置，将 192.168.121.112 下线
root@ubuntu2204:~ 21:39:35 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    server 192.168.121.112:8080 down;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
root@ubuntu2204:~ 21:39:37 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 21:39:39 # systemctl reload nginx

# 你会发现原来保持的下载连接没有中断，但新的请求，不会再被调度到 192.168.121.112
root@ubuntu2204:~ 21:39:51 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:40:05 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:40:06 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:40:06 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:40:06 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:40:07 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 21:40:08 # 

~~~

### 4.4.3 负载均衡调度算法

#### 4.4.3.1 源 IP hash

ip_hash 算法只使用 IPV4 的前 24 位做 hash 运算，如果客户端IP前24位一致，则会被调度到同一台后端服务器

~~~shell
# Proxy server 配置
root@ubuntu2204:~ 23:07:24 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    ip_hash;
    server 192.168.121.112:8080;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
root@ubuntu2204:~ 23:07:25 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 23:07:26 # systemctl restart nginx


# 192.168.121.111 作为客户端测试：调度到 192.168.121.112
root@ubuntu2204:~ 23:07:30 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 23:07:54 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 23:07:54 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 23:07:55 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:~ 23:07:55 # 


# 192.168.121.232 作为客户端测试：调度到 192.168.121.112 上
root@worker01:/var/www/html 23:08:31 
# curl www.test03.com
i am 192.168.121.112
root@worker01:/var/www/html 23:08:33 
# curl www.test03.com
i am 192.168.121.112
root@worker01:/var/www/html 23:08:34 
# curl www.test03.com
i am 192.168.121.112
root@worker01:/var/www/html 23:08:34 
# curl www.test03.com
i am 192.168.121.112

~~~

#### 4.4.3.2 使用自行指定的 key 做 hash 调度

##### 4.4.3.2.1 使用 $remote_addr

~~~shell
# Proxy Server 配置
# 三台 server 权重一样，调度算法 hash($remoute_addr)%3，值为 0，1，2 根据不同的值调度到不同server
root@ubuntu2204:~ 23:11:35 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    hash $remote_addr;
    server 192.168.121.112:8080;
    server 192.168.121.232;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}


# 192.168.121.111 测试
root@ubuntu2204:~ 23:12:46 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 23:12:52 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 23:12:52 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 23:12:53 # curl www.test03.com
i am 192.168.121.113


# 192.168.121.112 测试
root@ubuntu2204:/apps/nginx/html 21:38:48 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:/apps/nginx/html 23:13:03 # curl www.test03.com
i am 192.168.121.112
root@ubuntu2204:/apps/nginx/html 23:14:12 # curl www.test03.com
i am 192.168.121.112

~~~

~~~shell
# 三台 server 权重不一样，调度算法 hash($remoute_addr)%(1+2+3)，值为 0，1，2，3，4，5
# 0 调度到 210
# 1，2调度到 159
# 3，4，5调度到 213
upstream g1 {
    hash $remote_addr;
    server 192.168.121.112:8080 weight=1;
    server 192.168.121.232 weight=2;
    server 192.168.121.113 weight=3;
}
~~~

##### 4.4.3.2.2 使用 $request_uri

~~~shell
# Proxy Server 配置
# 根据 request_uri 进行调度，不同客户端访问同一个资源会被调度到同一台后端服务器上
root@ubuntu2204:~ 23:41:39 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    hash $request_uri;
    server 192.168.121.112:8080;
    server 192.168.121.232;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
root@ubuntu2204:~ 23:41:42 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 23:41:44 # systemctl restart nginx


# 客户端测试
root@ubuntu2204:~ 23:43:27 # curl www.test03.com/index.html
i am 192.168.121.113
root@ubuntu2204:~ 23:43:33 # curl www.test03.com/index.html
i am 192.168.121.113
root@ubuntu2204:~ 23:43:35 # curl www.test03.com/index.html
i am 192.168.121.113
root@ubuntu2204:~ 23:43:36 # curl www.test03.com/index.html
i am 192.168.121.113
root@ubuntu2204:~ 23:43:36 # curl www.test03.com/a.html
192.168.121.112 aaaa
root@ubuntu2204:~ 23:43:50 # curl www.test03.com/a.html
192.168.121.112 aaaa

~~~

#### 4.4.3.3 最少连接调度算法

~~~shell
root@ubuntu2204:~ 23:47:44 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    least_conn;
    server 192.168.121.112:8080;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
root@ubuntu2204:~ 23:47:46 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 23:47:48 # systemctl restart nginx
root@ubuntu2204:~ 23:47:51 # 


# 客户端开启一个下载连接，限速，让该连接一直保持
root@ubuntu2204:~ 23:48:00 # wget http://www.test03.com/test.img


# 下载请求被调度到 192.168.121.112 上了
root@ubuntu2204:/apps/nginx/html 23:44:14 #  ss -tnep | grep 80
ESTAB 0      0      192.168.121.112:8080 192.168.121.111:52596 users:(("nginx",pid=62199,fd=3)) uid:998 ino:281914 sk:2009 cgroup:/user.slice/user-0.slice/session-17.scope <->


# 新开客户端测试，请求不会被调度到 192.168.121.112 上
root@ubuntu2204:~ 23:48:45 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 23:48:46 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 23:48:46 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 23:48:46 # curl www.test03.com
i am 192.168.121.113
root@ubuntu2204:~ 23:48:47 # curl www.test03.com
i am 192.168.121.113

~~~

### 4.4.4 一致性 hash

~~~shell
# Proxy Server 配置
# 三台 server 权重一样，调度算法 hash($remoute_addr)%3，值为 0，1，2 根据不同的值调度到不同server
root@ubuntu2204:~ 23:11:35 # cat /etc/nginx/sites-enabled/www.test03.com.conf
upstream g1 {
    hash $remote_addr;
    server 192.168.121.112:8080;
    server 192.168.121.232;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test03.com;
    #root /var/www/html/www.test03.com;
    location /{
        proxy_pass http://g1;
        proxy_set_header Host $http_host;
    }
}
~~~

在上述配置中，三台后端服务器的权重都为 1，则总权重为 3，再使用客户端 IP 的 hash 值对总权重求余

假设当前调度情况如下

| hash($remote_addr) | hash($remote_addr)%3 | server          |
| ------------------ | -------------------- | --------------- |
| 3，6，9            | 0，0，0              | 192.168.121.112 |
| 1，4，7            | 1，1，1              | 192.168.121.113 |
| 2，5，8            | 2，2，2              | 192.168.121.232 |

此时如果后端新增一台服务器，则总权重会变为 4，那么同样的 hash 值，最后的调度结果如下

| hash($remote_addr) | hash($remote_addr)%3 | server          |
| ------------------ | -------------------- | --------------- |
| 4，8               | 0，0                 | 192.168.121.111 |
| 1，5，9            | 1，1，1              | 192.168.121.112 |
| 2，6               | 2，2                 | 192.168.121.232 |
| 3，7               | 3，3                 | 192.168.121.233 |

我们会发现，新增后端服务器后，总权重发生变化，则所有前端的请求都会被重新计算，调度到和原来不同的后端服务器上了，这样会导致在原来后端服务器上创建的数据，在新的服务器上没有了，减少后端服务器或修改后端服务器权重，都会导致重新调度，会导致原有缓存数据失效（例如登录状态，购物车等）

**一致性哈希**

一致性哈希（Consistent Hashing）是一种用于分布式系统中数据分片和负载均衡的算法，其中的"hash环"是该算法的核心概念之一

在一致性哈希中，所有可能的数据节点或服务器被映射到一个虚拟的环上。这个环的范围通常是一个固定的哈希空间，比如0到2\^32-1，每个数据节点或服务器被映射到环上的一个点，通过对其进行哈希计算得到。这个哈希值的范围也是在0到2\^32-1之间

在这个环上，数据会被分散到最接近它的节点。当有新的数据要存储时，首先通过哈希计算得到该数据的哈希值，然后在环上找到离这个哈希值最近的节点，将数据存储在这个节点上。同样，当要查询数据时，也是通过哈希计算得到数据的哈希值，然后找到最近的节点进行查询

由于哈希环是一个环形结构，节点的添加和删除对整体的影响相对较小。当添加或删除节点时，只有相邻的节点受到影响，而其他节点保持不变。这使得一致性哈希算法在分布式系统中能够提供较好的负载均衡性能，同时减小了数据迁移的开销

总的来说，一致性哈希中的哈希环是通过哈希计算将数据节点映射到环上，以实现数据分片和负载均衡的分布式算法

~~~shell
upstream g1 {
    hash $remote_addr;
    server 192.168.121.112:8080;
    server 192.168.121.232;
    server 192.168.121.113;
}
~~~



哈希环

![image-20250913235747695](Nginx.assets/image-20250913235747695.png)

环偏移/数据倾斜

在一致性哈希中，哈希环可能会面临的一个问题是环偏移（Ring Wrapping）。环偏移指的是哈希环上的某个区域过于拥挤，而其他区域相对空闲，这可能导致负载不均衡。为了解决这个问题，一些改进的一致性哈希算法引入了虚拟节点（Virtual Nodes）的概念

虚拟节点是对物理节点的一种扩展，通过为每个物理节点创建多个虚拟节点，将它们均匀地分布在哈希环上。这样一来，每个物理节点在环上的位置会有多个副本，而不是只有一个位置。这样一来，即使哈希环上的某个区域过于拥挤，也可以通过调整虚拟节点的数量来使得负载更均衡

## 4.5 综合案例

实现 http 自动重定向至 https，并将客户端 https 请求通过负载均衡的方式反向代理到后端的多台 http 服务器上

![image-20250914134014645](Nginx.assets/image-20250914134014645.png)



~~~shell
root@ubuntu2204:~ 13:51:37 # cat /etc/nginx/sites-enabled/www.test02.com.conf
upstream g2 {
    server 192.168.121.112:8080;
    server 192.168.121.113;
}
server{
    listen 80;
    server_name www.test02.com;
    return 302 https://$server_name$request_uri;
    # rewrite ^(.*) https://$server_name$1 permanent;

}

server {
    listen 443 ssl http2;
    server_name www.test02.com;
    ssl_certificate /usr/share/easy-rsa/pki/www.test02.com.pem;
    ssl_certificate_key /usr/share/easy-rsa/pki/private/www.test02.com.key;
    ssl_session_cache shared:sslcache:20m;
    ssl_session_timeout 10m;
    location / {
        proxy_pass https://g2;
        proxy_set_header host $http_host;
    }
}
root@ubuntu2204:~ 13:51:38 # systemctl restart nginx 

~~~



## 4.6 Nginx 的四层代理和负载

### 4.6.1 相关指令和参数

Nginx 在1.9.0版本开始支持tcp模式的负载均衡，在1.9.13版本开始支持 udp 协议的负载，udp 主要用于 DNS 的域名解析，其配置方式和指令和 http 代理类似，其基于 ngx_stream_proxy_module 模块实现 tcp 负载，另外基于模块 ngx_stream_upstream_module 实现后端服务器分组转发、权重分配、状态监测、调度算法等高级功能

如果编译安装，需要指定 --with-stream 选项才能支持 ngx_stream_proxy_module 模块

~~~shell
http://nginx.org/en/docs/stream/ngx_stream_proxy_module.html # 非http协议的反向代理
https://nginx.org/en/docs/stream/ngx_stream_upstream_module.html # 非http协议的负载均衡
~~~

### 4.6.2 实现 tcp 协议的反向代理

| role         | os system   | IP              |
| ------------ | ----------- | --------------- |
| client       | Windows     | 192.168.121.1   |
| proxy server | Ubuntu 2204 | 192.168.121.111 |
| mysql server | Ubuntu 2204 | 192.168.121.112 |
| redis server | Ubuntu 2204 | 192.168.121.113 |

~~~shell
# proxy server 设置，需要写在最外面
stream {
    server {
        listen 3306;
        proxy_pass 192.168.121.112:3306;
    }
    server {
        listen 6379;
        proxy_pass 192.168.121.113:6379;
    }
}
root@ubuntu2204:~ 17:10:30 # systemctl start nginx 
root@ubuntu2204:~ 17:10:53 # ss -tunlp | grep -E "3306|6379"
tcp   LISTEN 0      511          0.0.0.0:6379      0.0.0.0:*    users:(("nginx",pid=76220,fd=7),("nginx",pid=76219,fd=7),("nginx",pid=76218,fd=7),("nginx",pid=76217,fd=7),("nginx",pid=76216,fd=7))
tcp   LISTEN 0      511          0.0.0.0:3306      0.0.0.0:*    users:(("nginx",pid=76220,fd=6),("nginx",pid=76219,fd=6),("nginx",pid=76218,fd=6),("nginx",pid=76217,fd=6),("nginx",pid=76216,fd=6))

~~~

~~~shell
# mysql server 安装 MySQL，并设置远程用户
root@ubuntu2204:~ 13:38:32 # apt update && apt install -y mysql-server
root@ubuntu2204:~ 14:02:19 # mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.43-0ubuntu0.22.04.1 (Ubuntu)

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create user proxyer@'192.168.121.%' identified by '123456';
Query OK, 0 rows affected (0.03 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)

mysql> exit
Bye

# 当前mysql-server 只监听了本机的3306
root@ubuntu2204:~ 14:02:58 # ss -tunlp | grep 3306
tcp   LISTEN 0      70         127.0.0.1:33060      0.0.0.0:*    users:(("mysqld",pid=64216,fd=21))                       
tcp   LISTEN 0      151        127.0.0.1:3306       0.0.0.0:*    users:(("mysqld",pid=64216,fd=23))                       
# 修改配置，注释掉这两行
root@ubuntu2204:~ 14:03:04 #  vim /etc/mysql/mysql.conf.d/mysqld.cnf
#bind-address           = 127.0.0.1
#mysqlx-bind-address   = 127.0.0.1
skip-name-resolve #添加此行，跳过主机名反解

# 重启服务
root@ubuntu2204:~ 14:03:44 # systemctl restart mysql.service
root@ubuntu2204:~ 14:03:53 #  ss -tnlp | grep 3306
LISTEN 0      70                 *:33060            *:*    users:(("mysqld",pid=64591,fd=21))                       
LISTEN 0      151                *:3306             *:*    users:(("mysqld",pid=64591,fd=23))         
~~~

~~~shell
# redis server 安装 redis
root@ubuntu2204:~ 13:38:32 # apt update;apt install redis-server


# 当前只监听 127.1
root@ubuntu2204:~ 14:06:42 # ss -tnlp | grep 6379
LISTEN 0      511        127.0.0.1:6379      0.0.0.0:*    users:(("redis-server",pid=59909,fd=6))                                                                                             
LISTEN 0      511            [::1]:6379         [::]:*    users:(("redis-server",pid=59909,fd=7))                                                                                             
root@ubuntu2204:~ 14:07:52 # 


# 修改配置并重启
root@ubuntu2204:~ 14:09:56 # vim /etc/redis/redis.conf 
#bind 127.0.0.1 ::1
protected-mode no #关闭保护模式
root@ubuntu2204:~ 14:10:15 # systemctl restart redis 

root@ubuntu2204:~ 14:10:58 # ss -tnlp | grep 6379
LISTEN 0      511          0.0.0.0:6379      0.0.0.0:*    users:(("redis-server",pid=60325,fd=7))                                                                                             
LISTEN 0      511             [::]:6379         [::]:*    users:(("redis-server",pid=60325,fd=6))                                                                                             
root@ubuntu2204:~ 14:11:00 # 



~~~

~~~shell
# 客户端配置，并测试
root@ubuntu2204:~ 13:59:31 #  apt update;  apt install mysql-client-8.0 redis

# 直连测试
root@ubuntu2204:~ 17:11:19 #  mysql -h 192.168.121.112  -uproxyer -p'123456'

# 在 mysql 服务端查看
mysql> show processlist\G
*************************** 1. row ***************************
     Id: 5
   User: event_scheduler
   Host: localhost
     db: NULL
Command: Daemon
   Time: 9758
  State: Waiting on empty queue
   Info: NULL
*************************** 2. row ***************************
     Id: 8
   User: proxyer
   Host: 192.168.121.111:52664
     db: NULL
Command: Sleep
   Time: 9
  State: 
   Info: NULL
*************************** 3. row ***************************
     Id: 9
   User: root
   Host: localhost
     db: NULL
Command: Query
   Time: 0
  State: init
   Info: show processlist
3 rows in set, 1 warning (0.00 sec)


# redis 测试，客户端直连
root@ubuntu2204:~ 17:14:05 #  redis-cli -h 10.0.0.159
10.0.0.159:6379> exit

# 服务端查看
root@ubuntu2204:~ 17:19:58 # netstat  -tnep | grep 6379
tcp        0      0 192.168.121.113:6379    192.168.121.111:43838   ESTABLISHED 114        311109     60325/redis-server  
root@ubuntu2204:~ 17:20:30 # 
~~~

### 4.6.3 实现 TCP 协议的负载均衡

~~~shell
stream{
 upstream mysql{
 server 10.0.0.210:3306;
 server 10.0.0.159:3306;
 }
 upstream redis{
 server 10.0.0.210:6379;
 server 10.0.0.159:6379;
 }
 server{
 listen 3306;
 proxy_pass mysql;
 } 
 
 server{
 listen 6379;
 proxy_pass redis;
 }
}
~~~

## 4.7 实现 FastCGI 代理

### 4.7.1 相关指令和参数

关于 PHP 和 FastCGI 的内容请回顾 Apache 章节内容，此章节重点讲解 Nginx 将前端请求通过 FastCGI 协议反向代理到后端的 PHP-FPM，将请求交由 PHP 程序处理

http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html

~~~shell
fastcgi_index name; # 后端 FastCGI 服务器默认资源，默认值为空，作用域 http, server, location

fastcgi_pass address; # 指定后端 FastCGI 服务器地址，可以写 IP:port，也可以指定socket 文件
 # 作用域 location, if in location
 
fastcgi_param parameter value [if_not_empty];
 # 设置传递给FastCGI服务器的参数值，可以是文本，变量或组合，可用于将Nginx的内置变量赋值给自定义key
 # 作用域 http, server, location
~~~

### 4.7.2 PHP 环境准备

~~~shell
# 安装 php-fpm
root@ubuntu2204:~ 17:42:32 # apt install -y php8.1-fpm


# 查看版本
root@ubuntu2204:~ 17:44:16 # php -v 
PHP 8.1.2-1ubuntu2.22 (cli) (built: Jul 15 2025 12:11:22) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.1.2, Copyright (c) Zend Technologies
    with Zend OPcache v8.1.2-1ubuntu2.22, Copyright (c), by Zend Technologies 
root@ubuntu2204:~ 17:47:47 # systemctl status php8.1-fpm.service 
● php8.1-fpm.service - The PHP 8.1 FastCGI Process Manager
     Loaded: loaded (/lib/systemd/system/php8.1-fpm.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-09-14 17:43:54 CST; 4min 4s ago
       Docs: man:php-fpm8.1(8)
    Process: 82653 ExecStartPost=/usr/lib/php/php-fpm-socket-helper install /run/php/php-fpm.sock /etc/php/8.1/fpm/pool.d/www.conf 81 (code=exited, sta>
   Main PID: 82650 (php-fpm8.1)
     Status: "Processes active: 0, idle: 2, Requests: 0, slow: 0, Traffic: 0req/sec"
      Tasks: 3 (limit: 4514)
     Memory: 7.2M
        CPU: 219ms
     CGroup: /system.slice/php8.1-fpm.service
             ├─82650 "php-fpm: master process (/etc/php/8.1/fpm/php-fpm.conf)" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
             ├─82651 "php-fpm: pool www" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "">
             └─82652 "php-fpm: pool www" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "">

Sep 14 17:43:54 ubuntu2204 systemd[1]: Starting The PHP 8.1 FastCGI Process Manager...
Sep 14 17:43:54 ubuntu2204 systemd[1]: Started The PHP 8.1 FastCGI Process Manager.
root@ubuntu2204:~ 17:48:00 # 

# 查看所有文件
root@ubuntu2204:~ 17:48:00 # dpkg -L php8.1-fpm

# 查看配置文件
root@ubuntu2204:~ 17:48:33 # ls -lh /etc/php/8.1/
total 12K
drwxr-xr-x 3 root root 4.0K Sep 14 17:43 cli   # cli 模式配置
drwxr-xr-x 4 root root 4.0K Sep 14 17:43 fpm   # fpm 模式配置
drwxr-xr-x 2 root root 4.0K Sep 14 17:43 mods-available  # cli 和 fpm 中引用的具体内容
root@ubuntu2204:~ 17:48:54 # 



# PHP-FPM 主要配置项
root@ubuntu2204:~ 17:48:54 # cat /etc/php/8.1/fpm/php-fpm.conf | grep -E " ="
pid = /run/php/php8.1-fpm.pid # 主进程文件
error_log = /var/log/php8.1-fpm.log # 错误日志
;syslog.facility = daemon # 日志分类
;syslog.ident = php-fpm 
;log_level = notice # 日志级别
;log_limit = 4096 
;log_buffering = no 
;emergency_restart_threshold = 0 
;emergency_restart_interval = 0 
;process_control_timeout = 0
; process.max = 128
; process.priority = -19
;daemonize = yes # 后台守护进程运行
;rlimit_files = 1024
;rlimit_core = 0
;events.mechanism = epoll
;systemd_interval = 10



root@ubuntu2204:~ 17:49:46 #  cat /etc/php/8.1/fpm/pool.d/www.conf | grep -E " ="
;prefix = /path/to/pools/$pool
user = www-data # php-fpm worker 进程属主
group = www-data # php-fpm worker 进程属组
listen = /run/php/php8.1-fpm.sock # 与 PHP-FPM 的通信方式，可以写成 IP:port
;listen.backlog = 511
listen.owner = www-data
listen.group = www-data
;listen.mode = 0660
;listen.acl_users =
;listen.acl_groups =
;listen.allowed_clients = 127.0.0.1
; process.priority = -19
; process.dumpable = yes
pm = dynamic # 动态生成工作进程
pm.max_children = 5 # 最多5个工作进程
pm.start_servers = 2 # 启动时生成 2 个工作进程
pm.min_spare_servers = 1 # 最少1个空闲工作进程
pm.max_spare_servers = 3 # 最多3个空闲工作进程
;pm.max_spawn_rate = 32
;pm.process_idle_timeout = 10s;
;pm.max_requests = 500
;pm.status_path = /status # 状态页地址，注意路径不要和 nginx 状态页冲突
;pm.status_listen = 127.0.0.1:9001 # 访问状态页的IP和端口
;ping.path = /ping # php-fpm 心跳检测请求路径
;ping.response = pong # 心跳检测返回内容
;access.log = log/$pool.access.log # 访问日志路径
;access.format = "%R - %u %t \"%m %r%Q%q\" %s %f %{milli}d %{kilo}M %C%%" # 访问日志格式
;slowlog = log/$pool.log.slow # 慢日志路径
;request_slowlog_timeout = 0
;request_slowlog_trace_depth = 20
;request_terminate_timeout = 0
;request_terminate_timeout_track_finished = no
;rlimit_files = 1024
;rlimit_core = 0
;chroot =
;chdir = /var/www
;catch_workers_output = yes
;decorate_workers_output = no
;clear_env = no
;security.limit_extensions = .php .php3 .php4 .php5 .php7
;env[HOSTNAME] = $HOSTNAME
;env[PATH] = /usr/local/bin:/usr/bin:/bin
;env[TMP] = /tmp
;env[TMPDIR] = /tmp
;env[TEMP] = /tmp
;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@my.domain.com
;php_flag[display_errors] = off
;php_admin_value[error_log] = /var/log/fpm-php.www.log
;php_admin_flag[log_errors] = on
;php_admin_value[memory_limit] = 32M


#当前是使用 socket 进行数据交换，socket 必须是一个本地文件
#所以使用 socket 进行通信，要保证 nginx 和 php-fpm 运行在同一台服务器上
root@ubuntu2204:~ 17:50:29 # cat /etc/php/8.1/fpm/pool.d/www.conf | grep -E "^listen ="
listen = /run/php/php8.1-fpm.sock
root@ubuntu2204:~ 17:51:28 # 
root@ubuntu2204:~ 17:51:28 #  ls -lh /run/php/
total 4.0K
-rw-r--r-- 1 root     root      5 Sep 14 17:43 php8.1-fpm.pid
srw-rw---- 1 www-data www-data  0 Sep 14 17:43 php8.1-fpm.sock
lrwxrwxrwx 1 root     root     30 Sep 14 17:43 php-fpm.sock -> /etc/alternatives/php-fpm.sock
root@ubuntu2204:~ 17:51:39 # 



# 使用 IP:port 监听，Nginx 和 php-fpm 通信走网络 FastCGI 接口
root@ubuntu2204:~ 17:52:35 # cat /etc/php/8.1/fpm/pool.d/www.conf | grep -E "^listen ="
listen = 127.0.0.1:9000
root@ubuntu2204:~ 17:52:36 # 


# 取消下面几行注释
root@ubuntu2204:~ 17:52:36 #  vim /etc/php/8.1/fpm/pool.d/www.conf
;pm.status_path = /status
pm.status_path = /php-status
pm.status_listen = 127.0.0.1:9001
ping.path = /ping
ping.response = pong


# 重启 php
root@ubuntu2204:~ 17:54:15 # systemctl reload php8.1-fpm.service
root@ubuntu2204:~ 17:54:35 #  ss -tnlp | grep 9000
LISTEN 0      511        127.0.0.1:9000      0.0.0.0:*    users:(("php-fpm8.1",pid=82934,fd=10),("php-fpm8.1",pid=82933,fd=10),("php-fpm8.1",pid=82650,fd=8))                                 
root@ubuntu2204:~ 17:54:40 # 

~~~

### 4.7.3 配置 Nginx 转发到 FastCGI

~~~shell
root@ubuntu2204:~ 17:54:40 #  ll /etc/nginx/fastcgi*
-rw-r--r-- 1 root root 1125 May 31  2023 /etc/nginx/fastcgi.conf
-rw-r--r-- 1 root root 1055 May 31  2023 /etc/nginx/fastcgi_params
root@ubuntu2204:~ 17:55:21 # 

root@ubuntu2204:~ 17:55:21 # wc -l /etc/nginx/fastcgi*
  27 /etc/nginx/fastcgi.conf
  26 /etc/nginx/fastcgi_params
  53 total
root@ubuntu2204:~ 17:55:44 # diff /etc/nginx/fastcgi.conf /etc/nginx/fastcgi_params
2d1
< fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
root@ubuntu2204:~ 17:55:57 # 



# /etc/nginx/fastcgi.conf 和 /etc/nginx/fastcgi_params 都是用于配置 FastCGI 的默认参数的文件
# 这两个文件中都用 fastcgi_param 指令定义了很多要传给后端 FastCGI 接口的参数
# fastcgi.conf 比 fastcgi_params 中多出一行配置，至于为什么要用两个文件，属于历史遗留问题
# 在设置 FastCGI 反向代理时可以引用这两个文件中的任意一个，但引用 fastcgi_params 时，要额外加一行
#   fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
~~~

~~~shell
root@ubuntu2204:~ 18:04:54 # cat /etc/nginx/sites-enabled/www.test01.com.conf 
server{
    listen 80;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
    location ~  \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
    }
}
root@ubuntu2204:~ 18:06:36 # 
~~~

![image-20250914180623507](Nginx.assets/image-20250914180623507.png)

![image-20250914180721115](Nginx.assets/image-20250914180721115.png)

~~~shell
root@ubuntu2204:~ 18:08:52 # cat /etc/nginx/sites-enabled/www.test01.com.conf
server{
    listen 80;
    index index.html default.html a.txt;
    server_name www.test01.com;
    root /var/www/html/www.test01.com;
    location ~  \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
    }
    location /php-status {
        fastcgi_pass 127.0.0.1:9001;
        include fastcgi.conf;
    }
    location =/ping {
        fastcgi_pass 127.0.0.1:9000;
        include fastcgi.conf;
    }
    location /status {
        stub_status;
    }

}
root@ubuntu2204:~ 18:08:53 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 18:08:55 # systemctl restart nginx

~~~

![image-20250914180922329](Nginx.assets/image-20250914180922329-17578445632191.png)

![image-20250914180938723](Nginx.assets/image-20250914180938723.png)

![image-20250914181006628](Nginx.assets/image-20250914181006628.png)

![image-20250914181018306](Nginx.assets/image-20250914181018306.png)

![image-20250914181030387](Nginx.assets/image-20250914181030387.png)

![image-20250914181052327](Nginx.assets/image-20250914181052327.png)

### 4.7.4 综合案例

![image-20250914181228111](Nginx.assets/image-20250914181228111-17578447490043.png)

| role         | server                 | IP              |
| ------------ | ---------------------- | --------------- |
| proxy-server | Nginx                  | 192.168.121.111 |
| web-server01 | Nginx，php-fpm，discuz | 192.168.121.112 |
| web-server02 | Nginx，php-fpm，discuz | 192.168.121.113 |
| DB           | mysql                  | 192.168.121.220 |

~~~shell
# proxy server 配置
root@ubuntu2204:~ 18:20:37 # cat /etc/nginx/sites-enabled/www.test01.com.conf
upstream webs {
    server 192.168.121.112:8080;
    server 192.168.121.113 down;
}
server{
    listen 80;
    server_name www.test01.com;
    location / {
        proxy_pass http://webs;
        proxy_set_header host $http_host;
    }
}
root@ubuntu2204:~ 18:20:42 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ubuntu2204:~ 18:20:45 # systemctl restart nginx 
~~~

~~~shell
# web-server 配置
root@ubuntu2204:~ 18:21:47 # apt update;apt install php8.1-fpm php8.1-mysql php8.1-zip php8.1-xml -y
[root@ubuntu ~]# cat /etc/nginx/sites-enabled/bbs.m99-magedu.com.conf 
server{
       listen 80;
       server_name bbs.m99-magedu.com;
       root /var/www/html/www.test01.com;
       index index.html index.php;
 	   location ~ \.php$ {
               fastcgi_pass 127.0.0.1:9000;
               fastcgi_index index.php;
               include fastcgi.conf;
       }
}
[root@ubuntu ~]# cat /etc/php/8.1/fpm/pool.d/www.conf
;listen = /run/php/php8.1-fpm.sock
listen = 127.0.0.1:9000
#重启服务
[root@ubuntu ~]# systemctl restart nginx.service
[root@ubuntu ~]# systemctl restart php8.1-fpm.service
#下载源码并部署
# https://www.discuz.vip/download.html
[root@ubuntu ~]# unzip Discuz_X3.5_SC_UTF8_20231221.zip -d discuz
[root@ubuntu ~]# mv discuz/upload/ /var/www/html/bbs.m99-magedu.com
[root@ubuntu ~]# chown -R www-data.www-data /var/www/html/bbs.m99-magedu.com



#DB 配置
[root@ubuntu ~]# apt update;apt install mysql-server-8.0 redis-server
#修改 mysql 配置
[root@ubuntu ~]# cat /etc/mysql/mysql.conf.d/mysqld.cnf 
#注释两行
#bind-address = 127.0.0.1
#mysqlx-bind-address = 127.0.0.1
#添加两行
skip-name-resolve
default_authentication_plugin=mysql_native_password

[root@ubuntu ~]# systemctl restart mysql.service
#创建数据库，创建账号并授权
mysql> create database discuz;
mysql> create user 'discuzer'@'10.0.0.%' identified by '123456';
mysql> grant all on discuz.* to 'discuzer'@'10.0.0.%';
mysql> flush privileges;
~~~

~~~shell

#通过浏览器完成安装，在浏览器中打开 http://bbs.m99-magedu.com
# 然后修改 Proxy Server 配置，再完成另外一台安装，都完成安装后再次修改配置，让两台 Web Server 都上线
# 测试OK，但如果上传附件，图片，会发现有时候会加载不出来，因为文件只上传到了其中一台 Web Server 上
~~~

# 五、Nginx 二次开发

## 5.1 Tengine

Tengine是一个基于Nginx的开源Web服务器和反向代理服务器，旨在提供高性能和高并发处理能力。以下是关于Tengine的主要特点和信息：

- 起源：Tengine起源于淘宝网（阿里巴巴集团的在线购物平台）的内部需求，是在Nginx基础上进行优化和定制的结果。淘宝网在处理大规模、高并发的网络请求时，对Nginx进行了定制以满足其特定的性能和功能要求；
- 性能优化：Tengine在Nginx的基础上进行了一系列性能优化，特别是针对高并发场景。这包括对连接处理、负载均衡、静态文件服务等方面的优化
- 动态模块加载：Tengine支持动态模块加载，这使得用户可以根据具体需求在运行时加载或卸载模块，而无需重新编译和部署整个服务器；
- WebSocket支持：Tengine内置对WebSocket协议的支持，使其适用于实时通信应用，如即时聊天、实时通知等；
- 社区支持：Tengine在开源社区中有一定的用户群体，用户可以通过社区渠道获取支持和反馈

总体而言，Tengine是一个专注于性能优化的Web服务器，适用于高并发、大规模流量和实时通信的场景。由于其起源于淘宝网的内部需求，Tengine在处理电商等大型应用场景时表现出色

~~~shell
https://tengine.taobao.org/ #官网
https://tengine.taobao.org/documentation.html #文档
https://tengine.taobao.org/download/nginx@taobao.pdf #淘宝网Nginx定制开发实战
https://tengine.taobao.org/download/taobao_nginx_2012_06.pdf #淘宝网Nginx应用、定制开发实战
~~~

编译安装

~~~shell
# 编译安装
root@ubuntu2204:~ 21:02:22 # apt update;apt install gcc libssl-dev libpcre3-dev zlib1g-dev make -y 


# 创建用户
root@ubuntu2204:~ 21:03:52 # groupadd -r -g 123 nginx
root@ubuntu2204:~ 21:05:26 #  useradd -r -g nginx -u 123 -s /sbin/nologin nginx
root@ubuntu2204:~ 21:05:31 # id nginx 
uid=123(nginx) gid=123(nginx) groups=123(nginx)
root@ubuntu2204:~ 21:05:34 # 


# 下载源码编译并安装
root@ubuntu2204:~ 21:05:34 # wget https://tengine.taobao.org/download/tengine-3.1.0.tar.gz
root@ubuntu2204:~/tengine-3.1.0 21:06:43 # ./configure --prefix=/apps/tengine --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre
root@ubuntu2204:~/tengine-3.1.0 21:07:42 # make && make install
root@ubuntu2204:~/tengine-3.1.0 21:12:38 # tree /apps/
/apps/
└── tengine
    ├── conf
    │   ├── fastcgi.conf
    │   ├── fastcgi.conf.default
    │   ├── fastcgi_params
    │   ├── fastcgi_params.default
    │   ├── koi-utf
    │   ├── koi-win
    │   ├── mime.types
    │   ├── mime.types.default
    │   ├── nginx.conf
    │   ├── nginx.conf.default
    │   ├── scgi_params
    │   ├── scgi_params.default
    │   ├── uwsgi_params
    │   ├── uwsgi_params.default
    │   └── win-utf
    ├── html
    │   ├── 50x.html
    │   └── index.html
    ├── logs
    └── sbin
        └── nginx


# 基于 nginx/1.24.0 二次开发
root@ubuntu2204:~/tengine-3.1.0 21:16:21 # /apps/tengine/sbin/nginx -v
Tengine version: Tengine/3.1.0
nginx version: nginx/1.24.0
root@ubuntu2204:~/tengine-3.1.0 21:17:34 #


# 查看配置文件，语法与nginx 语法一致，但有很多独有的配置项
root@ubuntu2204:~/tengine-3.1.0 21:17:57 # cat /apps/tengine/conf/nginx.conf


# 启动
root@ubuntu2204:~/tengine-3.1.0 21:17:57 # /apps/tengine/sbin/nginx 
root@ubuntu2204:~/tengine-3.1.0 21:18:12 # ss -tunlp | grep 80
tcp   LISTEN 0      511               0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=7680,fd=6),("nginx",pid=7679,fd=6))


# 命令行下测试，提示 Server: Tengine/3.1.0
root@ubuntu2204:~/tengine-3.1.0 21:18:23 #  curl 127.1 -I
HTTP/1.1 200 OK
Server: Tengine/3.1.0
Date: Sun, 14 Sep 2025 13:18:55 GMT
Content-Type: text/html
Content-Length: 555
Last-Modified: Sun, 14 Sep 2025 13:12:38 GMT
Connection: keep-alive
ETag: "68c6bf46-22b"
Accept-Ranges: bytes

root@ubuntu2204:~/tengine-3.1.0 21:18:55 #
~~~

![image-20250914211921764](Nginx.assets/image-20250914211921764.png)

## 5.2 openresty

### 5.2.1 lua 脚本基本用法

Lua 是⼀个简洁、轻量、可扩展的脚本语⾔

Nginx+Lua优势

充分的结合Nginx的并发处理epool优势和Lua的轻量实现简单的功能且⾼并发的场景

- 统计IP
- 统计⽤户信息
- 安全WAF

~~~lua
-- 安装 lua
root@node1-111:~ 15:57:31 # apt-get upgrade;apt install lua5.4 -y

-- lua 的运行方式
// 命令式执行，交互式
root@node1-111:~ 15:57:58 # lua
Lua 5.4.4  Copyright (C) 1994-2022 Lua.org, PUC-Rio
> print("hello world")
hello world

// 文件式执行，非交互式
root@node1-111:~ 16:00:22 # cat test.lua
#!/usr/bin/lua
print("hello world")
root@node1-111:~ 16:00:24 # lua test.lua
hello world
root@node1-111:~ 16:00:27 # 

-- lua 的注释语法
// --⾏注释
#!/usr/bin/lua
--print("Hi is Wing!")
//块注释
--[[
 注释代码
--]]

-- lua 的基础语法
-- 变量定义
a = 123
// 注意事项
// 布尔类型只有 true 和 false
// 数字 0,空字符串都是 true
// lua 中的变量如果没有特殊说明, 全是全局变量

-- while 循环
// 计算1+2+3..+100
// Lua没有++或是+=这样的操作
root@node1-111:~/lua_code 16:05:42 # cat while.lua
#!/usr/bin/lua
sum = 0
num = 1
while num <= 100 do
    sum = sum + num
    num = num + 1
end
print("sum=",sum)
root@node1-111:~/lua_code 16:05:44 # lua while.lua
sum=	5050
root@node1-111:~/lua_code 16:05:45 # 

-- for 循环
// 循环1..100个数,sum每次+1到100
root@node1-111:~/lua_code 16:07:22 # vim for.lua
root@node1-111:~/lua_code 16:07:28 # cat for.lua
#!/usr/bin/lua
sum = 0
for i = 1,100 do
    sum = sum + 1
    print("i=",i,"sum",sum)
end
print("sum=", sum)

-- if 判断
root@node1-111:~/lua_code 16:10:26 # cat if.lua 
#!/usr/bin/lua
age=30
sex="Man"
if age == 40 and sex == "Man" then
    print("男⼈⼤于40")
    elseif age > 60 and sex ~= "Woman" then
    print("⾮⼥⼈⽽且⼤于60")
    else
    local age = io.read()
    print("Your age is",age)
    end
root@node1-111:~/lua_code 16:10:33 # lua if.lua 
11
Your age is	11

~~~

### 5.2.2 openresty 简介

OpenResty 是一个基于 Nginx 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关

OpenResty 通过汇聚各种设计精良的 Nginx 模块（主要由 OpenResty 团队自主开发），从而将 Nginx 有效地变成一个强大的通用 Web 应用平台。这样，Web 开发人员和系统工程师可以使用 Lua 脚本语言调动 Nginx 支持的各种 C 以及 Lua 模块，快速构造出足以胜任 10K 乃至 1000K 以上单机并发连接的高性能 Web 应用系统

OpenResty 的目标是让你的Web服务直接跑在 Nginx 服务内部，充分利用 Nginx 的非阻塞 I/O 模型，不仅仅对 HTTP 客户端请求，甚至于对远程后端诸如 MySQL、PostgreSQL、Memcached 以及 Redis 等都进行一致的高性能响应

![image-20250914212004362](Nginx.assets/image-20250914212004362.png)

https://openresty.org/cn/ 

编译安装

~~~shell
root@ubuntu2204:~ 21:20:40 #  wget https://openresty.org/download/openresty-1.25.3.1.tar.gz
root@ubuntu2204:~ 21:21:06 #  tar xf openresty-1.25.3.1.tar.gz
root@ubuntu2204:~/openresty-1.25.3.1 21:21:06 #  ./configure --prefix=/apps/openresty --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre --with-stream --with-stream_ssl_module --with-stream_realip_module
root@ubuntu2204:~ 21:21:06 # make && make install


# 查看版本
root@ubuntu2204:~ 21:33:25 # ls /apps/openresty/
bin  COPYRIGHT  luajit  lualib  nginx  pod  resty.index  site
root@ubuntu2204:~ 21:33:29 # 
root@ubuntu2204:~ 21:33:29 # /apps/openresty/bin/openresty -v
nginx version: openresty/1.25.3.1
root@ubuntu2204:~ 21:33:55 # 


# 启动
root@ubuntu2204:~ 21:33:55 # /apps/openresty/bin/openresty 
root@ubuntu2204:~ 21:34:15 # curl 127.1 -I
HTTP/1.1 200 OK
Server: openresty/1.25.3.1
Date: Sun, 14 Sep 2025 13:34:22 GMT
Content-Type: text/html
Content-Length: 128646
Last-Modified: Sun, 14 Sep 2025 13:32:49 GMT
Connection: keep-alive
ETag: "68c6c401-1f686"
Accept-Ranges: bytes

root@ubuntu2204:~ 21:34:22 # 



# 测试 lua 语言
location /lua {
    default_type text/html;
    content_by_lua_block {
        ngx.say("<p>hello world</p>")
    }
}

root@ubuntu2204:~ 21:36:15 #  killall openresty
root@ubuntu2204:~ 21:36:20 # /apps/openresty/bin/openresty 
root@ubuntu2204:~ 21:36:24 #  curl 127.1/lua
<p>hello world</p>
root@ubuntu2204:~ 21:36:29 # 

~~~

### 5.2.3 Nginx 调用 lua 指令

Nginx 调⽤ Lua 模块指令, Nginx 的可插拔模块加载执⾏

| 变量                               | 语法                                   |
| ---------------------------------- | -------------------------------------- |
| set_by_lua  set_by_lua_file        | 设置 Nginx 变量,可以实现负载的赋值逻辑 |
| access_by_lua access_by_lua_file   | 请求访问阶段处理, ⽤于访问控制         |
| content_by_lua content_by_lua_file | 内容处理器, 接受请求处理并输出响应     |

Nginx 调⽤ Lua API

| 变量                 | 含义                              |
| -------------------- | --------------------------------- |
| ngx.var              | nginx 变量                        |
| ngx.req.get_headers  | 获取请求头                        |
| ngx.req.get_uri_args | 获取url请求参数                   |
| ngx.redirect         | 重定向                            |
| ngx.print            | 输出响应内容体                    |
| ngx.say              | 输出响应内容体,最后输出⼀个换⾏符 |
| ngx.header           | 输出响应头                        |

#### 5.2.3.1 **set_by_lua** **和** **set_by_lua_file** 

set_by_lua 和 set_by_lua_file ：这两个模块都⽤于设置 Nginx 变量。set_by_lua 通过 inline Lua 代码设置变量的值，set_by_lua_file 则可以通过引⼊ Lua 脚本⽂件来设置变量。这两个模块通常⽤于实现负载的赋值逻辑，如根据请求的 headers 头部信息等进⾏动态变量设置。

~~~shell
~~~

