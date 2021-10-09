local AutoSession = require("auto-session")
local SessionLens = require('session-lens')

SessionLens.setup { path_display = {'shorten'}, }

-- TODO
-- - globals, curdir, terminal
-- - `terminal` also doesn't respect options
vim.o.sessionoptions="blank,buffers,curdir,folds,help,options,tabpages,winsize,resize,winpos"

AutoSession.setup({
    auto_session_root_dir = vim.fn.stdpath("data").."/sessions/",
    log_level = "info",
    auto_session_enable_last_session = false,
    auto_session_enabled = true,
    auto_save_enabled = false,
    auto_restore_enabled = false,
    auto_session_suppress_dirs = {},

    -- Handle NvimTree bug. NOTE Also see nvimtree.lua disabling vim.g.nvim_tree_auto_open
    pre_save_cmds = {"tabdo NvimTreeClose"},
    -- post_restore_cmds = {"tabdo NvimTreeOpen"},  -- TODO Not working
})

whichkey.register({
    ['\\s'] = {
        name = "session management",
        s = {"<cmd>SaveSession<CR>", "save the current session", noremap=true},
        S = {"<cmd>SaveSession", "save session in specified directory path", noremap=true},
        l = {"<cmd>RestoreSession<CR>", "load session for current path", noremap=true},
        L = {"<cmd>RestoreSession", "load session from specified directory path", noremap=true},
        x = {"<cmd>DeleteSession<CR>", "delete session for current path", noremap=true},
        X = {"<cmd>DeleteSession", "delete session for specified directory path", noremap=true},
    },
}, {prefix="<leader>"})
