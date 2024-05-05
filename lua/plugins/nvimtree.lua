-- Options --------------------------------------

-- NOTE Set options before `setup`, including call to require'nvim-tree', else some options (e.g. nvim_tree_hide_dotfiles) won't work.

-- Setup ----------------------------------------

local nvim_tree = require'nvim-tree'

local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Default mappings. BEGIN_DEFAULT_ON_ATTACH
  -- Alternatively, rather than specifying the default mappings, you may apply them via api.config.mappings.default_on_attach({bufnr})
  vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node,          opts('CD'))
  -- vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer,     opts('Open: In Place'))
  vim.keymap.set('n', '<C-k>', api.node.show_info_popup,              opts('Info'))
  vim.keymap.set('n', '<C-r>', api.fs.rename_sub,                     opts('Rename: Omit Filename'))
  vim.keymap.set('n', '<C-t>', api.node.open.tab,                     opts('Open: New Tab'))
  vim.keymap.set('n', '<C-v>', api.node.open.vertical,                opts('Open: Vertical Split'))
  vim.keymap.set('n', '<C-x>', api.node.open.horizontal,              opts('Open: Horizontal Split'))
  vim.keymap.set('n', '<BS>',  api.node.navigate.parent_close,        opts('Close Directory'))
  vim.keymap.set('n', '<CR>',  api.node.open.edit,                    opts('Open'))
  vim.keymap.set('n', '<Tab>', api.node.open.preview,                 opts('Open Preview'))
  vim.keymap.set('n', '>',     api.node.navigate.sibling.next,        opts('Next Sibling'))
  vim.keymap.set('n', '<',     api.node.navigate.sibling.prev,        opts('Previous Sibling'))
  vim.keymap.set('n', '.',     api.node.run.cmd,                      opts('Run Command'))
  vim.keymap.set('n', '-',     api.tree.change_root_to_parent,        opts('Up'))
  vim.keymap.set('n', 'a',     api.fs.create,                         opts('Create'))
  vim.keymap.set('n', 'bmv',   api.marks.bulk.move,                   opts('Move Bookmarked'))
  vim.keymap.set('n', 'B',     api.tree.toggle_no_buffer_filter,      opts('Toggle No Buffer'))
  vim.keymap.set('n', 'c',     api.fs.copy.node,                      opts('Copy'))
  vim.keymap.set('n', 'C',     api.tree.toggle_git_clean_filter,      opts('Toggle Git Clean'))
  vim.keymap.set('n', '[c',    api.node.navigate.git.prev,            opts('Prev Git'))
  vim.keymap.set('n', ']c',    api.node.navigate.git.next,            opts('Next Git'))
  vim.keymap.set('n', 'd',     api.fs.remove,                         opts('Delete'))
  vim.keymap.set('n', 'D',     api.fs.trash,                          opts('Trash'))
  vim.keymap.set('n', 'E',     api.tree.expand_all,                   opts('Expand All'))
  vim.keymap.set('n', 'e',     api.fs.rename_basename,                opts('Rename: Basename'))
  vim.keymap.set('n', ']e',    api.node.navigate.diagnostics.next,    opts('Next Diagnostic'))
  vim.keymap.set('n', '[e',    api.node.navigate.diagnostics.prev,    opts('Prev Diagnostic'))
  -- vim.keymap.set('n', 'F',     api.live_filter.clear,                 opts('Clean Filter'))
  -- vim.keymap.set('n', 'f',     api.live_filter.start,                 opts('Filter'))
  vim.keymap.set('n', 'g?',    api.tree.toggle_help,                  opts('Help'))
  vim.keymap.set('n', 'gy',    api.fs.copy.absolute_path,             opts('Copy Absolute Path'))
  -- vim.keymap.set('n', 'H',     api.tree.toggle_hidden_filter,         opts('Toggle Dotfiles'))
  vim.keymap.set('n', 'I',     api.tree.toggle_gitignore_filter,      opts('Toggle Git Ignore'))
  vim.keymap.set('n', 'J',     api.node.navigate.sibling.last,        opts('Last Sibling'))
  vim.keymap.set('n', 'K',     api.node.navigate.sibling.first,       opts('First Sibling'))
  vim.keymap.set('n', 'm',     api.marks.toggle,                      opts('Toggle Bookmark'))
  vim.keymap.set('n', 'o',     api.node.open.edit,                    opts('Open'))
  vim.keymap.set('n', 'O',     api.node.open.no_window_picker,        opts('Open: No Window Picker'))
  vim.keymap.set('n', 'p',     api.fs.paste,                          opts('Paste'))
  vim.keymap.set('n', 'P',     api.node.navigate.parent,              opts('Parent Directory'))
  vim.keymap.set('n', 'q',     api.tree.close,                        opts('Close'))
  vim.keymap.set('n', 'r',     api.fs.rename,                         opts('Rename'))
  vim.keymap.set('n', 'R',     api.tree.reload,                       opts('Refresh'))
  vim.keymap.set('n', 's',     api.node.run.system,                   opts('Run System'))
  vim.keymap.set('n', 'S',     api.tree.search_node,                  opts('Search'))
  -- vim.keymap.set('n', 'U',     api.tree.toggle_custom_filter,         opts('Toggle Hidden'))
  vim.keymap.set('n', 'W',     api.tree.collapse_all,                 opts('Collapse'))
  vim.keymap.set('n', 'x',     api.fs.cut,                            opts('Cut'))
  vim.keymap.set('n', 'y',     api.fs.copy.filename,                  opts('Copy Name'))
  vim.keymap.set('n', 'Y',     api.fs.copy.relative_path,             opts('Copy Relative Path'))
  vim.keymap.set('n', '<2-LeftMouse>',  api.node.open.edit,           opts('Open'))
  vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
  -- END_DEFAULT_ON_ATTACH

  -- You will need to insert "your code goes here" for any mappings with a custom action_cb
  vim.keymap.set('n', 'e', api.tree.expand_all, opts('Expand All'))
  vim.keymap.set('n', 'w', api.tree.collapse_all, opts('Collapse'))
  vim.keymap.set('n', 'i', api.live_filter.start, opts('Filter'))
  vim.keymap.set('n', 'I', api.live_filter.clear, opts('Clean Filter'))
  vim.keymap.set('n', 't', api.fs.rename_basename, opts('Rename: Basename'))
  vim.keymap.set('n', 'X', api.node.run.system, opts('Run System'))
  vim.keymap.set('n', 's', api.tree.search_node, opts('Search'))
  vim.keymap.set('n', '<C-p>', api.node.navigate.sibling.first, opts('First Sibling'))
  vim.keymap.set('n', '<C-n>', api.node.navigate.sibling.last, opts('Last Sibling'))

  -- Open/close node
  vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
  vim.keymap.set('n', 'l', function()
    api.node.open.edit()
    vim.cmd('norm! j')  -- TODO `j` not optimal for opening file.
  end, opts('Open and move dn'))

  -- Scroll buffer
  vim.keymap.set('n', '<C-u>', function()
      win_execute_main_buffer_win([[norm! \<c-u>]])
  end, opts('Scroll buffer up'))
  vim.keymap.set('n', '<C-d>', function()
      win_execute_main_buffer_win([[norm! \<c-d>]])
  end, opts('Scroll buffer down'))

  -- Preview. <C-k> and <C-j> for "persistent preview" via AHK binding for holding down "ctrl" key
  function move_up_and_preview()
    vim.cmd('norm! k')
    api.node.open.preview()
  end
  function move_down_and_preview()
    vim.cmd('norm! j')
    api.node.open.preview()
  end
  vim.keymap.set('n', 'K',     move_up_and_preview,   opts('Move up & preview'))
  vim.keymap.set('n', 'J',     move_down_and_preview, opts('Move down & preview'))
  vim.keymap.set('n', '<C-k>', move_up_and_preview,   opts('Move up & preview'))
  vim.keymap.set('n', '<C-j>', move_down_and_preview, opts('Move down & preview'))

  -- Toggle
  vim.keymap.set('n', 'gf', api.node.show_info_popup, opts('Info'))
  vim.keymap.set('n', 'gd', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
  vim.keymap.set('n', 'gi', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
  vim.keymap.set('n', 'gc', api.tree.toggle_git_clean_filter, opts('Toggle Git Clean'))
  vim.keymap.set('n', 'gh', api.tree.toggle_custom_filter, opts('Toggle Hidden'))

  -- Remove keys
  -- The dummy set before del is done for safety, in case a default mapping does not exist.
  -- You might tidy things by removing these along with their default mapping.
  -- For example
  -- vim.keymap.set('n', 'H',     '', { buffer = bufnr })
  -- vim.keymap.del('n', 'H',         { buffer = bufnr })
end


nvim_tree.setup {
  on_attach = on_attach,
  open_on_tab = false, -- opens the tree when changing/opening a new tab if the tree wasn't previously opened. NOTE Disable this to avoid inconsistent tab opening behaviour and 'lag'.

  filters = {
	dotfiles = true,
    custom = {
	  '.git', '.cache', 'node_modules', '.vscode',
	  'LICENSE', 'man',
	  'renv.lock', 'renv', '_targets$',
	  'Project.toml', 'Manifest.toml',
	  'cell.csl',
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
    indent_markers = {
      enable = false,
      inline_arrows = true,
      icons = {
        corner = '└',
        edge = '│',
        item = '│',
        bottom = '─',
        none = ' ',
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


