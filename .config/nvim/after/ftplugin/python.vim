" To fold python docstrings, see: https://vi.stackexchange.com/a/6968
iabbrev <buffer> doc@ """"""<Left><Left><Left>
iabbrev <buffer> geq@ ≥
iabbrev <buffer> leq@ ≤

" Silence mypy type checking for this line.
command! -buffer TypeIgnore silent! .s/\v$/  # type: ignore/
" Silence pylint warnings for this line.
command! -buffer InvalidName silent! .s/\v$/  # pylint: disable=invalid-name/
command! -buffer NoSelfUse silent! .s/\v$/  # pylint: disable=no-self-use/
command! -buffer UnusedArgument silent! .s/\v$/  # pylint: disable=unused-argument/

if exists("g:loaded_ale") && g:loaded_ale
    let b:ale_linters = ['jedils', 'pylint', 'mypy']
    let b:ale_fixers = ['isort', 'black']
    if g:loaded_VimCompletesMe
        let b:vcm_tab_complete = "omni"
        setlocal omnifunc=ale#completion#OmniFunc
    endif
endif

" if executable('rg')
"     command! -buffer TagGen silent! exec '!.vim/ptags.py $(rg --glob="*.py" --files)'
" endif
