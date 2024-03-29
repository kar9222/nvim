setlocal shiftwidth=2  " TODO

inoremap <buffer> <m-0> <space><-<space>
inoremap <buffer> <m-p> <space>\|><space>
inoremap <buffer> <m-e> <space>%like%<space>
inoremap <buffer> <m-i> <space>%in%<space>

" R's data.table
inoremap <buffer> <m-;> <space>:=<space>
inoremap <buffer> <m-.> .()<left>
inoremap <buffer> <m-[> [, ]<left>
inoremap <buffer> <m-:> `:=` ()<left>
inoremap <buffer> <m-S> .SDcols =


" {targets} --------------------------------------

nnoremap <buffer> <f8> <cmd>call Send_to_term("tar_outdated_()")<CR>
nnoremap <buffer> <f7> <cmd>call Send_to_term("tar_visnetwork_() ; max_active_win()")<CR>
" AHKREMAP <win-f9>
nnoremap <buffer> <c-m-f3> <cmd>call Send_to_term("tar_make_()")<CR>


" _ `tar_read`, `tar_load` -----------------------

func! s:send_tar_read_load(read_load)
    let read_load = a:read_load == 'read' ? 'tar_read' : 'tar_load'
    let text = read_load . '(' . expand('<cword>') . ')'
    call Send_to_term(text)
endfu

" NOTE It only works for single target
func! s:send_tar_read_load__visual(read_load)
    let col_start = getpos("'<")[2] - 1
    let col_end   = getpos("'>")[2] - 1
    let text = getline('.')[col_start : col_end]

    let read_load = a:read_load == 'read' ? 'tar_read' : 'tar_load'
    let text = read_load . '(' . text . ')'
    call Send_to_term(text)
endfu

nnoremap <buffer> <silent> <leader>h <cmd>call <SID>send_tar_read_load('read')<CR>
nnoremap <buffer> <silent> <leader>l <cmd>call <SID>send_tar_read_load('load')<CR>
xnoremap <buffer> <silent> <leader>h :<c-u>call <SID>send_tar_read_load__visual('read')<CR>
xnoremap <buffer> <silent> <leader>l :<c-u>call <SID>send_tar_read_load__visual('load')<CR>


" Shiny ------------------------------------------

func! Shiny_save_n_autoreload()
    write
    call Send_to_term('shinyr::save_n_autoreload()')
endfu
nnoremap <buffer> <silent> <f6> <cmd>call Shiny_save_n_autoreload()<CR>


" dt_pipe ----------------------------------------

" TODO
" - See tag TODO_NVIM for migrating this script from VSCode to Nvim.
" - Currently, when nvim-cmp pops up, it doesn't work. Temporary workaround is to escape and re-enter into insert mode.

" TODO Last line
" TODO Rename confusing `line`, `line2`

" TODO Init
" iris(par1 = 1,
"      par2 = 2)

" Resources
" getline, indent, repeat

" @param n_line_break 1 or 2

func! s:Dt_pipe(dt_arg_pos, n_line_break)

    if     a:n_line_break == 1 | let s:line_breaks = "\n"
    elseif a:n_line_break == 2 | let s:line_breaks = "\n\n"
    endif

    let getline2 = getline('.')
    let s:line2  = line('.')
    let col2     = col('.')

    let chr_after_cursor = getline2[col2 - 1]  " TODO Previously no `- 1`
    let g:z = chr_after_cursor

    " Insert text --------------------------------

    func! s:Insert_texts()

        " TODO_NVIM Previously "normal! a" due to escaping first in normal mode
        exe "normal! i" .
          \ s:text_before_indent . s:line_breaks .
          \ s:backspaces . s:indents . s:text_after_indent

        " " Cursor position is diff due to diff `text_after_indent`. Adjust it based on position of `]`
        if getline('.')[col('.')] == ']' | normal! l
        endif

        sleep 20m  " for `i`
    endfu

    " Texts, indents ------------------------------

    " _ Init -------------------------------------

    " BY HAND Place cursor AFTER ')'
    " TODO Make conditions above more robust

    if chr_after_cursor != "]"

        if a:dt_arg_pos == 2 | let s:text_before_indent = " [,"
        else                 | let s:text_before_indent = " ["
        endif

        if a:dt_arg_pos == 2 | let s:text_after_indent = "]"
        else                 | let s:text_after_indent = "][]"
        endif

        " ___ Get 'backspaces', 'indents' --------

        let chr_before_cursor = getline2[col2 - 1]

        " Case: `func(...)` -   -   -   -   -   -   -   -
        " Find matching brackets

        if chr_before_cursor == ")"

            func! s:Get_contents()
                return getline(s:line2)
            endfu

            let s:contents = s:Get_contents()

            func! s:Get_n_open_brac()
                return count(s:contents, '(')
            endfu

            func! s:Get_n_close_brac()
                return count(s:contents, ')')
            endfu

            let s:n_open_brac  = s:Get_n_open_brac()
            let s:n_close_brac = s:Get_n_close_brac()

            while (s:n_open_brac != s:n_close_brac) && s:line2 >= 1

              " Move up by 1 line and accumulate 'n_open_brac' and
              " 'n_close_brac' until they are equal
              let s:line2 -= 1
              let s:contents        = s:Get_contents()
              let s:n_open_brac     = s:n_open_brac  + s:Get_n_open_brac()
              let s:n_close_brac    = s:n_close_brac + s:Get_n_close_brac()
            endwh
        endif

        " If `chr_bfore_cursor` is ')', override `s:indent2` with indents of line with opening bracket
        if chr_before_cursor == ')' | let s:indent2 = indent(s:line2)
        " TODO
        " For normal case, 'line2' is current line. For Case `func(...)`, line2 is new.
        " Vim auto-indent 'line_break' based on current line, minus them back to adjust for cases where indents > 0, while for cases where indents == 0, it's not affected.
        " let s:indent2 = indent(s:line2) - indent('.')
        " let s:indent2 = indent('.')
        else                        | let s:indent2 = indent('.')
        endif

        " Adjust indents for i-arg & j-arg due to diff 'text_after_indent'
        " i-arg: `][`
        " j-arg: (none)
        if a:dt_arg_pos == 2 | let s:indent2 += 4
        else                 | let s:indent2 += 2
        endif

        " Delete all left for 'weird indentation'
        let s:backspaces = "\<C-u>"

        let s:indents = repeat(' ', s:indent2)

    " _ Cont -------------------------------------

    else
        if a:dt_arg_pos == 2 | let s:text_before_indent = " ][,"
        else                 | let s:text_before_indent = ""
        endif

        " `]` is automatically inserted after `[`
        if a:dt_arg_pos == 2 | let s:text_after_indent = ""
        else                 | let s:text_after_indent = "]["
        endif

        " ___ Get 'indent2' ----------------------

        " _____ Get last pipe --------------------

        " ...for correct indentation. For instance,
        " ][...]
        " ...
        " )]

        func! s:Get_contents()
            return getline(s:line2)
        endfu

        let s:contents = s:Get_contents()

        func! s:Get_is_line_open_brac()
            " For (respectively) 'init' i arg  || 'cont' i arg  ||  'cont' j arg
            if (s:contents =~ "[,")      ||
             \ (s:contents =~ "^\\s*][") ||
             \ (s:contents =~ "][,\\s*$")
                return 1
            endif
        endfu

        let s:is_line_open_brac = s:Get_is_line_open_brac()

        while ( ! s:is_line_open_brac)
            " Move up by 1 line and search for patterns of opening brackets...
            let s:line2 -= 1
            let s:contents = s:Get_contents()
            let s:is_line_open_brac = s:Get_is_line_open_brac()
        endwh

        " _____ Get contents below last pipe -----

        " ...for getting auto-generated indentation after 'line_break' for downstream adjustment (ie for single line & i-arg expr like `][...]`, auto-generated indentation is wrong)

        " TODO Refactor
        " For i-arg-last-pipe, do nothing. Else (for j-arg-last-pipe), move dn by 1 line. For instance, this solves
        " ][...,
        "   ...]
        " and
        " `s:is_line_brac_n_square_brac`
        if s:contents =~ "^\\s*][" | let s:line2 = s:line2 + 0
        else                       | let s:line2 = s:line2 + 1
        endif

        " Case: empty lines below last pipe

        func! s:Get_contents()
            return getline(s:line2)
        endfu

        let s:contents = s:Get_contents()

        " While 'contents' are empty
        while (s:contents =~ '^\s*$')
            " Move dn by 1 line and search for the nxt non-blank line...
            let s:line2 += 1
            let s:contents = s:Get_contents()
        endwh

        " _____ Get 'backspaces', 'indents' ------

        let s:is_line_i_pipe             = getline2   =~ '^\s*]['
        let s:is_line_brac_n_square_brac = getline2   =~ '^\s*)]'
        let s:is_line2_i_pipe            = s:contents =~ '^\s*]['
        let s:indent_line2               = indent(s:line2)

        " TODO
        " Vim auto-indent 'line_break' based on current line, minus them back to adjust for cases where indents > 0, while for cases where indents == 0, it's not affected.
        " let s:indent2 = indent(s:line2) - indent('.')
        let s:indent2 = 0

        if (a:dt_arg_pos == 1)

            if s:is_line_brac_n_square_brac ||
             \ ( ( ! s:is_line_i_pipe) &&
             \   ( ! s:is_line_brac_n_square_brac) && ( ! s:is_line2_i_pipe) )
                   " Minus 2 indents for inserting `][`. NOTE `<BS>` also depends on `tabstop`? Here, 1 backspace equals 2 tabstops
                   let s:backspaces = "\<BS>"
            else | let s:backspaces = ""
            endif
        endif

        if (a:dt_arg_pos == 2)

            let s:backspaces = ""

            if s:is_line_i_pipe || s:is_line2_i_pipe | let s:indent2 += 2
            endif
            if s:is_line_brac_n_square_brac | let s:indent2 += indent(s:line2)
            endif
        endif

        let s:indents = repeat(' ', s:indent2)
    endif

    " Call ---------------------------------------

    call s:Insert_texts()
    " try
    "     call s:Insert_texts()
    " catch
    "     call feedkeys(nvim_replace_termcodes('<right>', 1, 1, 1))
    "     " sleep 1000m
    "     " call feedkeys(nvim_replace_termcodes('<m-space>', 1, 1, 1))
    " endtry
endfu

" NOTE During the last steps, `<Esc>` before `i` for 'weird' highlighting
" NOTE `sleep` for dt_pipe_j_arg


" See ->                                Dt_pipe(dt_arg_pos, n_line_break)
" dt_pipe_arg_j
inoremap <buffer> <silent> <m-]> <cmd>call <sid>Dt_pipe(2, 1)<CR>
" dt_pipe_arg_i
inoremap <buffer> <silent> <C-]> <cmd>call <sid>Dt_pipe(1, 1)<CR>
" dt_pipe_arg_j_line_break AHKREMAP <m-s-]>
inoremap <buffer> <silent> <c-m-f5> <cmd>call <sid>Dt_pipe(2, 2)<CR>
" dt_pipe_arg_i_line_break AHKREMAP <c-s-]>
inoremap <buffer> <silent> <c-m-f4> <cmd>call <sid>Dt_pipe(1, 2)<CR>











" Backup -----------------------------------------

" Find opening bracket TODO Wrong?
" while i > 0 && line !~ "("
"     let i -= 1
"     let line = SanitizeRLine(getline(i))
" endwhile
" if i == 0
"     call RWarningMsg('Opening bracket `(` not found.')
"     return
" endif

" CONT Find chain

" let s:chainStart = i  " TODO
" let line = SanitizeRLine(getline(i))  " TODO
