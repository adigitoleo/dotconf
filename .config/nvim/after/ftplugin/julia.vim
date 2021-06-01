" Key mappings for julia code formatter.
" https://github.com/kdheepak/JuliaFormatter.vim
if exists(":JuliaFormatterFormat")
    nnoremap <LocalLeader>jf <Cmd>JuliaFormatterFormat<Cr>
    xnoremap <LocalLeader>jf <Cmd>JuliaFormatterFormat<Cr>
endif
