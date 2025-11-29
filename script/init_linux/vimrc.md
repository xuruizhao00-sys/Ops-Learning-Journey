```vimrc
" ==============================================================================
" Vim Configuration for YAML + Shell Scripts
" Core Features:
" 1. YAML: 2-space indent, Tab → Space, 换行后从头开始（无自动缩进）
" 2. Shell: Auto-insert personal info + current filename when creating new .sh files
" ==============================================================================

" ==================== 全局基础设置（适配所有文件） ====================
" 编码设置（避免中文乱码）
set encoding=utf-8
set fileencodings=utf-8,gbk,gb2312,cp936
set termencoding=utf-8

" 显示设置（提升编辑体验）
set number          " 显示行号
set cursorline      " 高亮当前行
set ruler           " 显示光标位置（行号/列号）
set mouse=a         " 启用鼠标支持（终端/图形界面通用）
set scrolloff=3     " 光标上下保留3行空白，避免靠近边界
set wildmenu        " 命令行补全优化（可视化选择）
set showcmd         " 显示当前输入的命令

" 搜索设置（智能搜索）
set ignorecase      " 搜索忽略大小写
set smartcase       " 输入大写字母时自动区分大小写
set incsearch       " 实时显示搜索结果
set hlsearch        " 高亮搜索匹配项（按 <ESC> 取消高亮）
nnoremap <ESC> :nohlsearch<CR><ESC>  " 快捷键：ESC 取消搜索高亮

" ==================== YAML 专属配置（核心需求） ====================
" 针对 .yaml/.yml 文件自动应用以下设置
autocmd FileType yaml,yaml.ansible setlocal
  \ shiftwidth=2        " 缩进宽度：2 字符
  \ tabstop=2           " 制表位宽度：2 字符
  \ expandtab           " Tab 键自动转换为空格
  \ noautoindent        " 关闭自动缩进（换行后不继承上一行缩进）
  \ nosmartindent       " 关闭智能缩进（取消语法结构缩进）
  \ commentstring=#\ %s  " YAML 注释格式（# 后加空格）
  \ nofoldenable        " 禁用折叠（避免破坏 YAML 结构可视化）
  \ syntax=yaml         " 启用 YAML 语法高亮
  \ filetype=yaml       " 强制识别为 YAML 类型

" 禁止 YAML 文件使用硬制表符（严格保证 Tab → Space）
autocmd FileType yaml,yaml.ansible setlocal noexpandtab! " 覆盖全局，确保 Tab 转空格
autocmd FileType yaml,yaml.ansible autocmd BufWritePre <buffer> :%s/\t/  /ge " 保存时自动替换残留 Tab 为 2 空格

" 额外优化：YAML 中按 Enter 直接从头开始（取消任何默认缩进）
autocmd FileType yaml,yaml.ansible inoremap <CR> <CR><C-u>
" 说明：<C-u> 是清除当前行的前导空格，确保换行后光标定位到行首

" ==================== Shell 脚本配置（自动插入个人信息 + 文件名） ====================
" 当新建 .sh 文件时，自动在开头插入个人信息 + 当前文件名（YAML 格式注释）
autocmd BufNewFile *.sh call InsertShellHeader()

" 定义 Shell 头部模板函数（包含文件名、个人信息）
function! InsertShellHeader()
  " 获取当前脚本文件名（仅保留文件名，不含路径）
  let s:filename = fnamemodify(bufname('%'), ':t')

  " 插入 YAML 格式的头部信息（注释包裹，不影响脚本执行）
  call append(0, "# ==============================================================================")
  call append(1, "# script information")
  call append(2, "# filename: " . s:filename)  " 自动填充当前脚本文件名
  call append(3, "# name: xuruizhao")
  call append(4, "# email: xuruizhao00@163.com")
  call append(5, "# v: LnxGuru")
  call append(6, "# GitHub: xuruizhao00-sys")
  call append(7, "# ==============================================================================")
  call append(8, "#!/bin/bash")  " Shell 脚本执行器（必须在第一行）
  call append(9, "set -euo pipefail  # 严格模式：报错即退出，禁止未定义变量，管道错误传递")
  call append(10, "")  " 空行分隔，提升可读性

  " Shell 脚本缩进配置（保持 2 字符缩进，启用自动缩进）
  setlocal shiftwidth=2
  setlocal tabstop=2
  setlocal expandtab
  setlocal autoindent
  setlocal smartindent

  " 启用 Shell 语法高亮和文件类型识别
  setlocal syntax=sh
  setlocal filetype=sh

  " 光标定位到模板后（第 11 行），方便直接编写代码
  call cursor(11, 1)
endfunction

" ==================== 其他优化（可选） ====================
" 保存时自动去除行尾多余空格（避免 YAML/Shell 语法警告）
autocmd BufWritePre * :%s/\s\+$//e

" 自动识别文件类型（确保 YAML/Shell 配置自动生效）
filetype plugin indent on

" 禁用备份文件（避免生成 .swp/.bak 冗余文件，按需开启）
set nobackup
set nowritebackup
set noundofile
```