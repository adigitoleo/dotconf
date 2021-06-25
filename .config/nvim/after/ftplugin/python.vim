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

" if executable('rg')
"     command! -buffer TagGen silent! exec '!.vim/ptags.py $(rg --glob="*.py" --files)'
" endif
