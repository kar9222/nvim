local fn = vim.fn
local api = vim.api


-- Toggle float for any buffer, including terminal --------

-- 2 is offset (e.g. border) for aligning text buffer's line number
local _width = vim.o.columns - file_explorer_width_julia - 2
_opts = {
    border = border,
    width = _width,
    height = 47,  -- NOTE Large enough to avoid hidden top few lines after clearing terminal
    col = math.ceil(vim.o.columns - _width) / 2 + file_explorer_width_julia
}

function open_float(buf, opts)
    local width  = opts.width or
        math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
    local height = opts.height or
        math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
    local row = (opts.row or
        math.ceil(vim.o.lines - height) / 2) - 1
    local col = (opts.col or
        math.ceil(vim.o.columns - width) / 2) - 1

    api.nvim_open_win(buf, true, {
        relative = 'editor',
        row = row, col = col,
        width = width, height = height,
        border = opts.border
    })
    vim.b.is_open_float = true
    vim.cmd([[
        augroup OpenFloat
          au!
          au WinClosed <buffer> let b:is_open_float = 0
        augroup END
    ]])
end

function toggle_float(buf, opts)
    if not vim.b.is_open_float or vim.b.is_open_float == 0 then
        open_float(buf, opts)
    else
        api.nvim_win_close(0, false)
    end
end

-- Toggle float for current buffer/terminal AHKREMAP <c-0>
vimp.nnoremap('<c-m-s-f4>', function() toggle_float(0, _opts) end)
api.nvim_set_keymap('t', '<c-m-s-f4>', '<cmd>lua toggle_float(0, _opts)<CR>', {noremap = true})  -- TODO This mapping results in exporting toggle_float and _opts as globals


-- History search -------------------------------

-- TODO This mapping results in exporting toggle_float and _opts as globals

local function height()
    local top_relative_line = fn.line('.') - fn.line('w0')
    local min_height = vim.o.lines - 5  -- Offset top and bottom of screen
    return min_height - top_relative_line  -- Remaining bottom space
end

function _hist_opts()  -- Use as function because of `height()`
    return {
        relative = 'cursor', style = 'minimal', border = border,
        row = 1, col = 0,
        height = height(),
        width = right_most_win_width - 1,  -- Offset border, etc
    }
end

-- Currently, this works well except when cursor is near the screen line where the floats have minimal height. The minimal height ignore the bottom placeholder buffer, that is, it floats on top of it. One solution is to float it above the cursor, see 'Backup' section below for draft implementation.
--
-- It's currently being used for R's radian REPL. Julia's REPL uses OhMyREPL's fzf bindings.
--
-- @usage For radian: os.system('nvr --nostart -c "lua search_history(\\"send_r_history\\", _hist_opts)"')
--
-- NOTE Weirdly, `startinsert` isn't needed
function search_history(cmd, opts_fn)
    local opts = opts_fn()
    local buf = api.nvim_create_buf(false, true)
    api.nvim_open_win(buf, true, opts)
    vim.cmd('term ' .. cmd)
end










-- Backup ---------------------------------------

-- When cursor is below specified minimum height, float the window above cursor. Needs to adjust for fzf UI (e.g. descending?)
-- local min_height = 10
-- local btm_relative_line = fn.line('w$') - fn.line('.')
-- if btm_relative_line < min_height then
--     return search_history(opts_fn)
--     return
-- end


-- Very messy draft
-- function search_history(opts)
--     local win = 2
--     local cmd = 'nvr -cc ' .. win .. '"wincmd w"'
--
--     vim.cmd('term `r_history | send_from_term_to_term 3`')
--     vim.cmd('startinsert')
--
--     vim.fn.termopen('send_r_history', {
--         on_exit = function()
--             -- ...
--         end
--     })
-- end
