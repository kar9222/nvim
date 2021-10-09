syn match vimFunc "func[tion]*"
syn match vimKeywordEnd "end[[:alpha:]]*"

" String TODO Double quotes `"` for vimStringDelim messed up with comment. Temporarily exclude it
hi link vimStringDelim Delimiter
syn match vimStringDelim "[']"
syn region vimString matchgroup=vimStringDelim start=+'+ skip=+\\'+ end=+'+
" syn region vimString matchgroup=vimStringDelim start=+"+ skip=+\\"+ end=+"+
