" Add folding of docstrings for foldmethod=syntax.
syn region  pythonDocstring start=+^\s*"""+ end=+"""+ keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
      \ fold

" Highlight docstrings as comments.
hi link pythonDocstring Comment

" Don't auto-indent when typing colons.
setlocal indentkeys-=: indentkeys-=<:>
