local gitsigns = require('gitsigns')

gitsigns.setup {
    signs = {  -- TODO Customize M.apply_word_diff of manager.lua?
    add          = {hl = 'GitSignsAdd'   , text = '▎', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '▎', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '▎', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '▎', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '▎', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  signcolumn = true,  -- Toggle with `:gitsigns toggle_signs`
  numhl      = false,  -- Toggle with `:gitsigns toggle_numhl`
  linehl     = false,  -- Toggle with `:gitsigns toggle_linehl`
  word_diff  = false,  -- Toggle with `:gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
  },
  current_line_blame_formatter_opts = {
    relative_time = false
  },
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {  -- Options passed to nvim_open_win
    border = border,
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  -- diff_opts.internal = true,  -- If vim.diff or luajit is present TODO See pull #357. No need anymore?
  yadm = { enable = false },
  keymaps = {  -- NOTE Similar keybinds as telescope's git actions
    -- Default keymap options
    noremap = true,

    -- Navigation TODO
    ['n <m-b>']   = {'<cmd>lua require"gitsigns.actions".prev_hunk({ wrap = false })<CR>'},
    ['n <m-n>']   = {'<cmd>lua require"gitsigns.actions".next_hunk({ wrap = false })<CR>'},
    ['n <m-s-b>'] = {'<cmd>lua require"gitsigns.actions".prev_hunk({ wrap = false, preview = true })<CR>'},
    ['n <m-s-n>'] = {'<cmd>lua require"gitsigns.actions".next_hunk({ wrap = false, preview = true })<CR>'},
    -- ['n <m-b>'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"},

    -- Text objects
    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',

    -- Git actions
    ['n <leader>gs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['v <leader>gs'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>gu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ['n <leader>gr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ['v <leader>gr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>gR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ['n <leader>gS'] = '<cmd>lua require"gitsigns".stage_buffer()<CR>',
    ['n <leader>gU'] = '<cmd>lua require"gitsigns".reset_buffer_index()<CR>',

    -- Git decoration
    ['n <leader>gg']  = '<cmd>lua require"gitsigns".preview_hunk_inline()<CR>',
    ['n <leader>gf']  = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ['n <leader>gB']  = '<cmd>lua require"gitsigns".blame_line({ true, true })<CR>',
    ['n <leader>gz']  = '<cmd>lua require"gitsigns".toggle_deleted()<CR>',
    ['n <leader>gn']  = '<cmd>lua require"gitsigns".toggle_linehl() require"gitsigns".toggle_numhl()<CR>',
    ['n <leader>gw']  = '<cmd>lua require"gitsigns".toggle_word_diff()<CR>',
    ['n <leader>gts'] = '<cmd>lua require"gitsigns".toggle_signs()<CR>',
    ['n <leader>gtn'] = '<cmd>lua require"gitsigns".toggle_numhl()<CR>',
    ['n <leader>gtb'] = '<cmd>lua require"gitsigns".toggle_current_line_blame()<CR>',
  },
}
