" Setup ------------------------------------------

let g:slime_dont_ask_default = 1  " TODO Bypass prompt and use the specified default config
let g:slime_no_mappings = 1  " Disable default mappings
let g:slime_target = "neovim"  " Term buffer
let g:slime_preserve_curpos = 1  " Default

" Startup ----------------------------------------

" TODO https://vi.stackexchange.com/questions/21449/send-keys-to-a-terminal-buffer

" Workaround to setup Nvim term job_id with {vim-slime} https://github.com/jpalardy/vim-slime/issues/232#issuecomment-692846238
func! SlimeOverrideConfig()
  let l:job_id = trim(execute(":echo b:terminal_job_id"))
  wincmd h
  let b:slime_config = {}
  let b:slime_config['jobid'] = job_id
endfu

" Alternatively, do something like: au TermOpen * call SlimeOverrideConfig()
func! StartNvimTerm()
    :vsp
    :Neomux  " :terminal tmux attach-session
    " :$  " TODO
    :vertical resize 73
    :call SlimeOverrideConfig()
endfu

nnoremap <leader>T <cmd>call StartNvimTerm()<CR>

" General ----------------------------------------

func! Repl_sendLine_move()  " TODO Adapt for operator mode `nmap`
  call slime#send(getline(".") . "\r")
  normal! j
endfu

nnoremap <leader>n <cmd>call slime#send(expand('<cword>') . "\r")<CR>
xmap <leader>n <plug>SlimeRegionSend
nnoremap <leader>u <cmd>call Repl_sendLine_move()<CR>
nmap <leader>m <plug>SlimeMotionSend
nmap <c-m-f9> <plug>SlimeParagraphSend  " AHKREMAP <c-CR>
nmap <f5> <plug>SlimeParagraphSend
" File TODO

" Run from top-to-current-line and current-line-to-last
nnoremap <leader>y <cmd>call slime#send_range(1, line('.'))<CR>
nnoremap <leader>t <cmd>call slime#send_range(line('.'), line('$') - 1)<CR>


" R, Julia ---------------------------------------

func! R_jl_func(func)
    let text = a:func . '(' . expand('<cword>') . ')'
    call slime#send(text . "\r")
endfu

augroup r_jl
    au!
    au FileType r,julia nnoremap <c-m-f12> <cmd>call R_jl_func('str')<CR>
    au FileType r,julia nnoremap <c-m-f11> <cmd>call R_jl_func('names')<CR>
augroup END





" augroup Terminal
"   au!
"   au TermOpen * let g:last_terminal_job_id = b:terminal_job_id
" augroup END

" func! REPLSend(lines)
"   call chansend(g:last_terminal_job_id, add(a:lines, ''))
"   normal! j
" endfu

" command! REPLSendLine call REPLSend([getline('.')])
" nnoremap <silent> <leader>u :REPLSendLine<cr>
