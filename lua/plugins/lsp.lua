-- Neovim's built-in LSP and plugins. Also include keys for other plugins (e.g. Aerial).
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
        open = "o", vsplit = "s",split = "i", quit = "q",scroll_down = "<C-f>", scroll_up = "<C-b>", -- quit can be a table
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
    api.nvim_buf_set_keymap(bufnr, 'n', 'gO', [[<cmd>lua require('telescope.builtin').lsp_workspace_symbols{ symbols = 'function' }<CR>]], opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gF', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    -- File-type-specific document symbols
    if vim.bo.filetype == 'r' then  -- Filter by section/func. NOTE `event` is my custom branch of {languageserver}
        api.nvim_buf_set_keymap(bufnr, 'n', 'ge', [[<cmd>lua require('telescope.builtin').lsp_document_symbols{ symbols = 'event' }<CR>]], opts)

        -- Filter documents for main kinds (e.g. Event and Function for R and Julia)
        -- Aerial backend for the source (e.g. LSP, treesitter, etc) and that it filters out some symbols
        -- See `filter_kind` option in aerial's config.
        -- Given the pre-filtered symbols, it's slightly faster than `lsp_document_symbols` as per my observations.
        api.nvim_buf_set_keymap(bufnr, 'n', 'gr', [[<cmd>lua require('telescope').extensions.aerial.aerial()<CR>]], opts)
    end
    if vim.bo.filetype == 'rmarkdown' then  -- Filter by markdown headings. NOTE `event` is my custom branch of {languageserver}
        api.nvim_buf_set_keymap(bufnr, 'n', 'go', [[<cmd>lua require('telescope.builtin').lsp_document_symbols{ symbols = 'event' }<CR>]], opts)
    else  -- No filter
        api.nvim_buf_set_keymap(bufnr, 'n', 'go', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
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

cfg.r_language_server.setup({
    autostart = true,  -- TODO Check for duplicated languageserver
    cmd = {'R', '--slave', '--no-init-file', '-e', 'languageserver::run()'},
    filetypes = {'r', 'rmd'},
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
    handlers = {  -- Temporarily disable it due to bugs/noise
        ["textDocument/publishDiagnostics"] = diagnostic_handlers(false, false, false, false)
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
