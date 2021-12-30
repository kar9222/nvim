local trouble = require("trouble")

vim.cmd('au FileType trouble setlocal cursorline')

trouble.setup({
    position = "right", -- position of the list can be: bottom, top, left, right
    width = right_most_win_width, -- width of the list when position is left or right
    height = 10, -- height of the trouble list when position is top or bottom
    mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" }, -- open buffer in new split
        open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
        open_tab = { "<c-t>" }, -- open buffer in new tab
        jump_close = {"o"}, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        preview = "p", -- preview the diagnostic location
        hover = "K", -- opens a small popup with the full multiline message
        close_folds = {"zM", "zm"}, -- close all folds
        open_folds = {"zR", "zr"}, -- open all folds
        toggle_fold = {"zA", "za"}, -- toggle fold of current file
        previous = "k", -- preview item
        next = "j" -- next item
    },
    indent_lines = true, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    icons = true, -- use devicons for filenames
    fold_open = "", -- icon used for open folds
    fold_closed = "", -- icon used for closed folds
    signs = {
        -- icons / text used for a diagnostic
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "﫠"
    },
    use_lsp_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
})

whichkey.register({  -- TODO `Trouble` or `TroubleToggle`
    name = "trouble",
    ll = {'<cmd>tabnew % | TroubleToggle<CR>', 'toggle'},
    lr = {'<cmd>TroubleToggle lsp_references<CR>',  'LSP references'},
    ld = {'<cmd>TroubleToggle document_diagnostics<CR>',  'LSP document diagnostics'},
    lw = {'<cmd>TroubleToggle workspace_diagnostics<CR>', 'LSP workspace diagnostics'},
    lo = {'<cmd>TroubleToggle loclist<CR>', 'loclist'},
    lq = {'<cmd>TroubleToggle quickfix<CR>', 'quickfix'},

}, {prefix = '<leader>', noremap = true, silent = true})


