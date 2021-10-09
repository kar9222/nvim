-- Helpers ----------------------------------------

-- Term navigation and opening. It covers three cases
-- - Term has been opened
--   1. Window is opened but not focused
--   2. Window is closed
-- 3. Term has not been opened
-- For all the cases, a single keybinding is required to open only if needed and focus on it, as detailed in the codes below.

-- Convenience function for creating new terminal
function newTerm(count, cmd, direction, winnr_term)
    return Terminal:new({
        count = count,  -- Usable 'count mark', but it's mainly used as placeholder
        cmd = cmd,
        direction = direction,
        on_open = function(term)
            rawset(_G, winnr_term, vim.api.nvim_get_current_win())  -- Mark term is open
            vim.cmd('startinsert!')
            -- vim.cmd('VimadeBufDisable')  -- TODO What is this? It's called before startinsert!
        end,
        -- Doesn't work for my case
        on_close = function(term)  ---@diagnostic disable-next-line
            rawset(_G, winnr_term, 0)  -- Reset?
            vim.cmd('quit!')
        end
    })
end

function term_toggle(_term, winnr_term)
    _winnr_term = rawget(_G, winnr_term)

    if _winnr_term > 0 then  -- Term has been opened  -- TODO Wrong? It's not 0
        -- Target window is opened but not focused
        if vim.tbl_contains(vim.api.nvim_list_wins(), _winnr_term) then
            vim.api.nvim_set_current_win(_winnr_term)  -- Focus term
        -- Window is closed
        else
            _winnr_term = 0  -- Reset? Not needed?
            _term:toggle()  -- Open term
        end
    else  -- Term has not been opened
        _term:toggle()  -- Open new term
    end
end

_G.winnr_R     = 0
_G.winnr_julia = 0
_G.winnr_shell = 0

julia_cmd = "julia --sysimage ~/.julia/my_sysimg/my_sysimg.so"
local RTerm     = newTerm(11, "radian -q", "vertical", "winnr_R")
local juliaTerm = newTerm(12, julia_cmd,   "vertical", "winnr_julia")
local shellTerm = newTerm(13, "zsh",       "vertical", "winnr_shell")

-- NOTE `_G`
function _G.RTerm_toggle()     term_toggle(RTerm,     "winnr_R") end
function _G.juliaTerm_toggle() term_toggle(juliaTerm, "winnr_julia") end
function _G.shellTerm_toggle() term_toggle(shellTerm, "winnr_shell") end

vimp.nnoremap('<m-9>', ':lua _G.RTerm_toggle()<CR>')
vimp.nnoremap('<m-8>', ':lua _G.juliaTerm_toggle()<CR>')
vimp.nnoremap('<m-s>', ':lua _G.shellTerm_toggle()<CR>')
