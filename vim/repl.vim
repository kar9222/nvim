" REPL for all file types

" Some functions are copied and adapted from [neoterm](https://github.com/kassio/neoterm). So those credits fully go to [Kassio Borges](https://github.com/kassio).

" NOTE neoterm's internal variables (e.g. last active terminal) are used. Hence, becareful when changing config/plugin/etc.
" TODO Highlight
" TODO neoterm_autoscroll

" NOTE Some keybinds depends on, for example, Send_to_term. If refactor this to Lua, change related keybinds.

let g:repl_bracketed_paste = 1
let g:repl_autoscroll = 1

func! Save_mark()  " TODO Some not working 
    norm! mb
endfu

func! Send_word_under_cursor()
    let text = expand('<cword>')

    let l = line('.')
    let col_start = searchpos(text, 'bnc')[1]
    let col_end = col_start + len(text)  
    call v:lua.highlight_range(l, l, col_start, col_end)

    call Send_to_term(text . "\r")
endfu

" @param move Move down by one line
func! Send_currentLine_move(move)
    call Save_mark()
    call GoDown_if_empty_or_comment()

    let l:line = getline('.')
    let l = line('.')
    if a:move 
        norm! j
    endif
    call Send_to_term(l:line)
    call v:lua.highlight_range(l, l, 1, 0)
endfu

function! Send_lines(...) abort
  let l:lines = join(getline(a:1, a:2), "\n")
  call Send_to_term(l:lines)
  call v:lua.highlight_range(a:1, a:2, 1, 0)
endfunction

function! Get_selection() abort
  let [l:lnum1, l:col1] = getpos("'<")[1:2]
  let [l:lnum2, l:col2] = getpos("'>")[1:2]

  if &selection ==# 'exclusive'
    let l:col2 -= 1
  endif

  let l:lines = getline(l:lnum1, l:lnum2)
  let l:lines[-1] = l:lines[-1][ : l:col2 - 1]
  let l:lines[0]  = l:lines[0][l:col1 - 1 : ]
  let l:lines = join(l:lines, "\n")
  return l:lines
endfunction

function! Send_selection() abort
  call Save_mark()
  call Send_to_term(Get_selection())
endfunction

function! Send_motion(type) abort
  call Save_mark()
  let [l:lnum1, l:col1] = getpos("'[")[1:2]
  let [l:lnum2, l:col2] = getpos("']")[1:2]
  let l:lines = getline(l:lnum1, l:lnum2)

  if a:type ==# 'char'
    let l:lines[-1] = l:lines[-1][ : l:col2 - 1]
    let l:lines[0]  = l:lines[0][l:col1 - 1 : ]
  endif
  let l:lines = join(l:lines, "\n")

  call Send_to_term(l:lines)

  " Highlight range
  if a:type ==# 'line'
      call v:lua.highlight_range(l:lnum1, l:lnum2, 1, 0)  
  elseif a:type ==# 'char'
      call v:lua.highlight_range(l:lnum1, l:lnum2, l:col1, l:col2 + 1, 'v', 0)  " TODO Correct? Param inclusive somehow makes it correct, regardless of value 
  endif

  call cursor(l:lnum2, 0)
endfunction

function! Go_down_send_paragraph() abort
    call GoDown_if_empty_or_comment()
    set operatorfunc=Send_motion
    normal! g@ipj
endfunction

" Get last active terminal job ID based on neoterm's internally recorded info. NOTE As per doc, `g.neoterm.last_active` is updated on `Tnew`, `T`, `Topen`, `Ttoggle` and `Texec`.
func! Last_active_term_job_id()
    return g:neoterm.instances[g:neoterm.last_active].termid
endfu

func! Autoscroll_last_active()
    call g:neoterm.instances[g:neoterm.last_active].normal('G')
endfu

func! Send_to_term(_cmd)
    let l:cmd = a:_cmd
    let l:cmd = cmd . "\r"

    if g:repl_bracketed_paste == 1
        let l:cmd = "\x1b[200~" .. cmd .. "\x1b[201~"
    endif
    call chansend(Last_active_term_job_id(), cmd)
    if g:repl_autoscroll | call Autoscroll_last_active() | endif
endfu


" Keybindings ------------------------------------
" TODO Need <c-u> ?
nnoremap <leader>n <cmd>call Send_word_under_cursor()<CR>
xnoremap <leader>n :<c-u> call Send_selection()<CR>
nnoremap <leader>u  <cmd>call Send_currentLine_move(1)<CR>
nnoremap <leader>q <cmd>call Send_currentLine_move(0)<CR>
nmap <silent> <leader>d :set operatorfunc=Send_motion<CR>g@
nnoremap <silent> <leader>a <cmd>call Go_down_send_paragraph()<CR>
" nmap <c-m-f9> <plug>SlimeParagraphSend  " AHKREMAP <c-CR>
" nmap <f5> <plug>SlimeParagraphSend
" File TODO

" Send_word_under_cursor and move. NOTE `' n'` is keybind defined for the function.
let @h=' nB'
let @j=' nj'
let @k=' nk'
let @l=' nW'

" Run top-to-current-line, current-line-to-last and all-lines
nnoremap <leader>y <cmd>call Send_lines(1, line('.'))<CR>
nnoremap <leader>t <cmd>call Send_lines(line('.'), line('$'))<CR>
nnoremap <leader>T <cmd>call Send_lines(1, line('$'))<CR>


" TODO
" nnoremap <silent> :<c-u>set opfunc=Send_to_term<CR>g@
" nnoremap <silent> :<c-u>set opfunc=neoterm#repl#opfunc<bar>exe 'norm! 'v:count1.'g@_'<cr>










" Backup -----------------------------------------

" TODO Benchmark latency for this and the current solution
" Hacky way to identify 'active term' triggered when cursor leave 'usually-used' window. TODO Description
" let g:term_leave = 0
" au TermOpen  * let g:term_leave = b:terminal_job_id
" au TermLeave * let g:term_leave = b:terminal_job_id
"
" Then, call something similar
" call chansend(g:term_leave, l:cmd)
