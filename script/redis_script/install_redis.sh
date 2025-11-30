#!/bin/bash
#
#********************************************************************
#Author:          wangxiaochun
#QQ:              29308620
#Date:            2020-07-22
#FileName：       install_redis.sh
#URL:             http://www.magedu.com
#Description:     The test script
#Copyright (C):   2020 All rights reserved
#********************************************************************

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
