if exists(":VimtexCountWords")
    nmap <silent> <buffer> <LocalLeader>c :VimtexCountWords<Cr>
    xmap <silent> <buffer> <LocalLeader>c :VimtexCountWords<Cr>
endif

if exists(":VimtexTocToggle")
    nmap <silent> <buffer> gO <plug>(vimtex-toc-toggle)
endif

func Eatchar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunc

" Can only use alphanum. or _ in abbreviation lhs, see
" https://github.com/neovim/neovim/issues/28150
iabbrev <buffer> _doc \begin{document}<Cr><Cr>\end{document}<Up>
iabbrev <buffer> _fig \begin{figure}<Cr>\centering<Cr>\caption{%<Cr><Cr>}\label{fig:}<Cr>\end{figure}<Up><Up><Esc>cc
iabbrev <buffer> _eq \begin{equation}\label{eq:}<Cr>\end{equation}<Up><End><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _list \begin{itemize}<Cr>\end{itemize}<Up><End><Cr>\item
iabbrev <buffer> _enum \begin{enumerate}<Cr>\end{enumerate}<Up><End><Cr>\item
iabbrev <buffer> _tab \begin{table}<cr><Cr>\end{table}<Up><Tab>
iabbrev <buffer> _tikz \begin{tikzpicture}<Cr>\end{tikzpicture}<Up><End><Cr>
iabbrev <buffer> _style [% Set up local styles.<Cr>]<Up><End><Cr>
iabbrev <buffer> _( \left(\right)<Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _[ \left[\right]<Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _{ \left\{\right\}<Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _cr <Left><Delete>~\cref{}<Left><C-r>=Eatchar('\s')<Cr>
