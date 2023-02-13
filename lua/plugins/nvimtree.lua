-- Options --------------------------------------

-- NOTE Set options before `setup`, including call to require'nvim-tree', else some options (e.g. nvim_tree_hide_dotfiles) won't work.

-- Setup ----------------------------------------

local nvim_tree = require'nvim-tree'
local cfg = require'nvim-tree.config'
local cb = cfg.nvim_tree_callback

nvim_tree.setup {
  open_on_setup = false, -- open the tree when running this setup function TODO see sessions.lua and startup.lua
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

  disable_netrw = false, -- Disables netrw completely TODO
  hijack_netrw = true, -- Hijack netrw window on startup. prevents netrw from automatically opening when opening directories (but lets you keep its other utilities) TODO

  hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
  diagnostics = { enable = false },

  update_cwd = true, -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  hijack_directories = {
    enable = true,
    auto_open = true,
  },

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
    cursorline = true,
    width = file_explorer_width_julia,  -- R's size TODO
    preserve_window_proportions = true,
    side = 'left',  -- 'left' | 'right' | 'top' | 'bottom'
    -- auto_resize = false,  -- if true the tree will resize itself after opening a file TODO This simplify/affects some of my settings?
    mappings = {
      custom_only = false,  -- custom only false will merge the list with the default mappings if true, it will only use your list to set the mappings
      list = {
        { key = 'e', action = 'expand_all' },
        { key = 'w', action = 'collapse_all' },
        { key = 'i', action = 'live_filter' },
        { key = 'I', action = 'clear_live_filter' },
        { key = 't', action = 'rename_basename' },
        { key = 'X', action = 'system_open' },
        { key = 's', action = 'search_node' },
        { key = '<C-p>', action = 'first_sibling' },
        { key = '<C-n>', action = 'last_sibling' },

        { key = 'l', cb = "<cmd>lua require'nvim-tree'.on_keypress('edit')<CR>j" },  -- Edit and go down. TODO `j` not optimal for opening file.
        { key = 'h', cb = cb('close_node') },
        { key = '<C-u>', cb = [[<cmd>call win_execute(win_getid(winnr('#')), "norm! \<c-u>")<CR>]] },
        { key = '<C-d>', cb = [[<cmd>call win_execute(win_getid(winnr('#')), "norm! \<c-d>")<CR>]] },

        -- Preview. <C-k> and <C-j> for "persistent preview" via AHK binding for holding down "ctrl" key
        { key = 'K',     cb = "k<cmd>lua require'nvim-tree'.on_keypress('preview')<CR>" },  -- Go up and preview
        { key = 'J',     cb = "j<cmd>lua require'nvim-tree'.on_keypress('preview')<CR>" },  -- Go down and preview
        { key = '<C-k>', cb = "k<cmd>lua require'nvim-tree'.on_keypress('preview')<CR>" },  -- Go up and preview
        { key = '<C-j>', cb = "j<cmd>lua require'nvim-tree'.on_keypress('preview')<CR>" },  -- Go down and preview

        -- Toggle
        { key = 'gf', action = 'toggle_file_info' },
        { key = 'gd', action = 'toggle_dotfiles' },
        { key = 'gi', action = 'toggle_git_ignored' },
        { key = 'ge', action = 'toggle_git_clean' },
        { key = 'gc', action = 'toggle_custom' },

        -- Remove
        { key = 'H',     action = '' },
        { key = 'f',     action = '' },
        { key = 'F',     action = '' },
        { key = '<C-e>', action = '' },
      }
    }
  },

  renderer = {
    special_files = {
      'README.md',
      'README.Rmd',
      'Makefile',
      'MAKEFILE',
      '_targets.R',
      '_shiny.R',
    },
    icons = {
      glyphs = {
        default = ' ',  -- Disable default
        symlink = ' ',  -- Disable default
      },
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = false,
      },
    },
  },

  actions = {
    open_file = {
      window_picker = { enable = false },
      resize_window = false,  -- if true the tree will resize itself after opening a file TODO This simplify/affects some of my settings?
    }
  },
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


