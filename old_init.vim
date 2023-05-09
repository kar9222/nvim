" Cursor -----------------------------------------

" Enable mode shapes, "Cursor" highlight, and blinking TODO
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
		    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
		    \,sm:block-blinkwait175-blinkoff150-blinkon175


" Navigation -------------------------------------

func! MultiScroll(up_dn)  " TODO Replace neoscroll?
    let up_dn = a:up_dn == 'up' ? "\<c-y>" : "\<c-e>"

    for i in range(1, 5)
        exe 'normal!' . up_dn
        " sleep 16m
    endfor
endfu

" nnoremap <c-y> <cmd>call MultiScroll('up')<CR>
" nnoremap <c-e> <cmd>call MultiScroll('dn')<CR>
nnoremap <c-y> 5<c-y>
nnoremap <c-e> 5<c-e>
vnoremap <c-y> 5<c-y>
vnoremap <c-e> 5<c-e>
" NOTE <c-y> and <c-e> are already mapped with 5<c-y> and 5<c-e>
inoremap <c-y> <c-o>5<c-y>
inoremap <c-e> <c-o>5<c-e>

" Toggle zoom of right window (hacky way) AHKREMAP TODO Temporarily use Vim script
let g:is_win_max = 0
func! Toggle_zoom_right_win()
    let right_most_win_num = winnr('10l')  " Hacky way  -- TODO Window ID, not number
    let old_width = winwidth(right_most_win_num)

    if !g:is_win_max
      exe ':vert ' . right_most_win_num . 'resize 160'
      wincmd l
      normal! i
      let g:is_win_max = 1
    else
      " TODO `old_width`:
      " exe ':vert ' . right_most_win_num . 'resize ' . old_width
      exe ':vert ' . right_most_win_num . 'resize 73'
      startinsert
      let g:is_win_max = 0
    endif
endfu
nnoremap <c-m-s-f10> <cmd>call Toggle_zoom_right_win()<CR>
inoremap <c-m-s-f10> <esc><cmd>call Toggle_zoom_right_win()<CR>
tnoremap <c-m-s-f10> <c-\><c-n><cmd>call Toggle_zoom_right_win()<CR>

" Implementation in Lua --------------------------
" -- Toggle zoom of right window
" local api = vim.api
" local fn  = vim.fn
" _G.is_win_max = false
" local function toggle_zoom_right_win()
"     right_most_win_num = api.nvim_win_get_number(...)
"     old_width = api.nvim_win_get_width(tostring(right_most_win_num))

"     if not is_zoom_toggle then
"         api.nvim_win_set_width(right_most_win_num, 160)
"         -- ...
"     else
"         api.nvim_win_set_width(right_most_win_num, old_width)
"         -- ...
"     end
" end
" vimp.nnoremap('<c-m-s-f10>', function() toggle_zoom_right_win() end)
" vimp.inoremap('<c-m-s-f10>', ...)
" vimp.tnoremap('<c-m-s-f10>', ...)
" ------------------------------------------------


" Editing ----------------------------------------

" TODO Error when run the 1st time, unless reload init.vim manually?
func! s:append_line_n_move(to)
    let to = a:to

    let line_ = to == 'dn' ? line('.') : line('.') - 1
    call append(line_, repeat([''], v:count1))

    let move = to == 'dn' ? 'j' : 'k'
    exe 'normal! ' . v:count1 . move
endfu

nnoremap <silent> <CR>      <Cmd>call <SID>append_line_n_move('dn')<CR>
nnoremap <silent> <leader>O <Cmd>call <SID>append_line_n_move('up')<CR>


" _ Section comment ------------------------------

" https://learnvimscriptthehardway.stevelosh.com/chapters/44.html
" set filetype?

" TODO General and need 1 more divider
func! s:section_comment(comment_start)
    " TODO Parameterize these based on file type
    let comment_start = a:comment_start
    let comment_end = ''

    " Construct num of divider
    let n_divider_max         = 51
    let n_space_after_section = 1
    let n_col_offset          = 1
    let n_divider = n_divider_max - len(comment_start) - n_space_after_section - n_col_offset - len(comment_end) - col('.')

    let section_ = repeat('-', n_divider)

    exe "normal! ^i" . comment_start
    exe "normal! $a " . section_ . comment_end
endfu
" TODO Why need <right> ?
au FileType r     inoremap <buffer> <m-c> <cmd>call <sid>section_comment('# ')<CR><right>
au FileType julia inoremap <buffer> <m-c> <cmd>call <sid>section_comment('# ')<CR><right>
au FileType vim   inoremap <buffer> <m-c> <cmd>call <sid>section_comment('" ')<CR><right>
au FileType lua   inoremap <buffer> <m-c> <cmd>call <sid>section_comment('-- ')<CR><right>
au FileType autohotkey inoremap <buffer> <m-c> <cmd>call <sid>section_comment('; ')<CR><right>
au FileType sh inoremap <buffer> <m-c> <cmd>call <sid>section_comment('# ')<CR><right>
" au FileType vim   nnoremap gc <Cmd>call <sid>section_comment('" ')<CR>
" Tests work ?
" au FileType r     nnoremap <buffer> <leader>h hh
" au FileType julia nnoremap <buffer> <leader>h ll


" Search -----------------------------------------

" TODO https://www.reddit.com/r/vim/comments/gnxp1p/remap_ctrlg_and_ctrlt_in_search/
cnoremap <expr> <c-n> getcmdtype() =~ '[\/?]' ? '<c-g>' : '<c-n>'
cnoremap <expr> <c-p> getcmdtype() =~ '[\/?]' ? '<c-t>' : '<c-p>'


" Unicode ----------------------------------------

" Same as Tmux

let @y = "ŷ"
let @m = "μ"
let @s = "σ"
let @p = "α"
let @b = "β"
let @g = "γ"
let @e = "ϵ"
let @r = "ρ"
let @l = "λ"
let @t = "θ"
let @d = "δ"
let @n = "η"
let @q = "√"
let @i = "ᵢ"
let @c = "⫫"
let @u = "τ"
let @2 = "²"
let @3 = "³"
let @4 = "±"


" {vim-easymotion} -------------------------------

" _ General --------------------------------------

" let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
" nmap s <Plug>(easymotion-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap <leader>m <Plug>(easymotion-bd-f)

" n-character search motion
map  <leader>F <Plug>(easymotion-sn)
omap <leader>F <Plug>(easymotion-tn)
" TODO
" These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
" map  n <Plug>(easymotion-next)
" map  N <Plug>(easymotion-prev)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" _ Custom highlighting --------------------------

" [Custom highlighting](https://github.com/easymotion/vim-easymotion/blob/9f1c449edfce6d61c7f620e3a9c1389b7b7e334f/doc/easymotion.txt#L942)

" hi clear EasyMotionTarget
" hi clear EasyMotionShade
au BufEnter * hi EasyMotionShade term=bold cterm=bold ctermfg=25 guifg=#6E858D
au BufEnter * hi EasyMotionIncSearch term=bold cterm=bold ctermfg=25 gui=bold guifg=#f02077
au BufEnter * hi EasyMotionTarget term=bold cterm=bold ctermfg=25 gui=bold guifg=#f02077
au BufEnter * hi EasyMotionTarget2First term=bold cterm=bold ctermfg=25 gui=bold guifg=#99ddff
au BufEnter * hi EasyMotionTarget2Second term=bold cterm=bold ctermfg=25 gui=bold guifg=#79bddf

" TODO Light theme
" au BufEnter * hi EasyMotionTarget term=bold cterm=bold ctermfg=25 gui=bold guifg=#440154
" au BufEnter * hi EasyMotionIncSearch term=bold cterm=bold ctermfg=25 gui=bold guifg=#440154
" au BufEnter * hi EasyMotionShade term=bold cterm=bold ctermfg=25 guifg=#81816F

" TODO
" EasyMotionTarget2First
" EasyMotionTarget2Second


" {targets.vim} ----------------------------------

" _ Custom keybind -------------------------------

let g:targets_aiAI = 'aIAi'


" {vim-easy-align} -------------------------------

" Align common operators
" TODO This doesn't work: `\ '#': { 'pattern': '#', 'left_margin': 2 },`
let g:easy_align_delimiters = {
\ '#': { 'pattern': '\s#', 'left_margin': 1 },
\ '~': { 'pattern': '\~' },
\ 'a': { 'pattern': '<-\|=\|,' }
\ }

" Interactive mode for motion/text object and visual mode
nmap ga         <Plug>(EasyAlign)
nmap <leader>ga <Plug>(LiveEasyAlign)
xmap ga         <Plug>(EasyAlign)
xmap <leader>ga <Plug>(LiveEasyAlign)
" Command line mode
xnoremap gA :Easy<space>


" {vim-wordmotion} -------------------------------

" Alternative {bkad/CamelCaseMotion}

let g:wordmotion_prefix = '<leader>'

" TODO More stuffs. See docs.


" Avoid scrolling when switching buffers ---------

" TODO See if this is needed: gillyb/stable-windows. But NOTE that installing this breaks my hacky <m-1>

" TODO https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers#:~:text=When%20switching%20buffers%20using%20the,line%20relative%20to%20the%20screen.
" Save current view settings on a per-window, per-buffer basis.
function! AutoSaveWinView()
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
function! AutoRestoreWinView()
    let buf = bufnr("%")
    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
        let v = winsaveview()
        let atStartOfFile = v.lnum == 1 && v.col == 0
        if atStartOfFile && !&diff
            call winrestview(w:SavedBufView[buf])
        endif
        unlet w:SavedBufView[buf]
    endif
endfunction

" When switching buffers, preserve window view.
autocmd BufLeave * call AutoSaveWinView()
autocmd BufEnter * call AutoRestoreWinView()


" Utils ------------------------------------------

func! CaptureExCmd(cmd)  " In new tab for debugging/etc
    redir => message
    silent exe a:cmd
    redir END

    if empty(message)
        echoerr 'No output'
    else
        tabnew
        setlocal buftype=nofile filetype=vim bufhidden=wipe noswapfile nobuflisted nomodified
        silent put=message
    endif
endfu

command! -nargs=+ -complete=command CaptureExCmd call CaptureExCmd(<q-args>)










" DEV --------------------------------------------

" " Convenience wrapper for developing syntax, highlighting, plugin, etc.
" " NOTE Adjust as appropriate
" " NOTE Un-comment when needed and, when done, comment-out.
" func! Reload_syn_hi()
"   " Clear and reload syntax
"   " syn clear
"   " :so /home/kar/project/my_pkg/mythings/linux/julia-vim/syntax/julia.vim
"   " :so /home/kar/project/my_pkg/mythings/linux/julia-vim/ftplugin/julia.vim<CR>

"   " Clear and reload highlight
"   " hi clear
"   colorscheme minimalist
"   :so /home/kar/project/my_pkg/mythings/linux/.config/nvim/after/syntax/r.vim

"   echo 'Reloaded. When done, comment out this section!  😂 🤣 ☺️ 😊 😇 '
" endfu

" nnoremap q <cmd>call Reload_syn_hi()<CR>
