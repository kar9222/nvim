local co = require('minimalist.colors')

local galaxyline = require("galaxyline")

local condition = require("galaxyline.condition")
local section = galaxyline.section

local buffer = require("galaxyline.provider_buffer")
local fileinfo = require("galaxyline.provider_fileinfo")
local extension = require("galaxyline.provider_extensions")
local whitespace = require("galaxyline.provider_whitespace")
-- the galaxyline icon providers are FUBAR, so we need this
local devicons = require("nvim-web-devicons")
local luapad_info = require("luapad.statusline")

-- Short line for special buffer types. Specify these without any styles to disable them. (NOTE As a result of 'Hacky providers', this is not needed because, without specifying short_line_list, it applies to all the buffers, including inactive buffers.)
-- galaxyline.short_line_list = {"NvimTree", "packer", "dbui", "term", "toggleterm"}


-- Hack providers --------------------------------

-- For window number (e.g. for Neomux), see [How to get Win num status in other statusline? · Issue #11 · nikvdp/neomux](https://github.com/nikvdp/neomux/issues/11)

-- Hacky workaround to hide inactive non-editor buffer (e.g. NvimTree). NOTE It's set for both active and inactive buffers so that when switching between active and inactive buffers, all statusline items are the same.
-- NOTE LSP providers are not needed due to NvimTree and terminal don't have these items.

-- TODO Optimize all e.g. combine is_term and is_special_buf since they both use `vim.fn.expand`
local function is_term()
    if vim.fn.stridx(vim.fn.expand('%'), 'term') == 0 then
        return true
    else
        return false
    end
end

local function is_special_buf()
    if vim.fn.expand('%:t') == 'NvimTree' then
        return true
    else
        return false
    end
end

local function leftMostSeparator_provider()
    if is_special_buf() then
        return ''
    else
        return '▎'
    end
end

local function termFileExt(file)
    if vim.fn.stridx(file, 'radian') > 0 then
        return 'R'
    elseif vim.fn.stridx(file, 'julia') > 0 then
        return 'jl'
    else
        return 'zsh'
    end
end

local function fileIcon_provider()
    file, ext = vim.fn.expand('%:t'), vim.fn.expand('%:e')

    if is_special_buf() then
        return ''
    elseif is_term() then
        return devicons.get_icon(file, termFileExt(file), {default=true})
    else
        return devicons.get_icon(file, ext, {default=true})
    end
end

local function fileIconColor()  -- TODO Not working. Temporarily use same color
    file, ext = vim.fn.expand('%:t'), vim.fn.expand('%:e')
    bg = co.slightly_lighter_bg
    color_R      = {co.DevIconR, bg}
    color_julia  = {co.DevIconJulia, bg}
    color_others = {co.DevIconOthers, bg}

    if is_special_buf() then
        return color_others
    elseif is_term() then
        if vim.fn.stridx(file, 'radian') > 0 then
            return color_R
        elseif vim.fn.stridx(file, 'julia') > 0 then
            return color_julia
        else
            return color_others
        end
    else  -- Text buffer
        if vim.fn.stridx(ext, 'R') == 0 then
            return color_R
        elseif vim.fn.stridx(ext, 'jl') == -1 then
            return color_julia
        else
            return color_others
        end
    end
end

local function fileName_provider()
    file = vim.fn.expand('%:t')
    term_title = vim.b.term_title

    if is_special_buf() then
        return ''
    elseif is_term() then
        if vim.fn.stridx(term_title, 'radian') > 0 then
            return 'R'
        elseif vim.fn.stridx(term_title, 'julia') > 0 then
            return 'Julia'
        else
            return 'Shell'
        end
    else  -- Text buffer
        return file
    end
end

local function fileIsReadOnly_provider()
    if is_special_buf() or is_term() then
        return ''
    else
        if vim.bo.readonly then return "" end
    end
end

local function lineInfo_provider()
    local l = vim.fn.line('.')
    local n = vim.fn.line("$")

    if is_special_buf() then
        return ''
    elseif is_term() then
        return string.format("%3d/%3d ", l, n)
    else  -- Text buffer
        return string.format("⌊%3d ", n)
    end
end


-- LSP providers ---------------------------------

local function lspcondition()
    if not ENABLE_LSP then return false end
    if _G.LSP_FILETYPES[vim.bo.filetype] == nil then return false end
    return true
end

-- returns text listing LSP clients
function getlspclient(msg)
    msg = msg or "LSP inactive"
    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
        return "("..msg..")"
    end
    local lsps = ""
    for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            -- print(client.name)
            if lsps == "" then
                -- print("first", lsps)
                lsps = client.name
            else
                if not string.find(lsps, client.name) then
                    lsps = lsps .. ", " .. client.name
                end
                -- print("more", lsps)
            end
        end
    end
    if lsps == "" then
        return "("..msg..")"
    else
        return "("..lsps..")"
    end
end



-- Status line -----------------------------------

table.insert(section.left, {
    LeftMostSeparator = {
        provider = leftMostSeparator_provider,
        highlight = {co.standout, co.slightly_lighter_bg},
    }
})

table.insert(section.left, {
    FileIcon = {
        provider = fileIcon_provider,
        separator = ' ',
        highlight = {co.bg_3, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(section.left, {
    FileName = {
        provider = fileName_provider,
        separator = ' ',
        highlight = {co.standout_special_1, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(section.left, {
    FileIsReadOnly = {
        provider = fileIsReadOnly_provider,
        separator = " ",
        highlight = {co.standout_more, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(section.right, {
    DiagnosticError = {
        provider = "DiagnosticError",
        icon = "  ",
        highlight = {co.standout, co.slightly_lighter_bg},
    },
})
table.insert(section.right, {
    DiagnosticWarn = {
        provider = "DiagnosticWarn",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(section.right, {
    DiagnosticInfo = {
        provider = "DiagnosticInfo",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(section.right, {
    DiagnosticHint = {
        provider = "DiagnosticHint",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(section.right, {
    ShowLspClient = {
        provider = getlspclient,
        condition = lspcondition,
        icon = " ",
        separator = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(section.right, {
    LineInfo = {
        provider = lineInfo_provider,
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})


-- Inactive buffer -------------------------------

table.insert(section.short_line_left, {
    LeftMostSeparator = {
        provider = leftMostSeparator_provider,
        highlight = {co.standout, co.slightly_lighter_bg},
    }
})

table.insert(section.short_line_left, {
    FileIcon = {
        provider = fileIcon_provider,
        separator = ' ',
        highlight = {co.bg_3, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(section.short_line_left, {
    FileName = {
        provider = fileName_provider,
        separator = ' ',
        highlight = {co.standout_special_1, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(section.short_line_left, {
    FileIsReadOnly = {
        provider = fileIsReadOnly_provider,
        separator = " ",
        highlight = {co.standout_more, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(section.short_line_right, {
    DiagnosticError = {
        provider = "DiagnosticError",
        icon = "  ",
        highlight = {co.standout, co.slightly_lighter_bg},
    },
})
table.insert(section.short_line_right, {
    DiagnosticWarn = {
        provider = "DiagnosticWarn",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(section.short_line_right, {
    DiagnosticInfo = {
        provider = "DiagnosticInfo",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(section.short_line_right, {
    DiagnosticHint = {
        provider = "DiagnosticHint",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(section.short_line_right, {
    ShowLspClient = {
        provider = getlspclient,
        condition = lspcondition,
        icon = " ",
        separator = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(section.short_line_right, {
    LineInfo = {
        provider = lineInfo_provider,
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})
