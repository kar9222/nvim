" REPL for R and Julia

" Some functions are copied and adapted from [Nvim-R](https://github.com/jalvesaq/Nvim-R). So those credits fully go to [Jakson Alves de Aquino](https://github.com/jalvesaq)

" NOTE Some functions (e.g. SanitizeRLine) are from built-in Vim runtime source vim/runtime/indent/r.vim

" Hierarchy
" 1. Block (e.g. function, for, if, while)
" 2. Paragraph
" 3. Line

" Helpers ----------------------------------------

function! RWarningMsg(wmsg)
    if v:vim_did_enter == 0
        exe 'autocmd VimEnter * call RWarningMsg("' . escape(a:wmsg, '"') . '")'
        return
    endif
    if mode() == 'i' && (has('nvim-0.4.3') || has('patch-8.1.1705'))
        call RFloatWarn(a:wmsg)
    endif
    echohl WarningMsg
    echomsg a:wmsg
    echohl None
endfunction

" Skip empty lines and lines whose first non blank char is '#'
function! GoDown()
    if &filetype == "rmd"
        let curline = getline(".")
        if curline =~ '^```$'
            call RmdNextChunk()
            return
        endif
    endif

    let i = line(".") + 1
    call cursor(i, 1)
    let curline = CleanCurrentLine()
    let lastLine = line("$")

    " TODO Optimize without repetitively calling `cursor`. Just call after the logic.?
    while i < lastLine && (curline[0] == '#' || strlen(curline) == 0)
        let i = i+1
        call cursor(i, 1)
        let curline = CleanCurrentLine()
    endwhile
endfunction

function! CleanOxygenLine(line)
    let cline = a:line
    if cline =~ "^\s*#\\{1,2}'"
        let synName = synIDattr(synID(line("."), col("."), 1), "name")
        if synName == "rOExamples"
            let cline = substitute(cline, "^\s*#\\{1,2}'", "", "")
        endif
    endif
    return cline
endfunction

function! CleanCurrentLine()
    let curline = substitute(getline("."), '^\s*', "", "")
    if &filetype == "r"
        let curline = CleanOxygenLine(curline)
    endif
    return curline
endfunction

" Cases: For example, the pairs are `(` and `)`
" ( ... ) : 0
" ( ...   : -1
"   ...   : 0
"   ... ) : 1
function! RParenDiff(str)
    " Exclude brackets from string, comments, etc
    let clnln = substitute(a:str, '\\"',  "", "g")
    let clnln = substitute(clnln, "\\\\'",  "", "g")
    let clnln = substitute(clnln, '".\{-}"',  '', 'g')
    let clnln = substitute(clnln, "'.\\{-}'",  "", "g")
    let clnln = substitute(clnln, "#.*", "", "g")

    " Get difference for `{`, `(`, `[` and their closing pairs
    let llen1 = strlen(substitute(clnln, '[{(\[]', '', 'g'))
    let llen2 = strlen(substitute(clnln, '[})\]]', '', 'g'))
    return llen1 - llen2
endfunction

" Similar logic as RParenDiff, but the details are different. NOTE Here, `strlen(line3) - strlen(line2)`, where RParenDiff uses the same `clnln`.
" Count braces TODO Combine both?
" { ... } : 0
" { ...   : 1
"   ...   : 0
"   ... } : -1
" NOTE For two blocks, one outer and one inner, when start iterating from the outer block, two `{` are found and `... += CountBraces(...)` results in positive `2`, then when two `}` are found, `2 - 2 = 0`.
function CountBraces(line)
    let line2 = substitute(a:line, "{", "", "g")
    let line3 = substitute(a:line, "}", "", "g")
    let result = strlen(line3) - strlen(line2)
    return result
endfunction

function CountBracket(line)
    let line2 = substitute(a:line, "(", "", "g")
    let line3 = substitute(a:line, ")", "", "g")
    let result = strlen(line3) - strlen(line2)
    return result
endfunction


" _ Rmd ------------------------------------------

" -- TODO Julia chunk

function! RmdIsInRCode(vrb)
    let chunkline = search("^[ \t]*```[ ]*{r", "bncW")
    let docline = search("^[ \t]*```$", "bncW")
    if chunkline == line(".")
        return 2
    elseif chunkline > docline
        return 1
    else
        if a:vrb
            call RWarningMsg("Not inside an R code chunk.")
        endif
        return 0
    endif
endfunction

function! RmdPreviousChunk() range
    let rg = range(a:firstline, a:lastline)
    let chunk = len(rg)
    for var in range(1, chunk)
        let curline = line(".")
        if RmdIsInRCode(0) == 1 || RmdIsInPythonCode(0)
            let i = search("^[ \t]*```[ ]*{\\(r\\|python\\)", "bnW")
            if i != 0
                call cursor(i-1, 1)
            endif
        endif
        let i = search("^[ \t]*```[ ]*{\\(r\\|python\\)", "bnW")
        if i == 0
            call cursor(curline, 1)
            call RWarningMsg("There is no previous R code chunk to go.")
            return
        else
            call cursor(i+1, 1)
        endif
    endfor
    return
endfunction

function! RmdNextChunk() range
    let rg = range(a:firstline, a:lastline)
    let chunk = len(rg)
    for var in range(1, chunk)
        let i = search("^[ \t]*```[ ]*{\\(r\\|python\\)", "nW")
        if i == 0
            call RWarningMsg("There is no next R code chunk to go.")
            return
        else
            call cursor(i+1, 1)
        endif
    endfor
    return
endfunction


" Send codes -------------------------------------

" TODO
let g:R_bracketed_paste = 1
let g:R_parenblock = 1
let g:R_paragraph_begin   = get(g:, "R_paragraph_begin",    1)

" @param ... Unused placeholder TODO
func! SendCmdToR(_cmd, ...)  " NOTE It's `Send_to_term` from repl.vim
    let l:cmd = a:_cmd
    " let l:cmd = cmd . "\r"

    " if g:repl_bracketed_paste == 1
    "     let l:cmd = "\x1b[200~" .. cmd .. "\x1b[201~"
    " endif
    call chansend(Last_active_term_job_id(), cmd)
    if g:repl_autoscroll | call Autoscroll_last_active() | endif
    return 1  " TODO For `let ok`
endfu

" Send current line to R.
function SendLineToR(godown, ...)
    let lnum = get(a:, 1, ".")
    let line = getline(lnum)
    if strlen(line) == 0
        if a:godown =~ "down"
            call GoDown()
        endif
        return
    endif

    if &filetype == "rmd"
        if line == "```"
            if a:godown =~ "down"
                call GoDown()
            endif
            return
        endif
        if line =~ "^```.*child *= *"
            call KnitChild(line, a:godown)  " TODO
            return
        endif
        let line = substitute(line, "^(\\`\\`)\\?", "", "")
        if RmdIsInRCode(0) != 1
            if RmdIsInPythonCode(0) == 0  " TODO
                call RWarningMsg("Not inside an R code chunk.")
                return
            else
                let line = 'reticulate::py_run_string("' . substitute(line, '"', '\\"', 'g') . '")'
            endif
        endif
    endif

    if &filetype == "r"
        let line = CleanOxygenLine(line)
    endif

    " Case: Block with chaining, if chaining option is set to true
    let block = 0
    if g:R_parenblock
        let chunkend = ""
        if &filetype == "rmd"
            let chunkend = "```"
        endif
        let rpd = RParenDiff(line)
        let has_op = line =~ '\|>\s*$'

        " TODO It doesn't handle cases where cursor is below opening paren
        " NOTE `let cline += 1` near the end of this `if` chunk
        if rpd < 0  " e.g. rpd is -1 where cursor is at opening paren
            let line1 = line(".")
            let cline = line1 + 1
            while cline <= line("$")
                let txt = getline(cline)
                if chunkend != "" && txt == chunkend  " Break for Rmd
                    break
                endif
                let rpd += RParenDiff(txt)  " If closing paren is found, rpd becomes 0
                if rpd == 0  " Closing paren
                    " Continue searching downwards if chaining is found
                    let has_op = getline(cline) =~ '\|>\s*$'
                    for lnum in range(line1, cline)
                        if g:R_bracketed_paste  " TODO
                            if lnum == line1 && lnum == cline
                                let ok = g:SendCmdToR("\x1b[200~" . getline(lnum) . "\x1b[201~\n", 0)
                            elseif lnum == line1
                                let ok = g:SendCmdToR("\x1b[200~" . getline(lnum))
                            elseif lnum == cline
                                let ok = g:SendCmdToR(getline(lnum) . "\x1b[201~\n", 0)
                            else
                                let ok = g:SendCmdToR(getline(lnum))
                            endif
                        else
                            let ok = g:SendCmdToR(getline(lnum))
                        end
                        if !ok
                            " always close bracketed mode upon failure
                            if g:R_bracketed_paste
                                call g:SendCmdToR("\x1b[201~\n", 0)
                            end
                            return
                        endif
                    endfor
                    call cursor(cline, 1)
                    let block = 1
                    break
                endif
                let cline += 1
            endwhile
        endif
    endif

    " Case: Single line
    if !block
        if g:R_bracketed_paste
            let ok = g:SendCmdToR("\x1b[200~" . line . "\x1b[201~\n", 0)
        else
            let ok = g:SendCmdToR(line)
        end
    endif

    if ok
        if a:godown =~ "down"
            call GoDown()
            if exists('has_op') && has_op
                call SendLineToR(a:godown)  " NOTE Recursively iterate chaining
            endif
        else
            if a:godown == "newline"
                normal! o
            endif
        endif
    endif
endfunction


" Default IsInRCode function when the plugin is used as a global plugin TODO
function! DefaultIsInRCode(vrb)
    return 1
endfunction
let b:IsInRCode = function("DefaultIsInRCode")

" Send paragraph to R
function SendParagraphToR(m)  " Omitted `e`
    if &filetype != "r" && b:IsInRCode(1) != 1
        return
    endif

    let o = line(".")
    let c = col(".")
    let i = o
    if g:R_paragraph_begin && getline(i) !~ '^\s*$'
        let line = getline(i-1)
        while i > 1 && !(line =~ '^\s*$' ||
                    \ (&filetype == "rnoweb" && line =~ "^<<") ||
                    \ (&filetype == "rmd" && line =~ "^[ \t]*```{\\(r\\|python\\)"))
            let i -= 1
            let line = getline(i-1)
        endwhile
    endif
    let max = line("$")
    let j = i
    let gotempty = 0
    while j < max
        let line = getline(j+1)
        if line =~ '^\s*$' ||
                    \ (&filetype == "rnoweb" && line =~ "^@$") ||
                    \ (&filetype == "rmd" && line =~ "^[ \t]*```$")
            break
        endif
        let j += 1
    endwhile
    let lines = getline(i, j)

    " TODO Modified code
    let lines = join(lines, "\n")
    let ok = g:SendCmdToR("\x1b[200~" . lines . "\x1b[201~\n", 0)
    " let ok = RSourceLines(lines, a:e, "paragraph")

    if ok == 0
        return
    endif
    if j < max
        call cursor(j, 1)
    else
        call cursor(max, 1)
    endif
    if a:m == "down"
        call GoDown()
    else
        call cursor(o, c)
    endif
endfunction


" Send functions to R. Summary of algo
" 1. Find the line containing `function`
" 2. Find function opening brace `{`
" 2. Find function closing brace `}`
function SendFunctionToR(m)  " Omitted `e`
    if &filetype != "r" && b:IsInRCode(1) != 1
        return
    endif

    let startline = line(".")
    let save_cursor = getpos(".")
    let line = SanitizeRLine(getline("."))
    let i = line(".")

    " Find the line containing `function` TODO Can be optimized with `{` ?
    while i > 0 && line !~ "function"
        let i -= 1
        let line = SanitizeRLine(getline(i))
    endwhile
    if i == 0
        call RWarningMsg("Begin of function not found.")
        return
    endif

    " Assert function assign operator `<-` or `=`
    let functionline = i
    while i > 0 && line !~ '\(<-\|=\)[[:space:]]*\($\|function\)'
        let i -= 1
        let line = SanitizeRLine(getline(i))
    endwhile
    if i == 0
        call RWarningMsg("The function assign operator  <-  was not found.")
        return
    endif

    " Find function opening brace `{`
    let firstline = i
    let i = functionline
    let line = SanitizeRLine(getline(i))
    let tt = line("$")
    while i < tt && line !~ "{"
        let i += 1
        let line = SanitizeRLine(getline(i))
    endwhile
    if i == tt
        call RWarningMsg("The function opening brace was not found.")
        return
    endif

    " Find function closing brace `}`
    let nb = CountBraces(line)  " `nb` of `functionline` is 1 with `{`
    while i < tt && nb > 0
        let i += 1
        let line = SanitizeRLine(getline(i))
        let nb += CountBraces(line)  " If `}` is found, `nb` becomes 0
    endwhile
    if nb != 0
        call RWarningMsg("The function closing brace was not found.")
        return
    endif
    let lastline = i

    if startline > lastline
        call setpos(".", [0, firstline - 1, 1])
        call SendFunctionToR(a:m)  " CUSTOM Omitted `e`
        call setpos(".", save_cursor)
        return
    endif

    let lines = getline(firstline, lastline)

    " TODO Modified code
    let lines = join(lines, "\n")
    let ok = g:SendCmdToR("\x1b[200~" . lines . "\x1b[201~\n", 0)
    " let ok = RSourceLines(lines, a:e, "function")

    if  ok == 0
        return
    endif
    if a:m == "down"
        call cursor(lastline, 1)
        call GoDown()
    endif
endfunction


" Send functions to R. Summary of algo
" 1. Find the line containing function/if/for/while
" 2. Find opening brace `{`
" 3. Find closing brace `}`
"
" NOTE With multi-block chunk, when cursor is at the first line of most outer block, the algo simply iterates from top to bottom.
"
" However, when cursor is at, for example, one line above the end of outer block, (also refer to CountBraces)
" 1. Find inner block...
" 2. Find outer block...
" Hence, this case results in slower algo because it needs to firstly find the inner block, then the next outer block, the next next outer block, and so on.
"
function SendBlockToR(m)  " Omitted `e`
    if &filetype != "r" && b:IsInRCode(1) != 1 | return | endif

    let startline = line(".")
    let save_cursor = getpos(".")
    let line = SanitizeRLine(getline("."))
    let i = line(".")

    " Find the line containing function/if/for/while followed by `(`
    while i > 0 && line !~ "\\(function\(\\|^\\s*if\\s*\(\\|^\\s*for\\s*\(\\|^\\s*while\\s*\(\\)"  " TODO Correct?
        let i -= 1
        let line = SanitizeRLine(getline(i))
    endwhile
    if i == 0
        call RWarningMsg("Begin of block not found.")
        return
    endif

    " Assert function assign operator `<-` or `=`
    let functionline = i
    " while i > 0 && line !~ '\(<-\|=\)[[:space:]]*\($\|function\)'
    "     let i -= 1
    "     let line = SanitizeRLine(getline(i))
    " endwhile
    " if i == 0
    "     call RWarningMsg("The function assign operator  <-  was not found.")
    "     return
    " endif

    " Find function opening brace `{`
    let firstline = i
    let i = functionline
    let line = SanitizeRLine(getline(i))
    let tt = line("$")
    while i < tt && line !~ "{"
        let i += 1
        let line = SanitizeRLine(getline(i))
    endwhile
    if i == tt
        call RWarningMsg("The function opening brace was not found.")
        return
    endif

    " Find function closing brace `}`
    let nb = CountBraces(line)  " `nb` of `functionline` is 1 with `{`
    while i < tt && nb > 0
        let i += 1
        let line = SanitizeRLine(getline(i))
        let nb += CountBraces(line)  " If `}` is found, `nb` becomes 0
    endwhile
    if nb != 0
        call RWarningMsg("The function closing brace was not found.")
        return
    endif
    let lastline = i

    " Recursively search upward for outer block
    " e.g. initial cursor position is in outer block, resulting in startline larger than lastline of the inner block
    if startline > lastline
        call setpos(".", [0, firstline - 1, 1])  " firstline of inner block
        call SendBlockToR(a:m)
        call setpos(".", save_cursor)
        return
    endif

    " These are called after the last recursive function (if any) TODO
    let lines = getline(firstline, lastline)
    let lines = join(lines, "\n")
    let ok = g:SendCmdToR("\x1b[200~" . lines . "\x1b[201~\n", 0)

    if ok == 0 | return | endif
    if a:m == "down"
        call cursor(lastline, 1)
        call GoDown()
    endif
endfunction


" Send the most outer block, including function/if/for/while/etc to R, even when cursor is at any of the inner block. Summary of algo
" 1. Search upwards for `}`
" 2. If first non-blank column is 0, it's assumed that the outer block has been found, though this might not be the rare cases where the inner block has no indentation.
" 3. Search the matching `}` of the most outer block
"
" NOTE It returns 0 for passing the value to SendChainToR
"
function SendMostOuterBlockToR(move)
    call GoDown_if_empty_or_comment()

    let save_pos = getpos('.')
    let pat = "\\(.*function\(\\|if\\s*\(\\|for\\s*\(\\|while\\s*\(\\)"
    let [l, c] = searchpos(pat, 'cbn', 1)

    if l == 0  " searchpos reach 1st line gives `l` 0
        " call RWarningMsg("Begin of block not found.")
        let s:is_mostOuterBlock = 0
        return
    endif

    " Recursively search upward for the most outer block, even if cursor is at any of the inner block
    if c != 1
        let l += -1  " Move up by 1 line to search for outer block
        call cursor(l, c)
        call SendMostOuterBlockToR(a:move)
        " call cursor(save_pos[1], save_pos[2])
        return
    endif

    " Most outer block is found. Find opening brace `{`
    let firstLine = l
    let line = SanitizeRLine(getline(l))
    let tt = line('$')
    while l < tt && line !~ "{"
        let l += 1
        let line = SanitizeRLine(getline(l))
    endwhile
    if l == tt
        call RWarningMsg('The opening brace was not found.')
        return
    endif

    " Find closing brace `}`
    let line = SanitizeRLine(getline(l))
    let nb = CountBraces(line)  " `nb` of line with `{` is 1
    while l < tt && nb > 0
        let l += 1
        let line = SanitizeRLine(getline(l))
        let nb += CountBraces(line)  " If `}` is found, `nb` becomes 0
    endwhile
    if nb != 0
        call RWarningMsg('The closing brace was not found.')
        return
    endif
    let lastLine = l

    if s:startLine > lastLine
        call cursor(s:startLine, 1)  " TODO Restore `call cursor` above
        " call RWarningMsg('Begin of block not found.')
        let s:is_mostOuterBlock = 0
        return
    endif

    " These are called after the last recursive function (if any) TODO
    let lines = getline(firstLine, lastLine)
    let lines = join(lines, "\n")
    let ok = g:SendCmdToR("\x1b[200~" . lines . "\x1b[201~\n", 0)
    call v:lua.highlight_range(firstLine, lastLine, 1, 0)

    if ok == 0 | return | endif
    if a:move == "down" | call cursor(lastLine + 1, 1) | endif
endfunction


" Send blocks, including function/if/for/while/etc to R. Summary of algo
" 1. Find the line containing function/if/for/while/etc
" 2. Find function opening brace `{`
" 2. Find function closing brace `}`
function __backup__SendBlockToR(m)  " Omitted `e`
    if &filetype != "r" && b:IsInRCode(1) != 1
        return
    endif

    let startline = line(".")
    let save_cursor = getpos(".")
    let line = SanitizeRLine(getline("."))
    let i = line(".")

    " Find the line containing `function` TODO Can be optimized with `{` ?
    while i > 0 && line !~ "{"
        let i -= 1
        let line = SanitizeRLine(getline(i))
    endwhile

    " CONT R block
    if i == 0
        call RWarningMsg("Begin of function not found.")
        return
    endif

    " Assert function assign operator `<-` or `=`
    " let functionline = i
    " while i > 0 && line !~ '\(<-\|=\)[[:space:]]*\($\|function\)'
    "     let i -= 1
    "     let line = SanitizeRLine(getline(i))
    " endwhile
    " if i == 0
    "     call RWarningMsg("The function assign operator  <-  was not found.")
    "     return
    " endif

    " Find function opening brace `{`
    let firstline = i
    " let i = functionline
    let line = SanitizeRLine(getline(i))
    let tt = line("$")
    " while i < tt && line !~ "{"
    "     let i += 1
    "     let line = SanitizeRLine(getline(i))
    " endwhile
    " if i == tt
    "     call RWarningMsg("The function opening brace was not found.")
    "     return
    " endif

    " Find function closing brace `}`
    let nb = CountBraces(line)  " `nb` of `functionline` is 1 with `{`
    while i < tt && nb > 0
        let i += 1
        let line = SanitizeRLine(getline(i))
        let nb += CountBraces(line)  " If `}` is found, `nb` becomes 0
    endwhile
    if nb != 0
        call RWarningMsg("The function closing brace was not found.")
        return
    endif
    let lastline = i

    if startline > lastline
        call setpos(".", [0, firstline - 1, 1])
        call SendBlockToR(a:m)  " CUSTOM Omitted `e`
        call setpos(".", save_cursor)
        return
    endif

    let lines = getline(firstline, lastline)

    " TODO Modified code
    let lines = join(lines, "\n")
    let ok = g:SendCmdToR("\x1b[200~" . lines . "\x1b[201~\n", 0)
    " let ok = RSourceLines(lines, a:e, "function")

    if  ok == 0
        return
    endif
    if a:m == "down"
        call cursor(lastline, 1)
        call GoDown()
    endif
endfunction

" Continue searching downwards if chaining is found by recording this variable for calling recursive function TODO
" TODO breakerofchain just trim of unwanted operators e.g. `+`, then remove these operators for the very last line.
function EndInOperator(line)  " TODO Parameterized SanitizeRLine
    let line = SanitizeRLine(a:line)
    " SanitizeRLine removes trailing whitespaces, hence there is no need to match them, as in `\s*$`
    return line =~ "\\(,\\|<-\\|=\\|%>%\\||>\\|+\\|-\\|*\\|/\\|&\\|&&\\||\\|||\\)$"
    " return line !~ "\\(%[^%]+%\\|\+\\|(?<!<)-\\|\*\\|/|\||&|&&|\|\||\|>\\)$"
endfunction

function ChainOperator(line)  " TODO
    let line = SanitizeRLine(a:line)
    return line =~ ",$"
endfunction

function Is_empty_or_comment_line(line)
    let is_empty = strlen(a:line) == 0
    let is_comment = a:line =~ "^\\s*#"
    return is_empty || is_comment ? 1 : 0
endfunction

" Recursively search upward for chaining pattern
function GetChainStart(move)  " s:chainStart init-ed with line('.')
    let line = SanitizeRLine(getline(s:chainStart))
    if &filetype == "r" | let line = CleanOxygenLine(line) | endif

    let chunkStart = ""
    if &filetype == "rmd"
        let chunkStart =~ "^```"
    endif
    let rpd = RParenDiff(line)

    " Case: Line with both paren, with opening paren or without paren (including middle of a function). Do nothing because
    " if rpd <= 0 | let s:chainStart = s:chainStart

    " Case: Block
    if rpd > 0  " Line with closing paren(s)
        let s:chainStart -= 1  " -1 because we are in a block
        while s:chainStart >= 1
            let txt = getline(s:chainStart)
            if chunkStart != "" && txt == chunkStart  " Break for Rmd
                break
            endif
            let rpd += RParenDiff(txt)  " If opening paren is found, rpd becomes 0

            if rpd > 0  " Hasn't reach opening bracket
                let s:chainStart -= 1
            else  " Found opening paren with rpd == 0
                break
            endif
        endwhile
    endif

    " Recursively search upward for chaining pattern.
    " NOTE s:chainStart tries searching for chain above empty/comment line, if any.
    let prevLineNr = s:chainStart - 1
    let prevLine = getline(prevLineNr)
    let is_empty_or_comment_line = Is_empty_or_comment_line(prevLine)
    if EndInOperator(prevLine) || is_empty_or_comment_line
        if ! is_empty_or_comment_line
            let s:first_not_empty_or_comment_line = prevLineNr
        endif
        let s:chainStart -= 1
        call GetChainStart(a:move)
        return
    endif
    " In case s:chainStart search beyond the s:first_not_empty_or_comment_line, restores it.
    let s:chainStart = s:first_not_empty_or_comment_line
endfunction

" Recursively search downward for chaining pattern
function GetChainEnd(move)  " s:chainEnd init-ed with line('.')
    let line = SanitizeRLine(getline(s:chainEnd))
    if &filetype == "r" | let line = CleanOxygenLine(line) | endif

    let chunkend = ""
    if &filetype == "rmd" | let chunkend = "```" | endif
    let rpd = RParenDiff(line)

    " Case: Line with both paren, with closing paren or without paren (including middle of a function). Do nothing because
    " if rpd >= 0 | let s:chainEnd = s:chainEnd

    " Case: Block
    if rpd < 0  " Line with opening paren(s)
        let s:chainEnd += 1  " +1 because we are in a block
        while s:chainEnd <= line("$")
            let txt = getline(s:chainEnd)
            if chunkend != "" && txt == chunkend  " Break for Rmd
                break
            endif
            let rpd += RParenDiff(txt)  " If closing paren is found, rpd becomes 0

            if rpd < 0  " Hasn't reach closing bracket
                let s:chainEnd += 1
            else  " Found closing paren with rpd == 0
                break
            endif
        endwhile
    endif

    " Recursively search downward for chaining pattern.
    " NOTE s:chainEnd tries searching for chain below empty/comment line, if any.
    " NOTE Unlike GetChainStart, s:chainEnd of GetChainEnd doesn't iterate beyond empty/comment line (due to the inherent algorithm), hence this part is slightly different than that of GetChainStart.
    let nextLine = getline(s:chainEnd)
    if EndInOperator(nextLine) || Is_empty_or_comment_line(nextLine)
        let s:chainEnd += 1
        call GetChainEnd(a:move)
        return
    endif
endfunction

" Recursively search downward for start of chain to the expression-at-cursor. If the expression-at-cursor is multi-line expression, it can be at any line.
function GetCurrentChain(move)  " s:chainEnd init-ed with line('.')
    let line = SanitizeRLine(getline(s:chainEnd))
    let rpd = RParenDiff(line)

    " Case: Line with both paren, with closing paren or without paren (including middle of a function). Do nothing because
    " if rpd >= 0 | let s:chainEnd = s:chainEnd

    " Case: Block
    if rpd < 0  " Line with opening paren(s)
        let s:chainEnd += 1  " +1 because we are in a block
        while s:chainEnd <= line("$")
            let txt = getline(s:chainEnd)
            let rpd += RParenDiff(txt)  " If closing paren is found, rpd becomes 0

            if rpd < 0  " Hasn't reach closing bracket
                let s:chainEnd += 1
            else  " Found closing paren with rpd == 0
                break
            endif
        endwhile
    endif

    " If 'chain operator' e.g. %>% isn't found, recursively search downward
    if ChainOperator(getline(s:chainEnd))
        let s:chainEnd += 1
        call GetCurrentChain(a:move)
    endif
endfunction

" NOTE Call this once to avoid being called recursively functions
function GoDown_if_empty_or_comment()
    let line = getline('.')
    let is_empty = strlen(line) == 0
    let is_comment = line =~ "^\\s*#"

    if is_empty || is_comment
        call GoDown()
    endif
endfunction

function SendChainToR(move)
    call GoDown_if_empty_or_comment()

    if &filetype == "rmd"  " TODO Does it belong here?
        if line == "```"
            if a:move =~ "down"
                call GoDown()
            endif
            return
        endif
        if line =~ "^```.*child *= *"
            call KnitChild(line, a:godown)  " TODO
            return
        endif
        let line = substitute(line, "^(\\`\\`)\\?", "", "")
        if RmdIsInRCode(0) != 1
            if RmdIsInPythonCode(0) == 0  " TODO
                call RWarningMsg("Not inside an R code chunk.")
                return
            else
                let line = 'reticulate::py_run_string("' . substitute(line, '"', '\\"', 'g') . '")'
            endif
        endif
    endif

    " Init for GetChainLineNr_***. Variables used for sending lines to REPL. Additionally, these variables are also useful for debugging e.g. after commenting out some codes.
    let l = line('.')
    let s:chainStart = l
    let s:chainEnd   = l
    let s:first_not_empty_or_comment_line = l

    call GetChainStart(a:move)
    call GetChainEnd(a:move)

    " TODO Modified code
    let lines = getline(s:chainStart, s:chainEnd)
    let lines = join(lines, "\n")
    let ok = g:SendCmdToR("\x1b[200~" . lines . "\x1b[201~\n", 0)
    call v:lua.highlight_range(s:chainStart, s:chainEnd, 1, 0)

    if ok == 0
        return
    endif
    if a:move == "down"
        call cursor(s:chainEnd + 1, 1)
    endif
endfunction

" Similar as SendChainToR. See there for detailed comments.
" The idea is stolen from [MilesMcBain/breakerofchains](jgithub.com/MilesMcBain/breakerofchains). The full credit goes to [Miles McBain](https://github.com/MilesMcBain)
function SendPartialChainToR(move)
    let l = line('.')

    let line = getline(l)
    let is_empty = strlen(line) == 0
    let is_comment = line =~ "^\s*#"
    if is_empty || is_comment
        call RWarningMsg('Cursor is not at chain block.')
        return
    endif

    let s:chainStart = l
    let s:chainEnd   = l
    call GetChainStart(a:move)
    call GetCurrentChain(a:move)
    let lines = getline(s:chainStart, s:chainEnd)

    " Trim trailing comment and chain-operator
    let lines[-1] = substitute(lines[-1], "#.*", '', '')
    let lines[-1] = substitute(lines[-1], "\\(%>%\\|+\\||>\\)\\s*$", '', '')

    let lines = join(lines, "\n")  " TODO
    let ok = g:SendCmdToR("\x1b[200~" . lines . "\x1b[201~\n", 0)
    call v:lua.highlight_range(s:chainStart, s:chainEnd, 1, 0)

    if ok == 0 | return | endif
    if a:move == "down"
        let nextLine = s:chainEnd + 1
        let firstNonBlankCol = match(getline(nextLine), '\S') + 1
        call cursor(nextLine, firstNonBlankCol)
    endif
endfunction

function GoDown_sendChainToR(move)
    call GoDown_if_empty_or_comment()  " Call here once
    call SendChainToR(a:move)
endfunction

function GoDown_sendBlockToR(move)
    call GoDown_if_empty_or_comment()  " Call here once
    call SendBlockToR(a:move)
endfunction

" If most outer block is found, send it, else, send chain object.
function GoDown_send_mostOuterBlock_or_chain(move)
    let s:startLine = line('.')  " Check if cursor is inside most outer block
    let s:is_mostOuterBlock = 1

    " call GoDown_if_empty_or_comment()  " Call here once
    " Run most outer block and, if it runs successfully, return 1, else 0
    call SendMostOuterBlockToR(a:move)
    if ! s:is_mostOuterBlock
        " call GoDown_if_empty_or_comment()
        call SendChainToR(a:move)
    endif
endfunction


" Julia ------------------------------------------

" Use internal functions/stuffs of {julia-vim} e.g. julia_blocks#select_a and b:julia_begin_keywordsm

let g:i = 0  " DEV
let s:start_pos = [0, 0, 0, 0]  " Init dummy variable

function RunMostOuterBlock_jl(move)
    call GoDown_if_empty_or_comment()

    let g:i += 1  " DEV
    " To deal with, for example, `a = begin ...`
    normal! $
    call julia_blocks#select_a()  " TODO
    let start_end_pos = julia_blocks#select_a()

    if empty(start_end_pos)  " Not in block
        " let s:is_mostOuterBlock = 0
        return
    else
        let [start_pos, end_pos] = start_end_pos
    endif

    if s:start_pos != start_pos
        let s:start_pos = start_pos
        call RunMostOuterBlock_jl(a:move)
        return
    endif
    let start_line = start_pos[1]
    let end_line = end_pos[1]

    let lines = getline(start_line, end_line)  " TODO
    let lines = join(lines, "\n")
    call v:lua.highlight_range(start_line, end_line, 1, 0)
    call SendCmdToR("\x1b[200~" . lines . "\x1b[201~\n", 0)

    if a:move == "down"
        call cursor(end_line + 1, 1)
    endif

    ec g:i
endfunction

" If most outer block is found, send it, else, send chain object.
function GoDown_send_mostOuterBlock_or_chain_jl(move)
    " let s:startLine = line('.')  " Check if cursor is inside most outer block
    " let s:is_mostOuterBlock = 1

    call GoDown_if_empty_or_comment()  " Call here once
    " Run most outer block and, if it runs successfully, return 1, else 0
    " call RunMostOuterBlock_jl(a:move)

    " TODO This is very slow
    " TODO Test if in julia block using syntax sydID?
    let flags = 'Wn'
    let searchret = searchpair(b:julia_begin_keywordsm, '', b:julia_end_keywords, flags, b:match_skip)

    if searchret > 0  " Cursor is in block
        call RunMostOuterBlock_jl(a:move)
    else " Cursor isn't in block
        call SendChainToR(a:move)  " TODO This is slow?
    endif

    " if ! s:is_mostOuterBlock
    "     " call GoDown_if_empty_or_comment()
    "     call SendChainToR(a:move)
    " endif
endfunction

" Send command ----------------------------------

func! Send_cmd(cmd)
    let l:text = a:cmd . "\r"
    call chansend(Last_active_term_job_id(), text)
    if g:repl_autoscroll | call Autoscroll_last_active() | endif
endfu


" _ Function -------------------------------------

func! R_jl_func(func, mode)
    " In insert mode, `<cword>` is 1 char to the right. Hence, hacky way is used to expand `<cword>`.
    if a:mode == 'insert'
        norm! h
    endif
    let cword = expand('<cword>')
    if a:mode == 'insert'
        norm! l
    endif

    let l:text = a:func . '(' . cword . ')' . "\r"

    call chansend(Last_active_term_job_id(), text)
    if g:repl_autoscroll | call Autoscroll_last_active() | endif
    call Highlight_text(cword)
endfu


" _ Help -----------------------------------------

" Use `workbench.action.terminal.sendSequence` instead of `r.runCommandWithSelectionOrWord` for correctly sending keypress `?` to Julia REPL
" NOTE Send "?" as" term sequence "\x3f" because Julia's REPL doesn't recognize "?". And bracketed-paste isn't required for the term sequence.

func! Send_help_sel()
    let text = "\x3f" . expand('<cword>')
    let save_val = g:repl_bracketed_paste
    let g:repl_bracketed_paste = 0  
    call Send_to_term(text)
    let g:repl_bracketed_paste = save_val  
endfu

func! Send_help_sel__visual()
    let text = "\x3f" . Get_selection()
    let save_val = g:repl_bracketed_paste
    let g:repl_bracketed_paste = 0  
    call Send_to_term(text)
    let g:repl_bracketed_paste = save_val  
endfu


" _ Keybinds -------------------------------------

augroup REPL_R
    au!
    au FileType r nnoremap <buffer> <f5> <cmd>call GoDown_send_mostOuterBlock_or_chain('down')<CR>
    au FileType r nnoremap <buffer> <c-m-f9> <cmd>call GoDown_send_mostOuterBlock_or_chain('down')<CR>  " AHKREMAP <c-CR>
    au FileType r nnoremap <buffer> <c-m-f8> <cmd>call GoDown_send_mostOuterBlock_or_chain('stay')<CR>  " AHKREMAP <c-m-CR>

    au FileType r,julia nnoremap <buffer> <leader>dc <cmd>call GoDown_sendChainToR('down')<CR>
    au FileType r,julia nnoremap <buffer> <leader>db <cmd>call GoDown_sendBlockToR('down')<CR>

    au FileType r,julia nnoremap <buffer> <leader><tab> <cmd>call Send_cmd('ans')<CR>
    au FileType r,julia nnoremap <buffer> <leader>`     <cmd>call Send_cmd('str(ans)')<CR>
    au FileType r,julia nnoremap <buffer> \s            <cmd>call Send_cmd('run_shiny()')<CR>

    au FileType quarto  nnoremap <buffer> \s            <cmd>call Send_cmd('quarto serve ' . expand('%') . ' --port 9999')<CR>

    au FileType r,julia nnoremap <buffer> <c-t> <cmd>call R_jl_func('str', 'normal')<CR>
    au FileType r,julia inoremap <buffer> <c-t> <cmd>call R_jl_func('str', 'insert')<CR>
    au FileType r,julia nnoremap <buffer> <c-a> <cmd>call R_jl_func('names', 'normal')<CR>
    au FileType r,julia inoremap <buffer> <c-a> <cmd>call R_jl_func('names', 'insert')<CR>

    au FileType r,julia nnoremap <buffer> <leader>? <cmd>call Send_help_sel()<CR>
    au FileType r,julia xnoremap <buffer> <leader>? :<c-u>call Send_help_sel__visual()<CR>
augroup END
" TODO let b:jlblk_count = 1
augroup REPL_jl
    au!
    au FileType julia nnoremap <buffer> <f5> <cmd>call GoDown_send_mostOuterBlock_or_chain_jl('down')<CR>
    au FileType julia nnoremap <buffer> <c-m-f9> <cmd>call GoDown_send_mostOuterBlock_or_chain_jl('down')<CR>  " AHKREMAP <c-CR>
    au FileType julia nnoremap <buffer> <c-m-f8> <cmd>call GoDown_send_mostOuterBlock_or_chain_jl('stay')<CR>  " AHKREMAP <c-m-CR>
augroup END

augroup REPL_R_jl
    au!
    au FileType r,julia nnoremap <buffer> <c-m-i> <cmd>call SendPartialChainToR('down')<CR>
    au FileType r,julia nnoremap <buffer> <m-I>   <cmd>call SendPartialChainToR('stay')<CR>
    au FileType r,julia inoremap <buffer> <c-m-i> <cmd>call SendPartialChainToR('down')<CR><esc>l
    au FileType r,julia inoremap <buffer> <m-I>   <cmd>call SendPartialChainToR('stay')<CR>
augroup END


" DEV?
" nnoremap e <cmd>call RunMostOuterBlock_jl('down')<CR>

" TODO Check whether cursor is in code block e.g. `{...}` or `keyword...end`
" TODO Highlight before sending code
" TODO Wrap both highlight and send codes?
" TODO GoDown_if_empty_or_comment wrong for e.g. 'send most outer in R' ?
    " let ret_find_block = s:find_block(current_mode)
    " if empty(ret_find_block)
    "   return 0
    " endif
