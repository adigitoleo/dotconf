" * * * * * * * * * * * * * *                    * * * * * * * * * * * * * * "
" * * *                                                                * * * "
" * *                     NEOVIM CONFIGURATION FILE                      * * "
" *                                                                        * "
" NOTE: Plugins are served using vim-plug. See the PLUGINS selection for more.
"       To set up vim-plug, first set g:VIM_PLUG_PATH and g:PLUGIN_HOME to the
"       desired paths (below). Next, ensure the correct plugin dependencies
"       are available and :call InitPlug(). Finally, restart and :PlugInstall

let g:VIM_PLUG_PATH = expand(stdpath('config') .. '/autoload/plug.vim')
let g:PLUGIN_HOME = expand(stdpath('data') .. '/plugged')

if executable('/usr/bin/python3')
    let g:python3_host_prog = '/usr/bin/python3'
    " NOTE: This python binary should have access to the `pynvim` module.
endif

" FUNCTIONS {{{1
function! InitPlug() abort "{{{2
    " Initialise plugin manager setup <https://github.com/junegunn/vim-plug>.
    echom 'Starting initial vim-plug setup...'
    if !executable('curl')
        echohl ErrorMsg
        echom 'Downloading vim-plug requires the `curl` program.'
        echom 'For Windows, download vim-plug yourself. '
                    \ ..'See https://github.com/junegunn/vim-plug'
        echohl None
        return
    else
        if empty(glob(g:VIM_PLUG_PATH))
            echom 'Downloading vim-plug plugin manager...'
            silent exec '!curl -fLo ' .. g:VIM_PLUG_PATH .. ' --create-dirs '
                \ ..'https://raw.githubusercontent.com/'
                \ ..'junegunn/vim-plug/master/plug.vim'
        else
            echohl WarningMsg
            echom 'Found existing file at ' .. g:VIM_PLUG_PATH
            echohl None
        endif
    endif
    echom 'Creating plugin directory...'
    call mkdir(g:PLUGIN_HOME, "p")
    echom 'Setup complete!'
    echom 'Restart neovim and run :PlugInstall to install plugins.'
endfunction

function! s:BufList() abort " {{{2
    " Get a list of open ('listed') buffer names.
    let l:bufnames = []
    for l:buf in getbufinfo({'buflisted': 1})
        let l:bufnames += [l:buf.name]
    endfor
    return l:bufnames
endfunction

function! s:FileFeed(sources, mods, sep) abort "{{{2
    " Get shell command to generate parsed and filtered file names.
    " a:sources -- list, each source is a sublist of file names
    " a:mods -- string, see :h filename-modifiers and :h fnamemodify()
    " a:sep -- string, separator to use for the file list e.g. '\n' or ' '

    " Respect &wildignore and ignore unnamed/help buffers.
    let l:ignore = split(&wildignore, ',') + ['^$', $VIMRUNTIME]
    if strchars(expand("%" .. a:mods))  " Exclude current buffer if named
        let l:ignore += [expand("%" .. a:mods)]
    endif

    let l:files = []
    for l:source in a:sources
        for l:file in l:source
            if filereadable(l:file)
                let l:file = fnamemodify(l:file, a:mods)
                if count(l:files, l:file) == 0  " Don't add duplicate filenames
                    let l:files += [l:file]
                endif
            endif
        endfor
    endfor

    for l:irule in l:ignore
        " Remove wildignore globs, filter() already matches on substrings.
        let l:irule = substitute(l:irule, '\*', '', 'g')
        " Escape dots since fnameescape() doesn't do it.
        let l:irule = substitute(l:irule, '\.', '\\\.', 'g')
        " Filter out blacklist matches.
        call filter(l:files, 'v:val !~? "'.fnameescape(l:irule).'"')
    endfor
    " Return as shell command to allow async streaming into fzf.
    if !empty(l:files)
        return 'echo -e "' .. join(l:files, a:sep) .. '"'
    else
        return 'true'
    endif
endfunction

function! s:TermFeed() abort "{{{2
    " Get shell command to generate a list of terminal buffers.
    let l:terminals = []
    for l:buf in getbufinfo({'bufloaded': 1})
        if l:buf.name =~ "term://"
            let l:terminals += [l:buf.name]
        endif
    endfor

    if strchars(expand("%"))  " Exclude current buffer if named
        " Escape dots since fnameescape() doesn't do it.
        let l:ignore = substitute(expand("%"), '\.', '\\\.', 'g')
        call filter(l:terminals, 'v:val !~? "' .. fnameescape(l:ignore) .. '"')
    endif

    " Return as shell command to allow async streaming into fzf.
    if !empty(l:terminals)
        return 'echo -e "' .. join(l:terminals, '\n') .. '"'
    else
        return 'true'
    endif
endfunction

function! s:CmdFeed() abort "{{{2
    " Get shell command to generate list of (almost) all *vim commands.
    let l:cmdlist = []

    " Get builtin commands from help index (extra arg bypasses wildignore).
    let l:help = expand('$VIMRUNTIME/doc/index.txt', 1)
    for l:line in readfile(l:help)
        if l:line =~ '^|:ex|'  " Exclude redundant and confusing legacy :ex cmd
            continue
        elseif l:line =~ '^|:grep|'  " Exclude braindead :grep (why u no :copen?)
            continue
        elseif l:line =~ '^|:\w\+|'  " Exclude 'special' commands like :! or :/
            let l:cmdlist += [matchstr(l:line, '^|:\zs\w\+\ze|')]
        endif
    endfor

    " Get user/plugin defined commands from `:command`.
    let l:com = split(execute('command'), '\n')[2:]
    for l:line in l:com
        if l:line =~ '^.\{4}\w\+'
            let l:cmdlist += [matchstr(l:line, '^.\{4}\zs\w\+\ze')]
        endif
    endfor
    " Return as shell command to allow async streaming into fzf.
    return 'echo -e "' .. join(l:cmdlist, '\n') .. '"'
endfunction

function! s:TermQuit(job_id, code, event) dict "{{{2
    " Callback to automatically delete terminal buffers on exit code 0.
    if a:code == 0 && &buftype == 'terminal'
        bdelete!
    endif
endfunction

function! s:HorizontalScrollMode(scrolltype) abort "{{{2
    " Allow continuous horizontal scrolling with 'z' + {'h', 'l', 'H' or 'L'}.
    " a:scrolltype -- string, a letter (as above), see `:h scroll-horizontal`.
    " <https://stackoverflow.com/a/59950870/12519962>
    if &wrap
        return
    endif

    echohl Title
    let typed_char = a:scrolltype
    while index( [ 'h', 'l', 'H', 'L' ], typed_char ) != -1
        execute 'normal! z' .. typed_char
        redrawstatus
        echon '-- Horizontal scrolling mode (h/l/H/L)'
        let typed_char = nr2char(getchar())
    endwhile
    echohl None | echo '' | redrawstatus
endfunction

function! NeatFoldText() abort "{{{2
    " Simplified, cleaner foldtext.

    " Make 'commentstring' into a more robust regex pattern.
    let l:commentstring = substitute(&commentstring, '%s', '\\s\\?%s', '')
    " Remove default fold markers, see :h foldmarker
    let l:match = '\s\?{\{3}\d\?'
    " Remove comment characters.
    let l:match .= '\|' .. join(split(l:commentstring, '%s'), '\|')
    " Remove triple-quotes (Python docstring syntax)
    let l:match .= '\|"""'

    let l:headerline = substitute(getline(v:foldstart), l:match, '', 'g')
    " Add a space at the end before optional fill chars.
    let l:foldtext = repeat('+ ', foldlevel(v:foldstart)) .. l:headerline .. ' '
    return l:foldtext
endfunction

function! CleanEmptyBuffers() abort "{{{2
    " Delete empty buffers that are not open in any window.
    " Based on <https://stackoverflow.com/a/10102604/12519962>
    " Best to run on CursorHold instead of WinEnter or something like that.
    let buffers = filter(range(1, bufnr('$')),
                \ 'bufexists(v:val) && empty(bufname(v:val)) &&
                \ bufwinnr(v:val)<0 && !getbufvar(v:val, "&mod")'
                \ )
    if !empty(buffers)
        exec 'bw ' .. join(buffers, ' ')
    endif
endfunction

function! DOS2unix() abort "{{{2
    " Convert DOS-style line endings to unix newlines.
    if &modifiable
        keeppatterns %s/\m\r\+$//ge
    endif
endfunction

function! FillLine() abort "{{{2
    " Fill line by repeating a string pattern.
    if &textwidth
        let l:str = input('FillLine>')  " Prompt for pattern
        " Add space after content if present and ends in different character.
        exec '.s/\m\([^\S' .. l:str .. ']\+\)$/\1 /e'

        " Calculate how many repetitions will fit.
        let l:lastcol = col('$')-1  " See :h col()
        if l:lastcol > 1
            let l:numstr = float2nr(floor((&textwidth-l:lastcol)/len(l:str)))
        else
            let l:numstr = float2nr(floor(&textwidth/len(l:str)))
        endif

        if l:numstr > 0
            .s/\m$/\=(repeat(l:str, l:numstr))/  " Append repeated pattern
        endif
    else
        echohl WarningMsg
        echom "FillLine requires nonzero textwidth setting"
        echohl None
    endif
endfunction

function! CopyFile() abort "{{{2
    " Copy file name, path or directory to clipboard.
    let l:msg = "Copy to clipboard:"
    let l:opt = "&Path\n&File name\n&Directory\n&Quit"
    let l:choice = confirm(l:msg, l:opt)

    if l:choice == 1
        let @+=expand('%:p')
    elseif l:choice == 2
        let @+=expand('%:t')
    elseif l:choice == 3
        let @+=expand('%:p:h')
    endif
    echo getreg()
endfunction

function! SmartSplit(...) abort "{{{2
    " Open new split and choose vertical or horizontal layout automatically.
    " a:1 -- string (optional), file name of buffer to open in split
    if !empty(a:1)
        exec (winwidth(0) > 120 ? 'vert ' : '') .. 'sbuffer ' .. a:1
    else
        exec (winwidth(0) > 120 ? 'vert ' : '') .. 'split|enew'
    endif
endfunction

function! Floating(buftag, ...) abort "{{{2
    " Check for adequate parent window size.
    if &columns < 25 || &lines < 30
        echoerr "failed to open floating window; vim window is too small"
        return v:true
    endif
    " Focus or create a floating window, a:1 sets the buftype.
    if exists("t:floating_buffers") && has_key(t:floating_buffers, a:buftag)
                \ && bufexists(t:floating_buffers[a:buftag])
        let l:buf = t:floating_buffers[a:buftag]
    else
        if exists("t:floating_buffers") && has_key(t:floating_buffers, a:buftag)
                    \ && !bufexists(t:floating_buffers[a:buftag])
            unlet t:floating_buffers[a:buftag]
        endif
        let l:buf = nvim_create_buf(v:false, v:true)
        if a:0 == 1 | call nvim_buf_set_option(l:buf, 'buftype', a:1) | endif
    endif
    let l:winconfig = {
                \   'relative': 'editor',
                \   'border': 'single',
                \   'row': 5,
                \   'col': 5,
                \   'width': &columns - 10,
                \   'height': &lines - 12,
                \}
    if exists("t:floating_window") && win_id2win(t:floating_window) > 0
        call win_gotoid(t:floating_window)
        call nvim_win_set_buf(t:floating_window, l:buf)
    else
        let l:win = nvim_open_win(l:buf, v:true, l:winconfig)
        call nvim_tabpage_set_var(0, 'floating_window', l:win)
    endif
    set nowrap nolist
    if !exists("t:floating_buffers")
        call nvim_tabpage_set_var(0, 'floating_buffers', {a:buftag : l:buf})
    elseif !has_key(t:floating_buffers, a:buftag)
        let t:floating_buffers[a:buftag] = l:buf
    else
        return v:true
    endif
    return v:false
endfunction

function! StartTerm(...) abort "{{{2
    " Create a floating terminal and optionally execute a shell command.
    if a:0
        if executable(a:1)
            let l:cmdstr = a:0 > 1 ? expandcmd(join(a:000)) : a:1
        else
            echoerr "no executable command called " .. a:1 | return
        endif
    else
        let l:cmdstr = &shell
    endif
    let l:has_buf = Floating(l:cmdstr)
    if l:has_buf | return | endif
    call nvim_buf_set_option(0, 'modified', v:false)
    call termopen(
                \ 'export TERM=' .. $TERM .. ' && ' .. l:cmdstr,
                \ a:0 ? {} : {"on_exit": function("<SID>TermQuit")},
                \)
endfunction

" OPTIONS {{{1
" Global booleans. {{{2
set noshowmode
set confirm
set ignorecase smartcase infercase
set signcolumn=yes
set splitbelow splitright
set hidden
set nojoinspaces
set noincsearch
set linebreak
set list
" Global configs. {{{2
if has('mouse')
    set mouse=a
endif
set spelllang=en_au
set spellfile=~/.config/nvim/after/spell/extras.en.utf-8.add
set timeoutlen=500
set clipboard+=unnamedplus
set matchpairs+=<:>
set shortmess+=cI
set shortmess-=F
set formatoptions-=t
let &scrolloff=3
let &showbreak='--'
set listchars+=trail:\ ,precedes:<,extends:>
set pumheight=15
set completeopt=menu,noselect,preview
set helpheight=0
set synmaxcol=200
" Indentation. {{{2
set tabstop=4      " Set indent size.
set softtabstop=-1 " Use tabstop value to insert indents with <Tab>.
set shiftwidth=0   " Use tabstop value to shift indent level with '<<','>>'.
set shiftround     " Round all indentation to multiples of tabstop value.
set expandtab      " Use spaces for indents.
" Folding. {{{2
set nofoldenable            " Don't enable folding by default.
set foldclose=all           " Motions that automatically close folds.
set foldopen-=block         " Motions that automatically open folds.
set fillchars=fold:\ ,      " Remove excessive fillchars for folds.
set foldtext=NeatFoldText() " Use custom foldtext.
" Misc. {{{2
if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --follow
endif

" COMMANDS {{{1
" Fuzzy finder (fzf) integration. {{{2
" <https://github.com/junegunn/fzf/blob/master/README-VIM.md>
if type(function('fzf#run'))
    " Configure default picker window.
    let g:fzf_layout = { 'window': {
                \   'width': 0.9, 'height': 0.6,
                \   'border': 'sharp', 'highlight': 'StatusLine',
                \}}

    function! s:FZFspecgen(source, dir, ...)
        " Generate spec for custom fuzzy finders.
        let l:dir = substitute(fnamemodify(a:dir, ':~'), '/*$', '/', '')
        return {
        \ 'source': a:source,
        \ 'sink': 'e',
        \ 'dir': l:dir,
        \ 'options': [
        \   '--multi',
        \   '--preview', 'case $(file {}) in *"text"*) head -200 {} ;;'
        \       .. '*) echo "Preview unavailable" ;; esac',
        \   '--preview-window', &columns > 120 ? 'right:60%:sharp' : 'down:60%:sharp',
        \   '--prompt', get(a:, 1, l:dir .. ' '),
        \ ]
        \}
    endfunction

    " Open recent files (v:oldfiles) or listed buffers.
    command! -bang FuzzyRecent call fzf#run(fzf#wrap(
        \ s:FZFspecgen(s:FileFeed([v:oldfiles, s:BufList()], ':~:.', '\n'),
        \ '', "Recent files: "), <bang>0))
    " Open files in <dir> (or :pwd by default).
    if !executable("rg")|echoerr "FuzzyFind command requires ripgrep"|endif
    command! -complete=dir -nargs=? -bang FuzzyFind call fzf#run(fzf#wrap(
        \ s:FZFspecgen("rg --files --hidden --no-messages" .. ' ;' .. s:TermFeed(), <q-args>),
        \ <bang>0))
    " Switch between listed buffers or loaded `:terminal` buffers.
    command! -bang FuzzySwitch call fzf#run(fzf#wrap(
        \ s:FZFspecgen(s:FileFeed([s:BufList()], ':~:.', '\n') .. ' ;' .. s:TermFeed(),
        \ '', "Open buffers: "), <bang>0))

    " Search for (most) cmdline mode commands. See s:CmdFeed() for details.
    " Semicolon <;> drops back to normal command line, <space>, ! or | are
    " appended to the match. Can't use ranges (nor from visual mode).

    function! s:FuzzyCmd_accept(fzf_out)
        let l:query = a:fzf_out[0]
        let l:key = a:fzf_out[1]
        let l:completion = get(a:fzf_out, 2, '')

        if empty(l:key)
            call nvim_input(':' .. l:completion .. '<Cr>')
        elseif l:key ==# ';'
            call nvim_input(':' .. l:query .. '')
        elseif l:key ==# 'space'
            call nvim_input(':' .. l:completion .. ' ')
        else
            call nvim_input(':' .. l:completion .. l:key .. ' ')
        endif
    endfunction

    command! FuzzyCmd
                \ call fzf#run({
                \   'source': s:CmdFeed(),
                \   'sink*': function('s:FuzzyCmd_accept'),
                \   'window': {
                \       'width': 1, 'height': 0.4, 'xoffset': 0, 'yoffset': 1,
                \       'border': 'top', 'highlight': 'StatusLine',
                \   },
                \   'options': [
                \       '--no-multi',
                \       '--print-query',
                \       '--prompt', ':',
                \       '--color', 'prompt:-1',
                \       '--expect', ';,space,!,|',
                \       '--layout', 'reverse-list',
                \   ]
                \})
endif

" Executable shortcuts. {{{2
if executable('theme')  " Toggle global TUI theme using external script.
    command! ToggleTheme silent! exec '!theme -t'
                \| let &background = get(systemlist('theme -q'), 0, 'light')
    command! SyncTheme silent! let &background = get(systemlist('theme -q'), 0, 'light')
endif
command! -nargs=* -complete=shellcmd Term call StartTerm(<f-args>)

" Misc. {{{2
" Help, my window is floating!
command! -complete=help -nargs=? H call Floating("help", "help") | help <args>
" Insert current date in ISO (YYYY-MM-DD) format.
command! InsertDate silent! exec "normal! a" .. strftime('%Y-%m-%d') .. "<Esc>"
" See :function FillLine.
command! FillLine call FillLine()
" Change current line to title case.
command! TitleCase silent! .s/\v(.*)/\L\1/|.s/\v<(\a)(\a{3,})/\u\1\L\2/g
" Change current line to sentence case.
command! SentenceCase silent! .s/\v(.*)/\L\1/|.s/\v<(\a)(\a*)/\u\1\L\2/
" Strip trailing whitespace.
command! StripTrails silent! keeppatterns %s/\s\+$//e
" Smart buffer splitting based on terminal width.
command! -nargs=? -bar -complete=buffer SmartSplit call SmartSplit(<q-args>)
" Easier vertical window resizing.
command! -nargs=1 Vresize exec 'vert resize' .. <q-args>
" Count occurances of a word without moving cursor (supports `n`/`N`).
command! -nargs=1 -range=% CountWord <line1>,<line2>s/\<<args>\>//gn
" Like :grep but open quickfix list for match selection (should be default...)
command! -nargs=+ Grep exec 'silent grep! <q-args>' | copen
" Like the above but search only in open buffers.
command! -nargs=+ BufGrep exec 'silent grep! <q-args> ' .. join(s:BufList(), ' ') | copen
" Edit a new buffer in the same directory as the focused buffer.
command! -nargs=1 EditNear exec 'edit %:h/' .. <q-args>

" AUTOCOMMANDS {{{1
" Special terminal buffer settings and overrides. {{{2
augroup terminal_buffer_rules
    autocmd!
    autocmd TermOpen * setlocal nonumber norelativenumber signcolumn=no
    autocmd TermOpen * startinsert
    autocmd TermEnter * setlocal scrolloff=0
    autocmd BufEnter,WinEnter term://* startinsert | setlocal nobuflisted
augroup END

" Special filetype settings and overrides. {{{2
augroup filetype_rules
    autocmd!
    " Consider using ftplugin scripts for complex stuff, `:h ftplugin`.
    " Verify that ':filetype' returns 'plugin:ON'.
    autocmd FileType sh,zsh setlocal textwidth=79
    autocmd FileType qf setlocal number norelativenumber cursorline textwidth=0
    autocmd FileType vim setlocal textwidth=78 foldmethod=marker foldenable
    autocmd FileType bash,sh setlocal foldmethod=marker
    autocmd FileType make setlocal noexpandtab
    autocmd FileType markdown setlocal foldlevel=1 foldenable
    autocmd FileType python setlocal textwidth=88 foldmethod=syntax
    autocmd FileType julia setlocal textwidth=92
    autocmd FileType plaintex setlocal filetype=tex
    autocmd FileType tex setlocal textwidth=0 wrap
    autocmd FileType enaml setlocal textwidth=88 filetype=python.enaml
    autocmd FileType yaml setlocal tabstop=2
    autocmd FileType css setlocal tabstop=2
    autocmd FileType xml,html setlocal tabstop=2
    autocmd FileType desktop set commentstring=#\ %s
    autocmd FileType fortran setlocal textwidth=92
    autocmd FileType nim setlocal softtabstop=-1 shiftwidth=0
    autocmd FileType cpp setlocal tabstop=2
augroup END

" Miscellaneous. {{{2
augroup misc
    autocmd!
    autocmd BufWritePost * exec "normal! " .. &foldenable ? "zx" : ""
    autocmd BufWritePost * if exists(":TagGen") > 0 | exec "TagGen" | fi
    autocmd CursorHold * call CleanEmptyBuffers()
    autocmd VimEnter,BufWinEnter * let &colorcolumn = "+" .. join(range(&columns)[1:], ",+")
    autocmd InsertLeave,CompleteDone * silent! pclose
    autocmd VimResized * wincmd =
    autocmd ColorScheme mellow hi link NormalFloat Normal
augroup END

" MAPPINGS {{{1
" De gustibus: general fixes and tweaks. {{{2
" Ergonomic, smart mode switches.
inoremap ¶ <Esc>
inoremap <M-;> <Esc>
nnoremap ; <Cmd>FuzzyCmd<Cr>
xnoremap ; :
xnoremap ¶ <Esc>
xnoremap <M-;> <Esc>
cnoremap ¶ <C-c>
cnoremap <M-;> <C-c>
tnoremap ° <C-\><C-n>
tnoremap <M-S-;> <C-\><C-n>
nnoremap q; q:
nnoremap Q <Nop>
" Some shell-style improvements to command mode mappings.
cnoremap <C-p> <Up>
cnoremap <C-n> <Up>
cnoremap <C-a> <C-b>
" Make Y consistent with D and C.
nnoremap Y y$
" Search in selection.
xnoremap / <Esc>/\%V
" Redo (can't use U, see :h U).
nnoremap yu <Cmd>redo<Cr>
" CTRL-L also clears search highlighting.
nnoremap <silent> <C-l> <Cmd>nohlsearch<Cr><C-l>
" Disable middle mouse paste.
noremap <MiddleMouse> <Nop>
noremap <2-MiddleMouse> <Nop>
noremap <3-MiddleMouse> <Nop>
noremap <4-MiddleMouse> <Nop>
" HorizontalScrollMode allows continuous scrolling with the indicated char.
nnoremap <silent> zh :call <SID>HorizontalScrollMode('h')<Cr>
nnoremap <silent> zl :call <SID>HorizontalScrollMode('l')<Cr>
nnoremap <silent> zH :call <SID>HorizontalScrollMode('H')<Cr>
nnoremap <silent> zL :call <SID>HorizontalScrollMode('L')<Cr>
" Tap space to clear messages.
nnoremap <silent> <Space> <Cmd>mode<Cr>

" Meta mappings: buffer navigation and control. {{{2
" Window navigation and relocation.
nnoremap ï <Cmd>wincmd w<Cr>
nnoremap <M-j> <Cmd>wincmd w<Cr>
nnoremap œ <Cmd>wincmd W<Cr>
nnoremap <M-k> <Cmd>wincmd W<Cr>
nnoremap ñ <Cmd>wincmd n<Cr>
nnoremap <M-n> <Cmd>wincmd n<Cr>
nnoremap ö <Cmd>wincmd p<Cr>
nnoremap <M-p> <Cmd>wincmd p<Cr>

" Leader mappings: run commands and call functions. {{{2
let mapleader = "\<Space>"
let maplocalleader = ","

" Insert char after cursor [count] times.
nnoremap <expr>     <Leader>a 'a' .. nr2char(getchar()) .. '<Esc>'
" Use FuzzySwitch to switch buffers.
nnoremap            <Leader>b <Cmd>FuzzySwitch<Cr>
" Toggle cursor column indicator.
nnoremap            <Leader>c <Cmd>set cursorcolumn!<Cr>
" Change working directory of focused window to directory containing focused file/buffer (fall back to HOME).
nnoremap <expr>     <Leader>d '<Cmd>lcd ' .. (empty(&buftype) && !empty(bufname()) ? '%:p:h' : '') .. '<Bar>pwd<Cr>'
" Open FuzzyFind quickly.
nnoremap            <Leader>f <Cmd>FuzzyFind<Cr>
" Toggle folding in focused buffer.
nnoremap            <Leader>h <Cmd>setlocal foldenable!<Cr>
" Insert char before cursor [count] times.
nnoremap <expr>     <Leader>i 'i' .. nr2char(getchar()) .. '<Esc>'
" Toggle cursor line indicator.
nnoremap            <Leader>l <Cmd>set cursorline!<Cr>
" Run :make! (the ! disables the stupid errorfile jump btw)
nnoremap            <Leader>m <Cmd>make!<Cr>
" Toggle line numbers for focused buffer.
nnoremap <silent>   <Leader>n <Cmd>set number! relativenumber!<Cr>
" Add [count] blank line(s) below.
nnoremap <expr>     <Leader>o '<Cmd>keepjumps normal! ' .. v:count .. 'o<Cr>'
" Add [count] blank line(s) above.
nnoremap <expr>     <Leader>O '<Cmd>keepjumps normal! ' .. v:count .. 'O<Cr>'
" Paste last yanked text ignoring cut text.
noremap             <Leader>p "0p
noremap             <Leader>P "0P
" Use FuzzyRecent to open recent files.
nnoremap            <Leader>r <Cmd>FuzzyRecent<Cr>
" Toggle spellchecker.
nnoremap <silent>   <Leader>s <Cmd>setlocal spell!<Cr>
" Sync theme to system.
nnoremap <silent>   <Leader>t <Cmd>SyncTheme<Cr>
" Write focused buffer if modified.
nnoremap <silent>   <Leader>w <Cmd>up<Cr>
" See :function CopyFile.
nnoremap <silent>   <Leader>y <Cmd>call CopyFile()<Cr>
" Toggle soft-wrapping of long lines to the view width.
nnoremap <silent>   <Leader>z <Cmd>setlocal wrap!<Cr>
" Attempt to autoformat focused paragraph/selection.
nnoremap <silent>   <Leader>\ gwip
xnoremap <silent>   <Leader>\ gw
" Convenient cmdline mode prefixes.
nnoremap            <Leader>/ :%s/<C-r><C-w>/
xnoremap            <Leader>/ :s/
nnoremap            <Leader>; :!

" Jump mappings: move cursor to next/previous thing. {{{2
" Fold navigation needs improvement.
nnoremap zj zjzt
nnoremap zk zkzb
" Quicker history jumps (consistent with qutebrowser, etc.)
nnoremap H <C-o>
nnoremap L <C-i>
" Coarse scrolling.
nnoremap [<Space> <C-u>
nnoremap ]<Space> <C-d>
" Better mapping for :tjump, clobbers :tselect.
nnoremap g] g<C-]>
" Jump to first/last character of current line.
noremap ]l g_
noremap [l ^
" Navigate to sentence clause punctuation.
noremap g( <Cmd>keeppatterns ?[.,;:!?]\( \\|\n\)<Cr>
noremap g) <Cmd>keeppatterns /[.,;:!?]\( \\|\n\)<Cr>
" Navigate to TODO / FIXME comments.
nnoremap ]t <Cmd>keeppatterns /TODO\\|FIXME<Cr>
nnoremap [t <Cmd>keeppatterns ?TODO\\|FIXME<Cr>

" PLUGINS {{{1
" Set builtin plugin options. {{{2
let g:loaded_netrw = 1  " Hack to disable buggy netrw completely.
let g:loaded_netrwPlugin = 1  " See :help netrw-noload.
" Markdown {{{3
let g:markdown_fenced_languages = [
            \'vim', 'python', 'sh', 'zsh', 'bash=sh', 'julia', 'fortran',
            \'haskell', 'java', 'c', 'css', 'ruby', 'erb=eruby', 'go',
            \'javascript', 'js=javascript', 'json=javascript',
            \'tex', 'scala', 'sql', 'gnuplot', 'html', 'xml', 'lisp',
            \]
let g:markdown_folding = 1
" reStructuredText {{{3
let g:rst_use_emphasis_colors = 1
let g:rst_fold_enabled = 0
" Fortran {{{3
let fortran_more_precise = 1
let fortran_free_source = 1
let fortran_do_enddo = 1
" HTML {{{3
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"
" }}} }}}
if !isdirectory(g:PLUGIN_HOME)
    finish
endif

" Load third-party plugins using vim-plug. {{{2
let g:plug_window = 'SmartSplit'
call plug#begin(g:PLUGIN_HOME)
    " Ergonomics and general fixes. {{{3
    Plug 'ncm2/float-preview.nvim'  " Use a floating window for preview-window.
    Plug 'tpope/vim-abolish'  " Word variant manipulation.
    Plug 'tpope/vim-commentary'  " Quickly comment/uncomment code.
    Plug 'tpope/vim-eunuch'  " UNIX helpers.
    Plug 'tpope/vim-fugitive'  " Git wrapper for vim habitat.
    Plug 'tpope/vim-surround'  " Quoting/parenthesizing made simple.
    Plug 'junegunn/vim-easy-align'  " Align text on delimiters.
    Plug 'justinmk/vim-sneak'  " Extended motions and operators like `f`.
    Plug 'farmergreg/vim-lastplace'  " Restore cursor position.
    Plug 'AndrewRadev/inline_edit.vim'  " For polyglot code and heredocs.
    Plug 'aymericbeaumet/vim-symlink'  " Follow symlinks (linux).
    Plug 'chrisbra/unicode.vim'  " Easy unicode and digraph handling.
    Plug 'arp242/jumpy.vim'  " Better and extended mappings for ]], g], etc.
    Plug 'inkarkat/vim-ingo-library'  " A vimscript library for inkarkat plugins.
    Plug 'inkarkat/vim-OnSyntaxChange'  " Events when changing syntax group.
    Plug 'inkarkat/vim-SearchHighlighting'  " Better hlsearch and `*`.
    Plug 'inkarkat/vim-AdvancedSorters'  " Sort by multiline patterns, etc.
    Plug 'dhruvasagar/vim-open-url'  " Open URL's in browser without netrw.
    " Dev tooling and filetype plugins. {{{3
    Plug 'nvim-lua/plenary.nvim'  " Lua functions/plugin dev library.
    Plug 'dense-analysis/ale'  " Async code linting.
    Plug 'wfxr/minimap.vim'  " A code minimap, like what cool Atom kids have.
    Plug 'chmp/mdnav'  " Markdown: internal hyperlink navigation.
    Plug 'alvan/vim-closetag'  " Auto-close (x)html tags.
    Plug 'cespare/vim-toml'  " Syntax highlighting for TOML configs.
    Plug 'vim-python/python-syntax'  " Python: improved syntax highlighting.
    Plug 'hattya/python-indent.vim'  " Python: improved autoindenting.
    Plug 'euclidianAce/BetterLua.vim'  " Lua: improved syntax highlighting.
    Plug 'jakemason/ouroboros'  " Switch between .c/.cpp and header files.
    if executable('latex')
        Plug 'lervag/vimtex'  " Comprehensive LaTeX integration.
    endif
    if executable('julia')
        Plug 'JuliaEditorSupport/julia-vim'  " Improved syntax highlighting.
        Plug 'kdheepak/JuliaFormatter.vim'  " Code auto-formatter.
    endif
    if executable('docker')
        Plug 'ekalinin/Dockerfile.vim'  " Syntax highlighting for dockerfiles.
    endif
    " Contributing/maintaining. {{{3
    Plug 'adigitoleo/vim-mellow'
    Plug 'adigitoleo/vim-mellow-statusline'
    " }}}
call plug#end()
" Check that plugins are installed before configuring.
if empty(glob(g:PLUGIN_HOME.'/*'))
    finish
endif

" Linting settings. {{{2
nnoremap ]e <Plug>(ale_next_wrap)
nnoremap [e <Plug>(ale_previous_wrap)
augroup ale_highlights
    autocmd!
    autocmd ColorScheme mellow hi link ALEError Visual
    autocmd ColorScheme mellow hi link ALEWarning Visual
    autocmd ColorScheme mellow hi link ALEErrorSign NonText
    autocmd ColorScheme mellow hi link ALEWarningSign CursorColumn
    autocmd VimResume * call map(nvim_list_bufs(), 'ale#Queue(0, "lint_file", v:val)')
augroup END
let g:ale_exclude_highlights = [
            \'TODO',
            \'line too long',
            \'missing.*py.typed',
            \'non-ASCII character',
            \]
let g:ale_linters = {'python': ['flake8', 'mypy'], 'cpp': ['cc', 'clang', 'cppcheck']}
let g:ale_fixers = {'cpp': ['clang-format'], 'lua': ['stylua']}
let g:ale_linters_ignore = {'cpp': ['clangcheck', 'clangtidy']}
let g:ale_python_flake8_options = "--max-line-length 88 --ignore=E203,W503"
let g:ale_python_mypy_options = "--ignore-missing-imports"
let g:ale_cpp_cc_options = "-std=c++17 -Wall"
let g:ale_cpp_clangd_options = "-std=c++17 -Wall"
" Latex settings. {{{2
let g:tex_flavor = 'latex'
let g:vimtex_fold_enabled = 1
let g:vimtex_quickfix_mode = 0  " See #1595
let g:vimtex_matchparen_enabled = 1
let g:vimtex_view_method = 'zathura'
let g:vimtex_fold_types = {
            \   'cmd_single' : {'enabled' : 0},
            \   'cmd_multi' : {'enabled' : 0},
            \   'items' : {'enabled' : 0},
            \   'envs': {
            \       'blacklist': [
            \           'equation', 'align', 'figure', 'enumerate', 'split',
            \           'equation*', 'align*', 'figure*', 'itemize',
            \           'pmatrix', 'bmatrix', 'vmatrix', 'Bmatrix', 'Vmatrix',
            \           'scope', 'displayquote', 'verbatim',
            \       ],
            \   },
            \}
let g:vimtex_indent_lists = [
            \ 'itemize',
            \ 'description',
            \ 'enumerate',
            \ 'thebibliography',
            \ 'compactitem',
            \]
let g:vimtex_quickfix_ignore_filters = [
    \   'underfull',
    \   'moderncv',
    \]

" Python settings {{{2
" Enable modern python syntax highlights.
let g:python_highlight_all = 1
let g:python_highlight_builtin_types = 0
let g:python_highlight_space_errors = 0
let g:python_highlight_indent_errors = 0

" Julia settings {{{2
let g:julia_indent_align_brackets = 0

" Motion settings. {{{2
" Respect 'ignorecase' and 'smartcase' settings.
let g:sneak#use_ic_scs = 1

" Use sneak to replace builin char search.
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
map gS <Plug>Sneak_,

augroup sneak_colors
    autocmd!
    " Some theme-agnostic colors for sneak hints.
    autocmd ColorScheme * hi! link Sneak VisualNOS
augroup END

" Miscellaneous {{{2
" Don't open folds when restoring cursor position.
let g:lastplace_open_folds = 0
" Use a wider minimap.
let g:minimap_width = 14
" Show more stuff in the minimap.
" let g:minimap_git_colors = 1  " https://github.com/wfxr/minimap.vim/issues/168
" let g:minimap_diffadd_color = "DiffAdd"
" let g:minimap_diffremove_color = "DiffDelete"
" let g:minimap_diff_color = "DiffChange"
" Use the latex to unicode converter provided by julia.vim for other filetypes.
let g:latex_to_unicode_file_types = ["julia", "markdown", "python", "tex"]
" Always use 80 char textwidth when writing comments/documentation.
if has_key(plugs, "vim-OnSyntaxChange")
    call OnSyntaxChange#Install('Comment', '^Comment$\|Doc[sS]tring', 0, 'i')
    augroup auto_wrap_comments
        " Set textwidth to 80 when editing.
        autocmd User SyntaxCommentEnterI if &textwidth > 0
                    \ | setlocal textwidth=80 formatoptions+=t | endif
        " Remove it again when leaving insert mode.
        autocmd User SyntaxCommentLeaveI exec 'filetype detect'
                    \ | setlocal formatoptions-=t
    augroup END
endif
" }}}}}}

let g:mellow_show_bufnr = 0

if $COLORTERM == "truecolor"
    set termguicolors
    " Inherit 'background' (dark/light mode) from terminal emulator.
    if executable('theme')
        let &background = get(systemlist('theme -q'), 0)
    else
        set background=light
    endif
    let g:mellow_user_colors = 1
    colorscheme mellow
    " let g:lightline = {'colorscheme': 'mellow'}
else
    colorscheme pablo
    set background=dark
    hi! link ColorColumn Normal
    hi! link Statusline NonText
    hi! link TabLineFill NonText
    hi! link TabLineSel NonText
    hi! link VertSplit NonText
    hi! link StatusLineNC NonText
endif

"   NOTE: Toggle dark/light mode using the :ToggleTheme command. This uses   "
" *       the external theme script to toggle all compatible TUI apps.     * "
" * *                                                                    * * "
" * * *                                                                * * * "
" * * * * * * * * * * * * * *                    * * * * * * * * * * * * * * "
