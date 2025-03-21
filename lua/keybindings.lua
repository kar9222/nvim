-- General keybindings

local vimp = require('vimp')
local api = vim.api
local fn = vim.fn

-- TODO wipe buffer on delete?
local function open_file_explorer()  -- For left padding
    vim.cmd([[
        NvimTreeOpen
        wincmd p
    ]])
end

function open_help_in_tab(arg)  -- TODO BufWipe?
    vim.cmd('tab help ' .. arg)
    open_file_explorer()
end

function open_man_in_tab(arg)  -- TODO BufWipe?
    vim.cmd('tab Man ' .. arg)
    open_file_explorer()
end
-- TODO Mimic official commands. `M` has missing completion?
vim.cmd('command! -nargs=? -complete=help H call v:lua.open_help_in_tab(<q-args>)')
vim.cmd('command! -nargs=? -complete=shellcmd M call v:lua.open_man_in_tab(<q-args>)')

-- NOTE Set these at top of the file
vimp.always_override = true  -- TODO
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })  -- TODO Why this need
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- vim.api.nvim_del_keymap('', '`')

-- Escape AHKREMAP <f10> to capslock
vimp.nnoremap({'silent'}, '<f10>', ':nohl<CR>')  -- TODO
vimp.inoremap('<f10>', '<esc>')
vimp.vnoremap('<f10>', '<esc>')  -- TODO
vimp.cnoremap('<f10>', '<c-c>')

-- Remap find prev/next f/F/t/T
vimp.nnoremap("'", ',')
vimp.nnoremap(',', ';')
-- Remap command mode
vimp.nnoremap(';', ':')
vimp.xnoremap(';', ':')
-- Convenience register. For example, qq to record. Q to replay.
-- vimp.nnoremap('<leader>Q', 'Q')  -- TODO
vimp.nnoremap('Q', '@@')

vimp.nmap('U', '_')
vimp.xmap('U', '_')

vimp.nnoremap('/', 'ms/')  -- Mark position before search
-- Reverse search directions for terminal.
-- For Normal mode in terminal buffer, `/` and `?` are the same
vimp.tnoremap('<f10>/', [[<c-\><c-n>?]])
vimp.tnoremap('<f10>?', [[<c-\><c-n>/]])

-- Saner text wrapping for markdown
vim.cmd('autocmd bufreadpre *..md setlocal textwidth=90')

-- Hacky way for finding highlight group under the cursor. Bind to `F10` in all modes
vim.cmd([[map <leader>/ :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>]])


-- TODO
-- map('n', '<CR>', ':noh<CR><CR>', {noremap = true}) -- clears search highlight & still be enter

-- TODO Functionize this
-- cd ~/path/to/your/directory | :Telescope find_files or :Telescope file_browser


-- File management -------------------------------

vimp.nnoremap({'silent'}, '<c-s>', ':update<CR>')
vimp.inoremap({'silent'}, '<c-s>', '<cmd>update<CR>')
vimp.vnoremap({'silent'}, '<c-s>', '<cmd>update<CR>')


-- Buffer, window and tab ------------------------

local function go_to_last_line_center()
    local end_screen_line = fn.line('w$')
    vim.cmd('norm! G')
    if fn.line('.') > end_screen_line then
        vim.cmd('norm! zz')
    end
end
vimp.nnoremap('gf', '<c-^>')
vimp.nnoremap('G', function() go_to_last_line_center() end)

-- Open tab/buffer (with swapfile, just in case) TODO Automatically `Bwipe`, not just `Bdelete`
local function enew_use_current_filetype()
    local ft = vim.bo.filetype
    vim.cmd('enew')
    api.nvim_buf_set_option(0, 'filetype', ft)
end
vimp.nnoremap('<c-m-f1>', function() enew_use_current_filetype() end)  -- AHKREMAP <c-m>

vimp.nnoremap('<c-m-s-f1>', '<cmd>$tab split | AerialOpen left<CR><cmd>wincmd p<CR>')  -- AHKREMAP <c-m-m>
vimp.tnoremap('<c-m-s-f1>', '<cmd>$tab split | AerialOpen left<CR><cmd>wincmd p | startinsert<CR>')  -- AHKREMAP <c-m-m>

-- Close tab/buffer TODO Close buffer <c-q> to close window if last buffer in the window
function close_tab_restore_last_active()  -- And restore the last active tab
    -- Save the last active tab number due to `tabclose` returns to the previous `tabpagenr` and mess up g:last_active_tab set by autocmd on TabLeave
    local correct_last_active_tab = tostring(vim.g.last_active_tab)
    vim.cmd('tabclose')
    vim.cmd('exe ' .. correct_last_active_tab .. '"tabnext"')
end
vimp.nnoremap('<c-m-q>', '<cmd>lua close_tab_restore_last_active()<CR>')
vimp.tnoremap('<c-m-q>', '<cmd>lua close_tab_restore_last_active()<CR>')
vimp.nnoremap({'silent'}, '<c-q>', ':confirm Bdelete<CR>')
vimp.tnoremap({'silent'}, '<c-q>', [[<c-\><c-n><c-w>c]])
-- vimp.nnoremap({'silent'}, '<c-m-q>',     ':confirm q<CR>')
vimp.nnoremap({'silent'}, '<c-m-s-f12>', ':bufdo :Bdelete<CR>')  -- AHKREMAP <c-s-m-q>

-- vimp.nnoremap('gn', '<C-^>')
-- vimp.nnoremap('g1', ':1b<cr>')
-- vimp.nnoremap('g2', ':2b<cr>')
-- -- TODO Complete till g9
-- vimp.nnoremap('g9', ':blast<cr>')

vimp.nnoremap('<c-h>', '<c-w>h')
vimp.nnoremap('<c-j>', '<c-w>j')
vimp.nnoremap('<c-k>', '<c-w>k')
vimp.nnoremap('<c-l>', '<c-w>l')
vimp.tnoremap('<c-j>', [[<c-\><c-n><c-w>ji]])  -- Note `i`
vimp.tnoremap('<c-k>', [[<c-\><c-n><c-w>ki]])

-- Same, convenience keybindings for window management
vimp.nnoremap('<c-w><c-p>', '<c-w>p')


-- TODO Others and bufnr("#") results in unexpected/wrong bufnr.
-- NOTE bufnr('#') results in wrong buffer number, hence use these. TODO Simplify.
-- Also see `start_placeholder` of startup.lua
vim.cmd([[
    au TermEnter * if getwinvar(winnr('#'), '&buftype') == '' | let g:prev_non_term_win_nr = winnr('#') | endif
    au BufEnter * if &filetype =~ '\(spectre_panel\|Outline\)' && getwinvar(winnr('#'), '&buftype') == '' | let g:prev_non_term_win_nr = winnr('#') | endif
]])

-- For <m-2>, see lua/terminal.lua
vim.g.move_to_right_win = 0  -- NOTE Passed from <m-2> for `startinsert`
function move_to_left_win()
    if vim.bo.buftype == 'terminal' or vim.bo.filetype == 'spectre_panel' or vim.bo.filetype == 'Outline' then
        api.nvim_set_current_win(fn.win_getid(vim.g.prev_non_term_win_nr))
    else
        vim.cmd('wincmd h')
    end
end
-- NOTE `startinsert` doesn't work if this command is called in lua. Hence, use this workaround.
local move_to_left_win__start_insert = '<cmd>lua move_to_left_win()<CR><cmd>if g:move_to_right_win == 1 | startinsert | let g:move_to_right_win = 0 | endif<CR>'
opts = {noremap = true}
api.nvim_set_keymap('n', '<m-1>', move_to_left_win__start_insert, opts)
api.nvim_set_keymap('i', '<m-1>', move_to_left_win__start_insert, opts)
api.nvim_set_keymap('t', '<m-1>', move_to_left_win__start_insert, opts)

-- Open last closed buffer TODO Cant find proper event for autocmd
-- vim.cmd([[
--     augroup BufCloseTrack
--         au!
--         au BufWinLeave * let g:last_closed_buf = bufnr('#')
--     augroup END
-- ]])
-- local function open_last_closed_buf()
--     api.nvim_command[[exe 'e ' . bufname(g:last_closed_buf)]]
-- end
-- vimp.nnoremap('<c-m-o>', function() open_last_closed_buf() end)




-- Prev/next tab
vimp.nnoremap('<c-m-h>', 'gT')
vimp.nnoremap('<c-m-l>', 'gt')
vimp.tnoremap('<c-m-h>', [[<c-\><c-n>gT]])
vimp.tnoremap('<c-m-l>', [[<c-\><c-n>gt]])
-- Move tab
vimp.nnoremap('<m-s-k>', '<cmd>tabmove -1<CR>')
vimp.nnoremap('<m-s-j>', '<cmd>tabmove +1<CR>')
--Remap gf to gt TODO
vimp.nnoremap('gt', 'gf')
vimp.nnoremap('gT', 'gF')
vimp.nnoremap('<c-w>gt', '<c-w>gf')
-- vimp.nmap('gt', 'gf')
-- vimp.vmap('gt', 'gf')
-- Go to last active tab.
vim.cmd('au TabLeave * let g:last_active_tab = tabpagenr()')
local go_to_last_active_tab = '<cmd>exe "tabnext " . g:last_active_tab<CR>'
vimp.nnoremap('gn',      go_to_last_active_tab)
vimp.nnoremap('<c-m-n>', go_to_last_active_tab)
vimp.tnoremap('<c-m-n>', go_to_last_active_tab)
-- Go to tab by number AHKREMAP <c-m-1>, <c-m-2>, ..., <c-m-9>
vimp.nnoremap('<c-m-f11>', '1gt')
vimp.nnoremap('<c-m-f12>', '2gt')
vimp.nnoremap('<m-#>',     '3gt')
vimp.nnoremap('<m-$>',     '4gt')
vimp.nnoremap('<m-%>',     '5gt')
vimp.nnoremap('<m-^>',     '6gt')
vimp.nnoremap('<m-&>',     '7gt')
vimp.nnoremap('<m-*>',     '8gt')
vimp.nnoremap('<m-(>',     '<cmd>tablast<CR>')
-- (terminal)
vimp.tnoremap('<c-m-f11>', '<cmd>1tabn<CR>')
vimp.tnoremap('<c-m-f12>', '<cmd>2tabn<CR>')
vimp.tnoremap('<m-#>',     '<cmd>3tabn<CR>')
vimp.tnoremap('<m-$>',     '<cmd>4tabn<CR>')
vimp.tnoremap('<m-%>',     '<cmd>5tabn<CR>')
vimp.tnoremap('<m-^>',     '<cmd>6tabn<CR>')
vimp.tnoremap('<m-&>',     '<cmd>7tabn<CR>')
vimp.tnoremap('<m-*>',     '<cmd>8tabn<CR>')
vimp.tnoremap('<m-(>',     '<cmd>tablast<CR>')


-- Moving around ---------------------------------

-- TODO_DECIDE Remap for dealing with word wrap
-- vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
-- vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })


-- _ Search forward/backward and center ----------

-- If window is full height, for example, it's not horizontal split, center screen after searching.
-- Else, for smaller window size, screen centering isn't optimal (e.g. searched item isn't near the bottom of the monitor).

local offset_screen_line = 5

local function is_win_full_height()
  local offset = 3  -- Offset tab line, status line and command line
  if api.nvim_win_get_height(0) == vim.o.lines - offset then
    return true
  else
    return false
  end
end

local function search_forward_center()
  local ok, res = pcall(vim.cmd, 'norm! ' .. vim.v.count1 .. 'n')
  if not ok then return end

  if is_win_full_height() then
    local end_screen_line_offset = fn.line('w$') - offset_screen_line
    if fn.line('.') >= end_screen_line_offset then
      vim.cmd('norm! zz')
    end
  end
end

local function search_backward_center()
  local ok, res = pcall(vim.cmd, 'norm! ' .. vim.v.count1 .. 'N')
  if not ok then return end

  if is_win_full_height() then
    local end_screen_line_offset = fn.line('w0') + offset_screen_line
    if fn.line('.') <= end_screen_line_offset then
      vim.cmd('norm! zz')
    end
  end
end

vimp.nnoremap('n', function() search_forward_center() end)
vimp.nnoremap('N', function() search_backward_center() end)


-- Window ----------------------------------------

-- Increase/decrease height. AHKREMAP <c-=> and <c-->
vimp.nnoremap('<c-m-up>',   '5<c-w>+')
vimp.nnoremap('<c-m-down>', '5<c-w>-')
vimp.inoremap('<c-m-up>',   '<cmd>norm 5<c-w>+<CR>')
vimp.inoremap('<c-m-down>', '<cmd>norm 5<c-w>-<CR>')
vimp.tnoremap('<c-m-up>',   [[<c-\><c-n>5<c-w>+i]])  -- Note `i`
vimp.tnoremap('<c-m-down>', [[<c-\><c-n>5<c-w>-i]])

-- Increase/decrease width. AHKREMAP <c-.> and <c-,>
vimp.nnoremap('<c-m-right>', '10<c-w>>')
vimp.nnoremap('<c-m-left>',  '10<c-w><')
vimp.inoremap('<c-m-right>', '<cmd>norm 10<c-w>><CR>')
vimp.inoremap('<c-m-left>',  '<cmd>norm 10<c-w><<CR>')
vimp.tnoremap('<c-m-right>', [[<c-\><c-n>10<c-w>>i]])  -- Note `i`
vimp.tnoremap('<c-m-left>',  [[<c-\><c-n>10<c-w><i]])

-- Maximize/minimize height
vimp.nnoremap('<c-w>=', '<c-w>_')
vimp.nnoremap('<c-w>-', '<cmd>resize 1<CR>')


-- Editing ---------------------------------------

-- Toggle options
vimp.nnoremap('<m-z>', '<cmd>set wrap!<CR>')
vimp.inoremap('<m-z>', '<cmd>set wrap!<CR>')
vimp.nnoremap([[\l]], '<cmd>set cursorline!<CR>')
vimp.nnoremap([[\c]], '<cmd>set cursorcolumn!<CR>')
vimp.nnoremap([[\b]], '<cmd>set scrollbind!<CR>')

-- Conceal level
vimp.nnoremap([[\1]], '<cmd>set conceallevel=1<CR>')
vimp.nnoremap([[\2]], '<cmd>set conceallevel=2<CR>')
vimp.nnoremap([[\3]], '<cmd>set conceallevel=0<CR>')

-- Move up/down by char
vimp.inoremap('<m-j>', '<down>')
vimp.inoremap('<m-k>', '<up>')

-- Move forward/backward by char/word
vimp.inoremap('<m-h>', '<left>')
vimp.inoremap('<m-l>', '<right>')
vimp.cnoremap('<m-h>', '<left>')
vimp.cnoremap('<m-l>', '<right>')
vimp.inoremap('<m-b>', '<c-left>')  -- TODO Last word missing 1 char
vimp.inoremap('<m-d>', '<c-right>')
vimp.cnoremap('<m-b>', '<c-left>')
vimp.cnoremap('<m-d>', '<c-right>')
vimp.cnoremap('<m-4>', '<c-e>')

-- Kill forward/backward char/word
vimp.inoremap('<c-l>', '<delete>')
vimp.inoremap('<c-b>', '<c-w>')
vimp.cnoremap('<c-l>', '<delete>')
vimp.tnoremap('<c-l>', '<delete>')
vimp.inoremap('<c-d>', '<cmd>norm de<CR>')

vimp.cnoremap('<c-b>', '<c-w>')
vimp.cnoremap('<c-d>', '<c-right><c-w><delete>')  -- TODO
-- vimp.cnoremap('<c-m-4>', '<left>')  -- TODO Keys unrecognized

-- Paste using system clipboard TODO Correct?
-- vimp.inoremap('<c-v>', [[<esc>:set paste<CR>a<c-r>=getreg('+')<CR><esc>:set nopaste<CR>mi`[=`]`ia]])
vimp.inoremap('<c-v>', [[<c-r>*]])  -- TODO HOTFIX
vimp.cnoremap('<c-v>', [[<c-r>*]])
vimp.tnoremap('<c-v>', [[<c-\><c-n>"*pi]])  -- Without carriage return

-- Move lines
-- Tips: To shift line by really big `shiftwidth`, for convenience, type `33` for `v:count1` and <key_to_shift>
local function shift_by_n_col(cmd, shiftwidth)
    local old_shiftwidth = vim.o.shiftwidth
    local new_shiftwidth = shiftwidth or vim.v.count1 * old_shiftwidth

    vim.o.shiftwidth = new_shiftwidth
    vim.cmd('norm! ' .. cmd)
    vim.o.shiftwidth = old_shiftwidth
end
vimp.nnoremap('<m-s-h>', function() shift_by_n_col('<<', 1) end)
vimp.nnoremap('<m-s-l>', function() shift_by_n_col('>>', 1) end)
vimp.nnoremap('<m-h>',   function() shift_by_n_col('<<') end)
vimp.nnoremap('<m-l>',   function() shift_by_n_col('>>') end)
vimp.nnoremap('<m-j>', '<cmd>m .+1<CR>==')
vimp.nnoremap('<m-k>', '<cmd>m .-2<CR>==')
vimp.vnoremap('<m-j>', ":m '>+1<CR>gv=gv")
vimp.vnoremap('<m-k>', ":m '<-2<CR>gv=gv")

vimp.inoremap('<c-z>', '<cmd>norm u<CR>')  -- Undo
vimp.nnoremap('gp', '`[v`]')  -- Reselect pasted text
-- Yank relative/full path
vimp.nnoremap('<c-m-y>',    function() fn.setreg('+', fn.expand('%')) end)
vimp.nnoremap('<c-s-m-f2>', function() fn.setreg('+', fn.expand('%:p')) end)


-- Search ----------------------------------------

-- TODO Visual mode https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches
vimp.nnoremap('<leader>*', [[:let @/='\<<c-r>=expand("<cword>")<CR>\>'<CR>:set hls<CR>]])


-- Terminal-specific ----------------------------

-- Other terminal's keybinds are scattered around e.g. in plugins' scripts

vim.cmd('au TermOpen * nnoremap <buffer> q <cmd>nohl<CR>i')

function search_prev_prompt()  -- For viewing lengthy output
    prev_first_screen_line_nr = fn.line('w0')
    vim.cmd('?' .. prompt)
    if fn.line('.') < prev_first_screen_line_nr then
        vim.cmd('normal! zt')
    end
end
-- NOTE Errors when set with vimpeccable. Use base lua syntax to set it
opts = {noremap = true}
api.nvim_set_keymap('t', '<f10>',  [[<c-\><c-n>]], opts)
api.nvim_set_keymap('t', '<f10>b', [[<c-\><c-n><cmd>lua search_prev_prompt()<CR>]], opts)

vimp.tnoremap('<c-y>', [[<c-\><c-n><c-y>]])

-- R's data.table
vimp.tnoremap('<m-;>', ' := ')
vimp.tnoremap('<m-.>', '.(')
vimp.tnoremap('<m-[>', '[, ')
vimp.tnoremap('<m-:>', '`:=` (')
vimp.tnoremap('<m-S>', '.SDcols = ')

-- Clear visible/all term
function clear_all_term()  -- TODO Known bug
    local save_scrollback = vim.bo.scrollback
    vim.bo.scrollback = 1
    vim.cmd('sleep 100m')
    vim.bo.scrollback = save_scrollback

    vim.cmd('startinsert | Tclear')
end
vimp.nnoremap('<m-3>', '<cmd>Tclear<CR>')
vimp.inoremap('<m-3>', '<cmd>Tclear<CR>')
vimp.tnoremap('<m-3>', '<c-l>')
api.nvim_set_keymap('t', '<c-s-m-f3>', '<cmd>lua clear_all_term()<CR>', opts)


-- Write terminal buffer to log file for inspection/debugging/etc
-- @param page 'screen' or 'full' page
function write_to_log(page)  -- TODO Use local func
    local file = '/tmp/nvim.log'
    local first_line
    local last_line
    local filetype

    -- Infer filetype based on terminal process
    local term_title = vim.b.term_title
    if string.match(term_title, 'radian') then
        filetype = 'r'
    elseif string.match(term_title, 'julia') then
        filetype = 'julia'
    else
        filetype = ''
    end

    if page == 'screen' then
        first_line = fn.line('w0')
        last_line  = fn.line('w$')
    else  -- page == 'full'
        first_line = 1
        last_line  = fn.line('$')
    end
    local range = first_line .. ',' .. last_line

    vim.cmd(range .. 'write! ' .. file)
    api.nvim_set_current_win(fn.win_getid(vim.g.middle_win_nr))
    vim.cmd('edit +' .. last_line .. ' ' .. file)
    api.nvim_buf_set_option(0, 'filetype', filetype)

    if page == 'screen' then  -- This is needed because the file is reused, and the previous redraw positions is saved
        vim.cmd('norm! zb')
    else  -- page == 'full'
        vim.cmd('norm! zz')
    end
end
vimp.tnoremap('<f10>l', "<cmd>lua write_to_log('screen')<CR>")
vimp.tnoremap('<f10>L', "<cmd>lua write_to_log('full')<CR>")


-- Scroll terminal when cursor is at normal buffer
local function term_scroll(cmd)
  vim.cmd('call g:neoterm.instances[g:neoterm.last_active].normal("' .. cmd .. '")')
end
vimp.nnoremap('<c-m-o>', function () term_scroll('gg') end)
vimp.inoremap('<c-m-o>', function () term_scroll('gg') end)
vimp.nnoremap('<c-m-w>', function () term_scroll('G') end)
vimp.inoremap('<c-m-w>', function () term_scroll('G') end)
vimp.nnoremap('<c-m-u>', function () term_scroll("\\<c-u>") end)
vimp.inoremap('<c-m-u>', function () term_scroll("\\<c-u>") end)
vimp.nnoremap('<c-m-d>', function () term_scroll("\\<c-d>") end)
vimp.inoremap('<c-m-d>', function () term_scroll("\\<c-d>") end)
vimp.nnoremap('<c-m-b>', function () term_scroll("\\<c-b>") end)
vimp.inoremap('<c-m-b>', function () term_scroll("\\<c-b>") end)
vimp.nnoremap('<c-m-f>', function () term_scroll("\\<c-f>") end)
vimp.inoremap('<c-m-f>', function () term_scroll("\\<c-f>") end)

local function term_search_prompt(prev_next)
  if prev_next == 'prev' then backward = 'b' else backward = '' end
  flags = 'W' .. backward
  cmd = "call search('" .. prompt .. "', '" .. flags .. "') | normal! zt"

  vim.cmd('call g:neoterm.instances[g:neoterm.last_active].vim_exec("' .. cmd .. '")')
end
vimp.nnoremap('<c-m-k>', function () term_search_prompt('prev') end)
vimp.inoremap('<c-m-k>', function () term_search_prompt('prev') end)
vimp.nnoremap('<c-m-j>', function () term_search_prompt('next') end)
vimp.inoremap('<c-m-j>', function () term_search_prompt('next') end)


-- Identify the syntax highlighting group used at the cursor
vimp.nnoremap([[<leader>/]], ':echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . "> trans<" . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>')


-- _ R ------------------------------------------

-- Copied from after/ftplugin/r.vim
vimp.tnoremap('<m-space>', '<pagedown>')  -- Remap radian's trigger completion
vimp.tnoremap('<f8>',     [[ <c-\><c-n><cmd>call Send_to_term("tar_outdated_()")<CR>i ]])
vimp.tnoremap('<f7>',     [[ <c-\><c-n><cmd>call Send_to_term("tar_visnetwork_() ; max_active_win()")<CR>i ]])
vimp.tnoremap('<c-m-f3>', [[ <c-\><c-n><cmd>call Send_to_term("tar_make_()")<CR>i ]])  -- AHKREMAP <win-f9>


-- Plot ------------------------------------------

local start_win = fn.win_getid(vim.g.middle_win_nr)

function plot_init()
    start_win = fn.win_getid(fn.winnr())
    to_last_active_term_win()
    vim.cmd('wincmd r')  -- Swap term buffer with placeholder buffer
    vim.cmd('resize 25')
    api.nvim_set_current_win(start_win)
end

function plot_restore()
    to_last_active_term_win()
    vim.cmd('wincmd r')  -- Swap term buffer with placeholder buffer
    vim.cmd('resize ' .. right_most_win_height)
    api.nvim_set_current_win(start_win)
end

-- AHKREMAP
vimp.nnoremap('<c-m-s-f8>', function() plot_init() end)
vimp.nnoremap('<c-m-s-f7>', function() plot_restore() end)
vimp.inoremap('<c-m-s-f8>', function() plot_init() end)
vimp.inoremap('<c-m-s-f7>', function() plot_restore() end)
-- NOTE Errors when set with vimpeccable. Use base lua syntax to set it
-- TODO When lua function call is supported by vimpeccable, use lua function call and add back `local` to `plot_init` and `plot_restore` above. Temporary workaround by exporting `plot_init` and `plot_restore` to global environment.
opts = {noremap = true}
api.nvim_set_keymap('t', '<c-m-s-f8>',  '<cmd>lua plot_init()<CR>', opts)
api.nvim_set_keymap('t', '<c-m-s-f7>',  '<cmd>lua plot_restore()<CR>', opts)


-- julia-vim -------------------------------------

-- NOTE It doesn't work if this is sourced at .../ftplugin/ directory. Hence source it here.
vim.g.julia_blocks_mappings = {
    -- Next/prev begin/end keywords
    move_n = "]a",
    move_N = "]A",
    move_p = "[a",
    move_P = "[A",
    -- Next/prev outer block, ignoring inner block(s)
    moveBlock_n = "]]",
    moveBlock_N = "][",
    moveBlock_p = "[[",
    moveBlock_P = "[]",
    -- Selection
    select_a = "aj",
    select_i = "ij",

    whereami = "",  -- Disable
}


-- Others ---------------------------------------

-- vimp.nnoremap('<leader><tab>', '<cmd>ls!<CR>')

-- Paste markdown link with URL from clipboard and automatic title fetching.
-- NOTE wget and perl are dependencies required to get and clean title.
local function paste_markdown_link()
  local url = fn.getreg('+')
  if url:find('^https?://') == nil then
    return print("Clipboard isn't a valid URL")
  end

  -- Get and clean title
  local title = fn.system(
    "wget -qO- '" .. url .. "' | " ..
    "perl -l -0777 -ne 'print $1 if /<title.*?>\\s*(.*?)\\s*<\\/title/si'"
  )
  if not vim.v.shell_error == 0 then  -- TODO Not working?
    return print('Errors occurred while fetching the URL title')
  end
  title = fn.substitute(title, 'SSL_INIT', '', '')
  title = fn.substitute(title, '\n', '', 'g')  -- Remove trailing newline

  local md_link = '[' .. title .. '](' .. url .. ')'
  api.nvim_put({ md_link }, 'c', true, true)
end

vimp.nnoremap([[\p]], function() paste_markdown_link() end)









-- Test reload config ----------------------------
vimp.nnoremap('<leader>P', function()  -- TODO
  -- Remove all previously added vimpeccable maps
  vimp.unmap_all()
  -- Unload the lua namespace so that the next time require('config.X') is called it will reload the file. Unload all namespaces at .../nvim/lua/plugins/
  require("etc.test_reload_config").unload_lua_namespace('etc')
  -- Make sure all open buffers are saved
  vim.cmd('silent wa')
  -- Execute our vimrc lua file again to add back our maps
  dofile(vim.fn.stdpath('config') .. '/init.lua')

  print("Reloaded vimrc!")
end)
--------------------------------------------------
