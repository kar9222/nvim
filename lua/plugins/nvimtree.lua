-- Options --------------------------------------

-- NOTE Set options before `setup`, including call to require'nvim-tree', else some options (e.g. nvim_tree_hide_dotfiles) won't work.

-- TODO This also sets cursorline for terminal buffer. But it's set on TermOpen, hence it's the same.
vim.cmd('au BufEnter NvimTree setlocal cursorline')  -- NOTE FileType doesn't work

vim.g.nvim_tree_disable_window_picker = 1
vim.g.nvim_tree_special_files = {
  ['README.md']  = true,
  ['README.Rmd'] = true,
  ['Makefile']   = true,
  ['MAKEFILE']   = true,
  ['_targets.R'] = true,
  ['_shiny.R']   = true,
}

vim.g.nvim_tree_icons = {
  default = ' ',  -- Disable default
  symlink = ' ',  -- Disable default
}

vim.g.nvim_tree_show_icons = {
  folder_arrows = 1,
  folders = 1,
  files = 1,
  git = 0
}


-- Setup ----------------------------------------

local nvim_tree = require'nvim-tree'
local cfg = require'nvim-tree.config'
local cb = cfg.nvim_tree_callback

nvim_tree.setup {
  open_on_setup = false, -- open the tree when running this setup function TODO see sessions.lua and startup.lua
  auto_close = false, -- closes neovim automatically when the tree is the last **WINDOW** in the view
  open_on_tab = false, -- opens the tree when changing/opening a new tab if the tree wasn't previously opened. NOTE Disable this to avoid inconsistent tab opening behaviour and 'lag'.
  ignore_ft_on_setup = {}, -- will not open on setup if the filetype is in this list

  filters = {
	dotfiles = true,
    custom = {
	  '.git', '.cache', 'node_modules', '.vscode',
	  'LICENSE', 'man',
	  'renv.lock', 'renv', '_targets',
	  'Project.toml', 'Manifest.toml'
	},
  },

  disable_netrw = true, -- disables netrw completely TODO
  hijack_netrw = true, -- Hijack netrw window on startup. prevents netrw from automatically opening when opening directories (but lets you keep its other utilities) TODO

  hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
  diagnostics = { enable = false },

  update_cwd = true, -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  update_to_buf_dir = { enable = true }, -- hijacks new directory buffers when they are opened TODO What is this

  update_focused_file = {  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
    enable = true,
    -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    -- only relevant when `update_focused_file.enable` is true
    update_cwd = false,
    -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
    -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
    ignore_list = {}
  },
  system_open = {  -- configuration options for the system open command (`s` in the tree by default)
    cmd  = nil,  -- leaving nil should work in most cases TODO
    args = {}  -- the command arguments as a list
  },

  view = {  -- width of the window, can be either a number (columns) or a string in `%`
    width = file_explorer_width_julia,  -- R's size TODO
    side = 'left',  -- 'left' | 'right' | 'top' | 'bottom'
    auto_resize = false,  -- if true the tree will resize itself after opening a file TODO This simplify/affects some of my settings?
    mappings = {
      custom_only = false,  -- custom only false will merge the list with the default mappings if true, it will only use your list to set the mappings
      list = {
        { key = {'l'}, cb = "<cmd>lua require'nvim-tree'.on_keypress('edit')<CR>j" },  -- Edit and go down. TODO `j` not optimal for opening file.
        { key = {'h'}, cb = cb('close_node') }
      }
    }
  }
}

whichkey.register({
    z = {
        name = 'nvim tree',
        c = { function() require'nvim-tree.lib'.collapse_all() end, 'collapse all folders', noremap = true },
        t = {':NvimTreeToggle<CR>', 'toggle', noremap = true},
        r = {':NvimTreeRefresh<CR>', 'refresh', noremap = true},
        f = {':NvimTreeFindFile<CR>', 'find file', noremap = true}
    }
}, {prefix = '<leader>'})
