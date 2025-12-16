---@type opencode.Opts
-- vim.g.opencode_opts = {
--   -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
-- }

vim.o.autoread = true  -- Required for `opts.events.reload`.

-- Action ---------------------------------------
vim.keymap.set({ 'n', 'x' }, '<C-a>', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask opencode' })
vim.keymap.set({ 'n', 'x' }, '<C-x>', function() require('opencode').select() end,                          { desc = 'Execute opencode action…' })
-- You may want these if you stick with the opinionated '<C-a>' and '<C-x>' above, otherwise consider '<leader>o'
vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment', noremap = true })
vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement', noremap = true })

-- Add range/line -------------------------------
vim.keymap.set({ 'n', 'x' }, '<leader>or', function() return require('opencode').operator('@this ') end,        { expr = true, desc = 'Add range to opencode' })
vim.keymap.set('n',          '<leader>ol', function() return require('opencode').operator('@this ') .. '_' end, { expr = true, desc = 'Add line to opencode' })

-- Scrolling ------------------------------------
vim.keymap.set('n', '<m-F>', function() require('opencode').command('session.page.down') end,      { desc = 'opencode full page down' })
vim.keymap.set('n', '<m-B>', function() require('opencode').command('session.page.up') end,        { desc = 'opencode full page up' })
vim.keymap.set('n', '<m-U>', function() require('opencode').command('session.half.page.up') end,   { desc = 'opencode half page up' })
vim.keymap.set('n', '<m-D>', function() require('opencode').command('session.half.page.down') end, { desc = 'opencode half page down' })

-- I use my own terminal setup (e.g. see lua/plugins/toggleterm.lua)
-- vim.keymap.set({ 'n', 't' }, '<C-.>', function() require('opencode').toggle() end,                          { desc = 'Toggle opencode' })
