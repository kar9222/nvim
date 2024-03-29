-- Keybindings for toggling the right windows which hold buffers for terminal, search panel, symbol outline, etc.
-- TODO Refactor/fix all

local Spectre = require("spectre")
local aerial = require('aerial')

local api = vim.api
local fn = vim.fn


-- Terminal --------------------------------------

-- TODO When repl.vim is converted to repl.lua, refactor and merge with repl.lua?
function toggle_last_active_term_right_most()  -- AHKREMAP
    -- Toggle last active terminal instance
    toggle_buf_right_most(last_active_term_buf_nr(), true)
    vim.cmd('startinsert')

    -- Toggle placeholder terminal buffer
    -- TODO If most right win is term buffer, don't toggle this
    placeholder_buf_nr = fn.bufnr(placeholder_buf_name)
    if fn.bufwinnr(placeholder_buf_nr) == -1 then  -- Hidden
        term_buf_win_id = api.nvim_get_current_win()
        vim.cmd('split | resize ' .. placeholder_buf_size)
        api.nvim_set_current_buf(placeholder_buf_nr)

        api.nvim_set_current_win(term_buf_win_id)
    end
end
vimp.nnoremap('<m-s>', function() toggle_last_active_term_right_most() end)
vimp.inoremap('<m-s>', function() toggle_last_active_term_right_most() end)


-- Search panel ----------------------------------

function setup_spectre()
    api.nvim_exec([[
        augroup SpectreCustom
            au! * <buffer>
            au BufEnter <buffer> lua on_enter()
            au BufLeave <buffer> lua on_leave()
        augroup END
    ]],
    false)
end

-- Generic function for calling various Spectre functions.
-- @param spectre_open_func Generic function for calling various Spectre functions
-- @param opts Options pass to `spectre_open_func`. For no arguments, pass `{}`.
--
function spectre_generic(spectre_open_func, opts)
    close_placeholder_win()
    close_all_term_wins()

    spectre_open_func(opts) -- Dynamically call various open function with/without opts

    api.nvim_win_set_width(0, right_most_win_width)  -- TODO use augroup?
    setup_spectre()
end

-- Current file: Open/word-under-cursor/selection
vimp.nnoremap('<m-f>',   function() spectre_generic(Spectre.open_file_search, {}) end)
vimp.nnoremap('<m-s-f>', function() spectre_generic(Spectre.open_file_search, {select_word = true}) end)
vimp.vnoremap('<m-f>',   function() spectre_generic(Spectre.open_file_search, {path = fn.expand('%')}) end)

-- Current directory: Open/word-under-cursor/selection AHKREMAP
vimp.nnoremap('<m-o>', function() spectre_generic(Spectre.open,        {}) end)
vimp.nnoremap('<m-O>', function() spectre_generic(Spectre.open_visual, {select_word = true}) end)  -- TODO Not working when it's active
vimp.vnoremap('<m-o>', function() spectre_generic(Spectre.open_visual, {}) end)  -- TODO Not working when it's active


-- Internally, in nvim-spectre/init.lua, when first opening spectre, `open` stores buffer number in `state.bufnr` where `state` is `require('spectre.state')`. Use this buffer number for scripting so that the same spectre buffer is re-used without opening new ones, which is the default behaviour. TODO See if issue is resolve.
local SpectreState = require('spectre.state')
-- Toggle, including open, without focus because focus is done by Spectre's API
-- This is useful, for example, for viewing previously searched words
function toggle_spectre(focus)  -- TODO Escape visual mode
    close_placeholder_win()

    if SpectreState.is_open == false then
        close_all_term_wins()
        Spectre.open()
        api.nvim_win_set_width(0, right_most_win_width)
        setup_spectre()
    else
        toggle_buf_right_most(SpectreState.bufnr, focus)
    end
end

-- Start in normal mode so that, when toggle open search panel from other buffers like terminal, normal mode navigation is available straightaway.
vimp.nnoremap('<m-8>', function() toggle_spectre(true) end)
vimp.inoremap('<m-8>', function()
    toggle_spectre(true)
    vim.cmd('stopinsert')
    setup_spectre()
end)
vimp.tnoremap('<m-8>', '<cmd>lua toggle_spectre(true)<CR>')  -- TODO When lua function call is supported by vimpeccable, use lua function call and add back `local` to `toggle_spectre` above. Temporary workaround by exporting `toggle_spectre` to global environment.


-- Aerial ---------------------------------------

function toggle_outline()
    close_all_term_wins()
    close_placeholder_win()
    aerial.toggle()
end

vimp.nnoremap('<m-e>', function() toggle_outline() end)
vimp.inoremap('<m-e>', function()
    vim.cmd('stopinsert')
    toggle_outline()
end)
vimp.tnoremap('<m-e>', '<cmd>lua toggle_outline()<CR>')  -- TODO When lua function call is supported by vimpeccable, use lua function call and add back `local` to `toggle_outline` above. Temporary workaround by exporting `toggle_outline` to global environment.
