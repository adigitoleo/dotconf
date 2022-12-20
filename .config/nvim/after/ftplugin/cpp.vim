" Key mappings for .cpp/.h switching.
" https://github.com/jakemason/ouroboros.nvim
if exists(":Ouroboros")
    nnoremap <LocalLeader>h <Cmd>Ouroboros<Cr>
endif

" Use xmake to build, https://xmake.io/#/
if executable('xmake')
    setlocal makeprg=xmake\ clean\ &&\ xmake\ b\ &&\ setsid\ -f\ xmake\ r
endif
