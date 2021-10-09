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
        return 73
    end
end

-- Start terminal with command
-- @param cmd If provided, run command in shell.
local function new_term(cmd)
    vim.cmd([[
        Tnew
        sleep 400m  " Same as startup.lua
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
    close_on_exit = true,
    shell = vim.o.shell,  -- set the default shell
    float_opts = {
        border = border,
        width = 125,
        height = 40,
        winblend = 3,
        highlights = {
            background = "Normal",
            border = "ToggleTermBorder",
        }
    },
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


-- Keybinds -------------------------------------

-- AHKREMAP <c-;>
vimp.tnoremap([[<c-m-f7>]], '<esc><cmd>ToggleTerm<CR>')  -- For non-toggleterm terminals
vimp.vnoremap([[<c-m-f7>]], '<esc><cmd>ToggleTerm<CR>')

whichkey.register({
    [';'] = {
        name = 'REPL and terminal',

        -- Default toggleterm is also shell term. Use default keybind for toggling.
        r = {':lua _R_term_toggle()<CR>',     'toggle R term in floating window',     noremap=true},
        j = {':lua _julia_term_toggle()<CR>', 'toggle Julia term in floating window', noremap=true},
        l = {':lua _btm_term_toggle()<CR>',   'toggle btm in a floating term',        noremap=true},
        s = {':lua _shell_term_toggle()<CR>', 'toggle shell term in floating window', noremap=true},
        z = {':Luapad<CR>',                   'open luapad',                          noremap=true},

        n = {
            name = 'new terminal',
            S = {'<cmd>lua start_shell_placeholder()<CR>', 'start shell and placeholder term', noremap=true},  -- NOTE This is from startup.lua
            s = {function() new_term() end,       'shell', noremap=true },
            r = {function() new_term(R_cmd) end,  'R',     noremap=true },
            j = {function() new_term(jl_cmd) end, 'Julia', noremap=true },
        },

        v = {
            name = 'open terminal in vertical split',  --  NOTE The `count` number (e.g. `#1`) depends on terminal classes defined above.
            [';'] = {'<cmd>vsp | b toggleterm#1<CR>', 'open default shell term in vertical split', noremap=true},
            r     = {'<cmd>vsp | b toggleterm#2<CR>', 'open R term in vertical split',             noremap=true},
            j     = {'<cmd>vsp | b toggleterm#3<CR>', 'open Julia term in vertical split',         noremap=true},
            l     = {'<cmd>vsp | b toggleterm#4<CR>', 'open btm term in vertical split',           noremap=true},
            s     = {'<cmd>vsp | b toggleterm#5<CR>', 'open shell term in vertical split',         noremap=true},
        }
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

