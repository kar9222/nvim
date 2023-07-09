" Namespace
syn match rNamespace "[[:alnum:]_.]\+\(::\)\@="

" Function
syn match rFunctionName '\w\+\( <- function\)\@='  " TODO One/more whitespace

" String
hi link rStringDelim Delimiter
syn region String matchgroup=rStringDelim start=+'+ skip=+\\'+ end=+'+
syn region String matchgroup=rStringDelim start=+"+ skip=+\\"+ end=+"+

" Override `!` operator from default `rOperator` highlight group
syn match rNotOperator "!"


" Code section, comment --------------------------

hi link rComment Comment

syn match rCommentKey "#" contained
syn match rCodeSectionEndDelim "----*" contained

syn match rComment "#.*" contains=rCommentKey
syn match rCodeSection "^\s*#.*----*$" contains=rCommentKey,rCodeSectionEndDelim

syn keyword rKeywordFunction function  " override `function` in rType
