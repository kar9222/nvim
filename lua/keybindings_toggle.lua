-- Keybindings for toggling the right windows which hold buffers for terminal, search panel, symbol outline, etc.

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
        old_win_id = api.nvim_get_current_win()  -- Win ID of term buffer
        vim.cmd('split | resize ' .. placeholder_buf_size)
        api.nvim_set_current_buf(placeholder_buf_nr)

        api.nvim_set_current_win(old_win_id)
    end
end
-- AHKREMAP ^!;
vimp.nnoremap('<c-m-s-f9>', function() toggle_last_active_term_right_most() end)
vimp.inoremap('<c-m-s-f9>', function() toggle_last_active_term_right_most() end)


-- Search panel ----------------------------------

-- Internally, in nvim-spectre/init.lua, when first opening spectre, `open` stores buffer number in `state.bufnr` where `state` is `require('spectre.state')`. Use this buffer number for scripting so that the same spectre buffer is re-used without opening new ones, which is the default behaviour. TODO See if issue is resolve.
local SpectreState = require('spectre.state')
-- Toggle without focus because focus is done by Spectre's API
function toggle_spectre(focus)  -- TODO Escape visual mode
    close_placeholder_win()
    toggle_buf_right_most(SpectreState.bufnr, focus)
end

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

-- Start in normal mode so that, when toggle open search panel from other buffers like terminal, normal mode navigation is available straightaway.
vimp.nnoremap('<m-8>', function() toggle_spectre(true) end)
vimp.inoremap('<m-8>', function()
    toggle_spectre(true)
    vim.cmd('stopinsert')
    setup_spectre()
end)
vimp.tnoremap('<m-8>', '<cmd>lua toggle_spectre(true)<CR>')  -- TODO When lua function call is supported by vimpeccable, use lua function call and add back `local` to `toggle_spectre` above. Temporary workaround by exporting `toggle_spectre` to global environment.


-- Current file: Open/word-under-cursor/selection
vimp.nnoremap('<m-f>',   function()
    toggle_spectre(false)
    Spectre.open_file_search()
    setup_spectre()
end)
vimp.nnoremap('<m-s-f>', function()
    toggle_spectre(false)
    Spectre.open_file_search({select_word = true})
    setup_spectre()
end)
vimp.vnoremap('<m-f>', function()
    toggle_spectre(false)
    Spectre.open_visual({path = fn.expand('%')})
    setup_spectre()
end)

-- Current directory: Open/word-under-cursor/selection AHKREMAP
vimp.nnoremap('<m-s>', function()
    toggle_spectre(false)
    Spectre.open()
    setup_spectre()
end)
vimp.nnoremap('<m-S>', function()
    toggle_spectre(false)
    Spectre.open_visual({select_word = true})
    setup_spectre()
end)
vimp.vnoremap('<m-s>', function()
    toggle_spectre(false)
    Spectre.open_visual()
    setup_spectre()
end)


-- Aerial ---------------------------------------

function toggle_outline()
    close_all_term_wins()
    close_placeholder_win()
    aerial.toggle()
end

-- Toggle outline with <m-s-2>
vimp.nnoremap('<m-@>', function() toggle_outline() end)
vimp.inoremap('<m-@>', function()
    vim.cmd('stopinsert')
    toggle_outline()
end)
vimp.tnoremap('<m-@>', '<cmd>lua toggle_outline()<CR>')  -- TODO When lua function call is supported by vimpeccable, use lua function call and add back `local` to `toggle_outline` above. Temporary workaround by exporting `toggle_outline` to global environment.
