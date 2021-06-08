"                                  vim:fen
"  * * * * * * * * *   _       _ _          _             * * * * * * * * *  "
"  * * * * * * * * *  (_)_ __ (_) |_ __   _(_)_ __ ___    * * * * * * * * *  "
"  * * * * * * * * *  | | '_ \| | __|\ \ / / | '_ ` _ \   * * * * * * * * *  "
"  * * * * * * * * *  | | | | | | |_  \ V /| | | | | | |  * * * * * * * * *  "
"        adigitoleo's |_|_| |_|_|\__|(_)_/ |_|_| |_| |_| for neovim 0.4      "

" NOTE: Plugins are served using vim-plug. See the PLUGINS selection for more.
"       To set up vim-plug, first set g:VIM_PLUG_PATH and g:PLUGIN_HOME to the
"       desired paths (below). Next, ensure the correct plugin dependencies
"       are available and :call InitPlug(). Finally, restart and :PlugInstall

let g:VIM_PLUG_PATH = expand(stdpath('config') .. '/autoload/plug.vim')
let g:PLUGIN_HOME = expand(stdpath('data') .. '/plugged')
 " Set scrolloff here so that TermLeave can reset it,
 " this is needed until <https://github.com/neovim/neovim/pull/11854> arrives.
let g:SCROLLOFF = 3

if executable('/usr/bin/python3')
    let g:python3_host_prog = '/usr/bin/python3'
    " NOTE: This python binary should have access to the `pynvim` module.
endif

" TODO: Move from ALE to vim-lsp OR plugin vim-julia-lint for Lint.jl via ALE
"       Cf: <https://github.com/zyedidia/julialint.vim>
" TODO: Plugin vim-pycfg for correct syntax highlighting of setup.cfg files.
" TODO: Set up offline thesaurus files, :h 'thesaurus'
" TODO: Make *Feed functions more robust by using fprint instead of echo.
" TODO: Add an on_exit caller to :Run that notifies of finished jobs.

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

function! s:BufList() " {{{2
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
    for l:buf in getbufinfo({'buflisted': 1})
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
    " Automatically delete terminal buffers on exit code 0.
    " Use with termopen(<command>, {'on_exit': '<SID>TermQuit'}) to get a
    " terminal that closes without waiting for confirmation.
    if a:code == 0
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
    " <https://stackoverflow.com/a/10102604/12519962>
    let buffers = filter(range(1, bufnr('$')),
                \ 'buflisted(v:val) && empty(bufname(v:val)) &&
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

" OPTIONS {{{1
" Global booleans. {{{2
" Don't show mode info in the command line.
set noshowmode
" Prompt for confirmation, rather than throwing errors, where possible.
set confirm
" Ignore case in general, but become case-sensitive when uppercase is present.
set ignorecase smartcase infercase
" Show sign column for warning/error indicators.
set signcolumn=yes
" Set initial split positions for horizontal and vertical windows.
set splitbelow splitright
" Prefer hiding buffers over unloading them, see :h 'hidden'.
set hidden
" Join lines with only one space after punctuation.
set nojoinspaces
" Turn search match highlighting off, except during matching.
set nohlsearch
" Soft-wrap on spaces.
set linebreak
" Don't soft-wrap lines by default.
set nowrap
" Show non-printable characters defined by 'listchars' by default.
set list
" Global configs. {{{2
" Enable mouse cursor support if possible.
if has('mouse')
    set mouse=a
endif
" Set language for built-in spellchecker.
set spelllang=en_au
" Set location to store additional words, see :h 'spellfile'.
set spellfile=~/.config/nvim/after/spell/extras.en.utf-8.add
" Reduce time to wait for sequential mappings.
set timeoutlen=500
" Integrate system clipboard with vim operations.
set clipboard+=unnamedplus
" Add character pairings for highlighting and '%' jumps.
set matchpairs+=<:>
" Suppress feedback messages during auto-completion.
set shortmess+=cI
" Show a few extra lines/columns while scrolling.
let &scrolloff=g:SCROLLOFF
" If lines need to be soft-wrapped, show virtual leading character(s).
let &showbreak = '+++ '
" Set up characters to show in place of non-printable characters with 'list'.
set listchars+=trail:\ ,precedes:<,extends:>
" Limit number of items shown in popup menus.
set pumheight=15
" Make help buffers respect :set ea
set helpheight=0
" Prevent syntax highlighting of absurdly long lines to save performance.
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
" Use ripgrep if available.
if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --follow
endif
" Use blinking (if available) cursor and different mode shapes (:h guicursor).
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
    \,sm:block-blinkwait175-blinkoff150-blinkon175

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
        \   '--preview', 'case $(file {}) in *"text"*) head -200 {} ;; *) echo "Preview unavailable" ;; esac',
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
    command! -complete=dir -nargs=? -bang FuzzyEdit call fzf#run(fzf#wrap(
        \ s:FZFspecgen($FZF_DEFAULT_COMMAND .. ' ;' .. s:TermFeed(), <q-args>),
        \ <bang>0))

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
command! Term enew | call termopen("$SHELL", {"on_exit": "<SID>TermQuit"})
if executable('theme')  " Toggle global TUI theme using external script.
    command! ToggleTheme silent! exec '!theme toggle'
                \| let &background = get(systemlist('theme query'), 0, 'light')
    command! SyncTheme silent! let &background = get(systemlist('theme query'), 0, 'light')
endif
if executable('elinks')
    command! Elinks enew | call termopen("elinks", {"on_exit": "<SID>TermQuit"})
endif
if executable('aerc')
    command! Aerc enew | call termopen("aerc", {"on_exit": "<SID>TermQuit"})
endif
if executable("ipython")
    command! IPython enew | call termopen("ipython --no-autoindent", {"on_exit": "<SID>TermQuit"})
endif
if executable("bpython")
    command! BPython enew | call termopen("bpython", {"on_exit": "<SID>TermQuit"})
endif
if executable("julia")
    command! Julia enew | call termopen("julia --color=no", {"on_exit": "<SID>TermQuit"})
endif

" Misc. {{{2
" Insert current date in ISO (YYYY-MM-DD) format.
command! InsertDate silent! exec "normal! a" .. strftime('%Y-%m-%d') .. "<Esc>"
" See :function FillLine.
command! FillLine call FillLine()
" Change current line to title case.
command! TitleCase silent! .s/\v(.*)/\L\1/|.s/\v<(\a)(\a{3,})/\u\1\L\2/g
" Change current line to sentence case.
command! SentenceCase silent! .s/\v(.*)/\L\1/|.s/\v<(\a)(\a*)/\u\1\L\2/
" Save and execute focused buffer as job (needs shebang + executable permissions).
command! Run exec 'up|call jobstart(expand("%:p"))'
" Strip trailing whitespace.
command! StripTrails silent! %s/\s\+$//e
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
    autocmd TermEnter * set scrolloff=0
    autocmd TermLeave * let &scrolloff=g:SCROLLOFF
    autocmd BufEnter,WinEnter term://* startinsert
augroup END

" Special filetype settings and overrides. {{{2
augroup filetype_rules
    autocmd!
    " Consider using ftplugin scripts for complex stuff, `:h ftplugin`.
    " Verify that ':filetype' returns 'plugin:ON'.
    autocmd FileType sh,zsh setlocal textwidth=79
    autocmd FileType qf setlocal number norelativenumber cursorline textwidth=0
    autocmd FileType vim setlocal textwidth=78 foldmethod=marker
    autocmd FileType bash,sh setlocal foldmethod=marker
    autocmd FileType make setlocal noexpandtab
    autocmd FileType markdown setlocal foldlevel=1 foldenable
    autocmd FileType python setlocal textwidth=88 foldmethod=syntax formatoptions-=t
    autocmd FileType plaintex setlocal filetype=tex
    autocmd FileType tex setlocal textwidth=0 wrap
    autocmd FileType enaml setlocal textwidth=88 filetype=python.enaml formatoptions-=t
    autocmd FileType yaml setlocal tabstop=2
    autocmd FileType desktop set commentstring=#\ %s
augroup END

" Miscellaneous. {{{2
augroup misc
    autocmd!
    autocmd BufWritePost * exec "normal! " .. &foldenable ? "zx" : ""
    autocmd BufWritePost * if exists(":TagGen") > 0 | exec "TagGen" | fi
    autocmd WinLeave * call CleanEmptyBuffers()
    autocmd VimEnter,BufWinEnter * let &colorcolumn = "+" .. join(range(&columns)[1:], ",+")
    autocmd InsertLeave,CompleteDone * silent! pclose
    autocmd VimResized * wincmd =
augroup END

" MAPPINGS {{{1
" De gustibus: general fixes and tweaks. {{{2
" Ergonomic, smart mode switches.
nnoremap <silent> ; <Cmd>FuzzyCmd<Cr>
inoremap <M-;> <Esc>
xnoremap ; :
xnoremap <M-;> <Esc>
cnoremap <M-;> <C-c>
tnoremap <M-:> <C-\><C-n>
nnoremap q; q:
nnoremap Q <Nop>
" Make Y consistent with D and C.
nnoremap Y y$
" Search in selection.
xnoremap / <Esc>/\%V
" Redo (can't use U, see :h U).
nnoremap yu <Cmd>redo<Cr>
" CTRL-L also toggles search highlighting.
nnoremap <silent> <C-l> <Cmd>set hlsearch!<Cr><C-l>
" Disable middle mouse paste.
noremap <MiddleMouse> <Nop>
noremap <2-MiddleMouse> <Nop>
noremap <3-MiddleMouse> <Nop>
noremap <4-MiddleMouse> <Nop>
" HorizontalScrollMode allows continuous scrolling with the indicated char.
nnoremap <silent> zh :call <SID>HorizontalScrollMode('h')<CR>
nnoremap <silent> zl :call <SID>HorizontalScrollMode('l')<CR>
nnoremap <silent> zH :call <SID>HorizontalScrollMode('H')<CR>
nnoremap <silent> zL :call <SID>HorizontalScrollMode('L')<CR>
" Tap space to clear messages.
nnoremap <silent> <Space> <Cmd>mode<Cr>

" Meta mappings: buffer navigation and control. {{{2
" Unload focused buffer while preserving window layout.
nnoremap <expr> <M-d> winnr('$') == 1 && tabpagenr('$') == 1 ?
            \ '<Cmd>bd<Cr>' :
            \ '<Cmd>' .. (bufloaded(0) ? 'b#' : 'enew') .. '<Bar>bd#<Cr>'
tnoremap <expr> <M-d> &filetype == "fzf" ? "" : (
            \ winnr('$') == 1 && tabpagenr('$') == 1 ?
            \ '<Cmd>bd<Cr>' :
            \ '<Cmd>' .. (bufloaded(0) ? 'b#' : 'enew') .. '<Bar>bd#<Cr>'
            \)
" Write focused buffer if modified.
nnoremap <M-s> <Cmd>up<Cr>
inoremap <M-s> <Cmd>up<Cr>
" Close window (i.e. the view on the focused buffer).
nnoremap <expr> <M-q> winnr('$') == 1 && tabpagenr('$') == 1 ?
            \  '<Cmd>confirm qa<Cr>': '<Cmd>close<Cr>'
" Add/remove indentation in insert mode.
inoremap <M-,> <C-d>
inoremap <M-.> <C-t>
" Navigate buffers (next, previous, most recent - if still loaded).
nnoremap <expr> <M-]> '<Cmd>bn<Cr>'
nnoremap <expr> <M-[> '<Cmd>bp<Cr>'
nnoremap <expr> <M-Tab> '<Cmd>b' .. (buflisted(0) ? '#' : 'n') .. '<Cr>'
tnoremap <expr> <M-]> &filetype == "fzf" ? "" : '<Cmd>bn<Cr>'
tnoremap <expr> <M-[> &filetype == "fzf" ? "" : '<Cmd>bp<Cr>'
tnoremap <expr> <M-Tab> &filetype == "fzf" ? "" : '<C-\><C-n><Cmd>b' .. (bufloaded(0) ? '#' : 'n') .. '<Cr>'
" Ergonomic alternative for expanding abbreviations.
inoremap <M-]> <C-]>
" Window navigation and relocation.
for key in ["h", "l", "j", "k", "t", "w"]
    exec 'nnoremap <M-' .. key .. '> <Cmd>wincmd ' .. key .. '<Cr>'
    exec 'tnoremap <M-' .. key .. '> <Cmd>wincmd ' .. key .. '<Cr>'
    exec 'nnoremap <M-' .. toupper(key) .. '> <Cmd>wincmd ' .. toupper(key) .. '<Cr>'
    exec 'tnoremap <M-' .. toupper(key) .. '> <Cmd>wincmd ' .. toupper(key) .. '<Cr>'
endfor
nnoremap <M-b> <Cmd>wincmd b<Cr>
nnoremap <M-p> <Cmd>wincmd p<Cr>

" Leader mappings: run commands and call functions. {{{2
let mapleader = "\<Space>"
let maplocalleader = ","

" Insert char after cursor [count] times.
nnoremap <expr>     <Leader>a 'a' .. nr2char(getchar()) .. '<Esc>'
" Toggle cursor column indicator.
nnoremap            <Leader>c <Cmd>set cursorcolumn!<Cr>
" Change working directory of focused window to directory containing focused file/buffer (fall back to HOME).
nnoremap <expr>     <Leader>d '<Cmd>lcd ' .. (empty(&buftype) && !empty(bufname()) ? '%:p:h' : '') .. '<Bar>pwd<Cr>'
" Toggle folding in focused buffer.
nnoremap            <Leader>f <Cmd>setlocal foldenable!<Cr>
" Enter prose mode (quit with :close/:quit).
nnoremap <expr>     <Leader>g '<Cmd>Goyo ' .. (&textwidth ? &textwidth + 2 : 82) .. '<Cr>'
" Insert char before cursor [count] times.
nnoremap <expr>     <Leader>i 'i' .. nr2char(getchar()) .. '<Esc>'
" Toggle cursor line indicator.
nnoremap            <Leader>l <Cmd>set cursorline!<Cr>
" Toggle line numbers for focused buffer.
nnoremap <silent>   <Leader>n <Cmd>set number! relativenumber!<Cr>
" Add [count] blank line(s) below.
nnoremap <expr>     <Leader>o '<Cmd>keepjumps normal! ' .. v:count .. 'o<Cr>'
" Add [count] blank line(s) above.
nnoremap <expr>     <Leader>O '<Cmd>keepjumps normal! ' .. v:count .. 'O<Cr>'
" Paste last yanked text ignoring cut text.
noremap             <Leader>p "0p
noremap             <Leader>P "0P
" Rename symbols using LSP (ALE implementation).
nnoremap <silent>   <Leader>r <Cmd>ALERename<Cr>
" Toggle spellchecker.
nnoremap <silent>   <Leader>s <Cmd>setlocal spell!<Cr>
" See :function CopyFile.
nnoremap <silent>   <Leader>y <Cmd>call CopyFile()<Cr>
" Toggle soft-wrapping of long lines to the view width.
nnoremap <silent>   <Leader>z <Cmd>setlocal wrap!<Cr>
" Attempt to autoformat focused paragraph/selection.
nnoremap <silent>   <Leader>\ gwip
xnoremap <silent>   <Leader>\ gw
" Convenient cmdline mode prefixes.
nnoremap            <Leader>/ :%s/<C-r><C-w>
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
" Jump to next/previous error, requires ALE.
nmap <silent> ]e <Plug>(ale_next_wrap_error)
nmap <silent> [e <Plug>(ale_previous_wrap_error)
" Jump to next/previous warning, requires ALE.
nmap <silent> ]w <Plug>(ale_next_wrap_warning)
nmap <silent> [w <Plug>(ale_previous_wrap_warning)

" PLUGINS {{{1
" Set builtin plugin options. {{{2
let g:loaded_netrwPlugin = 1  " Hack to disable buggy netrw completely.
" Markdown {{{3
let g:markdown_fenced_languages = [
            \'vim', 'python', 'sh', 'zsh', 'bash=sh',
            \'haskell', 'java', 'c', 'css', 'ruby', 'erb=eruby',
            \'javascript', 'js=javascript', 'json=javascript',
            \'tex', 'scala', 'sql', 'gnuplot', 'html', 'xml',
            \]
let g:markdown_folding = 1
" reStructuredText {{{3
let g:rst_use_emphasis_colors = 1
let g:rst_fold_enabled = 0
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
    Plug 'ackyshake/VimCompletesMe'  " Smart, context-aware <Tab> completion.
    Plug 'tpope/vim-abolish'  " Word variant manipulation.
    Plug 'tpope/vim-commentary'  " Quickly comment/uncomment code.
    Plug 'tpope/vim-eunuch'  " UNIX helpers.
    Plug 'tpope/vim-fugitive'  " Git wrapper for vim habitat.
    Plug 'tpope/vim-rsi'  " Readline mappings in relevant modes.
    Plug 'tpope/vim-surround'  " Quoting/parenthesizing made simple.
    Plug 'junegunn/vim-easy-align'  " Align text on delimiters.
    Plug 'justinmk/vim-sneak'  " Extended motions and operators like `f`.
    Plug 'farmergreg/vim-lastplace'  " Restore cursor position.
    Plug 'AndrewRadev/inline_edit.vim'  " For polyglot code and heredocs.
    Plug 'aymericbeaumet/vim-symlink'  " Follow symlinks (linux).
    Plug 'chrisbra/unicode.vim'  " Easy unicode and digraph handling.
    Plug 'junegunn/goyo.vim'  " Centered/focused mode for writing prose.
    Plug 'arp242/jumpy.vim'  " Better and extended mappings for ]], g], etc.
    " Dev tooling and filetype plugins. {{{3
    Plug 'dense-analysis/ale'  " Linting and LSP server.
    Plug 'mzlogin/vim-markdown-toc'  " Pandoc/GFM table of contents generator.
    Plug 'chmp/mdnav'  " Markdown: internal hyperlink navigation.
    Plug 'alvan/vim-closetag'  " Auto-close (x)html tags.
    Plug 'cespare/vim-toml'  " Syntax highlighting for TOML configs.
    Plug 'vim-python/python-syntax'  " Python: improved syntax highlighting.
    Plug 'hattya/python-indent.vim'  " Python: improved autoindenting.
    if executable('lua')
        Plug 'euclidianAce/BetterLua.vim'  " Lua: improved syntax highlighting.
    endif
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

    " Plug '~/vcs/vim-mellow'
    " Plug 'adigitoleo/vim-mellow', {'tag': '*'}
    Plug 'adigitoleo/vim-mellow'

    " Plug '~/vcs/vim-mellow-statusline'
    Plug 'adigitoleo/vim-mellow-statusline', {'tag': '*'}
    " Plug 'vim-airline/vim-airline'
    " Plug 'itchyny/lightline.vim'

    " Plug '~/vcs/vim-helpier'
    Plug 'adigitoleo/vim-helpier'

    " }}}
call plug#end()
" Check that plugins are installed before configuring.
if empty(glob(g:PLUGIN_HOME.'/*'))
    finish
endif

" Linting/LSP settings. {{{2
" Don't highlight todo comments, that's already handled by the colorscheme.
let g:ale_exclude_highlights = ['TODO']
" Run the fixers automatically. THIS ISN'T TOGGLED BY :ALEDisable (see #2260).
let g:ale_fix_on_save = 1
" Let ALE also set omnicomplete.
let g:ale_completion_enabled = 1
" Allow ALE to run imports for more completion suggestions.
let g:ale_completion_autoimport = 1
" Make VimCompletesMe do <C-p> completion on <Tab>.
let g:vcm_direction = 'p'

" Workaround for #2260 because ALEDisable doesn't... uhm... disable ALE.
function! s:ALEFixOnSaveToggle(vartype, value)
    let l:new = a:value == -1 ? '!' . get(eval(a:vartype . ':'), 'ale_fix_on_save', 0) : a:value
    execute 'let ' .  a:vartype . ':ale_fix_on_save = ' . l:new
endfunction
command! -bar ALEFixOnSaveToggle        call <SID>ALEFixOnSaveToggle('g', -1)
command! -bar ALEFixOnSaveToggleBuffer  call <SID>ALEFixOnSaveToggle('b', -1)
command! -bar ALEFixOnSaveEnable        call <SID>ALEFixOnSaveToggle('g', 1)
command! -bar ALEFixOnSaveEnableBuffer  call <SID>ALEFixOnSaveToggle('b', 1)
command! -bar ALEFixOnSaveDisable       call <SID>ALEFixOnSaveToggle('g', 0)
command! -bar ALEFixOnSaveDisableBuffer call <SID>ALEFixOnSaveToggle('b', 0)
command! -bar ALEEnableAll        ALEEnable | ALEFixOnSaveEnable
command! -bar ALEEnableAllBuffer  ALEEnableBuffer | ALEFixOnSaveEnableBuffer
command! -bar ALEDisableAll       ALEDisable | ALEFixOnSaveDisable
command! -bar ALEDisableAllBuffer ALEDisableBuffer | ALEFixOnSaveDisableBuffer

augroup ale_highlights
    autocmd!
    autocmd ColorScheme mellow hi link ALEError Visual
    autocmd ColorScheme mellow hi link ALEWarning Visual
    autocmd ColorScheme mellow hi link ALEErrorSign NonText
    autocmd ColorScheme mellow hi link ALEWarningSign CursorColumn
augroup END

" Latex settings. {{{2
" Ensure unified tex flavour for correct syntax handling.
let g:tex_flavor = 'latex'
" Enable syntax folding for latex files.
let g:vimtex_fold_enabled = 1
" Don't open quickfix window automatically, workaround for #1595
let g:vimtex_quickfix_mode = 0
" Don't perform enhanced matchparen searches, highlights bleed across buffers.
let g:vimtex_matchparen_enabled = 1
" Set up PDF viewer for LaTeX documents.
let g:vimtex_view_method = 'zathura'
" Tweak automatic folding.
let g:vimtex_fold_types = {
            \   'cmd_single' : {'enabled' : 0},
            \   'cmd_multi' : {'enabled' : 0},
            \   'envs': {
            \       'blacklist': [
            \           'equation', 'figure', 'enumerate',
            \           'pmatrix', 'bmatrix', 'vmatrix', 'Bmatrix', 'Vmatrix',
            \           'scope', 'displayquote', 'verbatim',
            \       ],
            \   },
            \}
" Tweak automatic list indenting.
let g:vimtex_indent_lists = [
            \ 'itemize',
            \ 'description',
            \ 'enumerate',
            \ 'thebibliography',
            \ 'compactitem',
            \]
" Suppress nuisance warnings.
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

" Motion settings. {{{2
" Use clever s and S mappings to free up ; and , for other uses.
let g:sneak#s_next = 1
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
" Settings for prose/notes writing.
augroup goyo_tweaks
    autocmd!
    autocmd User GoyoEnter mode | set spell sidescrolloff=15 wrap
    autocmd User GoyoLeave set nospell
augroup END
" Use the latex to unicode converter provided by julia.vim for other filetypes.
let g:latex_to_unicode_file_types = ["julia", "markdown"]

" Testing/development.
let g:helpier_buftype_matches = ["help", "quickfix"]

" }}}}}}

let g:mellow_custom_parts = [
            \ [function('strftime', ['%H:%M']), '%2*', 1, 0],
            \]
let g:mellow_show_bufnr = 0

if $TERM == "alacritty"
    set termguicolors  " <https://gist.github.com/XVilka/8346728>
    " Inherit 'background' (dark/light mode) from terminal emulator.
    let &background = get(systemlist('theme query'), 0, 'light')
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
