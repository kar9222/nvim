-- TODO Custom keybinds
-- TODO Highlight all entries using Actions.get_all_entries

local spectre = require("spectre")
local actions = require('spectre.actions')

local vimp = require('vimp')
local api = vim.api
local fn = vim.fn

vim.cmd('au FileType spectre_panel setlocal nonumber cursorline')

-- Preview file, toggle preview ------------------

-- Extracted from the plugins and customize?
-- TODO Refactor all of these with objects like trouble.nvim, and make functions local and access
-- them via `require`.

vim.g.toggle_preview = 1

-- Store info when entering
function on_enter()
    _G.spectre_parent_win_id = fn.win_getid(fn.winnr('#'))  -- TODO Make it robust using autocmd
    _G.spectre_parent_buf_nr = api.nvim_win_get_buf(_G.spectre_parent_win_id)
    _G.spectre_parent_cursor = api.nvim_win_get_cursor(_G.spectre_parent_win_id)
end

-- Reset parent buffer, cursor, etc when leaving
function on_leave()
    local t = current_entry()  -- TODO return nothing if error?
    if t == nil then return end
    clear_hl(t.bufnr)

    api.nvim_win_set_buf(_G.spectre_parent_win_id, _G.spectre_parent_buf_nr)
    api.nvim_win_set_cursor(_G.spectre_parent_win_id, _G.spectre_parent_cursor)
end

local function get_is_buf_loaded(bufnr)
    if bufnr == -1 then  -- Buffer isn't loaded
        return false
    else
        if not api.nvim_buf_is_loaded(bufnr) then
            return false
        else
            return true
        end
    end
end

function current_entry()
    -- Return nothing when cursor isn't placed on item
    local status, t = pcall(actions.get_current_entry)
    if not status or t == nil then return nil end

    local bufnr = fn.bufnr(t.filename)
    local is_buf_loaded = get_is_buf_loaded(bufnr)
    return {
        bufnr = bufnr,
        is_buf_loaded = is_buf_loaded,
        -- spectre's API
        filename = t.filename,
        lnum = t.lnum,
        col = t.col
    }
end

-- Preview file without navigating to the buffer/window
-- - For active and hidden buffers, when it's no longer being previewed, do nothing to these buffers, that is, they remain active/hidden.
-- - For unloaded buffer, it's wiped when it's hidden.
function preview_file()
    local t = current_entry()
    if t == nil then return end
    local bufnr = t.bufnr
    local current_parent_bufnr = api.nvim_win_get_buf(_G.spectre_parent_win_id)

    if not t.is_buf_loaded then
        -- NOTE Instead of using fn.bufnr(..., true), unloaded buffer is explicitly created this way to have its own buffer-line for convenience/etc.
        vim.cmd('badd ' .. t.filename)
        bufnr = fn.bufnr(t.filename)
        api.nvim_win_set_buf(_G.spectre_parent_win_id, bufnr)
        api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
    end
    if bufnr ~= current_parent_bufnr then  -- Hidden buffer
        api.nvim_win_set_buf(_G.spectre_parent_win_id, bufnr)
    end
    -- Active buffer
    api.nvim_win_set_cursor(_G.spectre_parent_win_id, {t.lnum, t.col})
    -- Due to the way I configure my statusline, hacky way to show file name of 'inactive' previewed buffer by setting file name of 'active' spectre buffer.
    pcall(set_preview_bufname, bufnr)  -- TODO Hacky way to HOTFIX `open_file_search` (current file) for preview file name

    api.nvim_buf_call(bufnr, function()  -- TODO What is this?
        -- Center preview line on screen and open enough folds to show it
        vim.cmd('norm! zz zv')
        if api.nvim_buf_get_option(bufnr, 'filetype') == '' then
            vim.cmd('do BufRead')
        end
    end)
    highlight_range(t.lnum, t.lnum, 1, 0, 'V', 0, bufnr, 'no_timeout')
end

function preview_next_prev(direction)
    local dir
    if direction == 'prev' then
        dir = 'k'
    else
        dir = 'j'
    end
    vim.cmd('norm! ' .. dir)
    if vim.g.toggle_preview == 1 then preview_file() end
end

function toggle_preview()
    local t = current_entry()
    if t == nil then return end

    if vim.g.toggle_preview == 1 then
        clear_hl(t.bufnr)
        vim.g.toggle_preview = 0
    else
        vim.g.toggle_preview = 1
    end
end

function set_preview_bufname(bufnr)
    api.nvim_buf_set_name(0, fn.bufname(bufnr) .. ' ') 
end


-- Setup -----------------------------------------

require('spectre').setup({
    open_cmd = 'botright vnew',
    replace_vim_cmd = "cdo",
    live_update = true, -- auto execute search again when you write to any file in vim
    is_open_target_win = true, --open file on opener window
    is_insert_mode = true,  -- start open panel on is_insert_mode
    lnum_for_results = false, -- show line number for search/replace results

    -- Remove all borders
    line_sep_start = '',
    result_padding = '    ',
    line_sep       = '',

    color_devicons = true,
    highlight = {
        ui            = "SpectreUI",
        filename      = "SpectreFileName",
        filedirectory = "SpectreFileDirectory",
        search        = "SpectreSearch",
        replace       = "SpectreReplace",
        border        = "SpectreBorder",
    },
    mapping={
      -- Toggle preview, preview, open file
      ['preview_file'] = {
          map = 'p',
          cmd = '<cmd>lua preview_file()<CR>',
          desc = 'preview'
      },
      ['toggle_preview'] = {
          map = 'P',
          cmd = '<cmd>lua toggle_preview()<CR>',
          desc = 'toggle preview'
      },
      ['preview_prev'] = {  -- TODO
          map = 'k',
          cmd = '<cmd>lua preview_next_prev("prev")<CR>',
          desc = 'preview previous'
      },
      ['preview_next'] = {  -- TODO
          map = 'j',
          cmd = '<cmd>lua preview_next_prev("next")<CR>',
          desc = 'preview next'
      },
      ['enter_file'] = {  -- TODO Optimize `zz` for smoother experience
          map = "<tab>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>zz",
          desc = "go to current file"
      },
      ['enter_file_2'] = {
          map = "<CR>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>zz",
          desc = "go to current file"
      },

      -- Navigate to prev/next field
      ['go_to_prev_field'] = {
          map = "gk",
          cmd = "<cmd>lua require('spectre').tab_shift()<CR>",
          desc = "go to prev field"
      },
      ['go_to_next_field'] = {
          map = "gj",
          cmd = "<cmd>lua require('spectre').tab()<CR>",
          desc = "go to next field"
      },

      -- Navigate to first-item/search/replace/path
      ['go_to_first_item_and_preview'] = {
          map = 'J',
          cmd = '<cmd>call nvim_win_set_cursor(0, [12, 0]) | lua preview_file()<CR>',
          desc = 'go to first item and preview'
      },
      ['go_to_search'] = {
          map = 'gs',
          cmd = '<cmd>call nvim_win_set_cursor(0, [3, len(getline(3))])<CR>',
          desc = 'go to search'
      },
      ['go_to_replace'] = {
          map = 'gr',
          cmd = '<cmd>call nvim_win_set_cursor(0, [5, len(getline(5))])<CR>',
          desc = 'go to replace'
      },
      ['go_to_path'] = {
          map = 'gp',
          cmd = '<cmd>call nvim_win_set_cursor(0, [7, len(getline(7))])<CR>',
          desc = 'go to path'
      },

      ['toggle_line'] = {
          map = "dd",
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = "toggle current item"
      },
      ['send_to_qf'] = {
          map = "<leader>q",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all item to quickfix"
      },
      ['replace_cmd'] = {
          map = "<leader>c",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace vim command"
      },
      ['show_option_menu'] = {
          map = "<leader>o",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show option"
      },
      ['run_replace'] = {
          map = "<leader>R",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all"
      },
      ['change_view_mode'] = {
          map = "<leader>v",
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = "change result view mode"
      },
      ['toggle_ignore_case'] = {
        map = "ti",
        cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
        desc = "toggle ignore case"
      },
      ['toggle_regex'] = {  -- TODO
        map = "tr",
        cmd = "<cmd>lua require('spectre').change_options('regex')<CR>",
        desc = "toggle regex"
      },
      ['toggle_ignore_hidden'] = {
        map = "th",
        cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
        desc = "toggle search hidden"
      },
    ['resume_last_search'] = {
        map = "<leader>l",
        cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
        desc = "resume last search before close"
      },
      -- you can put your mapping here it only use normal mode
    },
    find_engine = {
      ['rg'] = {  -- rg is map with finder_cmd
        cmd = "rg",
        args = {  -- default args
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        } ,
        options = {
          ['ignore-case'] = {
            value= "--ignore-case",
            icon="[I]",
            desc="ignore case"
          },
          ['regex'] = {  -- TODO
            value= "--regexp",
            icon="[R]",
            desc="regex"
          },
          ['hidden'] = {
            value="--hidden",
            desc="hidden file",
            icon="[H]"
          },
          -- you can put any option you want here it can toggle with
          -- show_option function
        }
      },
    },
    replace_engine={
        ['sed']={
            cmd = "sed",
            args = nil
        },
        options = {
          ['ignore-case'] = {
            value= "--ignore-case",
            icon="[I]",
            desc="ignore case"
          },
        }
    },
    default = {
        find = {  --pick one of item in find_engine
            cmd = "rg",
            options = {"ignore-case"}
        },
        replace={  --pick one of item in replace_engine
            cmd = "sed"
        }
    },
})





-- spectre's API --------------------------------

-- See select_entry of actions.lua
--[[ actions.open_file(t.filename, t.lnum, t.col)

-- Get items on cursor
actions.get_current_entry().filename
actions.get_all_entries()[1].filename
actions.get_all_entries()[2].filename

-- State. See state.lua
actions.get_state().query.search_query
actions.get_state().query.replace_query
actions.get_state().query.path
actions.get_state().query.is_file
-- ...
]]


