" ==========================================================
" File Name:    vimrc
" Author:       StarWing
" Version:      0.5 (2537)
" Last Change:  2019-02-09 00:30:11
" Must After Vim 7.0 {{{1
if v:version < 700
    finish
endif
" }}}1
" ==========================================================
" Settings {{{1

" init settings {{{2

silent! so $VIMRUNTIME/vimrc_example.vim

set encoding=utf-8
scriptencoding utf-8

if has('win32') && $LANG =~? 'zh_CN'
    let &rtp = iconv(&rtp, 'gbk', 'utf8')
endif

if has('eval')
    let s:cpo_save = &cpo
    if !exists('g:gui_running')
        let g:gui_running = has('gui_running')
    endif
endif

set cpo&vim " set cpo-=C cpo-=b

" generic Settings {{{2

set ambiwidth=single
set bsdir=buffer
set complete-=i
set completeopt=longest,menu
set diffopt+=vertical
set display=lastline
set fileencodings=ucs-bom,utf-8,cp932,cp936,gb18030,latin1
set fileformats=unix,dos
set formatoptions=tcqmB2
set grepprg=grep\ -rn\ 
set history=1000
set modeline " for debian.vim, changed the initial value
set shiftwidth=4
set softtabstop=4
set tags=./tags,tags,./tags;
set tabstop=8
set textwidth=70
set viminfo+=!
set virtualedit=block
set whichwrap+=<,>,h,l
set wildcharm=<C-Z>
set wildmenu
set shortmess=I
set mouse=a
set smartcase

" new in Vim 7.3 {{{2

if v:version > 703
    set formatoptions+=j
endif
if v:version >= 703 && has('persistent_undo')
    set undofile
endif


" titlestring & statusline {{{2

set titlestring=%f%(\ %m%h%r%)\ -\ StarWing's\ Vim:\ %{v:servername}
set laststatus=2

" helplang {{{2
if v:version >= 603
    set helplang=cn
endif

" diffexpr {{{2
if has('eval')
    set diffexpr=MyDiff('diff')

    function! MyDiff(cmd)
        let cmd = [a:cmd, '-a --binary', v:fname_in, v:fname_new]

        if &diffopt =~ 'icase'
            let cmd[1] .= ' -i'
        endif
        if &diffopt =~ 'iwhite'
            let cmd[1] .= ' -b'
        endif
        call writefile(split(system(join(cmd)), "\n"), v:fname_out)
    endfunction
endif

if has("win32") " {{{2
    if $LANG =~? 'zh_CN' && &encoding !=? "cp936"
        set termencoding=cp936

        lang mes zh_CN.UTF-8

        set langmenu=zh_CN.UTF-8
        silent! so $VIMRUNTIME/delmenu.vim
        silent! so $VIMRUNTIME/menu.vim
    endif

    if has("directx")
        set renderoptions=type:directx,geom:1
    endif

elseif has('unix') " {{{2
    if g:gui_running
        lang mes zh_CN.UTF-8
        set langmenu=zh_CN.UTF-8
        silent! so $VIMRUNTIME/delmenu.vim
        silent! so $VIMRUNTIME/menu.vim
    endif
    if has("termguicolors")
        " fix bug for vim
        let &t_8f="\<ESC>[38;2;%lu;%lu;%lum"
        let &t_8b="\<ESC>[48;2;%lu;%lu;%lum"

        " enable true color
        set termguicolors
    endif
    if exists('$TMUX')
        let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"

        execute "set <xUp>=\e[1;*A"
        execute "set <xDown>=\e[1;*B"
        execute "set <xRight>=\e[1;*C"
        execute "set <xLeft>=\e[1;*D"
    endif
endif " }}}2
if g:gui_running " {{{2
    set co=120 lines=35

    if exists('+gfn')
        if has('win32')
            silent! set gfn=Consolas:h9:qDRAFT
        elseif has('mac')
            set gfn=Monaco\ for\ Powerline:h14
        else
            "set gfn=Consolas\ 10 gfw=WenQuanYi\ Bitmap\ Song\ 10
            set gfn=DejaVu\ Sans\ Mono\ 9
        endif
    endif

endif " }}}2
" swapfiles/undofiles settings {{{2

let s:vimrcpath = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:tprefix = expand('~/.cache/vim')

function s:rtp_fix()
    set rtp-=~/.vim
    set rtp-=~/.vim/after
    exec 'set rtp^='.s:vimrcpath
    exec 'set rtp^='.s:vimrcpath.'/after'
endf

call s:rtp_fix()

for dir in ['/swapfiles', '/backupfiles', '/undofiles']
    let s:dir = s:tprefix.dir
    if !isdirectory(s:dir)
        if has('win32') && $LANG =~? 'zh_CN'
            let s:dir = iconv(s:dir, &enc, &tenc)
        endif
        silent! call mkdir(s:dir, 'p')
        unlet s:dir
    endif
endfor

if isdirectory(s:tprefix.'/swapfiles')
    let &directory=s:tprefix."/swapfiles"
endif
if isdirectory(s:tprefix.'/backupfiles')
    let &backupdir=s:tprefix."/backupfiles"
endif
if v:version >= 703 && isdirectory(s:tprefix.'/undofiles')
    let &undodir=s:tprefix."/undofiles"
endif

exec "set viminfo+=n".s:tprefix."/viminfo"

"}}}2
" ----------------------------------------------------------
" Helpers {{{1

" Environment Variables Setting {{{2
if has('eval')

    " mapleader value {{{3

    let mapleader = " "

    function! s:globfirst(pattern) " {{{3
        return simplify(split(glob(a:pattern), '\n', 1)[0])
    endfunction

    function! s:let(var, val) " {{{3
        exec 'let '.a:var.'=iconv("'.escape(a:val,'\"').'", &enc, &tenc)'
    endfunction

    " $VIMDIR {{{3
    for dir in split(globpath(&rtp, "plugin/*.vim"), "\<NL>")
        call s:let('$VIMDIR', fnamemodify(dir, ":p:h:h"))
        break
    endfor

    " $PATH in win32 {{{3
    if has("win32")
        call s:let('$PATH', s:globfirst($VIM."/vimfiles/tools").";".$PATH)
        let s:tools = [['git',    'git/bin'          ],
                    \  ['git',    'minGW/git/bin'    ],
                    \  ['cmake',  'cmake/bin'        ],
                    \  ['mingw',  'minGW/bin'        ],
                    \  ['minsys', 'minSYS/bin'       ],
                    \  ['mingw',  'minSYS/mingw/bin' ],
                    \  ['nim',    'nim/bin'          ],
                    \  ['lua53',  'lua53'            ],
                    \  ['lua52',  'lua52'            ],
                    \  ['lua51',  'lua51'            ],
                    \  ['luaJIT', 'luaJIT'           ],
                    \  ['lua',    'Lua'              ],
                    \  ['perl',   'perl/perl/bin'    ],
                    \  ['python', 'Python'           ],
                    \  ['python', 'Python27'         ],
                    \  ['python', 'Python36'         ],
                    \  ['msys64', 'msys64/usr/bin'   ],
                    \  ['msys2_mingw64', 'msys64/mingw64/bin'],
                    \  ['rust',   'Rust/bin'         ]]
        for [name, path] in s:tools
            if !isdirectory($VIM.'/../'.path) | continue | endif

            let s:{name}_path = s:globfirst($VIM.'/../'.path)

            if s:{name}_path != "" && $PATH !~ '\c'.substitute(path, '/', '[\\/]', 'g')
                call s:let('$PATH', $PATH.';'.s:{name}_path)
            else
                unlet s:{name}_path
            endif
        endfor
        unlet s:tools
        if exists('s:mingw_path') " {{{4
            let s:new_mingw_path = substitute(s:mingw_path, '\s\|,', '\\&', 'g')
            let &path .= ','.s:new_mingw_path.'\..\include,'.
                        \ s:new_mingw_path.'\..\include,'.
                        \ s:new_mingw_path.'\..\lib\gcc'
            unlet s:new_mingw_path
        endif

        if exists('s:python_path') " {{{4
            if !exists('$PYTHONPATH')
                call s:let('$PYTHONPATH', s:python_path.'\Lib;'.
                            \ s:python_path.'\Lib\site-packages')
            endif
            if $PATH !~ 'Scripts'
                call s:let('$PATH', s:python_path.'\Scripts;'.
                            \ $PATH)
            endif
        endif

        if exists('s:lua_path') " {{{4
            if isdirectory(s:lua_path.'\5.1')
                let s:lua_path = s:lua_path.'\5.1'
            endif
            call s:let('$LUA_DEV', s:lua_path)
            call s:let('$LUA_DEV', ';;'.s:lua_path.'\?.luac')
            call s:let('$PATH', s:lua_path.'\clibs;'.$PATH)

            if exists('s:mingw_path')
                call s:let('$C_INCLUDE_PATH', $C_INCLUDE_PATH.';'.s:lua_path.'\include')
                call s:let('$CPLUS_INCLUDE_PATH', $CPLUS_INCLUDE_PATH.';'.s:lua_path.'\include')
                call s:let('$LIBRARY_PATH', s:lua_path.'\lib')
            endif
        endif
        " }}}4
    endif

    " $DOC and $WORK {{{3
    if has('win32')
        let s:cur_root = fnamemodify($VIM, ':p')[0]
        let s:spec_path = [['$WORK', $VIM.'\..\..\..\Work'],
                    \ ['$DOC', nr2char(s:cur_root).':\Document'],
                    \ ['$WORK', nr2char(s:cur_root).':\Work']]
        for i in range(char2nr('D'), char2nr('Z'))
            let s:spec_path += [['$DOC', nr2char(i).':\Document'],
                        \ ['$WORK', nr2char(i).':\Work']]
        endfor
        unlet s:cur_root
    else
        let s:spec_path = [['$DOC', expand('~/Document')],
                    \ ['$WORK', '/work'],
                    \ ['$WORK', expand('~/Work')]]
    endif

    for [var, path] in s:spec_path
        if isdirectory(glob(path)) && !exists(var)
            call s:let(var, s:globfirst(path))
        endif
    endfor
    unlet s:spec_path

    if has('win32') && exists('$WORK') && isdirectory(glob("$WORK/Home"))
        let $HOME = glob("$WORK/Home")
    endif

    " $PRJDIR {{{3

    for dir in ['~', '~/..', $VIM, $VIM.'/..', $VIM.'/../..', $WORK]
        for name in ['prj', 'Code', 'Project']
            if isdirectory(expand(dir."/".name))
                call s:let('$PRJDIR', s:globfirst(dir."/".name))
                break
            endif
        endfor
    endfor

    if !exists('$PRJDIR') && exists('$WORK')
        let $PRJDIR = $WORK
    endif


    if exists('$PRJDIR') && argc() == 0
        let orig_dir = getcwd()
        map<silent> <leader>co :<C-U>exec "cd" fnameescape(g:orig_dir)<BAR>NERDTreeToggle<CR>
        silent! cd $PRJDIR
    endif " }}}3

endif " }}}2
" Generic autocmds {{{2
if has('autocmd')
    augroup vimrc_autocmds
        function! s:vimrc_write() " {{{3
            let time = strftime("%Y-%m-%d %H:%M:%S")
            let pos = winsaveview()

            $|if search('\c^" Vimrc History', 'bW')
                call append(line('.'), '" Write at '.time)
            endif

            1|if search('\c^"\s*Last Change:', 'W')
                call setline(line('.'),
                            \ matchstr(getline('.'), '\c^"\s*Last Change:\s*').time)
            endif

            1|if search('\c^"\s*Version:', 'W')
                let pat = '^"\s*[Vv]ersion:\v.{-}\ze%(\s*\((\d+)\))=$'
                let pv = matchlist(getline('.'), pat)
                if empty(pv[1])
                    call setline('.', getline('.').' (1)')
                else
                    call setline('.', pv[0].' ('.(str2nr(pv[1], 10)+1).')')
                endif
            endif

            call winrestview(pos)
        endfunction
        " }}}3

        au!
        au BufFilePost * filetype detect|redraw
        au BufWritePre $MYVIMRC,_vimrc silent call s:vimrc_write()
        au BufWritePre Y:/* set noundofile
        au BufReadPost * if getfsize(expand('%')) < 50000 | syn sync fromstart | endif
        "au BufWritePre * let &backup = (getfsize(expand('%')) > 500000)
        au BufNewFile,BufRead *.vba set noml
        au FileType clojure,dot,lua,haskell,m4,perl,python,ruby,scheme,tcl,vim,javascript,erlang
                    \   if !exists('b:ft') || b:ft != &ft
                    \|      let b:ft = &ft
                    \|      set sw=4 ts=8 sts=4 nu et sta fdc=2 fo-=t
                    \|  endif
        au FileType lua se sw=3 sts=3 ts=3 et
        au FileType lua let b:syntastic_checkers=['luacheck', 'lua']
        au FileType nim se sw=2 sts=2 ts=2 nu et fdm=marker fdc=2
        au FileType erlang se sw=2 sts=2 fdm=marker fdc=2 ff=unix
        au FileType javascript se sw=2 sts=2 ts=2 et fdc=2 fdm=syntax
        au FileType cs se ai nu noet sw=4 sts=4 ts=4 fdc=2 fdm=syntax
        au FileType javascript if exists("*JavaScriptFold")
                    \|             call JavaScriptFold()
                    \|         endif
        au FileType scheme if exists(":AutoCloseOff") == 2
                    \|         exec "AutoCloseOff"
                    \|     endif
        au FileType html set fo-=t
        au BufReadPost log.txt syn clear
                    \|         syn region Table start='{' end='}' contains=Table fold
                    \|         se fdc=5 fdm=syntax autoread

        if has("cscope")
            au VimLeave * cs kill -1
        endif

        " Don't screw up folds when inserting text that might affect them, until
        " leaving insert mode. Foldmethod is local to the window. Protect against
        " screwing up folding when switching between windows.
        autocmd InsertEnter *
                    \  if !exists('w:last_fdm')
                    \|     let w:last_fdm=&foldmethod | setlocal foldmethod=manual
                    \| endif
        autocmd InsertLeave,WinLeave *
                    \  if exists('w:last_fdm')
                    \|     let &l:foldmethod=w:last_fdm | unlet w:last_fdm
                    \| endif

    augroup end

    augroup NEOMAKE_ERL
        au!

        func! s:reg_tgame(path)
            for fn in glob(a:path.'/*', 0, 1)
                exec "au BufNewFile,BufRead "
                            \ substitute(fn.'\server\**\*.[he]rl', '\\', '/', 'g')
                            \ "let b:neomake_erlang_erlc_root='".fn."/server'" "|"
                            \ "let b:neomake_erlang_erlc_flags=["
                            \ "'-I', '".fn."/server']|echomsg 'setvar!'"
            endfor
        endfunc
        if has('win32')
            call s:reg_tgame("C:/Devel/Projects/tgame/versions")
            call s:reg_tgame("Y:/Work")
        elseif has('mac')
            call s:reg_tgame("/Users/sw/Work/Code/tgame/versions")
        else
            call s:reg_tgame("/home/wx/Work")
            call s:reg_tgame("/home/*/tgame/versions")
        end
    augroup END
endif
" Generic commands {{{2
if has("eval")

" Q for quit all {{{3
command! -bar Q qa!

" QfDo {{{3

fun! QFDo(bang, command)
     let qflist={}
     if a:bang
         let tlist=map(getloclist(0), 'get(v:val, ''bufnr'')')
     else
         let tlist=map(getqflist(), 'get(v:val, ''bufnr'')')
     endif
     if empty(tlist)
        echomsg "Empty Quickfixlist. Aborting"
        return
     endif
     for nr in tlist
     let item=fnameescape(bufname(nr))
     if !get(qflist, item,0)
         let qflist[item]=1
     endif
     endfor
     :exe 'argl ' .join(keys(qflist))
     :exe 'argdo ' . a:command
endfunc

com! -nargs=1 -bang Qfdo :call QFDo(<bang>0,<q-args>)


" EX, EV, EF, ES, EP {{{3

function! s:open_explorer(fname)
    let exec = has('win32') ? '!start explorer'  :
                \ has('mac') ? '!open -R' : '!nautilus'
    let fname = matchstr(glob(a:fname), '^\v.{-}\ze(\n|$)')

    if fname == ""
        let fname = "."
    endif
    if !isdirectory(fname)
        if has('win32')
            "exec exec '/select,'.iconv(fname, &enc, &tenc)
            exec exec '/select,'.fname
        elseif has('mac')
            exec exec iconv(fnamemodify(fname, ':p'), &enc, &tenc)
            call feedkeys("\<CR>")
        else
            exec exec iconv(fnamemodify(fname, ':h'), &enc, &tenc)
            call feedkeys("\<CR>")
        endif
    else
        "exec exec iconv(fname, &enc, &tenc)
        exec exec fname
    endif

    "call feedkeys("\n", 't')
endfunction

command! -nargs=* -complete=file EX call s:open_explorer(<q-args>)
command! EV EX $VIM
command! EF EX %:p

if exists('$VIMDIR')
    command! ES EX $VIMDIR
endif
if exists('$PRJDIR')
    command! EP EX $PRJDIR
endif

" VV GV {{{3

if has('win32')
    command! -nargs=* -complete=file VV exec "!start" v:progname <q-args>
    command! -nargs=* -complete=file VR exec "!start" v:progname <q-args>|qa!
    command! -nargs=* -complete=file VI !start vim <args>
    command! -nargs=* -complete=file VG !start gvim <args>
endif

" Full GUI {{{3

if g:gui_running
    set go-=e
    let s:has_mt = glob("$VIM/_fullscreen") == "" &&
                \  glob("$VIM/vimfiles/_fullscreen") == "" &&
                \  glob(s:vimrcpath."/_fullscreen") == ""
    if s:has_mt
        set go+=mT
    else
        set go-=m go-=T
    endif

    function! s:check_mt()
        if s:has_mt
            set go-=m go-=T
        else
            set go+=mT
        endif
        let s:has_mt = !s:has_mt
    endfunction

    command! -bar ToggleGUI call s:check_mt()

    map <F9> :<C-U>ToggleGUI<CR>
endif


" AddTo, SoScript {{{3
if exists("$VIMDIR")

    command! -nargs=1 -complete=customlist,VimfilesDirComplete
                \ AddTo call rename(expand('%'),
                \ $VIMDIR.'/<args>/'.expand('%:t')) | checkt
    let Script_folder = 'script'
    command! -nargs=1 -complete=customlist,ScriptDirFileComplete
                \ SoScript exec 'so $VIMDIR/'.Script_folder.'/<args>'

    function! VimfilesDirComplete(ArgLead, ...)
        return map(filter(split(globpath($VIMDIR,
                    \ escape(a:ArgLead, '?*[').'*'), "\n"),
                    \ 'isdirectory(v:val)'),
                    \ 'fnamemodify(v:val, ":t")')
    endfunction

    function! ScriptDirFileComplete(ArgLead, ...)
        return map(split(globpath($VIMDIR.'/scripts',
                    \ escape(a:ArgLead, '?*[').'*'), "\n"),
                    \ 'fnamemodify(v:val, ":t")')
    endfunction
endif

" Add Linenumber {{{3
  
command! -bar -range=% LN 
            \|silent <line1>,<line2>s/  /　/ge
            \|silent <line1>,<line2>s/^/\=printf(
            \           "|%0.*d| ", strlen(<line2>), line('.'))/ge
            \|silent! <line1>,<line2>yank *
            \|silent! undo
            \|let @/=""

command! -bar -range=% DLN
            \|silent <line1>,<line2>s/　/  /ge
            \|silent <line1>,<line2>s/^|\=\d\+\%(| \|:\)\=//ge
            \|nohl
  
" Font Size {{{3

let s:gf_pat = has('win32') || has('mac') ? 'h\zs\d\+' : '\d\+$'
command! -bar -count=10 FSIZE let &gfn = substitute(&gfn, s:gf_pat,
            \ <count>, '') | let &gfw = substitute(&gfw, s:gf_pat,
            \ <count>, '')

" }}}3

endif

" Generic maps {{{2

" cmdline edit key, emacs style {{{3

cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <C-N> <Down>
cnoremap <C-P> <Up>
cnoremap <M-F> <S-Right>
cnoremap <M-B> <S-Left>

" insert mode edit key, emacs style {{{3

"inoremap <C-A> <Home>
"inoremap <C-E> <End>
inoremap <C-F> <Right>
inoremap <C-B> <Left>
"inoremap <C-N> <Down>
"inoremap <C-P> <Up>
inoremap <M-F> <S-Right>
inoremap <M-B> <S-Left>

" clipboard operations {{{3
if has('eval')
    for op in ['y', 'Y', 'p', 'P']
        exec 'nmap z'.op.' "+'.op
        exec 'xmap z'.op.' "+'.op.'gv'
    endfor

    " inner buffer
    function! s:inner_buf()
        let line1 = nextnonblank(1)
        if line1 == 0
            " the buffer is blank, select it like with aa
            norm! ggVG
            return
        endif
        exec "norm!" line1."ggV". prevnonblank("$")."G"
    endfunc
    nor ii :<C-U>call <SID>inner_buf()<CR>
    nun ii| sunm ii

    " all buffer
    nor aa :<C-U>norm! ggVG<CR>
    nun aa| sunm aa

    " get Global
    nor gG :norm! ggVG<CR>
    sunm gG
    " Build buffer with zp
    nmap zB gGzp
    " get text zipped
    nmap gz zyaa``

    " set Y operator tp y$
    map Y y$
endif

" visual # and * operators {{{3

xnor<silent> # "sy?\V<C-R>=substitute(escape(@s, '\?'), '\n', '\\n', 'g')<CR><CR>
xnor<silent> * "sy/\V<C-R>=substitute(escape(@s, '\/'), '\n', '\\n', 'g')<CR><CR>

" window navigating/sizing {{{3

nmap <C-+> <C-W>+
nmap <C-,> <C-W><
nmap <C--> <C-W>-
nmap <C-.> <C-W>>
nmap <C-=> <C-W>=
xmap <C-+> <C-W>+
xmap <C-,> <C-W><
xmap <C--> <C-W>-
xmap <C-.> <C-W>>
xmap <C-=> <C-W>=

if has('eval')
    nmap Z8 :call <SID>wresize()<CR>

    function! s:wresize()
        if winwidth(0) < 80
            exec "norm 80\<C-W>|"
        endif

        if winheight(0) < 20
            exec "norm z20\<CR>"
        endif
    endfunction

else
    nmap Z8 80<C-W><BAR>z25<CR>
endif

xmap Z8 <ESC>Z8
map <M-j> <C-j>Z8
map <M-k> <C-k>Z8
map <M-h> <C-h>Z8
map <M-l> <C-l>Z8

" <leader>f# [Filetype]# set buffer tabstop and sw and et

noremap [Filetype]1 :<C-U>setl ts=8 sw=4 et nu fdm=syntax fdc=2<CR>
noremap [Filetype]2 :<C-U>setl ts=4 sw=0 sts=0 noet nu fdm=syntax fdc=2<CR>
noremap [Filetype]3 :<C-U>setl ts=8 sw=2 sts=2 et nu fdm=syntax fdc=2<CR>

" <leader>c cd to current file folder {{{3

map <leader>cd :<C-U>cd %:h<CR>
map <leader>cw :<C-U>cd Y:/trunk/server<CR>
map <leader>c1 :<C-U>call feedkeys(":\<lt>C-U>cd Y:/1.\<lt>Tab>", 't')<CR>

" <leader>c diff get/put {{{3

map <leader>cx :<C-U>noh\|pcl\|ccl\|lcl<CR>
map <leader>cg :diffget
map <leader>cp :diffput
map <leader>cf :diffupdate

" <leader>f [Filetype] {{{3

map <leader>f [Filetype]
noremap [Filetype] :<C-U>set filetype<CR>
noremap [Filetype]+ :<C-U>setf cpp<CR>
noremap [Filetype]c :<C-U>setf c<CR>
noremap [Filetype]C :<C-U>setf clojure<CR>
noremap [Filetype]d :<C-U>setf dot<CR>
noremap [Filetype]g :<C-U>setf go<CR>
noremap [Filetype]h :<C-U>setf haskell<CR>
noremap [Filetype]j :<C-U>setf java<CR>
noremap [Filetype]l :<C-U>setf lua<CR>
noremap [Filetype]L :<C-U>setf lisp<CR>
noremap [Filetype]m :<C-U>setf markdown<CR>
noremap [Filetype]M :<C-U>setf m4<CR>
noremap [Filetype]P :<C-U>setf perl<CR>
noremap [Filetype]p :<C-U>setf python<CR>
noremap [Filetype]T :<C-U>setf tex<CR>
noremap [Filetype]r :<C-U>setf rust<CR>
noremap [Filetype]R :<C-U>setf rest<CR>
noremap [Filetype]s :<C-U>setf scheme<CR>
noremap [Filetype]T :<C-U>setf tcl<CR>
noremap [Filetype]t :<C-U>setf text<CR>
noremap [Filetype]v :<C-U>setf vim<CR>

" <leader>cs get syntax stack {{{3
nmap<silent> <leader>cs :echo ""<bar>for id in synstack(line('.'),col('.'))
            \\|echo synIDattr(id, "name")
            \\|endfor<CR>

" <leader>hjkl window navigating and moving {{{3

nmap <leader>h <C-W>h
nmap <leader>j <C-W>j
nmap <leader>k <C-W>k
nmap <leader>l <C-W>l
nmap <leader>H <C-W>H
nmap <leader>J <C-W>J
nmap <leader>K <C-W>K
nmap <leader>L <C-W>L

" q quickfix error jumps {{{3

map <leader>qj :<C-U>cn!<CR>
map <leader>qk :<C-U>cp!<CR>

" <leader>r run current line {{{3

" vimrc edit
if has("win32")
    map <leader>re :drop $VIM/vimfiles/_vimrc<CR>
    map <leader>rr :so $VIM/vimfiles/_vimrc<CR>
else
    map <leader>re :drop $MYVIMRC<CR>
    map <leader>rr :so $MYVIMRC<CR>
endif

nmap <leader>rc :exec getline('.')[col('.')-1:]<CR>
xmap <leader>rc y:exec @"<CR>
nmap <leader>rv :echo eval(getline('.'))[col('.')-1:]<CR>
xmap <leader>rv y:echo eval(@")<CR>

" <leader>t terminal {{{3

if v:version >= 801
    map <leader>t :<C-U>terminal<CR>
elseif has('mac')
    map <leader>t :<C-U>!open -a iterm<CR>:call feedkeys("\<lt>CR>")<CR>
elseif !has('win32')
    map <leader>t :<C-U>!gnome-terminal &<CR>:call feedkeys("\<lt>CR>")<CR>
elseif executable('sh.exe')
    map <leader>t :<C-U>!start sh.exe --login -i<CR>
else
    map <leader>t :<C-U>!start cmd.exe<CR>
endif

" <leader>v vim invoke {{{3

if has('eval')
    function! s:get_restart_arg()
        if has('win32')
            let cmdline = '!start '.v:progname.' -c "cd '
        else
            let cmdline = '!'.v:progname.' -c "cd '
            call feedkeys("\<CR>")
        end
        if exists(":NERDTreeToggle") == 2
            return cmdline.fnameescape(getcwd()).'|NERDTreeToggle|wincmd l"'
        else
            return cmdline.fnameescape(getcwd()).'"'
        endif
    endfunction
    map <leader>vn :<C-U>exec <SID>get_restart_arg()<CR>
    map <leader>vr :<C-U>exec <SID>get_restart_arg()<BAR>qa!<CR>
    if has('win32')
        map <leader>vi :<C-U>!start gvim<CR>
    else
        map <leader>vi :<C-U>!gvim<CR><CR>
    end
end

" g[1-9] Airline {{{3

nmap g1 <Plug>AirlineSelectTab1
nmap g2 <Plug>AirlineSelectTab2
nmap g3 <Plug>AirlineSelectTab3
nmap g4 <Plug>AirlineSelectTab4
nmap g5 <Plug>AirlineSelectTab5
nmap g6 <Plug>AirlineSelectTab6
nmap g7 <Plug>AirlineSelectTab7
nmap g8 <Plug>AirlineSelectTab8
nmap g9 <Plug>AirlineSelectTab9
nmap gT <Plug>AirlineSelectPrevTab
nmap gt <Plug>AirlineSelectNextTab

" <leader>m Mark {{{3

map <leader>* <Plug>MarkSet
map <leader>/ <Plug>MarkRegex
map <leader>? <Plug>MarkSearchGroupNext
nmap * <Plug>MarkSearchNext
nmap # <Plug>MarkSearchPrev

sunmap <leader>*| ounmap <leader>*
sunmap <leader>/| ounmap <leader>/
sunmap <leader>?| ounmap <leader>?

" <leader>d [Denite] {{{3

map <leader>d [Denite]
noremap [Denite] :<C-U>Denite 
noremap [Denite]d :<C-U>Denite file_mru<CR>
noremap [Denite]b :<C-U>Denite buffer<CR>
noremap [Denite]f :<C-U>Denite file<CR>
noremap [Denite]a :<C-U>Denite directory_mru<CR>
noremap [Denite]m :<C-U>Denite mark<CR>
noremap [Denite]r :<C-U>Denite register<CR>
noremap [Denite]y :<C-U>Denite neoyank<CR>
noremap [Denite]l :<C-U>Denite line<CR>

sunmap <leader>d| ounmap <leader>d
sunmap [Denite]| ounmap [Denite]
sunmap [Denite]d| ounmap [Denite]d
sunmap [Denite]b| ounmap [Denite]b
sunmap [Denite]f| ounmap [Denite]f
sunmap [Denite]a| ounmap [Denite]a
sunmap [Denite]m| ounmap [Denite]m
sunmap [Denite]r| ounmap [Denite]r
sunmap [Denite]y| ounmap [Denite]y
sunmap [Denite]l| ounmap [Denite]l

" <leader>y [YCM] {{{3

map <leader>y [YCM]
noremap [YCM] :<C-U>YcmCompleter 
noremap <silent> [YCM]d :<C-U>YcmCompleter GoToDefinitionElseDeclaration<CR>

sunmap <leader>y| ounmap <leader>y
sunmap [YCM]| ounmap [YCM]
sunmap [YCM]d| ounmap [YCM]d

" <leader>b [NERDTree] {{{3

map <leader>b [NERDTree]
noremap [NERDTree] <Nop>
noremap <silent> [NERDTree]b :<C-U>NERDTreeToggle<CR>
noremap <silent> [NERDTree]f :<C-U>NERDTree %:h<CR>
noremap <silent> [NERDTree]p :<C-U>NERDTree $VIMDOR<CR>
noremap <silent> [NERDTree]s :<C-U>NERDTree $PRJDIR<CR>
noremap <silent> [NERDTree]v :<C-U>NERDTree $VIM<CR>
nnoremap <silent> [NERDTree]x :<C-U>NERDTree .<CR>
xnoremap <silent> [NERDTree]x "ey:NERDTree <C-R>e<CR>

sunmap <leader>b| ounmap <leader>b
sunmap [NERDTree]| ounmap [NERDTree]
sunmap [NERDTree]b| ounmap [NERDTree]b
sunmap [NERDTree]f| ounmap [NERDTree]f
sunmap [NERDTree]p| ounmap [NERDTree]p
sunmap [NERDTree]s| ounmap [NERDTree]s
sunmap [NERDTree]v| ounmap [NERDTree]v

" <leader>g [Git] {{{3

map <leader>g [Git]
noremap [Git] <Nop>
noremap <silent> [Git]l :<C-U>Glog<CR>
noremap <silent> [Git]d :<C-U>Gdiff<CR>
noremap <silent> [Git]b :<C-U>Gblame<CR>

sunmap <leader>g| ounmap <leader>g
sunmap [Git]| ounmap [Git]
sunmap [Git]l| ounmap [Git]l
sunmap [Git]d| ounmap [Git]d
sunmap [Git]b| ounmap [Git]b

" <leader><CR> EasyAlign {{{3

map <leader><CR> <Plug>(EasyAlign)
sunmap <leader><CR>| ounmap <leader><CR>

" }}}3

" }}}2
" ----------------------------------------------------------
" plugin settings {{{1
if has('eval')

" vim-plug {{{2

filetype off

call plug#begin(s:vimrcpath.'/bundle')


if exists(':Plug')

" Plug 'flazz/vim-colorschemes'
" Plug 'scrooloose/syntastic'

Plug 'yianwillis/vimcdoc'       " chinese document
"Plug 'w0rp/ale'            " live lint
"Plug 'mhinz/vim-signify'   " show difference
Plug 'neomake/neomake'     " live lint/build
"Plug 'metakirby5/codi.vim' " on-the-fly coding
Plug 'Shougo/deol.nvim', { 'on': [ 'Deol', 'DeolCd', 'DeolEdit' ] }
Plug 'Shougo/denite.nvim'
Plug 'luochen1990/rainbow'
Plug 'andymass/vim-matchup'
Plug 'roman/golden-ratio'

" denite sources
Plug 'Shougo/neomru.vim'
Plug 'Shougo/neoyank.vim'

" textobj
Plug 'junegunn/vim-easy-align'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-user'
Plug 'sgur/vim-textobj-parameter'
Plug 'tpope/vim-surround'


Plug 'Konfekt/FoldText'
Plug 'Raimondi/delimitMate'
Plug 'dyng/ctrlsf.vim', { 'on': 'CtrlSF' }
Plug 'easymotion/vim-easymotion'
Plug 'ervandew/supertab'
Plug 'fidian/hexmode'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTree', 'NERDTreeToggle' ] }
Plug 'mg979/vim-visual-multi'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'triglav/vim-visual-increment'
Plug 'vim-airline/vim-airline'
Plug 'Chiel92/vim-autoformat'

Plug 'inkarkat/vim-ingo-library'
Plug 'inkarkat/vim-mark'

" Language-spec
Plug 'OrangeT/vim-csharp', { 'for': 'csharp' }
Plug 'Shutnik/jshint2.vim', { 'for': 'javascript' }
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'leafo/moonscript-vim', { 'for': 'moonscript' }
Plug 'raymond-w-ko/vim-lua-indent', { 'for': 'lua' }
Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }
Plug 'vim-erlang/vim-erlang-runtime', { 'for': 'erlang' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'zah/nim.vim', { 'for': 'nim' }
Plug 'idris-hackers/idris-vim', { 'for': 'idris' }
"Plug 'thinca/vim-logcat'

if glob(s:tprefix.'/_enableYouCompleteMe') != ''
    Plug 'Valloric/YouCompleteMe', { 'for': [ 'c', 'cpp', 'csharp', 'python', 'go', 'rust', 'typescript', 'javascript', 'java' ] }
    Plug 'tenfyzhong/CompleteParameter.vim', { 'for': [ 'c', 'cpp', 'csharp', 'python', 'go', 'rust', 'typescript', 'javascript', 'java' ] }
    Plug 'Shougo/echodoc.vim', { 'for': [ 'c', 'cpp', 'csharp', 'python', 'go', 'rust', 'typescript', 'javascript', 'java' ] }
endif


call plug#end()
endif
filetype plugin indent on

" colorscheme {{{2
let base16colorspace=256
set background=dark
silent! colorscheme base16-eighties

" 2html {{{2

let html_dynamic_folds = 1
let html_ignore_conceal = 1
let html_no_pre = 1
let html_use_css = 1

" airline {{{2

let g:airline_powerline_fonts = 1
"let g:airline_symbols_ascii=1
let g:airline_skip_empty_sections = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#keymap_ignored_filetypes = [ 'denite', 'nerdtree' ]

let g:airline_mode_map = {
            \ '__' : '-',
            \ 'n'  : 'N',
            \ 'i'  : 'I',
            \ 'R'  : 'R',
            \ 'c'  : 'C',
            \ 'v'  : 'V',
            \ 'V'  : 'VL',
            \ '' : 'VB',
            \ 's'  : 'S',
            \ 'S'  : 'SL',
            \ '' : 'SB',
            \ 't'  : 'T',
            \ }

let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16_eighties'

" ctk {{{2

amenu 1.246 ToolBar.BuiltIn25 :CC<CR>
tmenu ToolBar.BuiltIn25 CTK Compile
amenu 1.247 ToolBar.BuiltIn15 :RUN<CR>
tmenu ToolBar.BuiltIn15 CTK Run
amenu 1.248 ToolBar.-sep5-1- <Nop>


" CtrlSF {{{2

" bind K to grep word under cursor
nnoremap K :<C-U>silent! :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" delimitMate {{{2

let g:delimitMate_expand_space = 1
let g:delimitMate_expand_cr    = 2
let g:delimitMate_jump_expansion = 0


" EasyAlign {{{2

let g:easy_align_delimiters = {
            \ 's': { 'pattern': '::' },
            \ '<': { 'pattern': '<<\|<=\|<-\|<' },
            \ '>': { 'pattern': '>>\|=>\|->\|>' },
            \ '/': {
            \     'pattern':         '//\+\|/\*\|\*/',
            \     'delimiter_align': 'l',
            \     'ignore_groups':   ['!Comment'] },
            \ ']': {
            \     'pattern':       '[[\]]',
            \     'left_margin':   0,
            \     'right_margin':  0,
            \     'stick_to_left': 0
            \   },
            \ ')': {
            \     'pattern':       '[()]',
            \     'left_margin':   0,
            \     'right_margin':  0,
            \     'stick_to_left': 0
            \   },
            \ 'd': {
            \     'pattern':      ' \(\S\+\s*[;=]\)\@=',
            \     'left_margin':  0,
            \     'right_margin': 0
            \   }
            \ }

" EasyVim {{{2

if &insertmode
    run! evim.vim
endif

" FoldText {{{2

set foldmethod=syntax

" { Syntax Folding
  let g:vimsyn_folding='af'
  let g:tex_fold_enabled=1
  let g:xml_syntax_folding = 1
  let g:clojure_fold = 1
  let ruby_fold = 1
  let perl_fold = 1
  let perl_fold_blocks = 1
" }

set foldenable
set foldlevel=0
set foldlevelstart=0
" specifies for which commands a fold will be opened
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo

nnoremap <silent> za za:<c-u>setlocal foldlevel?<CR>

nnoremap <silent> zr zr:<c-u>setlocal foldlevel?<CR>
nnoremap <silent> zm zm:<c-u>setlocal foldlevel?<CR>

nnoremap <silent> zR zR:<c-u>setlocal foldlevel?<CR>
nnoremap <silent> zM zM:<c-u>setlocal foldlevel?<CR>

" Change Option Folds
nnoremap zi  :<c-u>call <SID>ToggleFoldcolumn(1)<CR>
nnoremap coz :<c-u>call <SID>ToggleFoldcolumn(0)<CR>
nmap     cof coz

function! s:ToggleFoldcolumn(fold)
  if &foldcolumn
    let w:foldcolumn = &foldcolumn
    silent setlocal foldcolumn=0
    if a:fold | silent setlocal nofoldenable | endif
  else
      if exists('w:foldcolumn') && (w:foldcolumn!=0)
        silent let &l:foldcolumn=w:foldcolumn
      else
        silent setlocal foldcolumn=4
      endif
      if a:fold | silent setlocal foldenable | endif
  endif
  setlocal foldcolumn?
endfunction

" indent guide {{{2

let g:indent_guides_guide_size=1


" Lua {{{2

if exists('$QUICK_V3_ROOT')
    let g:lua_path = $QUICK_V3_ROOT."quick/cocos/?.lua;".
                   \ $QUICK_V3_ROOT."quick/cocos/?/init.lua;".
                   \ $QUICK_V3_ROOT."quick/framework/?.lua;".
                   \ $QUICK_V3_ROOT."quick/framework/?/init.lua;".
                   \ $LUA_PATH

    if has('lua')
        lua package.path=vim.eval('g:lua_path')..';'..package.path
    endif
endif

"let lua_complete_keywords = 1
"let lua_complete_globals = 1
"let lua_complete_library = 1
"let lua_complete_dynamic = 1
let lua_complete_omni = 0



" neomake {{{2

" When reading a buffer (after 1s), and when writing (no delay).
silent!  call neomake#configure#automake('rw', 1000)

if has('win32') || !g:gui_running

let g:neomake_error_sign = {'text': 'E>', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {
            \   'text': 'W>',
            \   'texthl': 'NeomakeWarningSign',
            \ }
let g:neomake_message_sign = {
            \   'text': 'M>',
            \   'texthl': 'NeomakeMessageSign',
            \ }
let g:neomake_info_sign = {'text': 'I>', 'texthl': 'NeomakeInfoSign'}

endif

if !exists('g:neomake_erlang_erlc_target_dir')
    let g:neomake_erlang_erlc_target_dir = tempname()
endif

function! s:neomake_Erlang_GlobPaths() abort
    " Find project root directory.
    let root = get(b:, 'neomake_erlang_erlc_root',
             \ get(g:, 'neomake_erlang_erlc_root'))
    if empty(root)
        let rebar_config = neomake#utils#FindGlobFile('rebar.config')
        if !empty(rebar_config)
            let root = fnamemodify(rebar_config, ':h')
        else
            " At least try with CWD
            let root = getcwd()
        endif
    endif
    let root = fnamemodify(root, ':p')
    let build_dir = root . '_build'
    let ebins = []
    if isdirectory(build_dir)
        " Pick the rebar3 profile to use
        let default_profile = expand('%') =~# '_SUITE.erl$' ?  'test' : 'default'
        let profile = get(b:, 'neomake_erlang_erlc_rebar3_profile', default_profile)
        let ebins += neomake#compat#glob_list(build_dir . '/' . profile . '/lib/*/ebin')
        let target_dir = build_dir . '/neomake'
    else
        let target_dir = get(b:, 'neomake_erlang_erlc_target_dir',
                       \ get(g:, 'neomake_erlang_erlc_target_dir'))
    endif
    " If <root>/_build doesn't exist it might be a rebar2/erlang.mk project
    if isdirectory(root . 'deps')
        let ebins += neomake#compat#glob_list(root . 'deps/*/ebin')
    endif
    " Set g:neomake_erlang_erlc_extra_deps in a project-local .vimrc, e.g.:
    "   let g:neomake_erlang_erlc_extra_deps = ['deps.local']
    " Or just b:neomake_erlang_erlc_extra_deps in a specific buffer.
    let extra_deps_dirs = get(b:, 'neomake_erlang_erlc_extra_deps',
                        \ get(g:, 'neomake_erlang_erlc_extra_deps'))
    if !empty(extra_deps_dirs)
        for extra_deps in extra_deps_dirs
            if extra_deps[-1] !=# '/'
                let extra_deps .= '/'
            endif
            let ebins += neomake#compat#glob_list(extra_deps . '*/ebin')
        endfor
    endif
    let args = ['-pa', 'ebin', '-I', 'include', '-I', 'src']
    for ebin in ebins
        let args += [ '-pa', ebin,
                    \ '-I', substitute(ebin, 'ebin$', 'include', '') ]
    endfor
    let args += get(b:, 'neomake_erlang_erlc_flags',
              \ get(g:, 'neomake_erlang_erlc_flags', []))
    if !isdirectory(target_dir)
        call mkdir(target_dir, 'p')
    endif
    let args += ['-o', target_dir]
    return args
endfunction

function! s:neomake_Erlang_InitForJob(jobinfo) abort dict
    let args = s:neomake_Erlang_GlobPaths()
    echomsg string(args)
    let self.args = args
endfunction

call neomake#config#set('ft.erlang.InitForJob',
            \ function('s:neomake_Erlang_InitForJob'))


" Neovim {{{2

function! g:NvimGUISetting()
    let g:gui_running = 1
    if exists(':GuiFont')
        GuiFont Monaco for Powerline:h16
        let g:airline_powerline_fonts = 1
        "GuiLinespace 8
    endif
    colors evening
endfunction

if has('nvim')
    call NvimGUISetting()
endif

" NERDTree {{{2

let NERDTreeBookmarksFile = s:tprefix.'/NERDTreeBookmarks'

" perl {{{2

let g:perl_fold = 1

" rainbow

let g:rainbow_active = 1

" surround {{{2

let g:surround_{char2nr("c")} = "/* \r */"


" zip {{{2
let g:loaded_zipPlugin= 1
let g:loaded_zip      = 1

" Denite.nvim {{{2

let g:neomru#file_mru_path = s:tprefix.'/mru_file'
let g:neomru#directory_mru_path = s:tprefix.'/mru_directory'
let g:neoyank#file = s:tprefix.'/yankring.txt'
call denite#custom#option('_', 'prompt', '❯')

" Mark {{{2

let g:mw_no_mappings = 1

" }}}2

endif

if exists('s:cpo_save')
    let &cpo = s:cpo_save
    unlet s:cpo_save
endif

" }}}1
" vim: set ft=vim ff=unix fdm=marker ts=8 sw=4 et sta nu:
