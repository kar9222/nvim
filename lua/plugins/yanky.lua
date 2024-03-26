require'yanky'.setup({
  ring = {
    history_length = 100,
    storage = 'shada',
    storage_path = vim.fn.stdpath('data') .. '/databases/yanky.db', -- Only for sqlite storage
    sync_with_numbered_registers = true,
    cancel_event = 'update',
    ignore_registers = { '_' },
    update_register_on_cycle = false,
  },
  picker = {
    select = {
      action = nil, -- nil to use default put action
    },
    telescope = {
      use_default_mappings = true, -- if default mappings should be used
      mappings = nil, -- nil to use default mappings or no mappings (see `use_default_mappings`)
    },
  },
  system_clipboard = {
    sync_with_ring = true,
  },
  highlight = {
    on_put = false,
    on_yank = false,
    -- timer = 500,
  },
  preserve_cursor_position = {
    enabled = true,
  },
  textobj = {
   enabled = true,
  },
})

-- Preserve cursor position on yank: By default in Neovim, when yanking text,
-- cursor moves to the start of the yanked text. Could be annoying especially
-- when yanking a large text object such as a paragraph or a large text object.
-- With this feature, yank will function exactly the same as previously with the
-- one difference being that the cursor position will not change after performing a yank.
vim.keymap.set({'n','x'}, 'y', '<Plug>(YankyYank)')

vimp.nnoremap('[v', [[<cmd>lua require('telescope').extensions.yank_history.yank_history()<CR>]])

vim.keymap.set({'n','x'}, 'p',  '<Plug>(YankyPutAfter)')
vim.keymap.set({'n','x'}, 'P',  '<Plug>(YankyPutBefore)')
vim.keymap.set({'n','x'}, 'gp', '<Plug>(YankyGPutAfter)')
vim.keymap.set({'n','x'}, 'gP', '<Plug>(YankyGPutBefore)')

vim.keymap.set('n', '[p', '<Plug>(YankyPreviousEntry)')
vim.keymap.set('n', ']p', '<Plug>(YankyNextEntry)')
vim.keymap.set('n', '[y', '<Plug>(YankyPreviousEntry)')
vim.keymap.set('n', ']y', '<Plug>(YankyNextEntry)')

vim.keymap.set('n', ']P', '<Plug>(YankyPutIndentAfterLinewise)')
vim.keymap.set('n', '[P', '<Plug>(YankyPutIndentBeforeLinewise)')

vim.keymap.set('n', '>p', '<Plug>(YankyPutIndentAfterShiftRight)')
vim.keymap.set('n', '<p', '<Plug>(YankyPutIndentAfterShiftLeft)')
vim.keymap.set('n', '>P', '<Plug>(YankyPutIndentBeforeShiftRight)')
vim.keymap.set('n', '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)')

vim.keymap.set('n', '=p', '<Plug>(YankyPutAfterFilter)')
vim.keymap.set('n', '=P', '<Plug>(YankyPutBeforeFilter)')
