-- TODO This [feat(generator): add new components table format #51](https://github.com/famiu/feline.nvim/pull/51) is big breaking change.
-- Inactive components not working. It seems to 'copy' active components, regardless of whether `enabled` is true/false.
-- See backup/backup_feline_breaking_chg.lua for an attempt to address the breaking change, where most of them are done except the inactive components as mentioned.

-- Currently using my custom branch kar9222/feline.nvim which revert to this commit:
-- a5bf10d79592e8d26f54381f5a7f5ee747defbae: Fix highlight background for `file_info`

-- -----------------------------------------------


-- NOTE Providers must evaluate to string. Some info accessed are numbers, such as buffer ID of some plugins. Conversion is necessary.
-- TODO Use conditional `enable` to hide unused provider?

local co = require('minimalist.colors')

local lsp = require('feline.providers.lsp')
local feline = require('feline')
local devicons = require("nvim-web-devicons")

local get_unique_filename = require('helpers.helpers_feline').get_unique_filename

local fn  = vim.fn
local api = vim.api

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
    'packer', 'NvimTree', 'Outline',  -- 'dbui',
}

local vertical_bar = '▎'


-- Helpers ---------------------------------------

-- For window number (e.g. for Neomux), see [How to get Win num status in other statusline? · Issue #11 · nikvdp/neomux](https://github.com/nikvdp/neomux/issues/11)

-- Hacky workaround to hide inactive non-editor buffer (e.g. NvimTree). NOTE It's set for both active and inactive buffers so that when switching between active and inactive buffers, all statusline items are the same.
-- NOTE LSP providers are not needed due to NvimTree and terminal don't have these items.

-- TODO Optimize all e.g. combine is_term and is_special_buf since they both use `vim.fn.expand`
local function is_term()
    if string.match(fn.expand('%'), 'term') then
        return true
    else
        return false
    end
end

local function not_term()
    return not is_term()
end

-- This plugin only differentiates between active and inactive buffers. To completely hide some buffers like NvimTree, while styleing active and inactive buffers accordingly, use this helper to completely disable status line.
local function not_special_buf()
    file = fn.expand('%:t')
    if file == '[packer]' or file == 'NvimTree' or file == 'OUTLINE' or file == 'placeholder' then
        return false
    else
        return true
    end
end

local function not_term_not_special()
    return not_term() and not_special_buf()
end

-- feline uses autocommand BufLeave/WinLeave/etc for constructing status line. Disable when no terminal is open and when specified terminal hasn't been opened.
local function is_term_and_exist(neoterm_id)
    term_exist = false
    n_term = fn.len(vim.g.neoterm.instances)  -- 0 if no term is open

    if n_term < tonumber(neoterm_id) then
        term_exist = false
    else
        term_exist = true
    end

    return is_term() and term_exist
end

local function termFileExt(file)
    if string.match(file, 'radian') then
        return 'R'
    elseif string.match(file, 'julia') then
        return 'jl'
    else
        return 'zsh'
    end
end

local function get_icon(filename, extension, opts)  -- Without highlight group
    icon, hl_group = devicons.get_icon(filename, extension, opts)
    return icon
end

local function fileIcon_provider()
    term_title, ext = vim.b.term_title, fn.expand('%:e')

    if is_term() then
        return get_icon(term_title, termFileExt(term_title), {default=true})
    else  -- Text buffer
        return get_icon(term_title, ext, {default=true})
    end
end

local function fileIconColor()  -- TODO Not working. Temporarily use same color
    file, ext = fn.expand('%:t'), fn.expand('%:e')
    bg = co.slightly_lighter_bg
    color_R      = {co.DevIconR, bg}
    color_julia  = {co.DevIconJulia, bg}
    color_others = {co.DevIconOthers, bg}

    if is_term() then
        if string.match(file, 'radian') then
            return color_R
        elseif string.match(file, 'julia') then
            return color_julia
        else
            return color_others
        end
    else  -- Text buffer
        if string.match(ext, 'R') then
            return color_R
        elseif string.match(ext, 'jl') then
            return color_julia
        else
            return color_others
        end
    end
end

local function normalFilename_provider()
    return get_unique_filename(fn.expand('%:p'))
end

local function fileIsReadOnly_provider()
    if vim.bo.readonly then
        return ""
    else
        return ''
    end
end

local function currentLine_provider()
    return string.format("%3d", fn.line('.'))
end

local function totalLine_provider()
    return string.format("%3d", fn.line('$'))
end

-- Terminal provider for both active and inactive buffers. One component for each neoterm instance. NOTE terminal buffers not opened with neoterm instance (e.g. via `:term` or other plugin) are not included.
-- @param neoterm_id (string) Unique ID of neoterm instance
local function term_provider(neoterm_id)
    buf_id = tostring(vim.g.neoterm.instances[neoterm_id].buffer_id)
    term_title = api.nvim_buf_get_var(buf_id, 'term_title')

    if string.match(term_title, 'radian') then
        return 'R'
    elseif string.match(term_title, 'julia') then
        return 'Julia'
    else
        return 'Shell'
    end
end

local function term_color(neoterm_id)
    if neoterm_id == tostring(vim.g.neoterm.last_active) then
        return {fg = co.standout}
    else
        return {fg = co.bg_2}
    end
end


-- Left components -------------------------------

-- Left components are slightly different for both active and inactive components. 'Not special' is handled by `properties`.

-- _ All except terminal and special buffers -----

-- ___ Active components -------------------------

table.insert(components.left.active, {  -- Left most separator
    provider = vertical_bar,
    enabled = not_term,
    hl = {fg = co.standout},
})

table.insert(components.left.active, {
    provider = fileIcon_provider,
    enabled = not_term,
    hl = {fg = co.bg_3},
    right_sep = ' ',
})

table.insert(components.left.active, {
    provider = normalFilename_provider,
    enabled = not_term,
    hl = {fg = co.standout},
    right_sep = ' ',
})

table.insert(components.left.active, {
    provider = fileIsReadOnly_provider,
    enabled = not_term,
    hl = {fg = co.standout_more},
})

-- ___ Inactive components -----------------------

-- As mentioned above, 'not special' is handled by `properties`

table.insert(components.left.inactive, {
    provider = fileIcon_provider,
    enabled = not_term_not_special,
    left_sep = ' ',  -- Left most separator. Placeholder for consistent starting position as active component's separator
    right_sep = ' ',
    hl = {fg = co.bg_3}
})

table.insert(components.left.inactive, {
    provider = normalFilename_provider,
    enabled = not_term_not_special,
    right_sep = ' ',
})

table.insert(components.left.inactive, {
    provider = fileIsReadOnly_provider,  -- Show for all buf
    enabled = not_term_not_special,
    hl = {fg = co.standout_more},
})



-- _ Terminal buffers ----------------------------

-- Active and inactive components for terminal buffers are the same.

-- Terminal components for both active and inactive buffers
-- @param neoterm_id (string) Unique ID of neoterm instance
local function term_components(neoterm_id, left_sep)
    return {
        provider = function() return term_provider(neoterm_id) end,
        enabled = function() return is_term_and_exist(neoterm_id) end,
        hl = function() return term_color(neoterm_id) end,
        left_sep = left_sep,
    }
end

-- Three whitespaces added for the 1st components (active and inactive) for spacing with buffers on the left.

table.insert(components.left.active, term_components('1', '   '))
table.insert(components.left.active, term_components('2', '  '))
table.insert(components.left.active, term_components('3', '  '))

table.insert(components.left.inactive, term_components('1', '   '))
table.insert(components.left.inactive, term_components('2', '  '))
table.insert(components.left.inactive, term_components('3', '  '))


-- Right components ------------------------------

-- Right components are only for active components

-- _ All except terminal and special buffers -----

local severity = vim.diagnostic.severity

table.insert(components.right.active, {
    provider = 'diagnostic_errors',
    icon = "  ",
    enabled = function() return lsp.diagnostics_exist(severity.ERROR) end,
    hl = {fg = co.standout_special_1},
})

table.insert(components.right.active, {
    provider = 'diagnostic_warnings',
    icon = "  ",
    enabled = function() return lsp.diagnostics_exist(severity.WARN) end,
    hl = {fg = co.standout_special_1},
})

table.insert(components.right.active, {
    provider = 'diagnostic_info',
    icon = "  ",
    enabled = function() return lsp.diagnostics_exist(severity.INFO) end,
    hl = {fg = co.bg_3},
})

table.insert(components.right.active, {
    provider = 'diagnostic_hints',
    icon = "  ",
    enabled = function() return lsp.diagnostics_exist(severity.HINT) end,
    hl = {fg = co.bg_3},
})


-- _ All except special buffers ------------------

table.insert(components.right.active, {
    provider = currentLine_provider,
    hl = {fg = co.bg_3},
    left_sep = '    ',
    right_sep = {str = ', ',
                 hl = {fg = co.bg_1}}
})

table.insert(components.right.active, {
    provider = totalLine_provider,
    hl = {fg = co.bg_3, style = 'bold'},
})




-- Run -------------------------------------------

feline.setup({  -- This must be called at the last
    default_fg = co.standout_special_1,
    default_bg = co.slightly_lighter_bg,
    separators = { vertical_bar = '▎' },
    properties = properties, components = components
})
