-- TODO See
-- - neoterm/.../repl.vim
-- - iron/.../lowlevel.lua
-- https://vi.stackexchange.com/questions/10167/is-there-a-way-that-i-can-identify-which-window-is-a-terminal-after-calling-the

-- TODO Highlight

-- - Use chansend
-- - Bracketed paste mode like neoterm

local api = vim.api
local fn  = vim.fn

_G.repl_bracketed_paste = 1  -- TODO Make this option

function send_currentLine_move()
    line = api.nvim_get_current_line()
    vim.cmd('normal! j')
    send_to_term(line)
end

function send_selection()
    sel_start = fn.getpos("'<")
    sel_end   = fn.getpos("'>")
    lines = api.nvim_buf_get_lines(0, sel_start[2], sel_end[2], false)
    -- TODO See neoterm

    send_to_term(lines)
end


-- Hacky way to identify 'active term' triggered when cursor leave 'usually-used' window. TODO Description
vim.cmd([[
  let g:term_leave = 0
  au TermOpen  * let g:term_leave = b:terminal_job_id
  au TermLeave * let g:term_leave = b:terminal_job_id
]])
-- vimp.nnoremap('z', ':ec "Term leave: " g:term_leave<CR>')

function send_to_term(_cmd)
    local cmd = _cmd

    cmd = cmd .. "\r"
    if _G.repl_bracketed_paste == 1 then
        cmd = '\x1b[200~' .. cmd .. '\x1b[201~'
    end

    fn.chansend(vim.g.term_leave, cmd)
end

vimp.nnoremap('<leader>u', function() send_currentLine_move() end)
vimp.xmap('<leader>n', function() send_selection() end)
