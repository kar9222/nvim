-- NOTE neoterm's internal variables (e.g. last active terminal) are used. Hence, becareful when changing config/plugin/etc.

local vimp = require('vimp')
local api = vim.api
local fn = vim.fn

-- `startinsert` ---------------------------------

-- NOTE `autocmd` `startinsert` for term buffer silently breaks things.

-- Automatically start term buffer in insert mode
-- If using neoterm `Tnew`, `startinsert` is set internally, hence setting here in my options again break things (e.g. after `Tnew`, cursor will be in insert mode)
vim.cmd('au TermOpen * setlocal nonumber nobuflisted')  -- TODO cursorline gone after closing additional window

-- neomux also set similar `autocmd` for `startinsert`. Disable it.
vim.g.neomux_no_term_autoinsert = 1

-- Go to right window and, if the right windows are two terminal buffers (one main terminal buffer and another placeholder terminal buffer), go to the last active terminal window.
-- NOTE Automatically enter term buffer in insert mode doesn't work. Workarounds tried
-- - au BufEnter * if &buftype == "terminal" | :startinsert | endif
-- - [...only switch to insert if the terminal wasn't focused before](https://github.com/neovim/neovim/issues/8816#issuecomment-539224440)
-- These two workarounds breaks things like {lightspeed.nvim}. Workaround:
local function move_to_right_win()
  vim.cmd([[
    wincmd l
    if &buftype == 'terminal' | startinsert | end
  ]])
  if fn.bufname() == placeholder_buf_name then
      to_last_active_term_win()
      vim.cmd('startinsert')  
  end
end
vimp.nnoremap('<m-2>', function() move_to_right_win() end)
vimp.inoremap('<m-2>', function()
  vim.g.move_to_right_win = 1  -- NOTE Passed to <m-1> for `startinsert`
  move_to_right_win()
end)
