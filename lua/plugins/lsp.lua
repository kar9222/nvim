-- Neovim's built-in LSP and plugins
-- Some configs are copied and adapted from {nvim-lspconfig} and full credits go to [neovim](https://github.com/neovim)

-- TODO https://github.com/neovim/nvim-lspconfig/wiki

local lsp = vim.lsp
local api = vim.api
local M = {}

local cfg = require("lspconfig")  -- Common configs for Neovim's built-in LSP
local protocol = require('vim.lsp.protocol')
local saga = require("lspsaga")
local provider = require("lspsaga/provider")
local action = require("lspsaga/codeaction")
local hover = require("lspsaga/hover")
local signature_help = require("lspsaga/signaturehelp")
local rename = require("lspsaga/rename")
local diagnostic = require("lspsaga/diagnostic")

-- TODO Default param not working
local function diagnostic_handlers(virtual_text, signs, underline, update_in_insert)
    return lsp.with(lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = virtual_text,
        signs = signs,
        underline = underline,
        update_in_insert = update_in_insert,
    })
end

-- Set global handlers for diagnostics. To override it for specific language, set it on language-specific setup.
-- TODO: will basically need your own plugin to make these easily toggleable; in the meantime, this
-- is a reasonable default, see https://github.com/nvim-lua/diagnostic-nvim/issues/73
lsp.handlers["textDocument/publishDiagnostics"] = diagnostic_handlers(true, true, true, true)

-- general config, via lspsaga
saga.init_lsp_saga({
    use_saga_diagnostic_sign = true,
    error_sign = " ",
    warn_sign = " ",
    hint_sign = " ",
    infor_sign = " ",
    diagnostic_header_icon = "ℒ ",
    code_action_icon = "𝔄",
    code_action_prompt = {
        enable = false,
        sign = false,
        sign_priority = 20,
        virtual_text = false,
    },
    finder_definition_icon = "𝔇 ",
    finder_reference_icon = "𝔯 ",
    max_preview_lines = 30, -- TODO preview lines of lsp_finder and definition preview
    finder_action_keys = {
        open        = 'l',
        quit        = 'q',  -- quit can be a table
        split       = 's',
        vsplit      = 'v',
        scroll_down = '<C-f>',
        scroll_up   = '<C-b>',
    },
    code_action_keys = {
        quit = "q", exec = "<CR>",
    },
    rename_action_keys = {
        quit = "<C-c>", exec = "<CR>",  -- quit can be a table
    },
    definition_preview_icon = "𝔇 ",
    border_style = "round",  -- "single" "double" "round" "plus"
    rename_prompt_prefix = "➤",
})

-- local fn = vim.fn
function M.go_to_definition_highlight()
    vim.lsp.buf.definition()
    -- highlight_range(fn.line('.'), fn.line('.'), 1, -1)  -- TODO Highlight after command finishes
end

-- Keybindings -----------------------------------

local on_attach = function(client, bufnr)
    -- For plugins with an `on_attach` callback, call them here.
    -- require('lsp_signature').on_attach()  -- TODO_lsp_signature Temporarily disabled

    -- Native LSP
    local opts = {noremap = true, silent = true}
    api.nvim_buf_set_keymap(bufnr, 'n', 'gd', "<cmd>lua require'plugins/lsp'.go_to_definition_highlight()<CR>", opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'go', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gO', [[<cmd>lua require('telescope.builtin').lsp_workspace_symbols{ symbols = 'function' }<CR>]], opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gF', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    -- File-type-specific document symbols
    if vim.bo.filetype == 'r' then  -- Filter by section/func. NOTE `event` is my custom branch of {languageserver}
        api.nvim_buf_set_keymap(bufnr, 'n', 'ge', [[<cmd>lua require('telescope.builtin').lsp_document_symbols{ symbols = 'event' }<CR>]], opts)
    end
    -- TODO Use telescope/others' implementations? e.g. `Telescope lsp_definition`, `Telescope lsp_references`
    -- z = {"<cmd>Telescope lsp_references<CR>", "search LSP references"},
    -- d = {"<cmd>Telescope lsp_definitions<CR>", "search LSP definitions"},

    -- LSP saga
    api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>Lspsaga preview_definition<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gh', '<cmd>Lspsaga lsp_finder<CR>', opts)  -- Cursor word definition and references
    api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>Lspsaga hover_doc<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gs', '<cmd>Lspsaga signature_help<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'i', '<c-space>', '<cmd>Lspsaga signature_help<CR>', opts)  -- TODO Use this or lsp_signature?
    api.nvim_buf_set_keymap(bufnr, 'n', 'gR', '<cmd>Lspsaga rename<CR>', opts)
    -- Code action
    api.nvim_buf_set_keymap(bufnr, 'n', 'gca', '<cmd>Lspsaga code_action<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'v', 'gca', ':<c-u>Lspsaga range_code_action<CR>', opts)
    -- Diagnostics
    api.nvim_buf_set_keymap(bufnr, 'n', 'gcd', '<cmd>Lspsaga show_line_diagnostics<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gcD', '<cmd>Lspsaga show_cursor_diagnostics<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', opts)

    -- HOTFIX Limited go-to-definition for R LSP
    api.nvim_buf_set_keymap(bufnr, 'n', 'gz', [[<cmd>lua require('telescope.builtin').grep_string({ search =  vim.fn.expand('<cword>') .. " <-", use_regex=true })<CR>]], opts)
end


-- Scroll: TODO https://github.com/glepnir/lspsaga.nvim/issues/68
-- doc_scroll_dn = function(default_key)
--     if require('lspsaga.hover').has_saga_hover() then
--       require('lspsaga.hover').smart_scroll_hover(1)
--     else
--       local key = vim.api.nvim_replace_termcodes(default_key,true,false,true)
--       vim.fn.nvim_feedkeys(key,'n',true)
--     end
--   end
-- vimp.nnoremap(opts, '<c-d>', function()
--     doc_scroll_dn('<c-d>')
-- end)


whichkey.register({
    ["L"] = {
        name = "LSP",
        S = {'<cmd>LspStart<CR>', 'start LSP client', noremap=true},
        I = {'<cmd>LspInfo<CR>', 'show LSP info', noremap=true},
        X = {function() lsp.stop_client(lsp.get_active_clients()) end, "stop all LSP clients", noremap=true},
        f = {"<cmd>Lspsaga lsp_finder<CR>", "open LSP finder", noremap=true},
        a = {action.code_action, "open LSP action", noremap=true},
        d = {hover.render_hover_doc, "view docs", noremap=true},
        s = {signature_help.signature_help, "help with signature", noremap=true},
        r = {rename.rename, "rename", noremap=true},
        v = {provider.preview_definition, "preview definition", noremap=true},
        ["1"] = {diagnostic.show_line_diagnostics, "show line diagnostics", noremap=true},
        ["2"] = {diagnostic.show_cursor_diagnostics, "show cursor diagnostics", noremap=true},
        ["]"] = {diagnostic.lsp_jump_diagnostic_next, "jump to next diagnostic", noremap=true},
        ["["] = {diagnostic.lsp_jump_diagnostic_prev, "jump to previous diagnostic", noremap=true},
    },
}, {prefix="<leader>"})


-- R ---------------------------------------------

-- TODO
-- Check if go to definition triggers multiple LSP
-- `--no-init-file` to deal with {renv} issues when lauching LSP: Workaround for using {languageserver} in user lib for {renv}-project by skipping project-level .Rprofile during {languageserver} startup. See {languageserver} issues #34 and {REditorSupport/vscode-r-lsp} pull #45.

-- ============================================================================================
-- Debounced R Diagnostics
-- TODO Check performance due to vim.api.nvim_create_autocmd({'TextChangedI', 'TextChanged'}

-- Problem: R LSP diagnostics (via lintr) appear too quickly while typing, causing distraction.
-- Solution: Delay diagnostics by N seconds after the user stops typing, and immediately hide
--           them when the user starts typing again.
--
-- Behavior:
--   1. User types        -> Diagnostics immediately hidden, timer cancelled
--   2. User keeps typing -> Timer keeps resetting, diagnostics stay hidden
--   3. User stops typing -> After `r_diagnostic_delay_ms` (default 3s), diagnostics appear
--
-- Implementation:
--   - Autocmd (TextChangedI/TextChanged): Clears diagnostics instantly on keystroke
--   - Custom LSP handler: Debounces diagnostic display with a timer
--
-- Configuration:
--   - Change `r_diagnostic_delay_ms` to adjust delay (in milliseconds)
--   - To disable diagnostics entirely, set handler to `function() end` in setup below
--
-- Performance (TextChangedI/TextChanged autocmd):
--   - Early return via `r_diagnostics_visible` flag: if diagnostics not visible and no
--     pending timer, callback exits immediately with just two boolean checks
--   - All operations are in-memory with no I/O:
--       - vim.lsp.get_active_clients(): O(1) table lookup
--       - vim.lsp.diagnostic.get_namespace(): O(1) lookup
--       - vim.diagnostic.reset(): O(n) where n = number of diagnostics (typically < 100)
--       - timer stop/close: O(1)
--   - Negligible compared to what already runs per-keystroke (treesitter, syntax, LSP didChange)
--
-- Note: Neither Neovim nor R languageserver provide a built-in delay setting.
--       This custom implementation is required.

local r_diagnostic_timer = nil       -- libuv timer handle
local r_diagnostic_delay_ms = 3000   -- delay before showing diagnostics
local r_pending_diagnostics = {}     -- stores latest diagnostic data from LSP
local r_diagnostics_visible = false  -- tracks if diagnostics are currently displayed

local r_base_handler = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = true,  -- show diagnostics even in insert mode
})

-- Clear diagnostics immediately on text change (before LSP responds)
vim.api.nvim_create_autocmd({'TextChangedI', 'TextChanged'}, {
    pattern = {'*.r', '*.R'},
    callback = function(args)
        if not r_diagnostics_visible and not r_diagnostic_timer then
            return  -- nothing to clear, skip for performance
        end
        if r_diagnostics_visible then
            local clients = vim.lsp.get_active_clients({ bufnr = args.buf, name = 'r_language_server' })
            for _, client in ipairs(clients) do
                local namespace = vim.lsp.diagnostic.get_namespace(client.id)  -- each LSP client has unique namespace
                vim.diagnostic.reset(namespace, args.buf)  -- clear signs/virtual text for this buffer
            end
            r_diagnostics_visible = false  -- mark as cleared to avoid redundant resets
        end
        if r_diagnostic_timer then
            r_diagnostic_timer:stop()
            r_diagnostic_timer:close()
            r_diagnostic_timer = nil  -- cancel pending diagnostic display
        end
    end
})

-- LSP handler: debounce diagnostics, only show after delay
local function r_debounced_diagnostic_handler(err, result, ctx, config)
    r_pending_diagnostics = { err = err, result = result, ctx = ctx, config = config }

    if r_diagnostic_timer then  -- cancel previous timer
        r_diagnostic_timer:stop()
        r_diagnostic_timer:close()
        r_diagnostic_timer = nil
    end

    r_diagnostic_timer = vim.loop.new_timer()
    r_diagnostic_timer:start(r_diagnostic_delay_ms, 0, vim.schedule_wrap(function()
        if r_pending_diagnostics.result then
            r_base_handler(  -- display diagnostics
                r_pending_diagnostics.err,
                r_pending_diagnostics.result,
                r_pending_diagnostics.ctx,
                r_pending_diagnostics.config
            )
            if r_pending_diagnostics.result.diagnostics and #r_pending_diagnostics.result.diagnostics > 0 then
                r_diagnostics_visible = true -- only set if there are actual diagnostics
            end
        end
        if r_diagnostic_timer then
            r_diagnostic_timer:stop()
            r_diagnostic_timer:close()
            r_diagnostic_timer = nil
        end
    end))
end
-- ============================================================================================

cfg.r_language_server.setup({
    autostart = true,  -- TODO Check for duplicated languageserver
    cmd = {'R', '--slave', '--no-init-file', '-e', 'languageserver::run()'},
    filetypes = {'r' },
    on_attach = on_attach,
    root_dir = function(fname)
        return cfg.util.find_git_ancestor(fname) or vim.loop.os_homedir()
    end,
    log_level = protocol.MessageType.Warning,
    docs = {
        package_json = 'https://raw.githubusercontent.com/REditorSupport/vscode-r-lsp/master/package.json',
        description = [[
        [languageserver](https://github.com/REditorSupport/languageserver) is an
        implementation of the Microsoft's Language Server Protocol for the R
        language.

        It is released on CRAN and can be easily installed by

        ```R
        install.packages("languageserver")
        ```
        ]],
        default_config = {
            root_dir = [[root_pattern(".git") or os_homedir]],
        },
    },
    -- To disable diagnostics (via lintr), replace `r_debounced_diagnostic_handler` with `function() end`
    handlers = {
        ["textDocument/publishDiagnostics"] = r_debounced_diagnostic_handler
    },
  })

-- Julia -----------------------------------------

local julia_cmd = {
    'julia',
    '--startup-file=no', '--history-file=no',
    vim.fn.stdpath('config')..'/lsp/lsp.jl'
}
cfg.julials.setup({
    autostart = false,  -- TODO
    cmd = julia_cmd,
    on_attach = on_attach,  -- TODO Validate
    on_new_config = function(cfg, _)
        cfg.cmd = julia_cmd
    end,
    filetypes={"julia"},
    -- HOTFIX: Temporarily disable it due to bugs/noise. This overrides global settings as defined above: lsp.handlers["textDocument/publishDiagnostics"]
    handlers = {
        ["textDocument/publishDiagnostics"] = function() end
    },
    -- log_level = protocol.MessageType.Debug,  -- TODO
})


-- Lua ------------------------------------------

-- NOTE This configures Sumneko to work for Neovim init.lua and plugin development. This setup is not intended to be used for any other types of projects.

require('neodev').setup({  -- IMPORTANT: make sure to setup neodev BEFORE lspconfig
    library = {
        vimruntime = true, -- runtime path
        types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
        plugins = true, -- installed opt or start plugins in packpath
        -- you can also specify the list of plugins to make available as a workspace library
        -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
    },
    lspconfig = {  -- pass any additional options that will be merged in the final lsp config
        autostart = false,
        cmd = {'lua-language-server'},  -- NOTE Installed from Arch's AUR
        -- on_attach = on_attach  -- TODO Use config of neodev?
    }
})

cfg.sumneko_lua.setup({
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace"
      }
    }
  }
})

return M








-- Backup ----------------------------------------

-- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
-- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
-- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--
-- local capabilities = protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
