-- TODO julia-vim breaks <CR> for nvim-cmp? 

vim.g.julia_indent_align_brackets = 1
vim.g.julia_indent_align_funcargs = 1

vim.g.latex_to_unicode_auto = 1  -- Completion triggered by space/second-backslash/etc
vim.g.latex_to_unicode_tab = 'command'  -- Tab completion. Only enable for command mode. Insert mode is handled
-- by nvim-cmp

-- whichkey.register({  -- TODO
--     o = {":call julia#toggle_function_blockassign()<CR>", "toggle Julia function block", noremap=true},
-- }, {prefix="<leader>"})
