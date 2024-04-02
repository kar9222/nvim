-- Manually start REPL `start_shell_placeholder_term` and toggleterm.nvim

-- TODO However you will not be able to use a count with the open mapping in terminal and insert modes. You can create buffer specific mappings to exit terminal mode and then use a count with the open mapping. Check Terminal window mappings for an example of how to do this.

-- TODO [Question :: (Re)-focus on open terminal window using it&#39;s count number · Issue #42 · akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim/issues/42#issuecomment-878896202)

-- TODO [Feature Idea: Terminals List that can be used with picker (e.g: Telescope) · Issue #80 · akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim/issues/80)


local toggleterm = require("toggleterm")
local terminal = require("toggleterm/terminal").Terminal
local vimp = require('vimp')

local R_cmd  = 'radian -q'
local jl_cmd = 'julia'

local function termsize(term)
    if term.direction == "horizontal" then
        return 20
    elseif term.direction == "vertical" then
        return right_most_win_width
    end
end

-- Start terminal with command
-- @param cmd If provided, run command in shell.
local function new_neoterm(cmd)
    vim.cmd([[
        Tnew
        sleep 170m  " Same as startup.lua TODO
    ]])
    if cmd ~= nil then vim.cmd('T ' .. cmd) end
    -- vim.g.neoterm_default_mod is set to 'vertical'. Hacky way to 'disable' the config: close and navigate to it.
    vim.cmd([[
        Tclose
        wincmd l
        Tnext
    ]])
end


toggleterm.setup({
    direction = "float",
    size = termsize,
    open_mapping = '<c-m-f7>',  -- AHKREMAP <c-;>
    insert_mappings = true,  -- NOTE Enable this else `tnoremap` causes error
    hide_numbers = true,
    shade_terminals = false, -- shading_factor = "<number>",
    start_in_insert = true,
    persist_size = true,
    persist_mode = false, -- if set to true (default) the previous terminal mode will be remembered. I set this to false to avoid bug.
    close_on_exit = true,
    shell = vim.o.shell,  -- set the default shell
    float_opts = {
        border = border,
        width = 125,
        height = 40,
        winblend = 3,
    },
    highlights = {
        -- highlights which map to a highlight group name and a table of it's values
        -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
        NormalFloat = { link = 'Normal' },
        FloatBorder = { link = 'ToggleTermBorder' },  -- Custom highlight group
    }
})

-- NOTE Source these after setup
local R_term     = terminal:new({ count = 2, cmd = R_cmd,  direction = 'float' })
local julia_term = terminal:new({ count = 3, cmd = jl_cmd, direction = 'float' })
local btm_term   = terminal:new({ count = 4, cmd = 'btm',  direction = 'float' })  -- TODO Compare resource usage of `btm` vs `btm -b`
local shell_term = terminal:new({ count = 5, cmd = 'zsh',  direction = 'float' })

function _R_term_toggle()     return R_term:toggle() end
function _julia_term_toggle() return julia_term:toggle() end
function _shell_term_toggle() return shell_term:toggle() end
function _btm_term_toggle()   return btm_term:toggle() end


-- Non-toggleterm -------------------------------

-- Open shell term in horizontal split using the window of placeholder buffer.
-- NOTE It only works with the specific layout of start_shell_placeholder in startup.lua.
-- When a terminal job ends, the layout is restored.
local function shell_term_horizontal()
  vim.cmd([[
    wincmd j | term
    startinsert
    setlocal signcolumn=auto
  ]])
  -- Half window height. Minus 4 for padding, etc
  vim.cmd('set winheight=' .. (vim.o.lines - 4) / 2)

  -- Partly copied from start_placeholder of startup.lua
  -- NOTE `Bwipe!` doesn't completely wipe buffer? Hence use `bwipe!`
  local restore_placeholder_buf =
    'spl ' .. placeholder_buf_name ..
    ' | resize ' .. placeholder_buf_size ..
    ' | setlocal nobuflisted' ..  -- Re-set
    ' | wincmd k | startinsert'  -- TODO startinsert not working
  vim.cmd('au TermClose <buffer> bwipe! | ' .. restore_placeholder_buf)
end


-- Keybinds -------------------------------------

-- AHKREMAP <c-;>
vimp.tnoremap([[<c-m-f7>]], '<esc><cmd>ToggleTerm<CR>')  -- For non-toggleterm terminals
vimp.vnoremap([[<c-m-f7>]], '<esc><cmd>ToggleTerm<CR>')

whichkey.register({
    [';'] = {
        name = 'REPL and terminal',

        -- Default toggleterm is also shell term. Use default keybind for toggling.
        R = {':lua _R_term_toggle()<CR>',     'toggle R term in floating window',     noremap=true},
        J = {':lua _julia_term_toggle()<CR>', 'toggle Julia term in floating window', noremap=true},
        S = {':lua _shell_term_toggle()<CR>', 'toggle shell term in floating window', noremap=true},
        l = {':lua _btm_term_toggle()<CR>',   'toggle btm in a floating term',        noremap=true},
        z = {':Luapad<CR>',                   'open luapad',                          noremap=true},

        r = {function() new_neoterm(R_cmd) end,  'new R neoterm',     noremap=true },
        j = {function() new_neoterm(jl_cmd) end, 'new Julia neoterm', noremap=true },
        s = {function() new_neoterm() end,       'new shell neoterm', noremap=true },

        v = {
            name = 'open terminal in vertical split',  --  NOTE The `count` number (e.g. `#1`) depends on terminal classes defined above.
            [';'] = {'<cmd>vsp | b toggleterm#1<CR>', 'open default shell term in vertical split', noremap=true},
            r     = {'<cmd>vsp | b toggleterm#2<CR>', 'open R term in vertical split',             noremap=true},
            j     = {'<cmd>vsp | b toggleterm#3<CR>', 'open Julia term in vertical split',         noremap=true},
            l     = {'<cmd>vsp | b toggleterm#4<CR>', 'open btm term in vertical split',           noremap=true},
            s     = {'<cmd>vsp | b toggleterm#5<CR>', 'open shell term in vertical split',         noremap=true},
        },

        h = {
            name = 'open terminal in horizontal split',  --  NOTE The `count` number (e.g. `#1`) depends on terminal classes defined above.
            s = {function() shell_term_horizontal() end, 'open non-toggle-shell-term in horizontal split', noremap=true},
        },
    },
}, {prefix='<leader>'})

-- terminal mode bindings
-- NOTE: it *is* possible to create macros that go directly into the terminal!!
-- TODO add lots of cool functionality here.
-- whichkey.register({
--     ["<C-n>"] = {"<cmd>stopinsert!<CR>", "get out of insert mode", noremap=true},
-- }, {mode="t"})


-- TODO julia terminal with automatic include
-- TODO use TermExec to send useful stuff

