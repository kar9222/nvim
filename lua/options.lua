local indent = 4
vim.cmd('filetype plugin indent on')

-- NOTE for `EDITOR`, see startup.lua
-- vim.fn.setenv("GIT_EDITOR", "nvr --remote-wait +'set bufhidden=wipe'")
-- TODO For lazygit
local half_col = tostring(math.ceil(0.7 * vim.o.columns))  -- NOTE Higher than 0.7 results in terminal redraw issues.
vim.fn.setenv("GIT_EDITOR", "nvr -cc " .. half_col .. "vsplit --remote-wait +'set bufhidden=wipe | nnoremap <buffer> q <cmd>bd<CR>'")


-- These are usually set by theme. Set here, just in case.
vim.o.background = 'dark'
vim.o.termguicolors = true  -- Enable true color TODO Check if this is on
vim.cmd('syntax enable')  -- TODO Need?

vim.cmd('set noequalalways')
vim.o.clipboard = 'unnamedplus'  -- Use OS clipboard
vim.o.completeopt = 'menuone,noinsert,noselect'  -- Autocomplete options
vim.o.expandtab = true  -- Expand tabs into spaces
vim.o.autoindent = true
vim.o.breakindent = true
vim.o.smarttab = true
vim.o.tabstop = indent
vim.o.shiftwidth = indent
vim.o.wildmode = 'list:longest'  -- Command-line completion mode
vim.o.shortmess = vim.o.shortmess..'c'  -- Maximum autocomplete popup height
vim.o.timeoutlen = 500  -- Note that this controls {which-key.nvim} TODO Use 700?
vim.o.textwidth = 0  -- Disable automatic break of longer line (previously 100) TODO
vim.o.splitright = true  -- Default to opening splits on the right
vim.o.splitbelow = true  -- Default to opening splits on the bottom
vim.o.scrollback = 100000
vim.o.inccommand = 'nosplit'  -- Shows the effects of a command incrementally, as you type

vim.o.hidden = true  -- Buffers are merely hidden when closed; needed for {toggleterm to work as intended}

vim.o.signcolumn = 'yes:1'  -- For gitsigns
vim.o.number = true  -- Enable number column
vim.o.numberwidth = 2  -- Number column fixed width
-- vim.o.cursorline = true  -- Highlight line number of cursor (depending on CursorLineNr and CursorLine highlights)

vim.cmd([[
  augroup DisableAutoCommentInsertion
    au!
    au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
  augroup END
]])

vim.o.foldmethod = 'syntax'  -- TODO
vim.o.foldenable = false  -- Turn-off folding TODO

-- vim.o.mouse = 'a'

--Case insensitive searching less /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- NOTE TODO neomux adds statusline. Consider use custom branch. Temporarily workaround by setting it to empty.
vim.g.neomux_win_num_status = ''

vim.g.netrw_browsex_viewer='/mnt/c/users/kar/scoop/shims/brave.exe'  -- TODO Fix linux

-- Highlight on yank. Note `VimHighlight` is custom highlight group
vim.api.nvim_exec(
  [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup = "VimHighlight"}
  augroup end
]],
  false
)


-- Pandoc, markdown ------------------------------

-- Disable 'pop up' of multi-line output in command line. Temporary workaround. NOTE Setting this at plugins/... doesn't work, hence set it here.
vim.g['pandoc#formatting#mode'] = 'h'

vim.g['pandoc#spell#enabled'] = 0

-- Conceal
vim.o.concealcursor='nc'  -- Set modes for conceal. `c` for 'incsearch'
vim.g['pandoc#syntax#conceal#urls'] = 1
vim.g['pandoc#syntax#conceal#blacklist'] = { 'ellipses', }
vim.g['pandoc#syntax#conceal#cchar_overrides'] = { atx = "○", }


-- neomux ---------------------------------------

-- NOTE Neomux sets keys by default and it checks with `if !exist(...)`. And it sets assigned vars to keys. Hence, set these vars to "dummy keys" ``.
vim.g.neomux_winswap_map_prefix    = ''  -- NOTE This is prefix for 9 windows (1 to 9)
vim.g.neomux_start_term_map        = ''
vim.g.neomux_start_term_split_map  = ''
vim.g.neomux_start_term_vsplit_map = ''
vim.g.neomux_winjump_map_prefix    = ''
vim.g.neomux_term_sizefix_map      = ''
vim.g.neomux_exit_term_mode_map    = ''
vim.g.neomux_yank_buffer_map       = ''
vim.g.neomux_paste_buffer_map      = ''
