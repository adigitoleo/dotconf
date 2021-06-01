if exists(":VimtexCountWords")
    nmap <silent> <buffer> <LocalLeader>c :VimtexCountWords<Cr>
    xmap <silent> <buffer> <LocalLeader>c :VimtexCountWords<Cr>
endif

iabbrev <buffer> $ \( \)<Left><Left><Left>
iabbrev <buffer> doc@ \begin{document}<Cr><Cr>\end{document}<Up>
iabbrev <buffer> fig@ \begin{figure}\label{fig:}<Cr>\end{figure}<Up><C-e><Left>
iabbrev <buffer> eq@ \begin{equation}\label{eq:}<Cr>\end{equation}<Up><C-e><Left>
iabbrev <buffer> list@ \begin{itemize}<Cr>\end{itemize}<Up><C-e><Cr>\item<Space>
iabbrev <buffer> enum@ \begin{enumerate}<Cr>\end{enumerate}<Up><C-e><Cr>\item<Space>
" iabbrev <buffer> tab \begin{table}<cr><Cr>\end{table}<Up><Tab>
iabbrev <buffer> tikz@ \begin{tikzpicture}<Cr>\end{tikzpicture}<Up><C-e><Cr>
iabbrev <buffer> style@ [% Set up local styles.<Cr>]<Up><C-e><Cr>
iabbrev <buffer> R3@ \mathbb{R}^{3}
