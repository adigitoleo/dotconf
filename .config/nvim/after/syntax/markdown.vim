" Block math. Look for '$$[anything]$$'
syn region displayMath matchgroup=MathDelimiter start=/\$\$/ end=/\$\$/ concealends
" Block math. Look for '\[[anything]\]'
syn region displayMath matchgroup=MathDelimiter start=/\\\[/ end=/\\\]/ concealends
" Inline math. Look for '$[not $][anything]$'
syn region inlineMath matchgroup=MathDelimiter start=/\$/ end=/\$/ concealends
" Inline math. Look for '\([anything]\)'
syn region inlineMath matchGroup=MathDelimiter start=/\\(/ end=/\\)/ concealends
" YAML/TOML frontmatter.
syn region frontMatter start=/\%^---\+$/ end=/---\+$/ conceal cchar=@
" Inline URLs look ugly, let's conceal them.
syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained conceal cchar=@

" Better inline code, look for '`[not `][anything]`'
syn match inlineCode '`[^`].\{-}`'

" Franklin.jl style macro markers
syn match franklinDiv '@@[^@].\+'

" Highlight links
hi link displayMath Statement
hi link inlineMath Function
hi link inlineCode PreProc
hi link franklinDiv Special
hi link markdownUrl Special
hi link frontMatter Special

" Ensure 'frontMatter' block is not treated like normal markdown.
function! s:NotSpecialBlock(lnum) abort
  return synIDattr(synID(a:lnum, 1, 1), 'name') !=# 'markdownCode' &&
              \ synIDattr(synID(a:lnum, 1, 1), 'name') !=# 'frontMatter'
endfunction

" Patch folding function to be aware of frontmatter.
function! MarkdownFold() abort
  let line = getline(v:lnum)

  if line =~# '^#\+ ' && s:NotSpecialBlock(v:lnum)
    return '>' . match(line, ' ')
  endif

  let nextline = getline(v:lnum + 1)
  if (line =~# '^.\+$') && (nextline =~# '^=\+$') && s:NotSpecialBlock(v:lnum + 1)
    return '>1'
  endif

  if (line =~# '^.\+$') && (nextline =~# '^-\+$') && s:NotSpecialBlock(v:lnum + 1)
    return '>2'
  endif

  return '='
endfunction
