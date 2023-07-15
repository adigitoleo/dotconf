function! s:MarkdownBoldToggle(visual) range
    if a:visual == v:true
        for l:line in range(a:firstline, a:lastline)
            if match(getline(l:line), '^\*\{2,3}[^\*]\+\*\{2,3}') >= 0
                exec 'keeppatterns' .. l:line .. 's/\%V\*\{2}\(.\+\)\*\{2}/\1/e'
            else
                exec 'keeppatterns' .. l:line .. 's/\%V.\+/**&**/e'
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
                exec 'keeppatterns' .. l:line .. 's/\%V*.*/*&*/e'
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

if exists('g:loaded_surround')
    nnoremap <silent> <localleader>b :call <SID>MarkdownBoldToggle(v:false)<Cr>
    nnoremap <silent> <localleader>i :call <SID>MarkdownItalicToggle(v:false)<Cr>
    vnoremap <silent> <localleader>b :call <SID>MarkdownBoldToggle(v:true)<Cr>
    vnoremap <silent> <localleader>i :call <SID>MarkdownItalicToggle(v:true)<Cr>
endif

iabbrev <buffer> :( \( \)<Left><Left><Left>
iabbrev <buffer> ;[ \[ \]<Left><Left><Left>
