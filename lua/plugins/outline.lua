local vimp = require('vimp')

vim.cmd('au FileType Outline setlocal cursorline')

vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = true,
    show_symbol_details = true,
    position = 'right',
    relative_width = false,
    width = right_most_win_width,
    show_numbers = false,
    show_relative_numbers = false,
    keymaps = { -- These keymaps can be a string or a table for multiple keys
        close = {'<f10>', "<esc>", "q"},
        goto_location = "<cr>",
        focus_location = "o",
        hover_symbol = "<c-space>",  -- TODO
        toggle_preview = "K",
        rename_symbol = "r",
        code_actions = "a",
    },
    lsp_blacklist = {},
    symbol_blacklist = {},
    symbols = {
        File = {icon = "", hl = "TSURI"},
        Module = {icon = "", hl = "TSNamespace"},
        Namespace = {icon = "", hl = "TSNamespace"},
        Package = {icon = "", hl = "TSNamespace"},
        Class = {icon = "𝓒", hl = "TSType"},
        Method = {icon = "ƒ", hl = "TSMethod"},
        Property = {icon = "", hl = "TSMethod"},
        Field = {icon = "", hl = "TSField"},
        Constructor = {icon = "", hl = "TSConstructor"},
        Enum = {icon = "ℰ", hl = "TSType"},
        Interface = {icon = "ﰮ", hl = "TSType"},
        Function = {icon = "", hl = "TSFunction"},
        Variable = {icon = "", hl = "TSConstant"},
        Constant = {icon = "", hl = "TSConstant"},
        String = {icon = "𝓐", hl = "TSString"},
        Number = {icon = "#", hl = "TSNumber"},
        Boolean = {icon = "⊨", hl = "TSBoolean"},
        Array = {icon = "", hl = "TSConstant"},
        Object = {icon = "⦿", hl = "TSType"},
        Key = {icon = "🔐", hl = "TSType"},
        Null = {icon = "NULL", hl = "TSType"},
        EnumMember = {icon = "", hl = "TSField"},
        Struct = {icon = "𝓢", hl = "TSType"},
        Event = {icon = "🗲", hl = "TSType"},
        Operator = {icon = "+", hl = "TSOperator"},
        TypeParameter = {icon = "𝙏", hl = "TSParameter"}
    }
}


-- TODO Buffer-specific symbols ------------------

-- See symbols-outline/symbols-outline.vim. Potential hacky workaround by changing `g:symbols_outline` to buffer-specific config e.g. `b:symbols_outline`


-- if exists('g:loaded_symbols_outline')
--     finish
-- endif
-- let g:loaded_symbols_outline = 1

-- if exists('g:symbols_outline')
--     call luaeval('require"symbols-outline".setup(_A[1])', [g:symbols_outline])
-- else
--     call luaeval('require"symbols-outline".setup()')
-- endif
---------------------------------------------------




-- "[r]": {

--     // Outline
--     "outline.showVariables": false,
--     "outline.showNumbers":   false,
--     "outline.showBooleans":  false,
--     "outline.showStrings":   false,
--     "outline.showArrays":    false,
--     "outline.showStructs":   false,  // It works despite warning of {Error Lens}
--   },
--   "[rmd]": {
--     // Outline
--     "outline.showVariables": false,
--     "outline.showNumbers":   false,
--     "outline.showBooleans":  false,
--     "outline.showStrings":   false,
--     "outline.showKeys":      false,  // It works despite warning of {Error Lens}
--   },
--   "[julia]": {
--     // Editor
--     "editor.wordWrapColumn": 86,  // recommended 92
--     // "editor.rulers": [92],
--     "editor.detectIndentation": false,  // TODO default true
--     // "editor.insertSpaces": true,     // TODO Remove after inspection

--     // Outline
--     "outline.showVariables": false,
--     "outline.showNumbers": false,
--     "outline.showBooleans": false,
--     "outline.showStrings": false,
--   },
