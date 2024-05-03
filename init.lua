-- Kar's Neovim config
-- NOTE Orders of sourcing is important.

-- Startup. NOTE `nested` to avoid some 'quirks'. TODO Moved to startup_session.lua. If things are stable, remove this.
-- vim.cmd('au VimEnter * nested lua require("startup")')

require('plugins')
require('helpers')
require('utils')
require("options")
require("keybindings")
require('minimalist').set()  -- TODO Source before keybindings_toggle workaround
require("keybindings_toggle")
require('terminal')
require('toggle_float')
require('toggle_term_tab')
-- require('repl')

-- TODO
vim.cmd('source ~/.config/nvim/old_init.vim')
vim.cmd('source ~/.config/nvim/vim/repl.vim')  -- Also see repl.lua
vim.cmd('source ~/.config/nvim/vim/repl_r_julia.vim')
vim.cmd('source ~/.config/nvim/vim/easyclip.vim')

pcall(require, 'plugins/plenary')  -- Source ASAP as it's used by plugins

pcall(require, 'plugins/whichkey')  -- NOTE whichkey.nvim must be sourced first

pcall(require, 'plugins/treesitter')  -- NOTE Some plugins like Neorg require treesitter to be sourced first. It's better to load treesitter as early as possible without harm.

pcall(require, 'plugins/yanky')
pcall(require, 'plugins/lightspeed')
pcall(require, 'plugins/kommentary')
pcall(require, 'plugins/cmp')
pcall(require, 'plugins/autopairs')  -- NOTE Setup nvim-cmp before this
pcall(require, 'plugins/luasnip')
pcall(require, 'plugins/lsp_signature')

pcall(require, 'plugins/neoterm')
pcall(require, 'plugins/toggleterm')

pcall(require, 'plugins/aerial')

pcall(require, 'plugins/bufferline')
pcall(require, 'plugins/feline')
pcall(require, 'plugins/nvimtree')

pcall(require, 'plugins/julia')

pcall(require, 'plugins/telescope')
pcall(require, 'plugins/harpoon')
pcall(require, 'plugins/spectre')

require('plugins/neogit')  -- TODO pcall(requice, 'plugins/neogit') breaks <c-g>
pcall(require, 'plugins/gitsigns')  -- NOTE Lazy loading e.g. on modified file
pcall(require, 'custom_plugins/delta')

pcall(require, 'plugins/indent_blankline')

pcall(require, 'plugins/lsp')  -- TODO  -- if ENABLE_LSP then pcall(require, 'plugins/lsp') end
pcall(require, 'plugins/trouble')
pcall(require, 'plugins/obsidian')

pcall(require, 'plugins/otter')
pcall(require, 'plugins/quarto')
pcall(require, 'plugins/zotero')

pcall(require, 'plugins/noice')

require('startup_session')  -- NOTE Call this last, after sourcing plugins. Else plugins like gitsigns breaks
