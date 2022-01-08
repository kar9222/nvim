-- Also see `new_term` of toggleterm.lua

local vimp = require('vimp')

vim.g.neoterm_repl_r = "radian"
vim.g.neoterm_bracketed_paste = 1
vim.g.neoterm_direct_open_repl = 1

vim.g.neoterm_autoinsert = 1  -- Open/toggle in insert mode
vim.g.neoterm_default_mod = 'vertical'  -- e.g. for new terminal (see toggleterm.lua)
vim.g.neoterm_size = 73
vim.g.autoscroll = 1  -- Only works for neoterm's command (e.g. Topen), not my custom REPL commands
vim.g.neoterm_automap_keys = ''
-- vim.g.neoterm_keep_term_open = 0  -- Calling :Tclose or :Ttoggle kills the terminal

opts = {'silent'}

-- TODO Screen can't be clear with alt+3 after Tprev/Tnext, unless this weird things happen. Temporary workaround. But it's still buggy.
-- vimp.tnoremap('<m-q>', '<cmd>Tprev<CR>')
-- vimp.tnoremap('<m-w>', '<cmd>Tnext<CR>')
vimp.tnoremap('<m-q>', [[<cmd>Tprev<CR><c-\><c-n><c-w>p<c-w>pi]])
vimp.tnoremap('<m-w>', [[<cmd>Tnext<CR><c-\><c-n><c-w>p<c-w>pi]])

-- Toggle term with <m-s-1>
vimp.nnoremap(opts, '<m-!>', '<cmd>Ttoggle<CR>')
vimp.inoremap(opts, '<m-!>', '<cmd>Ttoggle<CR>')
vimp.tnoremap(opts, '<m-!>', [[<c-\><c-n><cmd>Ttoggle<CR>]])


-- REPL ------------------------------------------

-- -- Send current line and move down
-- vimp.nnoremap(opts, '<leader>u', '<cmd>TREPLSendLine<CR>j')
-- vimp.xmap(opts, '<leader>n', '<plug>(neoterm-repl-send)')
-- -- Send current selection and move the end of selection region
-- -- vimp.vnoremap(opts, '<leader>n', [[<cmd>TREPLSendSelection<CR>`>j]])

-- -- https://github.com/kassio/neoterm/issues/329
-- vimp.nmap(opts, '<leader>m', '<plug>(neoterm-repl-send)')
-- vim.cmd('nmap <silent> <Plug>SendPara sip} :call repeat#set("\\<Plug>SendPara")<CR>')
-- -- vim.cmd [[
-- --     nmap <silent> <Plug>SendPara sip} :call repeat#set("\<Plug>SendPara")<CR>
-- -- ]]
-- vimp.nmap(opts, '<leader>ap', '<plug>SendPara')
