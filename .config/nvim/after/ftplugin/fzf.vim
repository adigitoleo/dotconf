for key in ["h", "l", "j", "k", "t", "w"]
    exec 'tnoremap <buffer> <M-' .. key .. '> <Nop>'
    exec 'tnoremap <buffer> <M-' .. toupper(key) .. '> <Nop>'
endfor
