local neogit = require('neogit')
local vimp = require('vimp')

vim.cmd('au BufEnter NeogitStatus setlocal nobuflisted cursorline')  -- TODO BufAdd/BufNew doesnt work
-- vim.cmd('au User NeogitStatusRefreshed :NvimTreeRefresh<CR>')  -- TODO Need?

neogit.setup {
  disable_signs = false,
  disable_context_highlighting = true,
  disable_commit_confirmation = true,
  auto_refresh = true,
  disable_builtin_notifications = false,
  commit_popup = { kind = "split", },
  signs = {  -- { Closed, Opened }
    section = { "", "" },
    item = { "", "" },
    hunk = { "", "" },
  },
}

vimp.nnoremap('<leader>gf', function()  -- TODO Optimize
    -- TODO au BufDelete <buffer> tabclose
    vim.cmd([[
        neogit
        NvimTreeOpen
        wincmd l
    ]])
end)





-- TODO Scripting neogit -------------------------

-- Git log

-- local git = require("neogit.lib.git")
-- local LogViewBuffer = require 'neogit.buffers.log_view'
-- local popup = require("neogit.lib.popup")
-- local function neogit_log()
--     local output = git.cli.log.format("fuller").args(unpack(popup:get_arguments())).call_sync()
--     LogViewBuffer.new(parse(output)):open()
-- end

-- vimp.nnoremap('<c-l>', function()
--     neogit_log()
-- end)
