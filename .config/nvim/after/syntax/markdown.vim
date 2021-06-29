" Block math. Look for '$$[anything]$$'
syn region displayMath start=/\$\$/ end=/\$\$/
" Inline math. Look for '$[not $][anything]$'
syn match inlineMath '\$[^$].\{-}\$'

" Better inline code, look for '`[not `][anything]`'
syn match inlineCode '`[^`].\{-}`'

" Franklin.jl style macro markers
syn match franklinDiv '@@'

" Highlight links
hi link displayMath Statement
hi link inlineMath Function
hi link inlineCode PreProc
hi link franklinDiv Special
