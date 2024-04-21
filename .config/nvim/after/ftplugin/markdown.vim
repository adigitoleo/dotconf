function! s:MarkdownBoldToggle(visual) range
    if a:visual == v:true
        for l:line in range(a:firstline, a:lastline)
            if match(getline(l:line), '^\*\{2,3}[^\*]\+\*\{2,3}') >= 0
                exec 'keeppatterns' .. l:line .. 's/\%V\*\{2}\(.\+\)\*\{2}/\1/e'
            else
                exec 'keeppatterns' .. l:line .. 's/\%V.*\%V./**&**/e'
            endif
        endfor
    else  " Single-word variant requires vim-surround plugin.
        let l:curword = expand('<cWORD>')
        if match(l:curword, '^\*\{2}[^\*]\+\*\{2}') >= 0
            call nvim_feedkeys('Ehds*ds*', 'm', v:true)
        elseif match(l:curword, '^\*\{3}[^\*]\+\*\{3}') >= 0
            call nvim_feedkeys('Ehhds*ds*', 'm', v:true)
        else
            call nvim_feedkeys('ysiW*.*', 'm', v:true)
        endif
    endif
endfunction

function! s:MarkdownItalicToggle(visual) range
    if a:visual == v:true
        for l:line in range(a:firstline, a:lastline)
            if match(getline(l:line), '^\*\{3}[^\*]\+\*\{3}') >= 0
                exec 'keeppatterns' .. l:line .. 's/\%V\*\(.\+\)\*/\1/e'
            elseif match(getline(l:line), '^\*[^\*]\+\*') >= 0
                exec 'keeppatterns' .. l:line .. 's/\%V\*\(.\+\)\*/\1/e'
            else
                exec 'keeppatterns' .. l:line .. 's/\%V.*\%V./*&*/e'
            endif
        endfor
    else  " Single-word variant requires vim-surround plugin.
        let l:curword = expand('<cWORD>')
        if match(l:curword, '^\*\{1}[^\*]\+\*\{1}') >= 0
            call nvim_feedkeys('Ehds*', 'm', v:true)
        elseif match(l:curword, '^\*\{2}[^\*]\+\*\{2}') >= 0
            call nvim_feedkeys('ysiW*', 'm', v:true)
        elseif match(l:curword, '^\*\{3}[^\*]\+\*\{3}') >= 0
            call nvim_feedkeys('Ehhds*', 'm', v:true)
        else
            call nvim_feedkeys('ysiw*', 'm', v:true)
        endif
    endif
endfunction

if luaeval('require("nvim-surround") ~= nil')
    nnoremap <silent> <localleader>b :call <SID>MarkdownBoldToggle(v:false)<Cr>
    nnoremap <silent> <localleader>i :call <SID>MarkdownItalicToggle(v:false)<Cr>
    vnoremap <silent> <localleader>b :call <SID>MarkdownBoldToggle(v:true)<Cr>
    vnoremap <silent> <localleader>i :call <SID>MarkdownItalicToggle(v:true)<Cr>
endif

func Eatchar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunc

iabbrev <buffer> :( \( \)<Left><Left><Left>
iabbrev <buffer> ;[ \[ \]<Left><Left><Left>
" Can only use alphanum. or _ in abbreviation lhs, see
" https://github.com/neovim/neovim/issues/28150
iabbrev <buffer> _mat \begin{matrix}\end{matrix}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _pmat \begin{pmatrix}\end{pmatrix}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _bmat \begin{bmatrix}\end{bmatrix}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _vmat \begin{vmatrix}\end{vmatrix}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _Vmat \begin{Vmatrix}\end{Vmatrix}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _Bmat \begin{Bmatrix}\end{Bmatrix}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _cases \begin{cases}\end{cases}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _rcases \begin{rcases}\end{rcases}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _smat \begin{smallmatrix}\end{smallmatrix}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _abs \left\vert  \right\vert<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _arr \begin{array}{}\end{array}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _subarr \begin{subarray}{}\end{subarray}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _pd \frac{\partial }{\partial }<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>
iabbrev <buffer> _spd \begin{pmatrix}\partial  / \partial \end{pmatrix<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><C-r>=Eatchar('\s')<Cr>}
