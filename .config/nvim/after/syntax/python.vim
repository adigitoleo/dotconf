" Add folding of docstrings for foldmethod=syntax.
syn region  pythonDocstring start=+^\s*"""+ end=+"""+ keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
      \ fold

" Fix decorator highlighting.
syn region pythonDecorator start=+^\s*@+ end=+$+
hi link pythonDecorator PreProc

" Highlight docstrings as comments.
hi link pythonDocstring Comment
" Since I can't figure out how to highlight variables as 'Identifier',
" link 'Constant' -> 'Identifier' instead to preserve the distinction.
hi link pythonNone Identifier
hi link pythonSingleton Identifier
hi! link Constant Identifier

" Don't auto-indent when typing colons.
setlocal indentkeys-=: indentkeys-=<:>

" Highlight string prefix modifiers in stronger color.
" FIXME: Don't catch things like pdf" in here...
syn match pythonStringModifier '[brf]"'me=e-1 contained
syn region pythonFString   start=+[fF]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell,pythonStringModifier
syn region pythonFString   start=+[fF]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell,pythonStringModifier
syn region pythonFString   start=+[fF]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest,pythonSpaceError,@Spell,pythonStringModifier
syn region pythonFString   start=+[fF]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest2,pythonSpaceError,@Spell,pythonStringModifier
syn region pythonBytes    start=+[bB]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonBytesError,pythonBytesContent,@Spell,pythonStringModifier
syn region pythonBytes    start=+[bB]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonBytesError,pythonBytesContent,@Spell,pythonStringModifier
syn region pythonBytes    start=+[bB]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonBytesError,pythonBytesContent,pythonDocTest,pythonSpaceError,@Spell,pythonStringModifier
syn region pythonBytes    start=+[bB]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonBytesError,pythonBytesContent,pythonDocTest2,pythonSpaceError,@Spell,pythonStringModifier
syn region pythonRawString  start=+[rR]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonRawEscape,@Spell,pythonStringModifier
syn region pythonRawString  start=+[rR]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonRawEscape,@Spell,pythonStringModifier
syn region pythonRawString  start=+[rR]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonDocTest,pythonSpaceError,@Spell,pythonStringModifier
syn region pythonRawString  start=+[rR]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonDocTest2,pythonSpaceError,@Spell,pythonStringModifier

hi link pythonStringModifier Operator
