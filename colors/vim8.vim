" 对于配色方案来说需要设置colors_name(配色方案,且跟文件名一致)否则会导致在某些版本的vim中无法应用该方案
" 这个配置由 `:hi` 获取并转换而来
" 请获取干净的配置, 即在没有配置过任何 vimrc和安装过vim插件的情况下执行
" 1. 打开vim, 执行 `:hi` 获取当前vim的样式并且复制出来
" 2. 去除 `xxx` (这个原来是用在展示颜色的无用) , 正则表达式: `:%s/xxx//g`
" 3. 在开头添加`hi`正则表达式: `:%s/\n/\rhi /g` , 但需要手动补偿第一行的hi
" 4. 转换 cleared 模式的配色比如, `hi Table           cleared` 
"   4.1 如果想要去除cleared 模式正则表达式: `:%s/hi\s\(\S\+\)\s\+cleared.*\n//g`
"   4.2 如果想保留cleared正则表达式: `:%s/hi\s\(\S\+\)\s\+cleared.*\n/hi clear \1\r/g` , 执行后变为`hi clear Table`
" 5. 转换 links 模式比如 `hi shHereDoc16     links to shRedir` , 执行后变成 `hi link shHereDoc16 shRedir`
"   正则表达式: `:%s/hi\s\(\S\+\)\s\+links\s\+to\s\+\(\S\+\)\n/hi link \1 \2\r/g`

" 这个是vim8的默认配置方案, 它是暗色配置方案
" 设置配色方案名称,如果不配置只是按照文件名确定配色方案名称在某些vim版本中无法找到
let colors_name = "vim8"
set background=dark
" 在vimrc中配置的配色方案需要在设置配色方案之后(即`colorscheme vim8`需要在vimr的其它配色前) 
" 否则会导致vimrc配色方案会因为下面的`hi clear`而被清除掉
hi clear
hi SpecialKey      term=bold ctermfg=4 guifg=Blue
hi link EndOfBuffer NonText
hi NonText         term=bold ctermfg=12 gui=bold guifg=Blue
hi Directory       term=bold ctermfg=4 guifg=Blue
hi ErrorMsg        term=standout ctermfg=15 ctermbg=1 guifg=White guibg=Red
hi IncSearch       term=reverse cterm=reverse gui=reverse
hi Search          term=reverse ctermbg=11 guibg=Yellow
hi MoreMsg         term=bold ctermfg=2 gui=bold guifg=SeaGreen
hi ModeMsg         term=bold cterm=bold gui=bold
hi LineNr          term=underline ctermfg=130 guifg=Brown
hi clear LineNrAbove
hi clear LineNrBelow
hi CursorLineNr    term=bold cterm=underline ctermfg=130 gui=bold guifg=Brown
hi link CursorLineSign SignColumn
hi link CursorLineFold FoldColumn
hi Question        term=standout ctermfg=2 gui=bold guifg=SeaGreen
hi StatusLine      term=bold,reverse cterm=bold,reverse gui=bold,reverse
hi StatusLineNC    term=reverse cterm=reverse gui=reverse
hi VertSplit       term=reverse cterm=reverse gui=reverse
hi Title           term=bold ctermfg=5 gui=bold guifg=Magenta
hi Visual          term=reverse ctermbg=7 guibg=LightGrey
hi VisualNOS       term=bold,underline cterm=bold,underline gui=bold,underline
hi WarningMsg      term=standout ctermfg=1 guifg=Red
hi WildMenu        term=standout ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
hi Folded          term=standout ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=LightGrey
hi FoldColumn      term=standout ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=Grey
hi DiffAdd         term=bold ctermbg=81 guibg=LightBlue
hi DiffChange      term=bold ctermbg=225 guibg=LightMagenta
hi DiffDelete      term=bold ctermfg=12 ctermbg=159 gui=bold guifg=Blue guibg=LightCyan
hi DiffText        term=reverse cterm=bold ctermbg=9 gui=bold guibg=Red
hi SignColumn      term=standout ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=Grey
hi Conceal         ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey
hi SpellBad        term=reverse ctermbg=224 gui=undercurl guisp=Red
hi SpellCap        term=reverse ctermbg=81 gui=undercurl guisp=Blue
hi SpellRare       term=reverse ctermbg=225 gui=undercurl guisp=Magenta
hi SpellLocal      term=underline ctermbg=14 gui=undercurl guisp=DarkCyan
hi Pmenu           ctermfg=0 ctermbg=225 guibg=LightMagenta
hi PmenuSel        ctermfg=0 ctermbg=7 guibg=Grey
hi PmenuSbar       ctermbg=248 guibg=Grey
hi PmenuThumb      ctermbg=0 guibg=Black
hi TabLine         term=underline cterm=underline ctermfg=0 ctermbg=7 gui=underline guibg=LightGrey
hi TabLineSel      term=bold cterm=bold gui=bold
hi TabLineFill     term=reverse cterm=reverse gui=reverse
hi CursorColumn    term=reverse ctermbg=7 guibg=Grey90
hi CursorLine      term=underline cterm=underline guibg=Grey90
hi ColorColumn     term=reverse ctermbg=224 guibg=LightRed
hi link QuickFixLine Search
hi StatusLineTerm  term=bold,reverse cterm=bold ctermfg=15 ctermbg=2 gui=bold guifg=bg guibg=DarkGreen
hi StatusLineTermNC  term=reverse ctermfg=15 ctermbg=2 guifg=bg guibg=DarkGreen
hi Cursor          guifg=bg guibg=fg
hi lCursor         guifg=bg guibg=fg
hi clear Normal
hi MatchParen      term=reverse ctermbg=14 guibg=Cyan
hi ToolbarLine     term=underline ctermbg=7 guibg=LightGrey
hi ToolbarButton   cterm=bold ctermfg=15 ctermbg=242 gui=bold guifg=White guibg=Grey40
hi Comment         term=bold ctermfg=4 guifg=Blue
hi Constant        term=underline ctermfg=1 guifg=Magenta
hi Special         term=bold ctermfg=5 guifg=#6a5acd
hi Identifier      term=underline ctermfg=6 guifg=DarkCyan
hi Statement       term=bold ctermfg=130 gui=bold guifg=Brown
hi PreProc         term=underline ctermfg=5 guifg=#6a0dad
hi Type            term=underline ctermfg=2 gui=bold guifg=SeaGreen
hi Underlined      term=underline cterm=underline ctermfg=5 gui=underline guifg=SlateBlue
hi Ignore          ctermfg=15 guifg=bg
hi Error           term=reverse ctermfg=15 ctermbg=9 guifg=White guibg=Red
hi Todo            term=standout ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
hi link String Constant
hi link Character Constant
hi link Number Constant
hi link Boolean Constant
hi link Float Number
hi link Function Identifier
hi link Conditional Statement
hi link Repeat Statement
hi link Label Statement
hi link Operator Statement
hi link Keyword Statement
hi link Exception Statement
hi link Include PreProc
hi link Define PreProc
hi link Macro PreProc
hi link PreCondit PreProc
hi link StorageClass Type
hi link Structure Type
hi link Typedef Type
hi link Tag Special
hi link SpecialChar Special
hi link Delimiter Special
hi link SpecialComment Special
hi link Debug Special

