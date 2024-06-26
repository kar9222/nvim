" Code section, comment --------------------------

" NOTE Slightly different than syntax/r.vim. Here, I use julia-vim's juliaCommentDelim and juliaCommentL. Highlight of juliaCommentDelim is style in theme.

syn match juliaCommentKey "#" contained
syn match juliaCodeSectionEndDelim "----*" contained

syn match juliaCodeSection "^\s*#.*----*$" contains=juliaCommentKey,juliaCodeSectionEndDelim


" For sending codes to REPL (see repl_r_julia.vim)
let b:jlblk_count = 1
