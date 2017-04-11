" ==========================================================
" File Name:    vimrc
" Author:       StarWing
" Version:      0.5 (2026)
" Last Change:  2017-04-10 22:21:59
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
endif
set cpo&vim " set cpo-=C cpo-=b

" generic Settings {{{2

"set ambiwidth=double
set bsdir=buffer
set complete-=i
set completeopt=longest,menu
set diffopt+=vertical
set display=lastline
set fileencodings=ucs-bom,utf-8,cp932,cp936,gb18030,latin1
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
"set statusline=
"set statusline+=%2*%-3.3n%0*%<  " buffer number
"set statusline+=%<\ %f  " file name
"set statusline+=\ %1*%h%m%r%w%0* " flag
"set statusline+=[
"
"if v:version >= 600
"    set statusline+=%{&ft!=''?&ft:'noft'}, " filetype
"    set statusline+=%{&fenc!=''?&fenc:&enc}, " fileencoding
"endif
"
"set statusline+=%{&fileformat}] " file format
"set statusline+=%= " right align
""set statusline+=\ %2*0x%-8B  " current char
"set statusline+=\ 0x%-8B  " current char
"set statusline+=\ %-12.(%l,%c%V%)[%o]\ %P " offset

if globpath(&rtp, "plugin/vimbuddy.vim") != ''
    set statusline+=\ %{VimBuddy()} " vim buddy
endif

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

if has('gui_running') " {{{2
    set co=120 lines=35

    if has('win32')
        silent! set gfn=Consolas:h9
        "silent! set gfw=YaHei_Mono:h10:cGB2312
        "exec 'set gfw='.iconv('新宋体', 'utf8', 'gbk').':h10:cGB2312'
    elseif has('mac')
        set gfn=Monaco:h10
    else
        "set gfn=Consolas\ 10 gfw=WenQuanYi\ Bitmap\ Song\ 10
        set gfn=DejaVu\ Sans\ Mono\ 9
    endif

endif " }}}2
if has("win32") " {{{2
    if $LANG =~? 'zh_CN' && &encoding !=? "cp936"
        set termencoding=cp936

        lang mes zh_CN.UTF-8

        set langmenu=zh_CN.UTF-8
        silent! so $VIMRUNTIME/delmenu.vim
        silent! so $VIMRUNTIME/menu.vim
    endif

    if has("directx")
        "set renderoptions=type:directx,geom:1
    endif

elseif has('unix') " {{{2
    if has('gui_running')
        lang mes zh_CN.UTF-8
        set langmenu=zh_CN.UTF-8
        silent! so $VIMRUNTIME/delmenu.vim
        silent! so $VIMRUNTIME/menu.vim
    endif
    if exists('$TMUX')
        set term=screen-256color
    endif
    if exists('$ITERM_PROFILE')
        if exists('$TMUX')
            let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
            let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
        elseif has('gui_running')
            let &t_SI = "\<Esc>]50;CursorShape=1\x7"
            let &t_EI = "\<Esc>]50;CursorShape=0\x7"
        endif
    end
    function! WrapForTmux(s)
        if !exists('$TMUX')
            return a:s
        endif

        let tmux_start = "\<Esc>Ptmux;"
        let tmux_end = "\<Esc>\\"

        return tmux_start.substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g').tmux_end
    endfunction

    function! XTermPasteBegin()
        set pastetoggle=<Esc>[201~
        set paste
        return ""
    endfunction

    if !has('gui_running')
        let &t_SI .= WrapForTmux("\<Esc>[?2004h")
        let &t_EI .= WrapForTmux("\<Esc>[?2004l")
        inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
    endif
endif " }}}2
" swapfiles/undofiles settings {{{2

let s:vimrcpath = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:tprefix = expand('~/.cache')

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

"}}}2
" ----------------------------------------------------------
" Helpers {{{1

" Environment Variables Setting {{{2
if has('eval')

    " mapleader value {{{3

    " let mapleader = ","

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

    " ~/.vim maybe use as vimfiles {{{3
    if has("win32") && isdirectory(expand('~/.vim'))
        set rtp+=~/.vim
    endif

    " viminfo path {{{3
    exec "set viminfo+=n".s:tprefix."/.viminfo"
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
                    \  ['python', 'Python35'         ],
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
        map<silent> <leader>od :<C-U>exec "cd" fnameescape(g:orig_dir)<BAR>NERDTreeToggle<CR>
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
        au FileType erlang se sw=2 sts=2 fdm=marker fdc=2
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

if has('gui_running')
    set go-=e
    let s:has_mt = glob("$VIM/_fullscreen") == "" &&
                \  glob("$VIM/vimfiles/_fullscreen") == "" &&
                \  glob("$HOME/.vim/_fullscreen") == ""
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


" DarkRoom {{{3

if has('win32') && executable('vimtweak.dll')
    let s:tweak_SetAlpha = 255
    let s:tweak_Caption = 1
    let s:tweak_Maximize = 0
    let s:tweak_TopMost = 0
    let s:tweak_initialize = 0

    function! s:tweak(method, argv)
        if !s:tweak_initialize
            " a bug in Vista
            if system('ver') =~ ' 6.'
                silent! libcallnr('vimtweak.dll', 'EnableTopMost', 0)
            endif

            let s:tweak_initialize = 1
        endif

        let s:tweak_{a:method} = a:argv
        return libcallnr('vimtweak.dll', (a:method == 'SetAlpha' ? '' : 'Enable').
                    \ a:method, a:argv)
    endfunction

    command! -bar -nargs=1 -count=0 VimTweak call s:tweak(<q-args>, <count>)
    command! -bang -bar Darkroom SwitchCaption | SwitchMaximize
    for var in ['Caption', 'Maximize', 'TopMost']
        exec 'com! -bar Switch'.var.' exec !s:tweak_'.var.
                    \ '."VimTweak '.var.'"'
    endfor
    command! -bar SwitchAlpha if s:tweak_SetAlpha == 255|230SetAlpha
                \ |else|255SetAlpha|endif
    command! -bar -count=255 SetAlpha <count>VimTweak SetAlpha
    map <F10> :<C-U>SwitchMaximize<CR>
    imap <F10> <ESC><F10>a
    map <F11> :<C-U>SwitchAlpha<CR>
    imap <F11> <ESC><F11>a
    map <F12> :<C-U>Darkroom!<CR>
    imap <F12> <ESC><F12>a
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

" explorer invoke {{{3

map <leader>ef :<C-U>vsp %:h<CR>
map <leader>ep :<C-U>vsp $VIMDOR<CR>
map <leader>es :<C-U>vsp $PRJDIR<CR>
map <leader>ev :<C-U>vsp $VIM<CR>
nmap <leader>ex :vsp .<CR>
xmap <leader>ex "ey:vsp <C-R>e<CR>

" vim invoke {{{3

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

" cd to current file folder {{{3

map <leader>cd :<C-U>cd %:h<CR>

" cmdline edit key, emacs style {{{3

nnoremap <Space> :
xnoremap <Space> :

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

" filetype settings {{{3
map <leader>f+ :<C-U>setf cpp<CR>
map <leader>fc :<C-U>setf c<CR>
map <leader>fC :<C-U>setf clojure<CR>
map <leader>fd :<C-U>setf dot<CR>
map <leader>fg :<C-U>setf go<CR>
map <leader>fh :<C-U>setf haskell<CR>
map <leader>fj :<C-U>setf java<CR>
map <leader>fl :<C-U>setf lua<CR>
map <leader>fL :<C-U>setf lisp<CR>
map <leader>fm :<C-U>setf markdown<CR>
map <leader>fM :<C-U>setf m4<CR>
map <leader>fP :<C-U>setf perl<CR>
map <leader>fp :<C-U>setf python<CR>
map <leader>fT :<C-U>setf tex<CR>
map <leader>fr :<C-U>setf rust<CR>
map <leader>fR :<C-U>setf rest<CR>
map <leader>fs :<C-U>setf scheme<CR>
map <leader>fT :<C-U>setf tcl<CR>
map <leader>ft :<C-U>setf text<CR>
map <leader>fv :<C-U>setf vim<CR>

" filter {{{3

map <leader>as :!astyle -oO -snwpYHU --style=kr --mode=c<CR>

" run current line {{{3
nmap <leader>rc :exec getline('.')[col('.')-1:]<CR>
xmap <leader>rc y:exec @"<CR>
nmap <leader>ec :echo eval(getline('.'))[col('.')-1:]<CR>
xmap <leader>ec y:echo eval(@")<CR>

" get syntax stack {{{3
" nmap<silent> <leader>gs :echo ""<bar>for id in synstack(line('.'),col('.'))
"             \\|echo synIDattr(id, "name")
"             \\|endfor<CR>

" vimrc edit {{{3
if has("win32")
    map <leader>re :drop $VIM/vimfiles/_vimrc<CR>
    map <leader>rr :so $VIM/vimfiles/_vimrc<CR>
else
    map <leader>re :drop $MYVIMRC<CR>
    map <leader>rr :so $MYVIMRC<CR>
endif

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
    " Build buffer with zip
    nmap zB gGzp
    " get text zipped
    nmap gz zyaa``

    " set Y operator tp y$
    map Y y$
endif

" set buffer tabstop and sw and et

map <leader>f1 :<C-U>setl ts=8 sw=4 et nu fdm=syntax fdc=2<CR>
map <leader>f2 :<C-U>setl ts=4 sw=4 noet nu fdm=syntax fdc=2<CR>

" indent {{{3

xmap > >gv
xmap < <gv
nmap g= gg=G
xmap g= gg=G

" quickfix error jumps {{{3

map <leader>qj :<C-U>cn!<CR>
map <leader>qk :<C-U>cp!<CR>

" quick complete (against supertab) {{{3

"inor <m-n> <c-n>
"inor <m-p> <c-p>

" visual # and * operators {{{3

xnor<silent> # "sy?\V<C-R>=substitute(escape(@s, '\?'), '\n', '\\n', 'g')<CR><CR>
xnor<silent> * "sy/\V<C-R>=substitute(escape(@s, '\/'), '\n', '\\n', 'g')<CR><CR>

" redo {{{3

map <m-r> <c-r>

" diff get/put {{{3

map <leader>dg :diffget
map <leader>dp :diffput
map <leader>du :diffupdate

" window navigating {{{3

nmap <C-+> <C-W>+
nmap <C-,> <C-W><
nmap <C--> <C-W>-
nmap <C-.> <C-W>>
nmap <C-=> <C-W>=
nmap <C-h> <C-W>h
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-l> <C-W>l
xmap <C-+> <C-W>+
xmap <C-,> <C-W><
xmap <C--> <C-W>-
xmap <C-.> <C-W>>
xmap <C-=> <C-W>=
xmap <C-h> <C-W>h
xmap <C-j> <C-W>j
xmap <C-k> <C-W>k
xmap <C-l> <C-W>l

" window resizing {{{3

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

" window moving {{{3


map <M-S-J> <C-W>J
map <M-S-K> <C-W>K
map <M-S-H> <C-W>H
map <M-S-L> <C-W>L

" tab navigating {{{3
nnoremap <leader>1 :tabnext 1<CR>
nnoremap <leader>2 :tabnext 2<CR>
nnoremap <leader>3 :tabnext 3<CR>
nnoremap <leader>4 :tabnext 4<CR>
nnoremap <leader>5 :tabnext 5<CR>
nnoremap <leader>6 :tabnext 6<CR>
nnoremap <leader>7 :tabnext 7<CR>
nnoremap <leader>8 :tabnext 8<CR>
nnoremap <leader>9 :tabnext 9<CR>

" save {{{3

map <C-S> :<C-U>w<CR>

" Function Key maps {{{3

" f1: show the wildmenu {{{4
map <F1> :<C-U>emenu <C-Z>
imap <F1> <ESC><F1>

" in cmode, it means print time
cnoremap <f1> <C-R>=escape(strftime("%Y-%m-%d %H:%M:%S"), '\ ')<CR>

" f2: VimFilerExplorer {{{4
map <F2> :VimFilerExplorer<CR>
imap <F2> <ESC><F2>

" f3: shell {{{4
map <F3> :VimShellTab<CR>
imap <F3> <ESC><F3>

" f4: clear hlsearch and qf/loc window {{{4
map <F4> :<C-U>noh\|pcl\|ccl\|lcl<CR>
imap <F4> <ESC><F4>a

" }}}4

" }}}3

" }}}2
" ----------------------------------------------------------
" plugin settings {{{1
if has('eval')


" Vundle {{{2

filetype off

let s:bundlePath=s:vimrcpath.'/bundle'
let &rtp.=','.s:bundlePath.'/Vundle.vim'
call vundle#begin(s:bundlePath)
unlet s:bundlePath

if exists(':Plugin')
Plugin 'hexman.vim'

Plugin 'VundleVim/Vundle.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'bling/vim-airline'
Plugin 'Shougo/neomru.vim'
Plugin 'Shougo/unite.vim'
Plugin 'Shougo/unite-outline'
Plugin 'Shougo/neossh.vim'
Plugin 'Shougo/vimproc.vim'
Plugin 'Shougo/vimshell.vim'
Plugin 'Shougo/vimfiler.vim'
Plugin 'Shougo/vinarise.vim'
Plugin 'yianwillis/vimcdoc'
Plugin 'godlygeek/tabular'
Plugin 'Raimondi/delimitMate'
"Plugin 'jiangmiao/auto-pairs'
Plugin 'mbbill/echofunc'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'qingxbl/Mark--Karkat'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'
Plugin 'dyng/ctrlsf.vim'
Plugin 'terryma/vim-multiple-cursors'

" Language-spec
Plugin 'Shutnik/jshint2.vim'
Plugin 'OrangeT/vim-csharp'
Plugin 'wting/rust.vim'
Plugin 'zah/nim.vim'
Plugin 'tikhomirov/vim-glsl'
Plugin 'elzr/vim-json'
Plugin 'thinca/vim-logcat'
Plugin 'leafo/moonscript-vim'
Plugin 'raymond-w-ko/vim-lua-indent'
Plugin 'vim-erlang/vim-erlang-runtime'

if glob(s:vimrcpath.'/_enableYouCompleteMe') != ''
    Plugin 'Valloric/YouCompleteMe'
endif

"Plugin 'xolox/vim-misc'  " required by lua.vim
"Plugin 'xolox/vim-lua-ftplugin'  " Lua file type plug-in for the Vim text editor

call vundle#end()
call s:rtp_fix()
endif
filetype plugin indent on

" colorscheme {{{2
let base16colorspace=256
set background=dark
silent! colorscheme base16-eighties

" Easy Vim {{{2

if &insertmode
    run! evim.vim
endif

" 2html {{{2

let html_dynamic_folds = 1
let html_ignore_conceal = 1
let html_no_pre = 1
let html_use_css = 1

" airline {{{2

let g:airline_symbols_ascii=1

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
            \ }

let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16_eighties'

" ctk {{{2

amenu 1.246 ToolBar.BuiltIn25 :CC<CR>
tmenu ToolBar.BuiltIn25 CTK Compile
amenu 1.247 ToolBar.BuiltIn15 :RUN<CR>
tmenu ToolBar.BuiltIn15 CTK Run
amenu 1.248 ToolBar.-sep5-1- <Nop>



" delimitMate {{{2

let g:delimitMate_expand_space = 1
let g:delimitMate_expand_cr    = 2
let g:delimitMate_jump_expansion = 0


" EasyGrep {{{2

let g:EasyGrepMode=2 " TrackExt
let g:EasyGrepCommand = 1


" indent guide {{{2

let g:indent_guides_guide_size=1


" mru {{{2

let g:neomru#file_mru_path = s:tprefix.'/neomru/file'
let g:neomru#directory_mru_path = s:tprefix.'/neomru/directory'
let g:unite_data_directory = s:tprefix.'/unite'

map <leader>u :Unite file_mru<CR>
map <leader>uu :Unite file_mru<CR>
map <leader>uf :Unite outline<CR>
map <leader>ub :Unite buffer<CR>

" multiple-cursors  {{{2

let g:multi_cursor_exit_from_insert_mode = 0
let g:multi_cursor_exit_from_visual_mode = 0

" perl {{{2

let g:perl_fold = 1

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



" surround {{{2

let g:surround_{char2nr("c")} = "/* \r */"


" syntastic {{{2

if exists(':SyntasticStatuslineFlag')
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
endif
let g:syntastic_cpp_compiler_options='-std=c++11'

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

" vcscommand {{{2

let g:VCSCommandMapPrefix = "<leader>vc"

" zip {{{2
let g:loaded_zipPlugin= 1
let g:loaded_zip      = 1

" }}}2
" VimShell {{{2
let g:vimshell_data_directory = s:tprefix.'/vimshell'
let g:vimshell_enable_smart_case = 1
let g:vimshell_prompt = '> '

" }}}2
" YouCompleteMe {{{2
nmap <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>

" VimFiler {{{2

" Disable netrw.vim
let g:loaded_netrwPlugin = 1
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_data_directory = s:tprefix.'/vimfiler'

" }}}

endif

if exists('s:cpo_save')
    let &cpo = s:cpo_save
    unlet s:cpo_save
endif

" }}}1
" vim: set ft=vim ff=unix fdm=marker ts=8 sw=4 et sta nu:
