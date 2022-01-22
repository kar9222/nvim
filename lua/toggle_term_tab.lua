local fn  = vim.fn
local api = vim.api
local vimp = require'vimp'

vim.g.lazygit_opened = 0
local lazygit_win = nil

-- Open lazygit in terminal in a new tab with env var `GIT_EDITOR` opening in vertical split (see options.lua)
local function open_lazygit()
    -- Upon TermClose, bwipe! also closes the tab
    vim.cmd([[
        tabnew | term lazygit
        startinsert

        au BufEnter <buffer> startinsert  " TODO Correct?
        au TermClose <buffer> bwipe! | let g:lazygit_opened = 0
    ]])
    vim.g.lazygit_opened = 1
    lazygit_win = fn.win_getid()
end

local function toggle_lazygit()
    if vim.g.lazygit_opened == 0 then  -- Lazygit is not open
        open_lazygit()
    else  -- Lazygit is open
        api.nvim_set_current_win(lazygit_win)
    end
end

vimp.nnoremap('<leader>gg', function() toggle_lazygit() end)
