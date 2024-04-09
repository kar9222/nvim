" TODO Correct?
runtime! ftplugin/r.vim

set textwidth=0

" Jump to prev/next start of fenced code block ----

func! Message(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfu

func! To_prev_code_block()
    let start_line = line('.')
    let start_screen_line = line('w0')
    normal! k
    let first_line = search('```{', 'bW')
    let last_line  = search('```', 'Wn')

    if start_line == line('.') + 1
        call Message("There is no more code block above.")
        normal! j
    else
        call v:lua.highlight_range(first_line + 1, last_line , 1, 1)
        normal! j
        if first_line < start_screen_line
            normal! zz
        endif
    endif
endfu

func! To_next_code_block()
    let start_line = line('.')
    let end_screen_line = line('w$')
    let first_line = search('```{', 'W')
    let last_line  = search('```', 'Wn')

    if start_line == line('.')
        call Message("There is no more code block below")
    else
        call v:lua.highlight_range(first_line + 1, last_line , 1, 1)
        normal! j
        if last_line > end_screen_line
            normal! zz
        endif
    endif
endfu

nnoremap <silent> [a <cmd>call To_prev_code_block()<CR>
nnoremap <silent> ]a <cmd>call To_next_code_block()<CR>


" Prev/next start/end of code block --------------

func! s:to_start_end_code_block(to)
    let flags       = a:to == 'previous' ? 'b' : ''
    let move_cursor = a:to == 'previous' ? 'j' : 'k'
    call search('^```', flags)
    exe 'normal! ' . move_cursor
endfu

nnoremap <silent> [s <Cmd>call <SID>to_start_end_code_block('previous')<CR>
nnoremap <silent> ]s <Cmd>call <SID>to_start_end_code_block('next')<CR>
xnoremap <silent> [s <Cmd>call <SID>to_start_end_code_block('previous')<CR>
xnoremap <silent> ]s <Cmd>call <SID>to_start_end_code_block('next')<CR>


" Custom text obj --------------------------------

" - TODO [kana/vim-textobj-user](https://github.com/kana/vim-textobj-user)
" - [Include text object for fenced code block? #282](https://github.com/plasticboy/vim-markdown/issues/282)
" - [How Do I Create New Text Objects in Neovim/Vim](https://jdhao.github.io/2020/11/15/nvim_text_objects/)

" __ Block ---------------------------------------

" Tmp soln
" TODO
" https://vi.stackexchange.com/questions/19027/how-to-expand-selection-to-containing-block
nnoremap <leader>B [{V%
xnoremap <leader>B "_y[{V%


" Markdown fenced code block ---------------------

" TODO Choose a better version from links above

function! s:inCodeFence()
    " Search backwards for the opening of the code fence.
	call search('^```.*$', 'bceW')
    " Move one line down
	normal! j
    " Move to the begining of the line at start selecting
	normal! 0v
    " Search forward for the closing of the code fence.
	call search("```", 'ceW')

	normal! kg_
endfunction

function! s:aroundCodeFence()
    " Search backwards for the opening of the code fence.
	call search('^```.*$', 'bcW')
	normal! v$
    " Search forward for the closing of the code fence.
	call search('```', 'eW')
endfunction

xnoremap <silent> if :<c-u>call <sid>inCodeFence()<cr>
onoremap <silent> if :<c-u>call <sid>inCodeFence()<cr>
xnoremap <silent> af :<c-u>call <sid>aroundCodeFence()<cr>
onoremap <silent> af :<c-u>call <sid>aroundCodeFence()<cr>


" REPL -------------------------------------------
" TODO If cursor at chunk end line
function! Send_chunk()  " TODO Check for cursor inside chunk
    let first_line = search('```{', 'bn')
    let last_line  = search('```', 'n')
    call Send_lines(first_line + 1, last_line - 1)
    call v:lua.highlight_range(first_line + 1, last_line , 1, 1)
endfunction
" AHKREMAP <c-s-CR>
nnoremap <c-m-f6> <cmd>call Send_chunk()<CR>
inoremap <c-m-f6> <cmd>call Send_chunk()<CR>


func! Shiny_save_n_autoreload__rmd()
    write
    call Send_to_term('shinyr::save_n_autoreload("reports/rmarkdown/index.Rmd")')
endfu

nnoremap <buffer> <silent> <f6> <cmd>call Shiny_save_n_autoreload__rmd()<CR>
