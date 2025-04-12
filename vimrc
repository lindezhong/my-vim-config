" 使用 :PlugInstall 安装插件, :PlugUpdate 更新插件 
call plug#begin('~/.vim/plugged')
" 查找文件插件
Plug 'Yggdroot/LeaderF'
" auto-pairs配置(自动匹配括号) jiangmiao/auto-pairs
" 自动各种括号补齐, 但在vim-session恢复的时候有bug, 去除掉
" Plug 'jiangmiao/auto-pairs'
" coc.nvim 提供vscode的vim移植
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" NerdCommenter配置(生成注释) preservim/nerdcommenter
" count\cc 注释 count默认1
" count\cu 取消注释 count默认1
" count\ci 注释，取消注释 count默认1
Plug 'preservim/nerdcommenter'
" NERDTree配置(目录树) preservim/nerdtree
" 目录树的使用主要通过在vim的command模式下键入如下命令，即可达到相应的效果。
" ?: 快速帮助文档
" o: 打开一个目录或者打开文件，创建的是 buffer，也可以用来打开书签
" go: 打开一个文件，但是光标仍然留在 NERDTree，创建的是 buffer
" t: 打开一个文件，创建的是Tab，对书签同样生效
" T: 打开一个文件，但是光标仍然留在 NERDTree，创建的是 Tab，对书签同样生效
" i: 水平分割创建文件的窗口，创建的是 buffer
" gi: 水平分割创建文件的窗口，但是光标仍然留在 NERDTree
" s: 垂直分割创建文件的窗口，创建的是 buffer
" gs: 和 gi，go 类似
" x: 收起当前打开的目录
" X: 收起所有打开的目录
" e: 以文件管理的方式打开选中的目录
" D: 删除书签
" m: 文件操作,新增文件/文件夹，删除文件/文件夹
Plug 'preservim/nerdtree'
" ultisnips 代码片段
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" 添加vim缓冲区标签(在vim最顶部出现打开的文件)
Plug 'ap/vim-buftabline'
" Markdown预览插件 iamcco/mathjax-support-for-mkdp(latex数学公式支持) iamcco/markdown-preview.vim
" :MarkdownPreview 打开预览 :MarkdownPreviewStop 关闭预览
Plug 'iamcco/mathjax-support-for-mkdp'
Plug 'iamcco/markdown-preview.vim'
" 用于vim debug
Plug 'puremourning/vimspector'
" vim latex snippets
Plug 'gillescastel/latex-snippets'
Plug 'lervag/vimtex'
Plug 'KeitaNakamura/tex-conceal.vim'
" vim 表格
" dhruvasagar/vim-table-mode vim 表格创建
" 1. 处理类似markdown 表格的数据格式 即 : | a | c | (|间需要空格)
" 2. :TableModeEnable 打开表格模式才能自动处理表格
" 3. :TableModeDisable 关闭表格模式
Plug 'dhruvasagar/vim-table-mode'
call plug#end()

syntax on
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set cindent
" 默认字符过多不换行, 使用 set wrap 恢复换行
set nowrap
set hidden
set nu
" 设置vim做字符串匹配时使用的最大内存,UltiSnips代码片段提示使用,默认为1000单位Kbyte
set maxmempattern=2000

if has('nvim')
    " 设置光标样式, 让nvim和vim保持一样都是闪烁的方块
    set guicursor=n-v-c-i:block
    " 设置底部状态栏样式, 0: 不显示状态栏 , 1: 仅在打开多个窗口时显示 , 2: 始终显示（即使只有一个窗口）
    set laststatus=1
    " 如果需要同步vim的默认颜色只要把 colors/vimdefault.vim 覆盖
    " /usr/share/nvim/runtime/colors/default.vim 就好
    " nvim 0.10 默认开启了真彩色, 但这个配色有点丑设置成关闭 
    set notermguicolors


    " 设置垂直选项卡分隔符为竖线字符
    set fillchars+=vert:\|
    " 设置水平分隔符为等号字符
    " set fillchars+=horiz:=
    " 设置折叠线为点字符
    set fillchars+=fold:-
    " 设置垂直和水平分隔符为不同的字符
    " set fillchars+=vert:│,horiz:─
    " 设置当前窗口边界为星号字符
    " set fillchars+=stl:*,stlnc:*
    " 设置不同窗口之间的分隔符为加号字符
    set fillchars+=eob:~
    " 配置分割符颜色, vim为 VertSplit 颜色组, 但nvim为WinSeparator
    highlight WinSeparator term=reverse cterm=reverse gui=reverse

else
endif


" 字典补全,使用Ctrl-X Ctrl-K快捷键，将在'dictionary'选项定义的文件中查找匹配的关键词。
" set dictionary=/usr/dict/words,/usr/share/dict/words
" set complete+=k "set complete option
" 词典补全 使用Ctrl-X Ctrl-T快捷键，将在'thesaurus'选项定义的文件中查找匹配的关键词。
" 因为在词典文件中，每行会包含多个单词，所以将显示匹配行中的所有单词
" set thesaurus=/usr/dict/words,/usr/share/dict/words
" 如果觉得<Ctrl-X><Ctrl-K>组合键太麻烦 ，那么也可以直接将字典补全添加到默认补全列表中，在vimrc中添加下面的代码
" set complete-=k complete+=k

" vim颜色方案(用来兼容ubuntu) ： 查看目录 /usr/share/vim/vim82/colors
colorscheme vim8
" 要选择其他背景颜色，您可以使用 
" :highlight CocFloating ctermbg=color
" 并更改错误消息的前景（文本）颜色，请使用
" :highlight CocErrorFloat ctermfg=color
" 在哪里 color是颜色名称或颜色编号（通常从 0 到 15）。 阅读有关颜色值的更多信息 
" :h cterm-colors
" 如果你想为 vim 使用 GUI，你应该考虑使用 guibg和 guifg
" :h gui-colors
" 修改coc 选择框颜色 CocMenuSel 为分组
" coc浮动窗口选中行颜色
highlight CocMenuSel ctermbg=LightGray
" coc浮动窗口颜色
highlight CocFloating ctermfg=DarkGray ctermbg=LightMagenta
" vim退出的时候自动保持 session , 在启动vim的时候可以使用 `LoadDirectoryMkSession` 加载
autocmd VimEnter * call InitDirectoryMkSession()
autocmd VimLeave * call SaveDirectoryMkSession()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""  在终端背景是暗色但的时候启用以下配置""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" coc 调用链颜色: 去除 for highlight ranges of outgoing calls.
" coc 范围选择颜色, 兼容代码片段提示
highlight CocSelectedRange ctermbg=Black
" coc 镶嵌提示颜色, 兼容提示函数的参数列表
highlight CocInlayHint ctermbg=DarkGray ctermfg=Blue
highlight CocInlayHintType ctermbg=DarkGray ctermfg=Blue
highlight CocInlayHintParameter ctermbg=DarkGray ctermfg=Blue
" 设置背景色兼容 coc location
highlight Normal ctermbg=Black
" 设置选中行颜色
highlight Visual ctermfg=Black
" 设置vim diff 颜色
highlight DiffChange ctermfg=White ctermbg=Black
highlight DiffText ctermfg=Black ctermbg=Red
highlight DiffAdd ctermfg=Black ctermbg=Blue
highlight DiffDelete ctermfg=Black ctermbg=Blue

" 树莓派兼容
set backspace=2
set nocompatible


" ==================================================
" =================== 快捷键配置 ===================
" ==================================================

" =================== 原生支持 =====================
" 缓冲文件
" :ls 查看缓冲文件
nmap <silent><C-Right> :bn <CR>
nmap <silent><C-Left> :bp <CR>
imap <silent><C-Right> <Esc>`^:bn <CR>i
imap <silent><C-Left> <Esc>`^:bp <CR>i
nmap <silent><C-l> :bn <CR>
nmap <silent><C-h> :bp <CR>
imap <silent><C-l> <Esc>`^:bn <CR>i
imap <silent><C-h> <Esc>`^:bp <CR>i
" 关闭缓冲文件
nmap <silent><C-n> :bd <CR>
imap <silent><C-n> <Esc>`^:bd <CR>i
" 关闭所有的缓冲文件
" nmap <silent><C-A-q> :bufdo bd <CR>
" imap <silent><C-A-q> <Esc>`^:bufdo bd <CR>i



" 窗口跳转
nmap <silent><Esc><C-h> <C-w><C-h>
nmap <silent><Esc><C-l> <C-w><C-l>
nmap <silent><Esc><C-k> <C-w><C-k>
nmap <silent><Esc><C-j> <C-w><C-j>
imap <silent><Esc><C-h> <Esc>`^<C-w><C-h>
imap <silent><Esc><C-l> <Esc>`^<C-w><C-l>
imap <silent><Esc><C-k> <Esc>`^<C-w><C-k>
imap <silent><Esc><C-j> <Esc>`^<C-w><C-j>
nmap <silent><C-A-Left> <C-w><C-h>
nmap <silent><C-A-Right> <C-w><C-l>
nmap <silent><C-A-Up> <C-w><C-k>
nmap <silent><C-A-Down> <C-w><C-j>
imap <silent><C-A-Left> <Esc>`^<C-w><C-h>
imap <silent><C-A-Right> <Esc>`^<C-w><C-l>
imap <silent><C-A-Up> <Esc>`^<C-w><C-k>
imap <silent><C-A-Down> <Esc>`^<C-w><C-j>

" 日常使用键
nmap <C-S> :w!<CR>i
vmap <C-S> <C-c>:w!<CR>
imap <C-S> <Esc>:w!<CR>i
nmap <A-Left> <C-o>
nmap <A-Right> <C-i>
imap <A-Left> <Esc>`^<C-o>
imap <A-Right> <Esc>`^<C-i>
nmap <A-h> <C-o>
nmap <A-l> <C-i>
nmap h <C-o>
nmap l <C-i>
imap <A-h> <Esc>`^<C-o>
imap <A-l> <Esc>`^<C-i>
imap <Esc> <Esc>`^
nmap <silent><S-u> :redo<CR>
nmap <S-j> <C-f>
nmap <S-k> <C-b>
vmap <S-j> <C-f>
vmap <S-k> <C-b>
nmap <S-h> <S-Left>
nmap <S-l> <S-Right>
vmap <S-h> <S-Left>
vmap <S-l> <S-Right>



" 窗口大小调整
" nmap <silent><C-[> :vertical res-1<CR>
" nmap <silent><C-]> :vertical res+1<CR>
" nmap <silent><C-PageUp> :res+1<CR>
" nmap <silent><C-PageDown> :res-1<CR>

" 支持从vim复制到剪切版
" 需要vim支持clipboard
" 执行 `vim --version | grep clipboard` 有 + 号
" 如果不支持clipboard则安装vim-gtk(直接执行apt install vim-gtk不用卸载原始vim)
" 对于已经支持clipboard的vim在ssh场景下需要开启X11转发(ssh -X -C)才能使用C-y复制到剪切板
" 对于X11转发开启有以下几个条件
" 1. 如果报错`Invalid MIT-MAGIC-COOKIE-1 keyError: Can't open display: localhost:12.0`
" 检查环境变量`XAUTHORITY`的配置情况 
" 这个环境变量在服务端需要配置, 在客户端不能配置
" 2. 服务端开启X11Forwarding即使服务端的`/etc/ssh/sshd_config`有如下配置
" 修改后需要重启ssh服务端执行`sudo systemctl restart ssh`
" X11Forwarding yes	    # 允许X11转发
" X11DisplayOffset 10   #（可选）转发从localhost:10开始
" X11UseLocalhost no	#（可选）禁止将X11转发请求绑定到本地回环地址上
" AddressFamily inet	#（可选）强制使用IPv4通道。
" 3. 客户端开启X11(客户端一般无需修改, 只有出问题后再修改)
" Host *
"     ForwardAgent yes      # 控制 SSH 代理转发功能。默认值为 no，表示禁止将本地的 SSH 认证代理（如私钥）转发到远程服务器
"     ForwardX11 yes        # 控制是否自动重定向 X11 图形界面到本地。默认值 no 表示禁用 X11 转发功能
"     ForwardX11Trusted yes # 此参数仅在 ForwardX11 yes 时生效，用于控制 X11 转发的安全级别。yes 表示启用“受信任的 X11 转发”，允许远程程序完全访问本地 X11 显示服务器；no 则限制远程程序的访问权限
" 支持在在Visual模式下, 通过C-y复制到系统剪切板
vnoremap <C-y> "+y
" 支持在normal模式下, 通过C-y粘贴系统剪切板
nnoremap <C-y> "*p

" 替换 :[range]s/{pattern}/{string}/[flags] [count]
" range 1,3:1-3行 .:$:当前行-最后一行 .:+4:当前行-后4行 %:当前所有行
" flags  g:要替换当前行中所有出现的搜索模式 c:要确认每次替换  i:忽略搜索模式的大小写
" pattern \<单词\>:要搜索整个单词 
" :.,$s/var*/var/gci 
" :5,20s/^/#/ 注释行（在行前添加#）从5到20
" :5,20s/^#// 取消注释的第5行到第20行，恢复之前的更改
" :%s/apple\|orange\|mango/fruit/g 将“苹果”，“橙色”和“芒果”的所有实例替换为“水果”
" :%s/\s\+$//e 删除每行末尾的尾随空格
"
" 使用表达式替换: 就是对\=之后的表达式求值用来做替换
" :%s@X@\=line('.') # 将大写X替换成行号
" :%s@X@\=printf("%03d", line('.')) # 将大写X替换成行号, 用print格式化
" | 表达式      | 功能               |
" | ----------- | ------------------ |
" | line('.')   | 行号               |
" | printf()    | 格式化字符串打印   |
"
" 特殊好用的正则集合
":%s/^\(.*\)$\n\1\n//g 将相连且相同的两行同时去掉只保留不同的行, 执行前需要先执行 `:sort` 以保证相同行相连
nmap <C-r> :%s///g
imap <C-r> <Esc>:%s///g


" ================= 自定义函数 =======================

" 如果vim打开的是一个文件夹则不会保存 mksession
" mksession 保存路径, 如果该目录不存在则会导致 SaveDirectoryMkSession LoadDirectoryMkSession 失效
" sessionoptions，用于指定保存会话的内容，默认值如下, 
" set sessionoptions=blank,buffers,curdir,folds,help,options,tabpages,winsize,terminal
" 使用以下命令，可以查看关于会话选项的帮助信息：
" :help 'sessionoptions'
" 去除blank(恢复编辑无名缓冲区的窗口)保证不会因为目录导致问题
set sessionoptions-=blank
" 关闭option, 这个回导致有时候回有一些bug, 但需要保留localoptions, 这个能保留filetype(文件格式)
set sessionoptions+=localoptions
set sessionoptions-=options

let g:MkSessionDirectory = expand('~') .  "/.vim-session"

" 初始化g:MkSessionFile(当前需要保存的mksession路径)
function! InitDirectoryMkSession()

    if  expand('%:p') != "" || !isdirectory(g:MkSessionDirectory)
        " expand('%:p')为当前文件的完整路径
        " 如果为 '' 则说明是一个目录, 不为空是一个文件
        " 如果vim打开的是一个文件直接结束, 这个方法只是保存文件夹得 mksession
        " 如果数据存储目录不存在则也不做任何事情
        return
    endif

    " 获取当前文件夹路径并且替换 / -> _
    let current_directory = substitute(expand('%:p:h'), '/', '_', 'g')
    " vim 和 nvim 加载不同的session文件, 因为会冲突
    if has('nvim')
        let g:MkSessionFile = g:MkSessionDirectory . "/" . current_directory . ".nvim"
    else
        let g:MkSessionFile = g:MkSessionDirectory . "/" . current_directory . ".vim"
    endif


    call LoadDirectoryMkSession()

endfunction


" 保存mksession
function! SaveDirectoryMkSession()

    if !exists("g:MkSessionFile") || g:MkSessionFile == ''
        " 如果mksession文件路径没定义则不保存mksession
        " 该变量由InitDirectoryMkSession定义,所以执行SaveDirectoryMkSession前需要先执行LoadDirectoryMkSession
        return
    endif

    execute 'silent! mksession! ' . g:MkSessionFile

endfunction

" 加载mksession
function! LoadDirectoryMkSession()

    if !exists("g:MkSessionFile") || !filereadable(g:MkSessionFile)
        " 如果mksession文件路径没定义则不保存mksession
        " 该变量由InitDirectoryMkSession定义,所以执行LoadDirectoryMkSession前需要先执行LoadDirectoryMkSession
        return
    endif

    execute 'silent! source ' . g:MkSessionFile

endfunction

command! LoadSession call LoadDirectoryMkSession()
command! SaveSession call SaveDirectoryMkSession()

" 静默退出不触发 `SaveDirectoryMkSession` 逻辑
function! Exit()
    if exists("g:MkSessionFile")
        if filereadable(g:MkSessionFile)
            " 如果老的session文件存在需要清理掉
            call delete(g:MkSessionFile)
        endif
         " 将原始变量置为空
         let g:MkSessionFile = ''
    endif

    quit
endfunction
" 静默退出不触发 `SaveDirectoryMkSession` 逻辑
" 使用 `:Exit` 触发
command! Exit call Exit()


" 连续执行退出 `:quit` n次
function! Quit(num)
    " 将输入转换为整数
    let n = a:num

    " 检查输入是否为有效整数
    if !empty(n) && n =~ '^\d\+$'
        for i in range(1, n)
            quit
        endfor
    else
        echo "请输入一个有效的整数！"
    endif
endfunction
" 连续执行退出 `:quit` n次
" 使用 `:Q n` 触发
command! -nargs=1 Q call Quit(<f-args>)


" =================== Yggdroot/LeaderF ======================
" 设置打开搜索的窗口是左边
let g:Lf_WindowPosition='left'
" 忽略查询的文件列表
let g:Lf_WildIgnore = {
\ 'dir': ['.git', '.github', '.vim', '.hg', '.svn'],
\ 'file': ['*.o', '*.a', '*.d', '*.i', '*.s', '*.bc', '*.so', '*.pyc', '*.swp', '*.class']
\ }

" =================== puremourning/vimspector =====================
" 用于vim debug
" F5启动通用debug
nmap <silent> <F5> <Plug>VimspectorContinue
" j+F5(先按j)启动java debug
nmap <silent> <F5>j :CocCommand java.debug.vimspector.start<CR>
" F7单步跳入
nmap <silent> <F7> <Plug>VimspectorStepInto
" F8单步跳过
nmap <silent> <F8> <Plug>VimspectorStepOver
" PageDown单步跳入
nmap <silent> <PageDown> <Plug>VimspectorStepInto
" PageUp单步跳过
nmap <silent> <PageUp> <Plug>VimspectorStepOver
" F9添加断点
nmap <silent> <F9> <Plug>VimspectorToggleBreakpoint
" F9添加条件断点
nmap <silent> <Leader><F9> <Plug>VimspectorToggleConditionalBreakpoint
" F6运行到下个断点
nmap <silent> <F6> <Plug>VimspectorRunToCursor


" =================== preservim/nerdtree =====================
" NERDTree配置(目录树) preservim/nerdtree
" NERDTree配置 打开侧边目录
nmap <silent><Esc><C-n> :NERDTreeToggle<CR>
" 快速定位到当前文件
nmap <silent><Esc><S-n> :NERDTreeFind<CR>
" NERDTree配置 打开侧边目录
imap <silent><Esc><C-n> <Esc>`^:NERDTreeToggle<CR>
" 快速定位到当前文件
imap <silent><Esc><S-n> <Esc>`^:NERDTreeFind<CR>

" =================== Yggdroot/LeaderF ======================
" leaderF配置(查找) Yggdroot/LeaderF
" :LeaderfFile搜索当前目录下的文件
" :LeaderfBuffer搜索当前的Buffer
" :LeaderfMru 搜索最近使用过的文件( search most recently used files)就是Mru
" :LeaderfLine 搜索当前文件中有的某个单词
" :LeaderfFunction 搜索当前文件的函数(这个很有意思，如下图列出该文件中所有的函数和变量)
" :Leaderf rg 实时调用rg搜索, 即 grep on the fly
" :Leaderf git 查看git相关功能

" 如果:Leaderf后面有感叹号，会直接进入 normal 模式；如果没有感叹号，则是输入模式，此时可以输入字符来进行模糊匹配过滤。可以用 tab 键在两个模式间来回切换。
" Leaderf rg基本支持 rg 所有的必要选项，用户如果对 rg 命令比较熟悉，可以在 vim 命令行内输入:Leaderf, 然后手敲 rg 命令，命令选项还可以通过 tab 来补全。 当然，更聪明的做法是定义一些快捷键。
" Leaderf rg的使用也比较简单，只要Leaderf[!] + rg 命令和选项（同命令行上一样）就可以了。 具体使用方法可以用:Leaderf rg -h来查看。
nmap <silent><C-p> :LeaderfFile<CR>
imap <silent><C-p> <Esc>`^:LeaderfFile<CR>
nmap <silent><C-f> :LeaderfLine<CR>
imap <silent><C-f> <Esc>`^:LeaderfLine<CR>
" 搜索后不关闭LeaderF , -F 禁用正则表达式
nmap <Esc><C-p> :Leaderf! rg -F --stayOpen -e ""
imap <Esc><C-p> <Esc>`^:Leaderf! rg -F --stayOpen -e ""


"  -F 禁用正则表达式只搜索文本, --stayOpen 不退出 LeaderF 
" leaderf#Rg#visual()会将上次光标选中的文本赋值给 LeaderF(即用v键后选中的文本)
" expand("<cword>") 是一个非常实用的函数，用于获取光标下的单词,即光标当前行内容


" " https://www.v2ex.com/t/527045 使用例子
" " 搜索光标下的单词，模式将被视为正则表达式，并直接进入正常模式
" noremap <C-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>
" " 搜索光标下的单词，模式将被视为正则表达式，
" " 将结果附加到之前的搜索结果中。
" noremap <C-G> :<C-U><C-R>=printf("Leaderf! rg --append -e %s ", expand("<cword>"))<CR>
" " 仅在当前缓冲区中逐字搜索光标下的单词
" noremap <C-B> :<C-U><C-R>=printf("Leaderf! rg -F --current-buffer -e %s ", expand("<cword>"))<CR>
" " 在所有列出的缓冲区中逐字搜索光标下的单词
" noremap <C-D> :<C-U><C-R>=printf("Leaderf! rg -F --all-buffers -e %s ", expand("<cword>"))<CR>
" " 按字面搜索可视化选定的文本，接受输入后不退出 LeaderF
" xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>
" " 调用上次搜索。如果结果窗口已关闭，请重新打开它。
" noremap go :<C-U>Leaderf! rg --recall<CR>
" " 在 *.h 和 *.cpp 文件中搜索光标所在的单词。
" noremap <Leader>a :<C-U><C-R>=printf("Leaderf! rg -e %s -g *.h -g *.cpp", expand("<cword>"))<CR>
" " 同上
" noremap <Leader>a :<C-U><C-R>=printf("Leaderf! rg -e %s -g *.{h,cpp}", expand("<cword>"))<CR>
" " 在 cpp 和 java 文件中搜索光标所在的单词。
" noremap <Leader>b :<C-U><C-R>=printf("Leaderf! rg -e %s -t cpp -t java", expand("<cword>"))<CR>
" " 在 cpp 文件中搜索光标所在的单词，排除 *.hpp 文件
" noremap <Leader>c :<C-U><C-R>=printf("Leaderf! rg -e %s -t cpp -g !*.hpp", expand("<cword>"))<CR>

" ==================== neoclide/coc.nvim ====================
" coc.nvim 提供vscode的vim移植
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
" 回车自动选择旧版
" inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" 回车自动选择新版
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> <C-e> :CocDiagnostics<CR>
imap <silent> <C-e> <Esc>`^:CocDiagnostics<CR>

" GoTo code navigation.
nmap <silent> <C-b> <plug>(coc-definition)
nmap <silent> <S-b> <plug>(coc-type-definition)
nmap <silent> <Esc><c-b> <plug>(coc-implementation)
nmap <silent> <Esc>b <plug>(coc-references)
nmap <silent> <C-Down> <plug>(coc-definition)
nmap <silent> <A-Down> <plug>(coc-implementation)
" nmap <silent> <A-j> <plug>(coc-implementation)
nmap <silent> j <plug>(coc-implementation)
nmap <silent> <C-Up> <plug>(coc-references)
imap <silent> <C-Down> <Esc><plug>(coc-definition)
imap <silent> <A-Down> <Esc><plug>(coc-implementation)
" imap <silent> <A-j> <Esc><plug>(coc-implementation)
imap <silent> j <Esc><plug>(coc-implementation)
imap <silent> <C-Up> <Esc><plug>(coc-references)
nmap <silent> <C-j> <plug>(coc-definition)
" nmap <silent> <A-j> <plug>(coc-implementation)
nmap <silent> <C-k> <plug>(coc-references)
imap <silent> <C-j> <Esc><plug>(coc-definition)
" imap <silent> <C-A-j> <Esc><plug>(coc-implementation)
" imap <silent> <A-j> <Esc><plug>(coc-implementation)
imap <silent> <C-k> <Esc><plug>(coc-references)

" Use <C-d> to show documentation in preview window.
nnoremap <silent> <C-d> :call <SID>show_documentation()<CR>
imap <silent> <C-d> <Esc>`^:call <SID>show_documentation()<CR>i


" coc调用链, 使用 <tab> 展开调用链 , t 字母打开操作 
" showIncomingCalls : 查看谁调用了自己, showOutgoingCalls: 我调用了谁
nmap <silent> <Esc><C-i> :call CocActionAsync('showIncomingCalls')<CR>
imap <silent> <Esc><C-i> <Esc>`^:call CocActionAsync('showIncomingCalls')<CR>
" nmap <silent> <Leader><S-h> :call CocActionAsync('showOutgoingCalls')

" Symbol renaming.
nmap <Leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <Leader>f  <Plug>(coc-format-selected)
nmap <Leader>f  <Plug>(coc-format-selected)

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <C-t>  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" 命令面板
" nmap <Esc><S-p> :CocCommand<CR>
" imap <Esc><S-p> <Esc>`^:CocCommand<CR>
" 代码自动生成
nmap <silent><Esc><S-i> <Plug>(coc-codeaction-cursor)
nmap <silent><Esc><Enter> <Plug>(coc-codeaction-cursor)
imap <silent><Esc><S-i> <Esc>`^<Plug>(coc-codeaction-cursor)i
imap <silent><Esc><Enter> <Esc>`^<Plug>(coc-codeaction-cursor)i



" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <Leader>a  <Plug>(coc-codeaction-selected)
nmap <Leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <Leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <Leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <Leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" 使用 <C-f> <S-down> 和 <C-b> <S-up> 对浮动窗口上下翻页
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

  nnoremap <silent><nowait><expr> <S-down> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <S-up> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <S-down> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <S-up> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <S-down> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <S-up> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" vim-ultisnips 插件
" coc.vim vim-ultisnips 配合 ultisnips使用 
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()


" coc-translator 翻译插件
" NOTE: do NOT use `nore` mappings
" popup
nmap <Leader>t <Plug>(coc-translator-p)
vmap <Leader>t <Plug>(coc-translator-pv)
" echo
nmap <Leader>e <Plug>(coc-translator-e)
vmap <Leader>e <Plug>(coc-translator-ev)
" replace
nmap <Leader>r <Plug>(coc-translator-r)
vmap <Leader>r <Plug>(coc-translator-rv)
" coc-markdown-preview-enhanced markdown 插件
" 快捷键 \v 快速带开markdown预览
nmap <Leader>v :CocCommand markdown-preview-enhanced.openPreview<CR>

" ==================================================
" =================== 快捷键配置 ===================
" ==================================================

" ==================== preservim/nerdtree ====================
" NERDTree配置(目录树) preservim/nerdtree
" NERDTree防止在窗口打开
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
" 当 NERDTree 是最后一个窗口时，自动关闭 vim
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" 目录显示隐藏文件即以 . 开头的文件活文件夹
let g:NERDTreeShowHidden = 1
" NERDTree 忽略文件规则 (忽略规则支持正则表达式, 比如忽略vim的Swap file,使用'\.swp$'表示以swp结尾文件)
let g:NERDTreeIgnore = [
            \ '\.swp$',
            \ '\~',
            \ '\.git',
            \ '\.vim',
            \ '\.github',
            \ '\.gitignore',
            \ '\.vimspector.json',
            \ ]





" ==================== SirVer/ultisnips ====================
" ==================== honza/vim-snippets ====================
" ultisnips 代码片段 SirVer/ultisnips honza/vim-snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" ==================== neoclide/coc.nvim ====================
" coc.nvim 提供vscode的vim移植
let g:coc_snippet_next = '<tab>'



" coc.vim neoclide/coc.nvim
" coc.vim 安装的插件
" 可以指定版本格式如下 'coc-<extension>@<version>'
" 可以通过 `:CocList extensions` 查看当前安装的coc插件版本
" 可以通过 `npm search coc-*` 查询coc的插件有哪些,该命令会返回一个插件页面可以查看有哪些版本
" 请注意coc-java版本升级后可能导致jdk版本过低,如果java代码无法编译或有其他问题需要设置`java.jdt.ls.java.home`指定jdk版本
let g:coc_global_extensions = [
            \ 'coc-word',
            \ 'coc-markdown-preview-enhanced',
            \ 'coc-webview',
            \ 'coc-translator',
            \ 'coc-json',
            \ 'coc-ultisnips',
            \ 'coc-java',
            \ 'coc-java-debug',
            \ 'coc-pyright',
            \ 'coc-html',
            \ 'coc-css',
            \ 'coc-tsserver',
            \ 'coc-clangd',
            \ 'coc-go',
            \ 'coc-sh'
            \ ]
" # 插件安装需要做的事
" ## coc-clangd
" ### 安装
" 1. 在vim中执行 :CocCommand clangd.install
" 2. 通过sudo apt install clangd -y 然后通过 coc-setting.json 中的 clangd.path参数指定clangd安装地址
" ### config
" clangd.path : clangd安装目录
" ## coc-jedi
" coc-jedi 依赖 python3-pip, python3-venv
" sudo apt install -y python3-pip python3-venv
" ## coc-word 单词替换
" 如果想要有英文翻译将 coc/coc-word 下的所有文件复制到 ~/.config/coc/extensions/node_modules/coc-word
" ## coc-ultisnips-select
" 如果想要选择snippets后自动展开snippets将 coc/coc-ultisnips-select 下的所有文件复制到 ~/.config/coc/extensions/node_modules/coc-ultisnips-select
" ## coc-java
" 需要自己手动下载lombok jar
" 并且下载后的lombok的jar包需要保持 lombok-${version}.jar 格式
" 比如将lombok下载到: ~/.config/coc/extensions/node_modules/coc-java/lombok/lombok-1.18.36.jar
" 如果路径修改了需要修改java.jdt.ls.vmargs

" coc-markdown-preview-enhanced coc markdown 预览插件
" 如果需要隐藏头部title(由插件 coc-webview 提供) 修改文件 ~/.config/coc/extensions/node_modules/coc-webview/lib/index.js
" 中div id = title 元素隐藏(可以搜索menu-list定位) <div id="title" style="display: none;visibility: none" >
" :CocCommand markdown-preview-enhanced.openPreview 打开预览
" | Command                                    | Functionality              |
" |--------------------------------------------+----------------------------|
" | markdown-preview-enhanced.openPreview      | Open preview               |
" | markdown-preview-enhanced.syncPreview      | Sync preview / Sync source |
" | markdown-preview-enhanced.runCodeChunk     | Run code chunk             |
" | markdown-preview-enhanced.runAllCodeChunks | Run all code chunks        |

" 忽略开启警告(比如vim版本问题的警告)
let g:coc_disable_startup_warning = 1
" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'


function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" 同单词高亮 Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}


" ==================== puremourning/vimspector ====================
" vimspector 远程debug插件,使用vscode的dap(Debug Adaptor Protocol)实现
" 支持语言如下(包含开启方法)
" | Language(s)          | Status      | Switch (for `install_gadget.py`)   | Adapter (for `:VimspectorInstall`)   | Dependencies             |
" | -------------------- | ----------- | ---------------------------------- | ------------------------------------ | -------------------------|
" | C, C++, Rust etc.    | Tested      | `--all` or `--enable-c` (or cpp)   | vscode-cpptools                      | mono-core                |
" | C, C++, Rust etc.    | Supported   | `--enable-rust`                    | CodeLLDB                             | Python 3                 |
" | Python               | Tested      | `--all` or `--enable-python`       | debugpy                              | Python 2.7 or Python 3   |
" | Go                   | Tested      | `--enable-go`                      | delve                                | Go 1.16+                 |
" | TCL                  | Supported   | `--all` or `--enable-tcl`          | tclpro                               | TCL 8.5                  |
" | Bourne Shell         | Supported   | `--all` or `--enable-bash`         | vscode-bash-debug                    | Bash v??                 |
" | Lua                  | Tested      | `--all` or `--enable-lua`          | local-lua-debugger-vscode            | Node, Npm,Lua interpreter|
" | Node.js              | Supported   | `--force-enable-node`              | vscode-node-debug2                   | 6 < Node < 12, Npm       |
" | Javascript           | Supported   | `--force-enable-chrome`            | debugger-for-chrome                  | Chrome                   |
" | Javascript           | Supported   | `--force-enable-firefox`           | vscode-firefox-debug                 | Firefox                  |
" | Java                 | Supported   | `--force-enable-java  `            | vscode-java-debug                    | Compatible LSP plugin    |
" | PHP                  | Experimental| `--force-enable-php`               | vscode-php-debug                     | Node, PHP, XDEBUG        |
" | C# (dotnet core)     | Tested      | `--force-enable-csharp`            | netcoredbg                           | DotNet core              |
" | F#, VB, etc.         | Supported   | `--force-enable-[fsharp,vbnet]`    | netcoredbg                           | DotNet core              |
" | Go (legacy)          | Legacy      | `--enable-go`                      | vscode-go                            | Node, Go, [Delve][]      |
" | C# (mono)            | _Retired_   | N/A                                | N/A                                  | N/A                      |
" | Python.legacy        | _Retired_   | N/A                                | N/A                                  | N/A                      |
" 支持的API如下
" | Mapping                                       | Function                                                            | API                                                               |
" | ---                                           | ---                                                                 | ---                                                               |
" | `<Plug>VimspectorContinue`                    | When debugging, continue. Otherwise start debugging.                | `vimspector#Continue()`                                           |
" | `<Plug>VimspectorStop`                        | Stop debugging.                                                     | `vimspector#Stop()`                                               |
" | `<Plug>VimpectorRestart`                      | Restart debugging with the same configuration.                      | `vimspector#Restart()`                                            |
" | `<Plug>VimspectorPause`                       | Pause debuggee.                                                     | `vimspector#Pause()`                                              |
" | `<Plug>VimspectorBreakpoints`                 | Show/hide the breakpoints window                                    | `vimspector#ListBreakpoints()`                                    |
" | `<Plug>VimspectorToggleBreakpoint`            | Toggle line breakpoint on the current line.                         | `vimspector#ToggleBreakpoint()`                                   |
" | `<Plug>VimspectorToggleConditionalBreakpoint` | Toggle conditional line breakpoint or logpoint on the current line. | `vimspector#ToggleBreakpoint( { trigger expr, hit count expr } )` |
" | `<Plug>VimspectorAddFunctionBreakpoint`       | Add a function breakpoint for the expression under cursor           | `vimspector#AddFunctionBreakpoint( '<cexpr>' )`                   |
" | `<Plug>VimspectorGoToCurrentLine`             | Reset the current program counter to the current line               | `vimspector#GoToCurrentLine()`                                    |
" | `<Plug>VimspectorRunToCursor`                 | Run to Cursor                                                       | `vimspector#RunToCursor()`                                        |
" | `<Plug>VimspectorStepOver`                    | Step Over                                                           | `vimspector#StepOver()`                                           |
" | `<Plug>VimspectorStepInto`                    | Step Into                                                           | `vimspector#StepInto()`                                           |
" | `<Plug>VimspectorStepOut`                     | Step out of current function scope                                  | `vimspector#StepOut()`                                            |
" | `<Plug>VimspectorUpFrame`                     | Move up a frame in the current call stack                           | `vimspector#UpFrame()`                                            |
" | `<Plug>VimspectorDownFrame`                   | Move down a frame in the current call stack                         | `vimspector#DownFrame()`                                          |
" | `<Plug>VimspectorBalloonEval`                 | Evaluate expression under cursor (or visual) in popup               | *internal*                                                        |


" ==================== gillescastel/latex-snippets ====================
" ==================== lervag/vimtex ====================
" ==================== KeitaNakamura/tex-conceal.vim ====================
" vim latex 配置插件 gillescastel/latex-snippets lervag/vimtex KeitaNakamura/tex-conceal.vim 
" 配置参考: https://github.com/gillescastel/latex-snippets
" 快捷键 : \ll(<Leader>ll) 快速编译,打开文件 
let g:tex_flavor='latex'
" let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
" 禁用评论中的拼写检查
let g:vimtex_syntax_nospell_comments=1
" set conceallevel=1
" let g:tex_conceal='abdmg'
" hi Conceal ctermbg=none
" vim tex拼写检查 会导致中文报错
" setlocal spell
" vim tex 拼写检查单词库/语言
" set spelllang=en_us
" inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" ==================== dhruvasagar/vim-table-mode ====================
" dhruvasagar/vim-table-mode vim 表格创建
" 1. 处理类似markdown 表格的数据格式 即 : | a | c | (|间需要空格)
" 2. :TableModeEnable 打开表格模式才能自动处理表格
" 3. :TableModeDisable 关闭表格模式

function! s:isAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction
" 在已经有表格的情况下比如 | xx | xx | 在新行输入 || 生成水平线 |----|----|
inoreabbrev <expr> <bar><bar>
          \ <SID>isAtStartOfLine('\|\|') ?
          \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
inoreabbrev <expr> __
          \ <SID>isAtStartOfLine('__') ?
          \ '<c-o>:silent! TableModeDisable<cr>' : '__'

" vim 打开的时候自动打开表格模式
autocmd VimEnter * silent TableModeEnable

" 要获得与 ReST 兼容的表，
" +-----------------+--------------------------+------------+
" | name            | address                  | phone      |
" +=================+==========================+============+
" | John Adams      | 1600 Pennsylvania Avenue | 0123456789 |
" +-----------------+--------------------------+------------+
" | Sherlock Holmes | 221B Baker Street        | 0987654321 |
" +-----------------+--------------------------+------------+
" let g:table_mode_corner_corner='+'
" let g:table_mode_header_fillchar='='
" 对于 Markdown 兼容的表，请使用 
" |-----------------|--------------------------|------------|
" | name            | address                  | phone      |
" |-----------------|--------------------------|------------|
" | John Adams      | 1600 Pennsylvania Avenue | 0123456789 |
" |-----------------|--------------------------|------------|
" | Sherlock Holmes | 221B Baker Street        | 0987654321 |
" |-----------------|--------------------------|------------|
" let g:table_mode_corner='|'
