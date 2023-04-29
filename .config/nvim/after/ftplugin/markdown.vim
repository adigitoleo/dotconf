function! s:MarkdownBoldToggle()
    let l:curword = expand('<cWORD>')
    if match(l:curword, '^\*\{2}[^\*]\+\*\{2}') >= 0
        call nvim_feedkeys('Ehds*ds*', 'm', v:true)
    elseif match(l:curword, '^\*\{3}[^\*]\+\*\{3}') >= 0
        call nvim_feedkeys('Ehhds*ds*', 'm', v:true)
    else
        call nvim_feedkeys('ysiW*.*', 'm', v:true)
    endif
endfunction

function! s:MarkdownItalicToggle()
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
endfunction

if exists('g:loaded_surround')
    map <silent> <localleader>b :call <SID>MarkdownBoldToggle()<Cr>
    map <silent> <localleader>i :call <SID>MarkdownItalicToggle()<Cr>
endif

iabbrev <buffer> :( \( \)<Left><Left><Left>
iabbrev <buffer> ;[ \[ \]<Left><Left><Left>
