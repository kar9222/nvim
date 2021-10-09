" Startup ----------------------------------------

" func! StartNvimTerm()
"     :vsp
"     :terminal tmux attach-session
"     " :$  " TODO
"     :vertical resize 73
" endfu

" nnoremap <leader>T <cmd>call StartNvimTerm()<CR>


" REPL -------------------------------------------

" TODO If this is used, remove `REPL.GlobalOptions.auto_indent = false...` from startup.jl
" TODO See vim-slime, for example
" - setreg
" - Restore yanked register `"`...

" TODO For Julia REPL, try `call feedkeys("<CR>")`

function! s:SendToWindow(type, direction)

  let s:saved_register = @@
  let s:saved_pos = getpos(".")

  " Obtain wanted text
  if a:type == 'v' || a:type == 'V' || a:type == "\<C-V>"
    keepjumps normal! `<v`>y
    if a:type == 'V'
      let @@ = substitute(@@, '\n$', '', '')  " Remove EOL
    endif
    call setpos(".", getpos("'>"))
  elseif a:type ==# "char"
    keepjumps normal! `[v`]y
    call setpos(".", getpos("']"))
  elseif a:type ==# "line"
    keepjumps normal! `[V`]$y
    call setpos(".", getpos("']"))
  endif

  let g:mytype=a:type

  " Was the cursor at the end of line?
  let s:endofline = 0
  if col(".") >=# col("$")-1
    let s:endofline = 1
  endif

  execute "wincmd " . a:direction
  normal! gp
  call chansend(3, "\r")
  wincmd p

  " Position the cursor for the next action
  if s:endofline
    normal! j0
  elseif a:type ==# "char"
    normal! l
  endif

  " Restore register
  let @@ = s:saved_register

endfunction


function! SendRight(type)
  call s:SendToWindow(a:type, 'l')
endfunction

func! SendWordUnderCursor()
  let s:saved_registerK = @k
  let @k = expand('<cword>')
  wincmd l
  normal! "kp
  call chansend(3, "\r")
  wincmd p
  let @k = s:saved_registerK  " Restore register
endfu

func! SendLineMove()
  let s:saved_registerK = @k
  let @k = getline('.')
  wincmd l
  normal! "kp
  call chansend(3, "\r")
  wincmd p
  normal! j  " TODO Move further if it's comment?
  let @k = s:saved_registerK  " Restore register
endfu

func! SendParagraphMove()
  let s:saved_registerJ = @j
  let s:saved_register_clipboard = @+

  normal! yap
  call setpos(".", getpos("'>"))
  wincmd l
  normal! gp
  call chansend(3, "\r")
  wincmd p
  normal! j  " TODO Move further if it's comment?

  " Restore register
  let @+ = s:saved_register_clipboard
endfu

func! SendRange(startLine, endLine)
  let rv = getreg('"')
  let rt = getregtype('"')

  silent exe a:startLine . ',' . a:endLine . 'yank'
  wincmd l
  normal! gp
  call chansend(3, "\r")
  wincmd p

  call setreg('"', rv, rt)  " Restore registers
endfu


" Word-under-cursor
nnoremap <silent> <leader>n <cmd>call SendWordUnderCursor()<CR>
vnoremap <silent> <plug>SendRightV :<c-u>call SendRight(visualmode())<CR>
" Selection
xmap <leader>n <plug>SendRightV
" Single line and move
nnoremap <silent> <leader>u <cmd>call SendLineMove()<CR>
" Motion, including multi-line
nmap <silent> <leader>m :set operatorfunc=SendRight<CR>g@
" Paragraph TODO Motion like vim-slime?
nnoremap <silent> <c-m-f9> <cmd>call SendParagraphMove()<CR>  " AHKREMAP <c-CR>
nnoremap <silent> <f5> <cmd>call SendParagraphMove()<CR>
" File TODO

" Run from top-to-current-line and current-line-to-last
nnoremap <silent> <leader>y <cmd>call SendRange(1, line('.'))<CR>
nnoremap <silent> <leader>t <cmd>call SendRange(line('.'), line('$') - 1)<CR>


" R, Julia ---------------------------------------

func! R_jl_func(func)
    let s:saved_registerK = @k
    let s:saved_registerJ = @j

    let @j = a:func . '(' . expand('<cword>') . ')'
    let @k = "\r"

    wincmd l
    normal! "jp
    normal! "kp
    wincmd p

    " Restore registers
    let @j = s:saved_registerJ
    let @k = s:saved_registerK
endfu

augroup r_jl
    au!
    au FileType r,julia nnoremap <c-m-f12> <cmd>call R_jl_func('str')<CR>
    au FileType r,julia nnoremap <c-m-f11> <cmd>call R_jl_func('names')<CR>
augroup END
