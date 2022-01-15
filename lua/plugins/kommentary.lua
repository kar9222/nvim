local cfg = require('kommentary.config')
vim.g.kommentary_create_default_mappings = false

cfg.configure_language('julia', {
    single_line_comment_string = '#',
})

cfg.configure_language('autohotkey', {
    single_line_comment_string = ';',
})

cfg.configure_language({ 'julia', 'lua', 'autohotkey' }, {
    prefer_single_line_comments = true,
})

vim.api.nvim_set_keymap('n', '<leader>cc', '<plug>kommentary_line_default',  {})
vim.api.nvim_set_keymap('i', '<c-m-s-f6>', '<c-c><leader>cclla',  {})  -- AHKREMAP TODO
vim.api.nvim_set_keymap('n', '<leader>c',  '<plug>kommentary_motion_default',{})
vim.api.nvim_set_keymap('x', '<leader>c',  '<plug>kommentary_visual_default<c-c>',{})  -- NOTE `<c-c>` for canceling selection

-- Increase/decrease commenting level
-- NOTE Do not use same `<leader>c` as above to avoid clashes of keybindings and causes lag
vim.api.nvim_set_keymap('n', '<leader>Cic', '<Plug>kommentary_line_increase',  {})
vim.api.nvim_set_keymap('n', '<leader>Ci',  '<Plug>kommentary_motion_increase',{})
vim.api.nvim_set_keymap('x', '<leader>Ci',  '<Plug>kommentary_visual_increase',{})
vim.api.nvim_set_keymap('n', '<leader>Cdc', '<Plug>kommentary_line_decrease',  {})
vim.api.nvim_set_keymap('n', '<leader>Cd',  '<Plug>kommentary_motion_decrease',{})
vim.api.nvim_set_keymap('x', '<leader>Cd',  '<Plug>kommentary_visual_decrease',{})
