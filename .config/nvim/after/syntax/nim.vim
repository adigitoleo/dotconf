" Vim syntax file for the Nim language.

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Comments
syn keyword nimTodo FIXME NOTE NOTES TODO XXX contained
syn match nimLineComment "#.*$" contains=nimTodo,@Spell
syn region nimBlockComment start=+#\[+ end=+\]#+ contains=nimTodo,@Spell,nimBlockComment

" Built-in and stdlib types and constants
syn keyword nimConstant nil int int8 int16 int32 int64 cint
syn keyword nimConstant byte uint uint8 uint16 uint32 uint64
syn keyword nimConstant float float8 float16 float32 float64 Inf NaN NegInf
syn keyword nimConstant cfloat cdouble clong clongdouble clonglong cshort
syn keyword nimConstant char cchar string cstring seq array tuple range set
syn keyword nimConstant cschar csize_t cstringArray cuint
syn keyword nimConstant culong cushort culonglong RootObj StackTraceEntry
syn keyword nimConstant varargs untyped bool nimvm any auto iterable lent
syn keyword nimConstant openArray Ordinal owned pointer Positive sink
syn keyword nimConstant Slice SomeFloat SomeInteger SomeNumber SomeOrdinal
syn keyword nimConstant SomeSignedInt SomeUnsignedInt typed typedesc void
syn keyword nimConstant AccessViolationDefect AllocStats ArithmeticDefect
syn keyword nimConstant AssertionDefect AtomType BackwardsIndex BiggestFloat
syn keyword nimConstant BiggestInt BiggestUInt ByteAddress CatchableError
syn keyword nimConstant DeadThreadDefect Defect Exception DivByZeroDefect
syn keyword nimConstant Endianness EOFError IOError ExecIOEffect IOEffect
syn keyword nimConstant FieldDefect FileSeekPos FloatDivByZeroDefect
syn keyword nimConstant FloatInexactDefect FloatingPointDefect
syn keyword nimConstant FloatInvalidOpDefect FloatOverflowDefect
syn keyword nimConstant FloatUnderflowDefect ForeignCell ForLoopStmt
syn keyword nimConstant GC_Strategy HSlice IndexDefect RootEffect JsRoot
syn keyword nimConstant KeyError ValueError LibraryError OSError Natural
syn keyword nimConstant NilAccessDefect NimNode ObjectAssignmentDefect
syn keyword nimConstant ObjectConversionDefect OutOfMemDefect OverflowDefect
syn keyword nimConstant PFloat32 PFloat64 PFrame TFrame PInt32 PInt64
syn keyword nimConstant RangeDefect ReadIOEffect ReraiseDefect
syn keyword nimConstant ResourceExhaustedError RootRef StackOverflowDefect
syn keyword nimConstant TimeEffect TypeOfMode UncheckedArray WriteIOEffect
syn keyword nimConstant appType CompileDate CompileTime cpuEndian hostCPU
syn keyword nimConstant hostOS isMainModule NimMajor NimMinor NimPatch
syn keyword nimConstant NimVersion QuitFailure QuitSuccess

" Strings and character literals
syn region nimString start=+"+ end=+"+ skip=+\%(\\\\\|\\"\)+ contains=nimEscape,@Spell
syn region nimString start=+"""+ end=+"""+ keepend contains=@Spell
syn match nimChar "'.*'"

" Integer numbers in various representations
let s:dec_regex = "\d\%(_\?\d\)*\%(\>\|\ze\D\)"
let s:hex_regex = "0x\x\%(_\?\x\)*\%(\>\|\ze\X\)"
let s:bin_regex = "0b[01]\%(_\?[01]\)*\%(\>\|\ze[^01]\)"
let s:oct_regex = "0o\o\%(_\?\o\)*\%(\>\|\ze\O\)"
let s:int_regex = "\%(" . s:hex_regex
      \         . "\|"  . s:bin_regex
      \         . "\|"  . s:oct_regex
      \         . "\|"  . s:dec_regex
      \         . "\)"
exec 'syn match nimNumber "' . s:int_regex . '"'
syn match nimUnaryMinus "\%(\s\|\t\|\n\|\r\|[,;(\[{]\)-\ze\d"
syn match nimNumberSuffix "\d\zs'[iIuUfF]\%(8\|16\|32\|64\)\?\%(\>\|\ze\D\)"

" Booleans
syn keyword nimBoolean true false on off

" Floating point numbers in various representations
"  starting with a dot, optional exponent
let s:float_regex1 = "\.\d\%(_\?\d\)*\%([eE][-+]\?\d\+\)\?\%(\>\|\ze\D\)"
"  with dot, optional exponent
let s:float_regex2 = "\d\%(_\?\d\)*\.\%(\d\%(_\?\d\)*\)\?\%([eE][-+]\?\d\+\)\?\%(\>\|\ze\D\)"
"  without dot, with exponent
let s:float_regex3 = "\d\%(_\?\d\)*[eE][-+]\?\d\+\%(\>\|\ze\D\)"

"  starting with a dot
let s:hexfloat_regex1 = "0x\.\%\(\x\%(_\?\x\)*\)\?[pP][-+]\?\d\+\%(\>\|\ze\X\)"
"  starting with a digit
let s:hexfloat_regex2 = "0x\x\%(_\?\x\)*\%\(\.\%\(\x\%(_\?\x\)*\)\?\)\?[pP][-+]\?\d\+\%(\>\|\ze\X\)"

let s:float_regex = "\%(" . s:float_regex3
      \           . "\|"  . s:float_regex2
      \           . "\|"  . s:float_regex1
      \           . "\|"  . s:hexfloat_regex2
      \           . "\|"  . s:hexfloat_regex1
      \           . "\)"
exec 'syn match nimFloat "' . s:float_regex . '"'

" Identifiers and functions (incl. some from sdlib i.e. system module)
syn match nimIdentifier "\<\l\%(\h\w\|\w\|\d\)*\*\?\>"
syn keyword nimKeyword proc func method macro template iterator
syn match nimFunction "\l\%(\h\w\|\w\|\d\)*\*\?\%(\[T\]\)\?\ze("

syn keyword nimFunction abs add card chr clamp cmp compiles
syn keyword nimFunction create createShared createSharedU createU
syn keyword nimFunction cstringArrayToSeq dealloc deallocCStringArray
syn keyword nimFunction deallocHeap deallocImpl deallocShared deallocSharedImpl
syn keyword nimFunction debugEcho dec declared declaredScope deepCopy default
syn keyword nimFunction defined del delete dispose echo equalMem excl find
syn keyword nimFunction finished freeShared getStackTrace getStackTraceEntries
syn keyword nimFunction getTypeInfo gorge gorgeEx high inc insert internalNew
syn keyword nimFunction isNil isNotForeign iterToProc len low max min move
syn keyword nimFunction new newSeq newSeqOfCap newSeqUninitialized newString
syn keyword nimFunction newStringOfCap ord pop pred prepareMutation procCall
syn keyword nimFunction protect quit rawEnv rawProc repr reset resize resizeShared
syn keyword nimFunction runnableExamples setControlCHook setCurrentException
syn keyword nimFunction setFrame setFrameState setGcFrame setLen shallow shallowCopy
syn keyword nimFunction sizeof slurp staticExec staticRead substr swap
syn keyword nimFunction toBiggestFloat toBiggestInt toFloat toInt toOpenArray
syn keyword nimFunction toOpenArrayByte toU8 toU16 toU32 typeof unsafeAddr unsafeNew
syn keyword nimFunction wasMoved ze ze64 zeroMem countdown countup varargsLen
syn keyword nimFunction alloc alloc0 allocShared closureScope disarm dumpAllocstats
syn keyword nimFunction formatErrorIndexBound formatFieldDefect likely
syn keyword nimFunction newException offsetOf once rangeCheck realloc
syn keyword nimFunction realloc0 reallocShared reallocShared0 unlikely unown
syn keyword nimFunction doAssertRaises raiseAssert failedAssertImpl doAssert
syn keyword nimFunction assert onFailedAssert items mpairs fieldPairs pairs mitems fields
syn keyword nimFunction addFloat addInt writeFile write writeChars endOfFile
syn keyword nimFunction getFilePos readChars readLines write readLine open
syn keyword nimFunction writeFile reopen readChar writeBuffer getFileHandle
syn keyword nimFunction close getOsFileHandle readFile setFilePos lines
syn keyword nimFunction getFileSize readBytes setInheritable flushFile readAll
syn keyword nimFunction readBuffer writeBytes

" Conditionals
syn keyword nimConditional and case elif else if is isnot not notin of or when xor

" Repeats
syn keyword nimRepeat break continue do for while

" Operators
syn match nimOperator "[=+\-*/<>@$~&%|!?^.:\\`,;]"

" Exception keywords
syn keyword nimException except finally raise try

" All other keywords
syn keyword nimKeyword addr as asm atomic bind block cast const
syn keyword nimKeyword converter defer discard distinct div end enum
syn keyword nimKeyword export from generic import in include
syn keyword nimKeyword interface lambda let mixin mod
syn keyword nimKeyword object out ptr ref return shared
syn keyword nimKeyword shl shr static type using var with without yield

" Types start with uppercase (mostly)
syn match nimType "\<\u\%(\h\w\|\w\|\d\)*\*\?\>"

" Delimiters
syn match nimDelimiter "[()\[\]{}]"

" Default highlight group links, see :h group-name
hi def link nimConstant Constant
hi def link nimTodo SpecialComment
hi def link nimLineComment Comment
hi def link nimBlockComment Comment
hi def link nimChar Character
hi def link nimString String
hi def link nimEscape SpecialChar
hi def link nimNumber Number
hi def link nimUnaryMinus Number
hi def link nimBoolean Boolean
hi def link nimFloat Float
hi def link nimIdentifier Identifier
hi def link nimKeyword Keyword
hi def link nimFunction Function
hi def link nimConditional Conditional
hi def link nimRepeat Repeat
hi def link nimOperator Operator
hi def link nimException Exception
hi def link nimPragma PreProc
hi def link nimType Type
hi def link nimDelimiter Delimiter
hi def link nimNumberSuffix Special

syn sync match nimSync grouphere NONE "^\%(proc\|func\|method\|type\)\>"

if version > 600
    let b:current_syntax = "nim"
endif
let &cpo = s:cpo_save
unlet s:cpo_save
