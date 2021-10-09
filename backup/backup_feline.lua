-- This is working. Terminal buffer behaves like normal text buffer.

local co = require('minimalist.colors')

local lsp = require('feline.providers.lsp')
local Feline = require('feline')
local DevIcons = require("nvim-web-devicons")

local get_unique_filename = require('helpers.helpers_feline').get_unique_filename

local fn = vim.fn

local properties = {  -- Init
    force_inactive = {
        filetypes = {},
        buftypes  = {},
        bufnames  = {}
    }
}

local components = {  -- Init
    left  = {active = {}, inactive = {}},
    mid   = {active = {}, inactive = {}},
    right = {active = {}, inactive = {}},
}

properties.force_inactive.filetypes = {
    'NvimTree', 'dbui', 'packer'
}

local vertical_bar = '▎'


-- Helpers ---------------------------------------

-- For window number (e.g. for Neomux), see [How to get Win num status in other statusline? · Issue #11 · nikvdp/neomux](https://github.com/nikvdp/neomux/issues/11)

-- Hacky workaround to hide inactive non-editor buffer (e.g. NvimTree). NOTE It's set for both active and inactive buffers so that when switching between active and inactive buffers, all statusline items are the same.
-- NOTE LSP providers are not needed due to NvimTree and terminal don't have these items.

-- TODO Optimize all e.g. combine is_term and is_special_buf since they both use `vim.fn.expand`
local function is_term()
    if fn.stridx(fn.expand('%'), 'term') == 0 then
        return true
    else
        return false
    end
end

-- This plugin only differentiates between active and inactive buffers. To completely hide some buffers like NvimTree, while styleing active and inactive buffers accordingly, use this helper to completely disable status line.
local function not_special_buf()
    if fn.expand('%:t') == 'NvimTree' or fn.expand('%:t') == 'term_placeholder' then
        return false
    else
        return true
    end
end

local function termFileExt(file)
    if fn.stridx(file, 'radian') > 0 then
        return 'R'
    elseif fn.stridx(file, 'julia') > 0 then
        return 'jl'
    else
        return 'zsh'
    end
end

local function fileIcon_provider()
    term_title, ext = vim.b.term_title, fn.expand('%:e')

    if is_term() then
        return DevIcons.get_icon(term_title, termFileExt(term_title), {default=true})
    else  -- Text buffer
        return DevIcons.get_icon(term_title, ext, {default=true})
    end
end

local function fileIconColor()  -- TODO Not working. Temporarily use same color
    file, ext = fn.expand('%:t'), fn.expand('%:e')
    bg = co.slightly_lighter_bg
    color_R      = {co.DevIconR, bg}
    color_julia  = {co.DevIconJulia, bg}
    color_others = {co.DevIconOthers, bg}

    if is_term() then
        if fn.stridx(file, 'radian') > 0 then
            return color_R
        elseif fn.stridx(file, 'julia') > 0 then
            return color_julia
        else
            return color_others
        end
    else  -- Text buffer
        if fn.stridx(ext, 'R') == 0 then
            return color_R
        elseif fn.stridx(ext, 'jl') == -1 then
            return color_julia
        else
            return color_others
        end
    end
end

local function fileName_provider()
    term_title = vim.b.term_title

    if is_term() then
        if fn.stridx(term_title, 'radian') > 0 then
            return 'R'
        elseif fn.stridx(term_title, 'julia') > 0 then
            return 'Julia'
        else
            return 'Shell'
        end
    else  -- Text buffer
        return get_unique_filename(fn.expand('%:p'))
    end
end

local function fileIsReadOnly_provider()
    if is_term() then
        return ''
    else
        if vim.bo.readonly then
            return ""
        else
            return ''
        end
    end
end

local function currentLine_provider()
    return string.format("%3d", fn.line('.'))
end

local function totalLine_provider()
    return string.format("%3d", fn.line('$'))
end


-- Active components -----------------------------

-- _ Left ----------------------------------------

components.left.active[1] = {  -- Left most separator
    provider = vertical_bar,
    hl = {fg = co.standout},
}

components.left.active[2] = {
    provider = fileIcon_provider,
    hl = {fg = co.bg_3},
    right_sep = ' ',
}

components.left.active[3] = {
    provider = fileName_provider,
    hl = {fg = co.standout},
    right_sep = ' ',
}

components.left.active[4] = {
    provider = fileIsReadOnly_provider,
    hl = {fg = co.standout_more},
    right_sep = ' ',
}


-- _ Right ---------------------------------------

components.right.active[1] = {
    provider = 'diagnostic_errors',
    icon = "  ",
    enabled = function() return lsp.diagnostics_exist('Error') end,
    hl = {fg = co.standout_special_1},
}

components.right.active[2] = {
    provider = 'diagnostic_warnings',
    icon = "  ",
    enabled = function() return lsp.diagnostics_exist('Warning') end,
    hl = {fg = co.standout_special_1},
}

components.right.active[3] = {
    provider = 'diagnostic_info',
    icon = "  ",
    enabled = function() return lsp.diagnostics_exist('Information') end,
    hl = {fg = co.bg_3},
}

components.right.active[4] = {
    provider = 'diagnostic_hints',
    icon = "  ",
    enabled = function() return lsp.diagnostics_exist('Hint') end,
    hl = {fg = co.bg_3},
}

components.right.active[5] = {
    provider = currentLine_provider,
    hl = {fg = co.bg_3},
    left_sep = '    ',
    right_sep = {str = ', ',
                 hl = {fg = co.bg_1}}
}

components.right.active[6] = {
    provider = totalLine_provider,
    hl = {fg = co.bg_3, style = 'bold'},
}


-- Inactive components ---------------------------

-- _ Left ----------------------------------------

components.left.inactive[1] = {  -- Left most separator
    provider = ' ',
    enabled = not_special_buf,
    hl = {fg = co.standout}
}

components.left.inactive[2] = {
    provider = fileIcon_provider,
    enabled = not_special_buf,
    right_sep = ' ',
    hl = {fg = co.bg_3}
}


components.left.inactive[3] = {
    provider = fileName_provider,
    enabled = not_special_buf,
    right_sep = ' ',
}

components.left.inactive[4] = {
    provider = fileIsReadOnly_provider,  -- Show for all buf
    hl = {fg = co.standout_more},
    right_sep = ' ',
}


-- Run -------------------------------------------

Feline.setup({  -- This must be called at the last
    default_fg = co.standout_special_1,
    default_bg = co.slightly_lighter_bg,
    separators = { vertical_bar = '▎' },
    properties = properties, components = components
})
