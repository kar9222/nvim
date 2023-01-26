local bufferline = require("bufferline")
local colors = require('minimalist.colors')

local vimp = require('vimp')

bufferline.setup({  -- TODO custom_areas
    options = {
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        -- NOTE: this plugin is designed with this icon in mind,
        -- and so changing this is NOT recommended, this is intended
        -- as an escape hatch for people who cannot bear it for whatever reason
        indicator = {
            icon = '▎', -- this should be omitted if indicator style is not 'icon'
            style = 'icon', -- | 'underline' | 'none',
        },
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        --- name_formatter can be used to change the buffer's label in the bufferline.
        --- Please note some names can/will break the
        --- bufferline so use this at your discretion knowing that it has
        --- some limitations that will *NOT* be fixed.
        name_formatter = function(buf)  -- buf contains a "name", "path" and "bufnr"
            -- remove extension from markdown files for example
            if buf.name:match('%.md') then
                return vim.fn.fnamemodify(buf.name, ':t:r')
            end
        end,
        max_name_length = 18,
        max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
        tab_size = 18,
        diagnostics = false,  -- NOTE can do "nvim_lsp"
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            return "("..count..")"
        end,
        -- NOTE: this will be called a lot so don't do any heavy processing here
        -- TODO may want to set some of these
        -- custom_filter = function(buf_number)
        --     -- Filter out terminal TODO https://github.com/akinsho/nvim-bufferline.lua/issues/176
        --     if vim.bo[buf_number].filetype ~= "neoterm" then return true end
        --     if vim.bo[buf_number].filetype ~= "qf" then return true end

        --     -- filter out filetypes you don't want to see
        --     if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
        --         return true
        --     end
        --     -- filter out by buffer name
        --     if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
        --         return true
        --     end
        --     -- filter out based on arbitrary rules
        --     -- e.g. filter out vim wiki buffer from tabline in your work repo
        --     if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
        --         return true
        --     end
        -- end,
        offsets = {{filetype = "NvimTree", text = ""}},
        show_buffer_icons = true, -- disable filetype icons for buffers
        show_buffer_close_icons = false,
        show_close_icon = false,
        show_tab_indicators = true,
        persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
        -- can also be a table containing 2 custom separators
        -- [focused and unfocused]. eg: { '|', '|' }
        separator_style = {'', ''},
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        sort_by = "id",  -- TODO
    },
    highlights = {
        fill = {
            bg = colors.bg,
        },
        background = {
            fg = colors.standout_less,
            bg = colors.bg,
        },
        buffer_visible = {
            fg = colors.bright_bg_1,
            bg = colors.bg,
        },
        buffer_selected = {
            fg = colors.standout,
            bold = false,
            italic = false,
        },
        pick = {
            fg = colors.standout_more,
            bg = colors.bg,
            bold = true,
            italic = false,
        },
        pick_visible = {
            fg = colors.standout_more,
            bg = colors.bg,
            bold = true,
            italic = false,
        },
        pick_selected = {
            fg = colors.bg,  -- Hacky way to 'disable' it
            bg = colors.bg,
            bold = true,
            italic = false,
        },
        duplicate = {
            fg = colors.bg_2,
            bg = colors.bg,
        },
        duplicate_visible = {
            fg = colors.bg_2,
            bg = colors.bg,
        },
        duplicate_selected = {
            fg = colors.bg_2,
            bg = colors.bg,
        },

        tab = {
            fg = colors.bg_2,
            bg = colors.bg,
        },
        tab_selected = {
            fg = colors.standout,
        },
        -- For tab
        separator = {  -- Disable using `bg`
            fg = colors.bg,
            bg = colors.bg,
        },
        separator_selected = {
            fg = colors.standout,
        },
    }
})

local function temporal_compare(buf1, buf2)
    local t1 = vim.loop.fs_stat(buf1.path).mtime.sec
    local t2 = vim.loop.fs_stat(buf2.path).mtime.sec
    return t1 > t2
end

vimp.nnoremap('<m-q>', function() bufferline.cycle(-1)  end)
vimp.nnoremap('<m-w>', function() bufferline.cycle(1) end)
vimp.inoremap('<m-q>', function() bufferline.cycle(-1)  end)  -- TODO esc
vimp.inoremap('<m-w>', function() bufferline.cycle(1) end)  -- TODO esc

-- AHKREMAP
vimp.nnoremap('<c-m-s-left>', function() bufferline.move(-1) end)
vimp.nnoremap('<c-m-s-right>', function() bufferline.move(1) end)
vimp.inoremap('<c-m-s-left>', function() bufferline.move(-1) end)  -- TODO esc
vimp.inoremap('<c-m-s-right>', function() bufferline.move(1) end)  -- TODO esc

-- vimp.nnoremap('gn', )  -- TODO

-- TODO Unregister commonly used commands here e.g. g1, g2, ...
whichkey.register({
    name = "manage buffers and tabs",
    [","] = {function() return bufferline.close_in_direction("left") end, "close all buffers to the left"},
    ["."] = {function() return bufferline.close_in_direction("right") end, "close all buffers to the right"},
    ["1"] = {function() return bufferline.go_to_buffer(1) end, "go to buffer 1"},
    ["2"] = {function() return bufferline.go_to_buffer(2) end, "go to buffer 2"},
    ["3"] = {function() return bufferline.go_to_buffer(3) end, "go to buffer 3"},
    ["4"] = {function() return bufferline.go_to_buffer(4) end, "go to buffer 4"},
    ["5"] = {function() return bufferline.go_to_buffer(5) end, "go to buffer 5"},
    ["6"] = {function() return bufferline.go_to_buffer(6) end, "go to buffer 6"},
    ["7"] = {function() return bufferline.go_to_buffer(7) end, "go to buffer 7"},
    ["8"] = {function() return bufferline.go_to_buffer(8) end, "go to buffer 8"},
    ["9"] = {function() return bufferline.go_to_buffer(9) end, "go to buffer 9"},  -- TODO go to last buffer
}, {prefix="g"})

vimp.nnoremap('<leader>i', '<cmd>BufferLinePick<CR>')

whichkey.register({
    name = "manage buffers and tabs",
    d = {function() return bufferline.close_buffer_with_pick() end, "pick buffer to close"},
    e = {function() return bufferline.sort_buffers_by("extension") end, "sort buffers by extension"},
    s = {function() return bufferline.sort_buffers_by("directory") end, "sort buffers by directory"},
    t = {function() return bufferline.sort_buffers_by(temporal_compare) end, "sort buffers by last modified"},
    T = {function() return bufferline.sort_buffers_by("tabs") end, "sort buffers by tabs"},
    -- x = {function() return vim.cmd("bd") end, "close current buffer"},
}, {prefix = "<leader>Q"})
