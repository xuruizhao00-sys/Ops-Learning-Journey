[TOC]



## 分析 nginx 日志

~~~python
[root@moudle-ubuntu python]# cat nginx_access.log 
127.0.0.1 - - [22/Nov/2024:10:00:00 +0000] "GET /index.html HTTP/1.1" 200 512
192.168.1.1 - - [22/Nov/2024:10:05:00 +0000] "POST /login HTTP/1.1" 404 1024
10.0.0.2 - - [22/Nov/2024:10:10:00 +0000] "GET /about HTTP/1.1" 200 2048
127.0.0.1 - - [22/Nov/2024:10:15:00 +0000] "GET /contact HTTP/1.1" 500 512
192.168.1.1 - - [22/Nov/2024:10:20:00 +0000] "POST /upload HTTP/1.1" 403 1024

[root@moudle-ubuntu python]# cat test.py 
import os

ip_status = {}
status_code = {}
with open("nginx_access.log","r",encoding='utf-8') as fp:
	for line in fp:
		data = line.strip().split(" ")
		ip = data[0]
		code = data[-2]
		# 判断 IP 是否存在于字典中
		if ip not in ip_status:
			ip_status[ip] = 1
		else:
			ip_status[ip] += 1
		# 判断 code 是否存在于字典中
		if code  not in ip_status:
			status_code[code] = 1
		else:
			status_code[code] += 1

# write to file
with open("./nginx_summary.txt","w",encoding='utf-8') as summary:
	summary.write("Nginx 日志分析之 IP 结果")
	for ip,count in ip_status.items():
		summary.write(f"{ip}:{count}次\n")

	summary.write("Nginx 日志分析之 status_code 结果")
	for code,count in status_code.items():
		summary.write(f"{code}:{count}次\n")

# 将字典中的数据显示在终端
print("Nginx 日志分析之 IP 结果")
for ip,conut in ip_status.items():
	print(f"{ip}:{count}次\n")

print("Nginx 日志分析之 status_code 结果")
for code,count in status_code.items():
	print(f"{code}:{count}次\n")


[root@moudle-ubuntu python]# 
e)

[root@moudle-ubuntu python]# python3 test.py
{'127.0.0.1': 2, '192.168.1.1': 2, '10.0.0.2': 1}
{'200': 1, '404': 1, '500': 1, '403': 1}

~~~

结果

~~~shell
[root@moudle-ubuntu python]# python3 test.py 
Nginx 日志分析之 IP 结果
127.0.0.1:1次

192.168.1.1:1次

10.0.0.2:1次

Nginx 日志分析之 status_code 结果
200:1次

404:1次

500:1次

403:1次

[root@moudle-ubuntu python]# cat nginx_summary.txt 
Nginx 日志分析之 IP 结果127.0.0.1:2次
192.168.1.1:2次
10.0.0.2:1次
Nginx 日志分析之 status_code 结果200:1次
404:1次
500:1次
403:1次
[root@moudle-ubuntu python]# 

~~~

# 一、Ubuntu 安装 python3

## 1.1 python 安装

```bash
apt-get update;apt install -y python3 python3-pip
┌─[root@goland] - [~] - [2025-11-11 01:37:11]
└─[0] <> python3 -V
Python 3.12.3

```

## 1.2 pip 通用配置

Windows 配置文件 ~/pip/pip.ini

Linux 配置文件 ~/.pip/pip.ini

```python
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host = mirrors.aliyun.com
```

`pip install pkgname` 命令，是按照 python 包的命令

## 1.3 安装虚拟环境

### 1.3.1 virtualenv

```python
# 安装虚拟环境
apt install -y python3-virtualenv

# 创建 python 用户
# 创建用户并指定家目录、登录shell
sudo useradd -m -d /home/python -s /bin/zsh python

# 切换用户，创建虚拟环境
sudo - python
# 创建存放虚拟环境的目录和代码项目目录
mkdir venvs 
mkdir projects/cmdb

# 创建虚拟环境
cd venvs
┌─[python@goland] - [~/venvs] - [2025-11-11 01:57:30]
└─[2] <> virtualenv vcmdb 
created virtual environment CPython3.12.3.final.0-64 in 827ms
  creator CPython3Posix(dest=/home/python/venvs/vcmdb, clear=False, no_vcs_ignore=False, global=False)
  seeder FromAppData(download=False, pip=bundle, via=copy, app_data_dir=/home/python/.local/share/virtualenv)
    added seed packages: pip==24.0
  activators BashActivator,CShellActivator,FishActivator,NushellActivator,PowerShellActivator,PythonActivator

┌─[python@goland] - [~/venvs] - [2025-11-11 01:57:45]
└─[0] <> cd vcmdb 
┌─[python@goland] - [~/venvs/vcmdb] - [2025-11-11 01:57:46]
└─[0] <> ls
bin  lib  pyvenv.cfg

# virtualenv -p 参数指定使用那个 python 环境创建
virtualenv -p /usr/bin/python3.6 v36

# Linux 
/usr/bin/python3 --> /usr/bin/python3.10 
python3 -V ===> python3.10 version
/usr/bin/python --> /usr/bin/python2.xx
	# default python3.xx
    python --> python3.xx 错误
# virtual env
virtualenv  vcmdb
activeate  vcmdb  /home/python/venvs/vcmdb/bin/python
/home/python/venvs/vcmdb/bin/python ---> /usr/bin/python3(l) ---> /usr/bin/python3.10


/home/python/venvs/vcmdb/bin/python3 ---> /home/python/venvs/vcmdb/bin/python ---> /usr/bin/python3(l) ---> /usr/bin/python3.10

# python3.8.20 
virtualenv  v3820
activeate  v3820  /home/python/venvs/vcmdb/bin/python
python
	/home/python/venvs/v3820/bin/python ---> /usr/bin/python3.8
    /home/python/venvs/v3820/bin/python3 --> /home/python/venvs/v3820/bin/python --> /usr/bin/python3.8

# 激活虚拟环境，在最前面有小括号
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 02:07:52]
└─[0] <> source ~/venvs/vcmdb/bin/activate
(vcmdb) ┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 02:09:33]
└─[0] <> python -V  
Python 3.12.3
(vcmdb) ┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 02:09:42]
└─[0] <> 
# 退出虚拟环境
(vcmdb) ┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 02:09:42]
└─[0] <> deactivate 
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 02:10:09]
└─[0] <> 
```

```python
2. $ sudo apt update

$ sudo apt install software-properties-common

3. 将Deadsnakes PPA添加到系统的来源列表中：

$ sudo add-apt-repository ppa:deadsnakes/ppa

4. 启用存储库后，请使用以下命令安装Python 3.8：

$ sudo apt install python3.8 -y

5. 通过键入以下命令验证安装是否成功：

$ python3.8 –version
```

### 1.3.2pyenv

https://github.com/pyenv/pyenv

```python
┌─[python@goland] - [~] - [2025-11-11 02:39:59]
└─[0] <> curl -fsSL https://pyenv.run | bash
正克隆到 '/home/python/.pyenv'...
remote: Enumerating objects: 1448, done.
remote: Counting objects: 100% (1448/1448), done.
remote: Compressing objects: 100% (726/726), done.
remote: Total 1448 (delta 903), reused 892 (delta 589), pack-reused 0 (from 0)
接收对象中: 100% (1448/1448), 1.17 MiB | 2.17 MiB/s, 完成.
处理 delta 中: 100% (903/903), 完成.
正克隆到 '/home/python/.pyenv/plugins/pyenv-doctor'...
remote: Enumerating objects: 11, done.
remote: Counting objects: 100% (11/11), done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 11 (delta 1), reused 5 (delta 0), pack-reused 0 (from 0)
接收对象中: 100% (11/11), 38.72 KiB | 179.00 KiB/s, 完成.
处理 delta 中: 100% (1/1), 完成.
正克隆到 '/home/python/.pyenv/plugins/pyenv-update'...
remote: Enumerating objects: 10, done.
remote: Counting objects: 100% (10/10), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 10 (delta 1), reused 5 (delta 0), pack-reused 0 (from 0)
接收对象中: 100% (10/10), 完成.
处理 delta 中: 100% (1/1), 完成.
正克隆到 '/home/python/.pyenv/plugins/pyenv-virtualenv'...
remote: Enumerating objects: 64, done.
remote: Counting objects: 100% (64/64), done.
remote: Compressing objects: 100% (57/57), done.
remote: Total 64 (delta 10), reused 23 (delta 0), pack-reused 0 (from 0)
接收对象中: 100% (64/64), 43.19 KiB | 230.00 KiB/s, 完成.
处理 delta 中: 100% (10/10), 完成.

WARNING: seems you still have not added 'pyenv' to the load path.

# Load pyenv automatically by appending
# the following to 
# ~/.bash_profile if it exists, otherwise ~/.profile (for login shells)
# and ~/.bashrc (for interactive shells) :

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

# Restart your shell for the changes to take effect.

# Load pyenv-virtualenv automatically by adding
# the following to ~/.bashrc:

eval "$(pyenv virtualenv-init -)"

┌─[python@goland] - [~] - [2025-11-11 02:40:28]
└─[0] <> echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc
┌─[python@goland] - [~] - [2025-11-11 02:40:49]
└─[0] <> 

```

```python
# 安装依赖
sudo apt update
sudo apt install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    git

这些依赖包括：
libssl-dev：解决_ssl模块缺失问题
libbz2-dev：解决_bz2模块缺失问题
libncurses5-dev和libncursesw5-dev：解决_curses模块缺失问题
libffi-dev：解决_ctypes模块缺失问题
libreadline-dev：解决readline模块缺失问题


# 安装 python 解释器
┌─[python@goland] - [~] - [2025-11-11 03:47:20]
└─[0] <> pyenv install 3.8.8
Downloading Python-3.8.8.tar.xz...
-> https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tar.xz
Installing Python-3.8.8...
patching file Misc/NEWS.d/next/Build/2021-10-11-16-27-38.bpo-45405.iSfdW5.rst
patching file configure
patching file configure.ac
Installed Python-3.8.8 to /home/python/.pyenv/versions/3.8.8
┌─[python@goland] - [~] - [2025-11-11 04:07:41]
└─[0] <> pyenv   install 3.10.12
Downloading Python-3.10.12.tar.xz...
-> https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tar.xz
Installing Python-3.10.12...
Installed Python-3.10.12 to /home/python/.pyenv/versions/3.10.12
# 下载 python 版本
pyenv uninstall 3.5.2

# 查看可用的 python 版本
# pyenv versions 查看所有版本
# pyenv version 查看当前的版本
┌─[python@goland] - [~] - [2025-11-11 03:54:48]
└─[0] <> pyenv versions     
* system (set by /home/python/.pyenv/version)
  3.8.8
┌─[python@goland] - [~] - [2025-11-11 03:55:29]
└─[0] <> pyenv version 
system (set by /home/python/.pyenv/version)


# 切换版本
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 03:58:14]
└─[0] <> pyenv local 3.8.8
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 03:58:25]
└─[0] <> python3 -V       
Python 3.12.3
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 03:58:31]
└─[0] <> python -V  
Python 3.8.8
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 03:58:51]
└─[0] <>

# 子目录会继承当前的版本
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 03:59:41]
└─[0] <> mkdir a/b -pv
mkdir: 已创建目录 'a'
mkdir: 已创建目录 'a/b'
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 03:59:45]
└─[0] <> cd a            
┌─[python@goland] - [~/projects/cmdb/a] - [2025-11-11 03:59:48]
└─[0] <> python -V
Python 3.8.8
┌─[python@goland] - [~/projects/cmdb/a] - [2025-11-11 03:59:51]
└─[0] <> cd b     
┌─[python@goland] - [~/projects/cmdb/a/b] - [2025-11-11 03:59:56]
└─[0] <> python -V
Python 3.8.8
┌─[python@goland] - [~/projects/cmdb/a/b] - [2025-11-11 03:59:58]
└─[0] <> cd ~/projects         
┌─[python@goland] - [~/projects] - [2025-11-11 04:00:11]
└─[127] <> python3 -V
Python 3.12.3
┌─[python@goland] - [~/projects] - [2025-11-11 04:00:17]
└─[0] <> 

```

```python
# 创建虚拟环境
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:22:47]
└─[0] <> pyenv virtualenv 3.8.8 v388
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:23:06]
└─[130] <> pyenv local 3.10.12
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:23:12]
└─[0] <> python -V          
Python 3.10.12
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:23:15]
└─[0] <> pyenv local v388   
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:23:28]
└─[0] <> python -V       
Python 3.8.8
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:23:30]
└─[0] <> pyenv virtualenv 3.10.12 v31012
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:24:37]
└─[0] <> pyenv local v31012             
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:24:51]
└─[0] <> python -V         
Python 3.10.12

# 激活虚拟环境
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:25:03]
└─[0] <> pyenv activate v31012
(v31012) ┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:27:19]
└─[0] <>

# 停止当前的虚拟环境
(v31012) ┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:27:19]
└─[0] <> pyenv deactivate v31012
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:28:16]
└─[0] <> 

# 删除虚拟环境
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:28:16]
└─[0] <> pyenv virtualenv-delete v388   
pyenv-virtualenv: remove /home/python/.pyenv/versions/3.8.8/envs/v388? (y/N) y
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:28:57]
└─[0] <> 
┌─[python@goland] - [~/projects/cmdb] - [2025-11-11 04:28:57]
└─[0] <> pyenv versions              
  system
  3.8.8
  3.10.12
  3.10.12/envs/v31012
* v31012 --> /home/python/.pyenv/versions/3.10.12/envs/v31012 (set by/home/python/projects/cmdb/.python-version)
```

# 二、python 基础

## 2.1 python 解释器

| 解释器      | 说明                                                         |
| ----------- | ------------------------------------------------------------ |
| **CPython** | 官方，C 语言开发，最广泛的 python 解释器                     |
| IPython     | 交互式、功能增强的 Cpython                                   |
| PyPy        | python 语言编写的 python 解释器                              |
| Jython      | python 的源代码编译成 Java 字节码，跑在 JVM 上               |
| IronPython  | 与 Jyphon 类似，运行在 .Net 平台的解释器，python 的源代码编译成  .Net 字节码 |
| stackless   | Python 的增强版解释器，不使用 CPython 的 C 的栈，采用微线程概念编程，并发编程 |

## 2.2 基础语法

### 2.2.1 注释

```python
# 我是注释
```

### 2.2.2 数字

- 整数 int
  - python3 开始不再区分 long、int，long 被重命名为 int，所以只有 int 类型
  - 进制表示
    - 十进制 10
    - 十六进制 0x10
    - 八进制 0o10
    - 二进制 0b10
  - bool 类型 True False
- 浮点数 float
  - 精度问题
  - 本质上使用了 C 的 double 类型
- 复数 complex

### 2.2.3 字符串

- 使用 '' 单引号引用的字符序列
- ''' 和 """ 单双三引号可以跨行、可以在其中自由的使用单双引号
- r 前缀：在字符串前面加上 r 或者 R 前缀，表示该字符串不做特殊处理
- f 前缀：3.6 版本开始，新增 f 前缀，格式化字符串

```python
print('aaa',"aaa",'''aaa''',"""aaa""")
print('a"a',"a'a","""a''a""",'''"""aaa"""''')
# 转义字符：\ + 字符
# ' 是界定符，\' 表示单引号
print('''aaa\'''')
# output
aaa aaa aaa aaa
a"a a'a a''a """aaa"""
aaa'
```

**字符串拼接**

```python
print(str(1)+'a'+','+'b')

# output
1a,b
```

**转义字符**

让字符不再显示他当前的意义，例如：\t t 就不再是当前意义字符 t 了，而是被转成了 tab 键

转义字符只表示一个字符

```
\n：换行 Linux
\t：tab，向右偏移 4或8 个字符
\r：mac 中换行
\r\n：回车换行 windows 2 个字符
\\：转义转义字符
```

```python
print("\\")
print(r"\n")

# output
\
\n
```

取消转义字符含义

```python
print(r"D:\新建文件夹\OneDrive\桌面\Linux\xuruizhao")
D:\新建文件夹\OneDrive\桌面\Linux\xuruizhao

r"string"
# 取消 string 中所有的转义字符

```

字符串格式化

```python
a = 1
b = 2
print(f"{a}+{b}={a+b}")
print("{}+{}={}".format(a,b,a+b))
# output
1+2=3
1+2=3


```



### 2.2.4 缩进

- 未使用花括号，采用缩进的方式来表示层级
- 约定使用 4 个空格缩进

### 2.2.5 续行

- 在行尾使用 \ ，注意 \ 之后除了紧跟着换行之外不能有其他字符
- 如果使用括号，认为括号内是一个整体，其内部跨行不用 \

### 2.2.6 标识符

1. 一个名字，用来指代一个值

2. 只能是字母、下划线和数字

3. 只能以字母或下划线开头
4. 不能是python的关键字，例如def、 class就不能作为标识符

5. Python是大小写敏感的

标识符约定: 

- 不允许使用中文
- 也不建议使用拼音
- 不要使用岐义单词，例如class 
- 在python中不要随便使用下划线开头的标识符

**常量**

- 一旦赋值就不能改变值的标识符
- python 中 无法定义常量

**字面常量**

一个单独的不可变量，例如 12 "abc" 

**变量**

赋值后可以改变的量

**标识符的本质**

每一个标识符对应一个具有数据结构的值，但是这个值不方便直接访问，程序员就可以通过其对应的标识符来访问数据，标识符就是一个指代。一句话，标识符是给程序员编程使用的

**类型注解**

3.6 后支持，非强制性限制

```python
c = 3
c:int = 4
print(c)
c = "aaa"
print(c)
# output
4
aaa
```

### 2.2.7、基础类型实战

#### 1. 数值类型（int/float/complex）

```python
# 整数（无大小限制）
a = 10
b = -20
c = 0x1A  # 十六进制（26）
print(a + b)  # 输出：-10
print(c * 2)  # 输出：52

# 浮点数（注意精度问题）
d = 3.14
e = 1.2e3  # 科学计数法（1200.0）
print(d + e)  # 输出：1203.14
print(0.1 + 0.2)  # 避坑：浮点数精度问题，输出 0.30000000000000004
print(round(0.1 + 0.2, 2))  # 解决：保留2位小数，输出 0.3

# 复数
f = 2 + 3j
g = -1j
print(f + g)  # 输出：(2+2j)
print(f.real)  # 实部：2.0
print(f.imag)  # 虚部：3.0
```

#### 2. 字符串类型（str）

```python
s = "  Python 3.12  "

# 索引与切片
print(s[0])  # 输出：空格（第一个字符）
print(s[1:7])  # 输出：Python（左闭右开）
print(s[-2:])  # 输出：空格（最后两个字符）

# 拼接与重复
print("Hello" + " " + "World")  # 输出：Hello World
print("a" * 3)  # 输出：aaa

# 常用方法
print(s.strip())  # 去首尾空格：Python 3.12
print(s.upper())  # 转大写：  PYTHON 3.12
print(s.split())  # 分割字符串：['Python', '3.12']
print(s.replace("Python", "Java"))  # 替换：  Java 3.12

# 避坑：字符串不可变
# s[0] = "x"  # 报错：TypeError: 'str' object does not support item assignment
```

#### 3. 布尔类型（bool）与空类型（NoneType）

```python
# 布尔类型
print(3 > 2)  # 输出：True
print(True and False)  # 逻辑与：False
print(True or False)  # 逻辑或：True
print(not True)  # 逻辑非：False

# 布尔与整数的关系（不推荐直接使用）
print(True == 1)  # 输出：True
print(False == 0)  # 输出：True

# 空类型
x = None
print(x is None)  # 推荐：判断空值，输出 True
print(x == None)  # 不推荐：结果相同，但可读性差
```

------

### 2.2.8、复合类型实战

#### 1. 列表（list）

```python
lst = [1, "a", 3.14, [4, 5]]  # 支持嵌套

# 增删改查
lst.append(6)  # 末尾添加：[1, 'a', 3.14, [4, 5], 6]
lst.insert(1, "b")  # 指定位置插入：[1, 'b', 'a', 3.14, [4, 5], 6]
lst.pop()  # 删除末尾元素：6，列表变为 [1, 'b', 'a', 3.14, [4, 5]]
lst.remove("a")  # 删除指定值：[1, 'b', 3.14, [4, 5]]

# 切片与排序
print(lst[1:3])  # 输出：['b', 3.14]
print(sorted([3, 1, 2]))  # 临时排序：[1, 2, 3]

# 列表推导式（高效创建列表）
squares = [x * x for x in range(5)]  # 输出：[0, 1, 4, 9, 16]
even_squares = [x * x for x in range(5) if x % 2 == 0]  # 带条件：[0, 4, 16]

# 避坑：列表可变，赋值传递引用
lst1 = [1, 2, 3]
lst2 = lst1  # 引用传递，不是复制
lst2.append(4)
print(lst1)  # 输出：[1, 2, 3, 4]（lst1 也被修改）
# 解决：创建副本
lst3 = lst1.copy()  # 或 lst3 = lst1[:]
lst3.append(5)
print(lst1)  # 输出：[1, 2, 3, 4]（lst1 不受影响）
```

#### 2. 元组（tuple）

```python
# 定义（单个元素必须加逗号）
t1 = (1, 2, 3)
t2 = (4,)  # 正确：单个元素元组
t3 = 5, 6, 7  # 省略括号也可以

# 索引与切片（同列表）
print(t1[0])  # 输出：1
print(t1[1:3])  # 输出：(2, 3)

# 避坑：元组不可变
# t1[0] = 10  # 报错：TypeError: 'tuple' object does not support item assignment

# 元组推导式（生成器表达式）
t4 = tuple(x * 2 for x in range(3))  # 输出：(0, 2, 4)
```

#### 3. 字典（dict）

```python
# 定义（键必须是不可变类型）
d = {"name": "张三", "age": 20, "score": {"math": 90, "english": 85}}

# 增删改查
d["gender"] = "男"  # 新增键值对
d["age"] = 21  # 修改值
print(d["name"])  # 输出：张三（通过键取值）
print(d.get("score", {}).get("math"))  # 安全取值：90（避免键不存在报错）

# 遍历字典
for key in d:
    print(key, d[key])  # 输出键和值
for key, value in d.items():
    print(key, value)  # 更简洁的遍历

# 字典推导式
d2 = {x: x * x for x in range(5)}  # 输出：{0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# 避坑：键必须不可变
# d[[1, 2]] = "list"  # 报错：TypeError: unhashable type: 'list'
```

#### 4. 集合（set）

```python
# 定义（空集合必须用 set()）
s1 = {1, 2, 3, 3}  # 自动去重：{1, 2, 3}
s2 = set([4, 5, 6])
s3 = set()  # 空集合

# 增删操作
s1.add(4)  # 添加元素：{1, 2, 3, 4}
s1.remove(2)  # 删除元素：{1, 3, 4}
s1.discard(5)  # 安全删除（元素不存在不报错）

# 集合运算
print(s1 & s2)  # 交集：{}（无共同元素）
print(s1 | s2)  # 并集：{1, 3, 4, 5, 6}
print(s1 - s2)  # 差集：{1, 3, 4}

# 集合推导式
s4 = {x for x in range(10) if x % 2 == 1}  # 奇数集合：{1, 3, 5, 7, 9}

# 避坑：集合无序
print(s1)  # 输出顺序不固定（如 {1, 3, 4} 或 {3, 1, 4}）
```

### 2.2.9、关键特性实战

#### 1. 可变类型 vs 不可变类型

```python
# 不可变类型（str、int、tuple）
a = "hello"
b = a
a = a + " world"  # 创建新对象
print(b)  # 输出：hello（b 仍指向原对象）

# 可变类型（list、dict、set）
lst = [1, 2, 3]
lst2 = lst
lst.append(4)  # 修改原对象
print(lst2)  # 输出：[1, 2, 3, 4]（lst2 也指向原对象）
```

#### 2. 类型判断与转换

```python
# 类型判断
print(type(10) == int)  # 输出：True
print(isinstance(10, int))  # 输出：True（推荐，支持继承）
print(isinstance(10, float))  # 输出：False

# 类型转换
print(int("123"))  # 字符串转整数：123
print(float(10))  # 整数转浮点数：10.0
print(str(3.14))  # 浮点数转字符串："3.14"
print(list((1, 2, 3)))  # 元组转列表：[1, 2, 3]
print(tuple([1, 2, 3]))  # 列表转元组：(1, 2, 3)
```

Python 逻辑运算的核心是**布尔值（`True`/`False`）**，以及**与（`and`）、或（`or`）、非（`not`）** 三个关键字。

### 2.2.10 逻辑运算符

#### 2.2.10.1 逻辑运算符

##### 2.2.10.1.1 `and`（与）

- **定义**：所有条件都为 `True` 时，结果才为 `True`。
- **真值表**：

| a    | b    | a and b |
| ---- | ---- | ------- |
| T    | T    | T       |
| T    | F    | F       |
| F    | T    | F       |
| F    | F    | F       |

- **示例**：

```python
print(True and True)   # True
print(True and False)  # False
print(5 > 3 and 3 > 1) # True
print(5 > 3 and 3 > 5) # False
```

##### 2.2.10.1.2 `or`（或）

- **定义**：至少一个条件为 `True` 时，结果就为 `True`。
- **真值表**：

| a    | b    | a or b |
| ---- | ---- | ------ |
| T    | T    | T      |
| T    | F    | T      |
| F    | T    | T      |
| F    | F    | F      |

- **示例**：

```python
print(True or True)   # True
print(True or False)  # True
print(5 > 3 or 3 > 1) # True
print(5 > 3 or 3 > 5) # True
print(5 < 3 or 3 > 5) # False
```

##### 2.2.10.1.3 `not`（非）

- **定义**：取反，`True` 变 `False`，`False` 变 `True`。
- **真值表**：

| a    | not a |
| ---- | ----- |
| T    | F     |
| F    | T     |

- **示例**：

```python
print(not True)   # False
print(not False)  # True
print(not (5 > 3)) # False
```

------

#### 2.2.10.2 短路求值（Short-circuit Evaluation）

Python 的逻辑运算具有**短路特性**，即如果通过前面的条件就能确定最终结果，就不会再计算后面的条件。

##### 2.2.10.2.1 `and` 的短路

- 如果第一个条件为 `False`，则结果必定为 `False`，不再计算第二个条件。

```python
def f():
    print("函数 f 被调用了")
    return False

def g():
    print("函数 g 被调用了")
    return True

print(f() and g())
# 输出：
# 函数 f 被调用了
# False
# （函数 g 没有被调用）
```

##### 2.2.10.2.2  `or` 的短路

- 如果第一个条件为 `True`，则结果必定为 `True`，不再计算第二个条件。

```python
def f():
    print("函数 f 被调用了")
    return True

def g():
    print("函数 g 被调用了")
    return False

print(f() or g())
# 输出：
# 函数 f 被调用了
# True
# （函数 g 没有被调用）
```

------

#### 2.2.10.3 优先级

逻辑运算符的优先级从高到低为：`not` > `and` > `or`。

```python
print(not True or False and True)
# 等价于：(not True) or (False and True)
# 结果：False
```

------

#### 2.2.10.4 常见用法

##### 2.2.10.4.1 条件判断

```python
age = 20
is_student = True

if age > 18 and is_student:
    print("成年学生")
else:
    print("不符合条件")
```

##### 2.2.10.4.2 变量赋值

```python
a = 5
b = 10

max_val = a if a > b else b
print(max_val)  # 10

# 等价于：
max_val = a > b and a or b
```

##### 2.2.10.4.3 过滤数据

```python
nums = [1, 2, 3, 4, 5, 6]
even_nums = [x for x in nums if x % 2 == 0]
print(even_nums)  # [2, 4, 6]
```

------

#### 2.2.10.5 注意事项

1. **布尔值与其他类型的转换**：

   - `0`、`""`、`[]`、`{}`、`None` 等被视为 `False`。
   - 非 `0` 数字、非空字符串、非空列表等被视为 `True`。

   ```python
   print(bool(0))      # False
   print(bool(""))     # False
   print(bool([]))     # False
   print(bool(1))      # True
   print(bool("hello"))# True
   ```

   

2. **避免滥用 `and`/`or` 代替 `if-else`**：

   - 简单场景可以使用，但复杂逻辑建议用 `if-else`，可读性更高。

3. **`is` 与 `==` 的区别**：

   - `is` 判断两个对象是否是同一个（内存地址相同）。
   - `==` 判断两个对象的值是否相等。

   ```python
   a = [1, 2, 3]
   b = a
   c = [1, 2, 3]
   
   print(a is b)  # True
   print(a is c)  # False
   print(a == c)  # True
   ```

   

------

#### 2.2.10.6 总结

- 逻辑运算的核心是 `True`/`False`。
- `and`：全真才真，有假则假（短路）。
- `or`：有真则真，全假才假（短路）。
- `not`：取反。
- 优先级：`not` > `and` > `or`。
- 常见用法：条件判断、变量赋值、过滤数据。
- 注意：布尔值转换、可读性、`is` 与 `==` 的区别。

### 2.2.11 运算符

Python 3.12.3 的运算符按功能可分为 **算术运算、比较运算、赋值运算、逻辑运算、位运算、成员运算、身份运算** 七大类，核心是掌握运算符的优先级和用法，以下是系统梳理和实战代码。

------

#### 2.2.11.1 算术运算符

| 运算符 | 描述                 | 示例                |
| ------ | -------------------- | ------------------- |
| `+`    | 加法                 | `3 + 5 = 8`         |
| `-`    | 减法                 | `10 - 4 = 6`        |
| `*`    | 乘法                 | `2 * 6 = 12`        |
| `/`    | 除法（结果为浮点数） | `10 / 3 = 3.333...` |
| `//`   | 整除（向下取整）     | `10 // 3 = 3`       |
| `%`    | 取模（求余数）       | `10 % 3 = 1`        |
| `**`   | 幂运算               | `2 ** 3 = 8`        |
| `-`    | 负号                 | `-5`                |
| `+`    | 正号                 | `+3`                |

**实战代码：**

```python
a = 10
b = 3

print(a + b)   # 输出：13
print(a - b)   # 输出：7
print(a * b)   # 输出：30
print(a / b)   # 输出：3.3333333333333335
print(a // b)  # 输出：3（整除）
print(a % b)   # 输出：1（余数）
print(a ** b)  # 输出：1000（10的3次方）
print(-a)      # 输出：-10
print(+b)      # 输出：3
```

------

#### 2.2.11.2 比较运算符

| 运算符 | 描述     | 示例             |
| ------ | -------- | ---------------- |
| `==`   | 等于     | `3 == 5 → False` |
| `!=`   | 不等于   | `3 != 5 → True`  |
| `>`    | 大于     | `3 > 5 → False`  |
| `<`    | 小于     | `3 < 5 → True`   |
| `>=`   | 大于等于 | `3 >= 3 → True`  |
| `<=`   | 小于等于 | `3 <= 2 → False` |

**实战代码：**

```python
x = 5
y = 5
z = 3

print(x == y)  # 输出：True
print(x != z)  # 输出：True
print(x > z)   # 输出：True
print(x < z)   # 输出：False
print(x >= y)  # 输出：True
print(x <= z)  # 输出：False
```

------

#### 2.2.11.3 赋值运算符

| 运算符 | 描述     | 示例                   |
| ------ | -------- | ---------------------- |
| `=`    | 简单赋值 | `a = 10`               |
| `+=`   | 加法赋值 | `a += 5 → a = a + 5`   |
| `-=`   | 减法赋值 | `a -= 3 → a = a - 3`   |
| `*=`   | 乘法赋值 | `a *= 2 → a = a * 2`   |
| `/=`   | 除法赋值 | `a /= 4 → a = a / 4`   |
| `//=`  | 整除赋值 | `a //= 3 → a = a // 3` |
| `%=`   | 取模赋值 | `a %= 5 → a = a % 5`   |
| `**=`  | 幂赋值   | `a **= 2 → a = a ** 2` |

**实战代码：**

```python
a = 10

a += 5
print(a)  # 输出：15

a -= 3
print(a)  # 输出：12

a *= 2
print(a)  # 输出：24

a /= 4
print(a)  # 输出：6.0

a //= 3
print(a)  # 输出：2.0

a %= 5
print(a)  # 输出：2.0

a **= 2
print(a)  # 输出：4.0
```

------

#### 2.2.11.4 位运算符

| 运算符 | 描述     | 示例（二进制）        |      |            |
| ------ | -------- | --------------------- | ---- | ---------- |
| `&`    | 按位与   | `101 & 011 = 001`     |      |            |
| `      | `        | 按位或                | `101 | 011 = 111` |
| `^`    | 按位异或 | `101 ^ 011 = 110`     |      |            |
| `~`    | 按位取反 | `~101 = -110`（补码） |      |            |
| `<<`   | 左移     | `101 << 1 = 1010`     |      |            |
| `>>`   | 右移     | `101 >> 1 = 010`      |      |            |

**实战代码：**

```python
a = 5    # 二进制：101
b = 3    # 二进制：011

print(a & b)   # 输出：1（001）
print(a | b)   # 输出：7（111）
print(a ^ b)   # 输出：6（110）
print(~a)      # 输出：-6（补码：...11111010）
print(a << 1)  # 输出：10（1010，左移1位=×2）
print(a >> 1)  # 输出：2（010，右移1位=÷2取整）
```

------

#### 2.2.11.5 成员运算符

| 运算符   | 描述           | 示例                      |
| -------- | -------------- | ------------------------- |
| `in`     | 是否在序列中   | `3 in [1,2,3] → True`     |
| `not in` | 是否不在序列中 | `4 not in [1,2,3] → True` |

**实战代码：**

```python
lst = [1, 2, 3, 4]
s = "Python"

print(3 in lst)        # 输出：True
print(5 not in lst)    # 输出：True
print("y" in s)        # 输出：True
print("z" not in s)    # 输出：True
```

------

#### 2.2.11.6 身份运算符

| 运算符   | 描述                             | 示例         |
| -------- | -------------------------------- | ------------ |
| `is`     | 是否是同一个对象（内存地址相同） | `a is b`     |
| `is not` | 是否不是同一个对象               | `a is not b` |

**注意：**

- `==` 比较值是否相等
- `is` 比较内存地址是否相同

**实战代码：**

```python
a = [1, 2, 3]
b = a          # 引用同一对象
c = [1, 2, 3]  # 新对象，值相同但地址不同

print(a is b)      # 输出：True
print(a is c)      # 输出：False
print(a == c)      # 输出：True
print(a is not c)  # 输出：True
```

------

#### 2.2.11.7 运算符优先级（从高到低）

1. **括号** `()`
2. **幂运算** `**`
3. **位取反** `~`、**正负号** `+/-`
4. **算术运算** `*`、`/`、`//`、`%`
5. **算术运算** `+`、`-`
6. **位运算** `<<`、`>>`
7. **位运算** `&`
8. **位运算** `^`
9. **位运算** `|`
10. **比较运算** `==`、`!=`、`>`、`<`、`>=`、`<=`
11. **身份运算** `is`、`is not`
12. **成员运算** `in`、`not in`
13. **逻辑运算** `not`
14. **逻辑运算** `and`
15. **逻辑运算** `or`

**实战代码：**

```python
# 优先级示例：先乘除后加减，逻辑运算最后
print(2 + 3 * 4)          # 输出：14（3*4=12，2+12=14）
print(True or False and False)  # 输出：True（and优先级高于or，先算False and False=False，再算True or False=True）
print((2 + 3) * 4)        # 输出：20（括号改变优先级）
```

------

#### 2.2.11.8 总结

- 算术运算：用于数值计算
- 比较运算：返回布尔值，用于条件判断
- 赋值运算：简化变量更新
- 逻辑运算：布尔值逻辑判断，有短路特性
- 位运算：直接操作二进制位，效率高
- 成员运算：判断元素是否在序列中
- 身份运算：判断对象是否同一
- 优先级：括号最高，逻辑运算最低，遵循 “先乘除后加减”

### 2.2.12 常见内建函数

#### 2.2.12.1 类型转换函数

| 函数       | 功能                                                         | 示例                                        |
| ---------- | ------------------------------------------------------------ | ------------------------------------------- |
| `int(x)`   | 将 x 转换为整数                                              | `int("123") → 123`                          |
| `float(x)` | 将 x 转换为浮点数                                            | `float("3.14") → 3.14`                      |
| `str(x)`   | 将 x 转换为字符串<br />在 python 中可以将任何类型转为 string | `str(123) → "123"`                          |
| `bool(x)`  | 将 x 转换为布尔值                                            | `bool(0) → False`                           |
| `list(x)`  | 将 x 转换为列表                                              | `list((1,2,3)) → [1,2,3]`                   |
| `tuple(x)` | 将 x 转换为元组                                              | `tuple([1,2,3]) → (1,2,3)`                  |
| `set(x)`   | 将 x 转换为集合                                              | `set([1,2,2]) → {1,2}`                      |
| `dict(x)`  | 将 x 转换为字典                                              | `dict([("a",1), ("b",2)]) → {"a":1, "b":2}` |

**实战代码：**

```python
print(int("100"))       # 100
print(float(20))        # 20.0
print(str(3.14))        # "3.14"
print(bool("hello"))    # True
print(list("abc"))      # ['a', 'b', 'c']
print(tuple([1,2,3]))   # (1, 2, 3)
print(set("aabbcc"))    # {'a', 'b', 'c'}
print(dict(a=1, b=2))   # {'a': 1, 'b': 2}
```

------

#### 2.2.12.2 数值运算函数

| 函数               | 功能             | 示例                     |
| ------------------ | ---------------- | ------------------------ |
| `abs(x)`           | 返回 x 的绝对值  | `abs(-5) → 5`            |
| `max(x1, x2, ...)` | 返回最大值       | `max(1,3,5) →5`          |
| `min(x1, x2, ...)` | 返回最小值       | `min(1,3,5) →1`          |
| `sum(iterable)`    | 求和             | `sum([1,2,3]) →6`        |
| `pow(x, y)`        | 计算 x 的 y 次方 | `pow(2,3) →8`            |
| `round(x, n)`      | 四舍五入         | `round(3.1415, 2) →3.14` |

**实战代码：**

```python
print(abs(-10))                # 10
print(max([5, 8, 2, 10]))      # 10
print(min(3, 1, 4, 1, 5))      # 1
print(sum(range(1, 101)))       # 5050（1到100求和）
print(pow(3, 4))               # 81
print(round(2.675, 2))         # 2.67（注意浮点数精度问题）
```

------

#### 2.2.12.3 序列操作函数

| 函数              | 功能             | 示例                                              |
| ----------------- | ---------------- | ------------------------------------------------- |
| `len(seq)`        | 返回序列长度     | `len([1,2,3]) →3`                                 |
| `sorted(seq)`     | 排序并返回新列表 | `sorted([3,1,2]) →[1,2,3]`                        |
| `reversed(seq)`   | 反转并返回迭代器 | `list(reversed([1,2,3])) →[3,2,1]`                |
| `enumerate(seq)`  | 返回索引和元素   | `list(enumerate(["a","b"])) →[(0,"a"), (1,"b")]`  |
| `zip(seq1, seq2)` | 打包成元组       | `list(zip([1,2], ["a","b"])) →[(1,"a"), (2,"b")]` |

**实战代码：**

```python
lst = ["apple", "banana", "cherry"]
print(len(lst))                      # 3
print(sorted(lst, key=len))          # ['apple', 'cherry', 'banana']（按长度排序）
print(list(reversed(lst)))           # ['cherry', 'banana', 'apple']

for idx, item in enumerate(lst):
    print(f"{idx}: {item}")          # 0: apple, 1: banana, 2: cherry

keys = ["a", "b", "c"]
values = [1, 2, 3]
print(dict(zip(keys, values)))       # {'a': 1, 'b': 2, 'c': 3}
```

------

#### 2.2.12.4 输入输出函数

| 函数            | 功能         | 示例                           |
| --------------- | ------------ | ------------------------------ |
| `print(*args)`  | 打印输出     | `print("Hello", "World")`      |
| `input(prompt)` | 读取用户输入 | `name = input("请输入姓名：")` |

**实战代码：**

```python
print("Hello", "Python", sep=" - ")  # Hello - Python（自定义分隔符）
print("结束", end="\n\n")            # 自定义结束符

name = input("请输入你的名字：")
print(f"你好，{name}!")               # 你好，张三!
```

------

#### 2.2.12.5 集合操作函数

| 函数                     | 功能                    | 示例                                           |
| ------------------------ | ----------------------- | ---------------------------------------------- |
| `all(iterable)`          | 所有元素为真则返回 True | `all([True, 1, "a"]) →True`                    |
| `any(iterable)`          | 任一元素为真则返回 True | `any([False, 0, ""]) →False`                   |
| `filter(func, iterable)` | 过滤元素                | `list(filter(lambda x: x%2==0, [1,2,3])) →[2]` |
| `map(func, iterable)`    | 映射元素                | `list(map(lambda x: x*2, [1,2,3])) →[2,4,6]`   |

**实战代码：**

```python
print(all([1, 2, 3]))                # True
print(any([0, "", None]))            # False

nums = [1, 2, 3, 4, 5]
even_nums = list(filter(lambda x: x % 2 == 0, nums))
print(even_nums)                     # [2, 4]

doubled = list(map(lambda x: x * 2, nums))
print(doubled)                       # [2, 4, 6, 8, 10]
```

------

#### 2.2.12.6 对象操作函数

| 函数                   | 功能                   | 示例                         |
| ---------------------- | ---------------------- | ---------------------------- |
| `id(obj)`              | 返回对象内存地址       | `id("hello")`                |
| `type(obj)`            | 返回对象类型           | `type(123) →int`             |
| `isinstance(obj, cls)` | 判断对象是否为类的实例 | `isinstance(123, int) →True` |

**实战代码：**

```python
s = "Python"
print(id(s))                         # 输出内存地址（示例：140708242258352）
print(type(s))                       # <class 'str'>
print(isinstance(s, str))            # True
print(isinstance(s, (str, int)))     # True（判断是否为多个类中的一个）
```

```python
# type 是元类
# 元类就是构造类的类
type(str)
<class 'type'>

type(type)
<class 'type'>
```



------

#### 2.2.12.7 其他常用函数

| 函数                       | 功能                    | 示例                                 |
| -------------------------- | ----------------------- | ------------------------------------ |
| `range(start, stop, step)` | 生成整数序列            | `list(range(1, 10, 2)) →[1,3,5,7,9]` |
| `chr(i)`                   | 返回 Unicode 字符       | `chr(65) →"A"`                       |
| `ord(c)`                   | 返回字符的 Unicode 编码 | `ord("A") →65`                       |
| `help(obj)`                | 查看对象帮助信息        | `help(str)`                          |

**实战代码：**

```python
print(list(range(5)))                # [0, 1, 2, 3, 4]
print(chr(97))                       # 'a'
print(ord("中"))                     # 20013
help(str.split)                      # 查看字符串 split 方法的帮助文档
```

------

#### 2.2.12.8 总结

- **类型转换**：`int()`、`str()`、`list()` 等
- **数值运算**：`max()`、`min()`、`sum()`、`round()`
- **序列操作**：`len()`、`sorted()`、`enumerate()`、`zip()`
- **输入输出**：`print()`、`input()`
- **集合操作**：`all()`、`any()`、`filter()`、`map()`
- **对象操作**：`id()`、`type()`、`isinstance()`
- **其他**：`range()`、`chr()`、`ord()`、`help()`

