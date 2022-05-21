syntax on
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set cindent
set nu

" vim颜色方案(用来兼容ubuntu) ： 查看目录 /usr/share/vim/vim82/colors
colorscheme default

" 树莓派兼容
set backspace=2
set nocompatible

execute pathogen#infect()
syntax on
filetype plugin indent on

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
"
" NERDTree配置 打开侧边目录
nmap <silent><ESC><C-n> :NERDTreeToggle<CR>
nmap <silent><ESC><S-n> :NERDTreeFind<CR>
imap <silent><ESC><C-n> <Esc>`^:NERDTreeToggle<CR>
imap <silent><ESC><S-n> <Esc>`^:NERDTreeFind<CR>
" NERDTree防止在窗口打开
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" leaderF配置(查找) Yggdroot/LeaderF
" :LeaderfFile搜索当前目录下的文件
" :LeaderfBuffer搜索当前的Buffer
" :LeaderfMru 搜索最近使用过的文件( search most recently used files)就是Mru
" :LeaderfLine 搜索当前文件中有的某个单词
" :LeaderfFunction 搜索当前文件的函数(这个很有意思，如下图列出该文件中所有的函数和变量)
nmap <silent><C-p> :LeaderfFile<CR>
nmap <silent><C-f> :LeaderfLine<CR>
imap <silent><C-p> <Esc>`^:LeaderfFile<CR>
imap <silent><C-f> <Esc>`^:LeaderfLine<CR>


" auto-pairs配置(自动匹配括号) jiangmiao/auto-pairs


" NerdCommenter配置(生成注释) preservim/nerdcommenter
" count\cc 注释 count默认1
" count\cu 取消注释 count默认1
" count\ci 注释，取消注释 count默认1

" 缓冲栏 fholgado/minibufexpl.vim
" 设置minibufexplorer窗口最大高度为1行
" let g:miniBufExplMaxSize = 1

" 缓冲文件
" :ls 查看缓冲文件
set hidden
nmap <silent><ESC><right> :bn <CR>
nmap <silent><ESC><left> :bp <CR>
nmap <silent><ESC><w> :bd <CR>
imap <silent><ESC><right> <Esc>`^:bn <CR>i
imap <silent><ESC><left> <Esc>`^:bp <CR>i
imap <silent><ESC><w> <Esc>`^:bd <CR>i
" 缓冲文件兼容ubuntu
nmap <silent><A-right> :bn <CR>
nmap <silent><A-left> :bp <CR>
nmap <silent><A-w> :bd <CR>
imap <silent><A-right> <Esc>`^:bn <CR>i
imap <silent><A-left> <Esc>`^:bp <CR>i
imap <silent><A-w> <Esc>`^:bd <CR>i

" 窗口跳转
nmap <silent><ESC><C-j> <C-w><C-h>
nmap <silent><ESC><C-l> <C-w><C-l>
nmap <silent><ESC><C-i> <C-w><C-k>
nmap <silent><ESC><C-k> <C-w><C-j>
imap <silent><ESC><C-j> <Esc>`^<C-w><C-h>
imap <silent><ESC><C-l> <Esc>`^<C-w><C-l>
imap <silent><ESC><C-i> <Esc>`^<C-w><C-k>
imap <silent><ESC><C-k> <Esc>`^<C-w><C-j>



" 日常使用键
nmap <C-S> :w!<CR>i
vmap <C-S> <C-C>:w!<CR>
imap <C-S> <Esc>:w!<CR>i
nmap <C-left> <C-o>
nmap <C-RIGHT> <C-i>
imap <C-left> <Esc>`^<C-o>
imap <C-RIGHT> <Esc>`^<C-i>
imap <ESC> <Esc>`^
nmap <silent><S-u> :redo<CR>
" 替换 :[range]s/{pattern}/{string}/[flags] [count]
" range 1,3:1-3行 .:$:当前行-最后一行 .:+4:当前行-后4行 %:当前所有行
" flags  g:要替换当前行中所有出现的搜索模式 c:要确认每次替换  i:忽略搜索模式的大小写
" pattern \<单词\>:要搜索整个单词 
" :.,$s/var*/var/gci 
" :5,20s/^/#/ 注释行（在行前添加#）从5到20
" :5,20s/^#// 取消注释的第5行到第20行，恢复之前的更改
" :%s/apple\|orange\|mango/fruit/g 将“苹果”，“橙色”和“芒果”的所有实例替换为“水果”
" :%s/\s\+$//e 删除每行末尾的尾随空格
nmap <C-r> :%s///g
imap <C-r> <ESC>:%s///g


" ultisnips 代码片段 SirVer/ultisnips honza/vim-snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

let g:coc_snippet_next = '<tab>'

" coc.vim vim-ultisnips 配合 ultisnips使用 
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()



" coc.vim neoclide/coc.nvim
" coc.vim 安装的
let g:coc_global_extensions = ['coc-json','coc-ultisnips', 'coc-java', 'coc-java-lombok', 'coc-pyright', 'coc-jedi', 'coc-tsserver', 'coc-clangd']
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

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> <C-e> :CocDiagnostics<CR>
imap <silent> <C-e> <Esc>`^:CocDiagnostics<CR>

" GoTo code navigation.
nmap <silent> <c-b> <plug>(coc-definition)
nmap <silent> <s-b> <plug>(coc-type-definition)
nmap <silent> <esc><c-b> <plug>(coc-implementation)
nmap <silent> <esc>b <plug>(coc-references)
nmap <silent> <c-down> <plug>(coc-definition)
nmap <silent> <A-down> <plug>(coc-implementation)
nmap <silent> <c-up> <plug>(coc-references)
imap <silent> <c-down> <Esc>`^:<C-u>call       CocActionAsync('jumpDefinition')<CR>i
imap <silent> <A-down> <Esc>`^:<C-u>call       CocActionAsync('jumpImplementation')<CR>i
imap <silent> <c-up> <Esc>`^:<C-u>call       CocActionAsync('jumpReferences')<CR>i


function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'


" Use <C-h> to show documentation in preview window.
nnoremap <silent> <C-h> :call <SID>show_documentation()<CR>
imap <silent> <C-h> <Esc>`^:call <SID>show_documentation()<CR>i

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

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

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
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

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
" nmap <ESC><S-p> :CocCommand<CR>
" imap <ESC><S-p> <Esc>`^:CocCommand<CR>
" 代码自动生成
nmap <silent><ESC><S-i> :CocAction<CR>
nmap <silent><ESC><ENTER> :CocAction<CR>
imap <silent><ESC><S-i> <Esc>`^:CocAction<CR>i
imap <silent><ESC><ENTER> <Esc>`^:CocAction<CR>i
