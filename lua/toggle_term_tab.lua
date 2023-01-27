-- Open and toggle terminal program (e.g. lazygit, lazydocker) in a new tab
-- For lazygit, it's also opened with env var `GIT_EDITOR` opening in vertical split (see options.lua)
-- Usage: To add/remove/edit additional program, amend `cmds` table and keybinds accordingly

local fn  = vim.fn
local api = vim.api
local vimp = require'vimp'

cmds = { 'lazygit', 'lazydocker' }  -- Add/remove/edit programs

for _, cmd in pairs(cmds) do
    local is_opened = cmd .. '_opened'
    local win_id    = cmd .. '_win'
    api.nvim_set_var(is_opened, 0)
    api.nvim_set_var(win_id, nil)
end

-- @param cmd (string) For example, 'lazygit' or 'lazydocker'
local function open_term_tab(cmd)
    local is_opened = cmd .. '_opened'
    local win_id    = cmd .. '_win'

    vim.cmd('tabnew | term ' .. cmd)
    vim.cmd([[
        startinsert
        au BufEnter <buffer> startinsert  " TODO Correct?
    ]])
    -- Upon TermClose, bwipe! also closes the tab
    vim.cmd('au TermClose <buffer> bwipe! | let g:' .. is_opened .. '= 0')
    api.nvim_set_var(is_opened, 1)
    api.nvim_set_var(win_id, fn.win_getid())
end

-- @param cmd (string) For example, 'lazygit' or 'lazydocker'
local function toggle_term_tab(cmd)
    local is_opened = cmd .. '_opened'
    local win_id    = cmd .. '_win'

    if api.nvim_get_var(is_opened) == 0 then  -- Isn't opened
        open_term_tab(cmd)
    else  -- Opened
        api.nvim_set_current_win(api.nvim_get_var(win_id))
    end
end

vimp.nnoremap('<c-space>',  function() toggle_term_tab('lazygit') end)
vimp.nnoremap('<leader>go', function() toggle_term_tab('lazydocker') end)
