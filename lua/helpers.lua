local fn = vim.fn
local api = vim.api

middle_win_nr = 2  -- File explorer window on the left is #1. The (top) middle window is #2.
file_explorer_width_julia = 25
file_explorer_width_R = 30
right_most_win_height = 38
right_most_win_width = 73  -- TODO Replace hard values by this variable
placeholder_buf_name = 'placeholder'  -- TODO Update feline
placeholder_buf_size = 9

border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }

-- Helpers for toggling buffers, including terminal, search panel.
function toggle_buf(win_id, buf_nr, focus)
    if buf_nr ~= nil then  -- Target buffer has been open but hidden
        if fn.bufwinnr(buf_nr) == -1 then  -- Hidden
            api.nvim_win_set_buf(win_id, buf_nr)
        end
        if focus then
            api.nvim_set_current_win(win_id)
        end
    end
    -- Else, do nothing
end

-- NOTE If there are two windows on the right, toggle the upper right most window, which is handled by `winnr('10l')`
function toggle_buf_right_most(buf_nr, focus)
    if fn.len(api.nvim_list_wins()) <= 2 then  -- Target window is close HACKY
        vim.cmd('vsp')
    end
    win_id = fn.win_getid(fn.winnr('10l'))
    toggle_buf(win_id, buf_nr, focus)
end

function close_placeholder_win()  -- If it exists
    win_id = fn.win_getid(fn.bufwinnr('^' .. placeholder_buf_name .. '$'))
    if win_id ~= 0 then
        api.nvim_win_close(win_id, false)
    end
end

function close_term_win()
    win_id = fn.win_getid(vim.fn.winnr('10l'))
    api.nvim_win_close(win_id, false)
end

function last_active_term_buf_nr()
    -- Last active terminal instance
    instance_id = tostring(vim.g.neoterm.last_active)
    buf_nr = vim.g.neoterm.instances[instance_id].buffer_id
    return buf_nr
end

function to_last_active_term_win()
    win_id = fn.win_getid(fn.bufwinnr(last_active_term_buf_nr()))
    api.nvim_set_current_win(win_id)
end


-- Highlight -------------------------------------

local yank_ns = api.nvim_create_namespace('hlyank')

-- TODO Merge line_start, line_end, col_start, col_end,
-- TODO Reorder params. `local` function
-- TODO Those call with arg `inclusive` somehow correct (e.g. spectre and Send_motion)
-- @param timeout time in ms before highlight is cleared (default `150`). When 'no_timeout' is provided, no timeout for highlight.
function highlight_range(line_start, line_end, col_start, col_end, rtype, inclusive, bufnr, timeout)
  local col_start = col_start or 1
  local col_end   = col_end or 1
  local bufnr     = bufnr or 0  -- Current buffer
  local timeout   = timeout or 150
  local rtype     = rtype or 'V'
  local inclusive = inclusive or false

  api.nvim_buf_clear_namespace(bufnr, yank_ns, 0, -1)  -- TODO What is this?

  local line_start = line_start - 1
  local line_end   = line_end - 1
  local col_start  = col_start - 1  -- TODO? + getpos(...)[4]
  local col_end    = col_end - 1    -- TODO? + getpos(...)[4]

  vim.highlight.range(
    bufnr, yank_ns, 'Search',
    {line_start, col_start}, {line_end, col_end},  
    rtype, inclusive
  )
  -- TODO Bad control flow
  if timeout == 'no_timeout' then
    return
  else
    -- Clear highlight after `timeout` milliseconds
    vim.defer_fn(
    function()
        -- if api.nvim_buf_is_valid(bufnr) then
        api.nvim_buf_clear_namespace(bufnr, yank_ns, 0, -1)
        -- end
    end,
    timeout  
    )
  end
end


function clear_hl(bufnr)  -- TODO `local` function
    api.nvim_buf_clear_namespace(bufnr, yank_ns, 0, -1)  -- TODO What is this 
end
