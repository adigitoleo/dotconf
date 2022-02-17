filetype plugin on
xnoremap ¶ <Esc>
inoremap ¶ <Esc>
cnoremap ¶ <Esc>
if $TERM == "linux" || $TERM == "screen"
    set bg=dark
    if $TERM == "screen"
       echoerr "colors will all be messed up in 'screen' $TERM, try running ssh inside a local tmux session" 
    endif
else
    set bg=light
    colo mellow
endif
set number rnu
set expandtab
set softtabstop=4
set shiftwidth=4
