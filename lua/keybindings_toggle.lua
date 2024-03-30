-- Keybindings for toggling the right windows which hold buffers for terminal, search panel, symbol outline, etc.
-- TODO Refactor/fix all

local Spectre = require("spectre")
local aerial = require('aerial')

local api = vim.api
local fn = vim.fn


-- Terminal --------------------------------------

-- TODO When repl.vim is converted to repl.lua, refactor and merge with repl.lua?
function toggle_last_active_term_right_most()  -- AHKREMAP
    last_active_term_buf_nr_var = last_active_term_buf_nr()

    if last_active_term_buf_nr_var == nil then
        start_shell_placeholder()
        return
    end

    -- Toggle last active terminal instance
    toggle_buf_right_most(last_active_term_buf_nr_var, true)
    vim.cmd('startinsert')
    right_most_win_id__autocmd()

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
    right_most_win_id__autocmd()
    on_enter()  -- See plugins/spectre.lua TODO Is this the correct way of calling it here?
end

-- Generic function for calling various Spectre functions.
-- @param spectre_open_func Generic function for calling various Spectre functions
-- @param opts Options pass to `spectre_open_func`. For no arguments, pass `{}`.
--
function spectre_generic(spectre_open_func, opts)
    close_placeholder_win()
    close_all_term_wins()

    -- Close previously opened most right win (e.g. outline)
    if vim.g.right_most_win_id ~= nil and  -- No previously opened right most win
       vim.g.right_most_win_id ~= 0 then   -- Set by right_most_win_id__autocmd
        api.nvim_win_close(vim.g.right_most_win_id, false)
    end

    spectre_open_func(opts) -- Dynamically call various open function with/without opts

    api.nvim_win_set_width(0, right_most_win_width)  -- TODO use augroup?
    setup_spectre()
end

-- Current file: Open/word-under-cursor/selection
vimp.nnoremap('<m-s-f>', function() spectre_generic(Spectre.open_file_search, {}) end)
vimp.nnoremap('<m-f>',   function() spectre_generic(Spectre.open_file_search, {select_word = true}) end)
vimp.vnoremap('<m-f>',   function() spectre_generic(Spectre.open_file_search, {path = fn.expand('%')}) end)

-- Current directory: Open/word-under-cursor/selection AHKREMAP
vimp.nnoremap('<m-E>', function() spectre_generic(Spectre.open,        {}) end)
vimp.nnoremap('<m-e>', function() spectre_generic(Spectre.open_visual, {select_word = true}) end)
vimp.vnoremap('<m-e>', function() spectre_generic(Spectre.open_visual, {}) end)


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

-- TODO Refactor due to Aerial is opened by default for R/Julia directory.
function toggle_outline()
    close_all_term_wins()
    close_placeholder_win()

    aerial.toggle()

    -- Set width here due to setting width on startup won't work. See lua/startup.lua
    vim.cmd('sleep 1m')  -- NOTE Hacky solution. Otherwise it won't work.
    api.nvim_win_set_width(0, right_most_win_width)

    right_most_win_id__autocmd()
end

vimp.nnoremap('<m-o>', function() toggle_outline() end)
vimp.inoremap('<m-o>', function()
    vim.cmd('stopinsert')
    toggle_outline()
end)
vimp.tnoremap('<m-o>', '<cmd>lua toggle_outline()<CR>')  -- TODO When lua function call is supported by vimpeccable, use lua function call and add back `local` to `toggle_outline` above. Temporary workaround by exporting `toggle_outline` to global environment.
