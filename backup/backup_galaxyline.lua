-- Backup for using Tmux in Neovim terminal buffer


local co = require('minimalist.colors')

local GalaxyLine = require("galaxyline")

local Condition = require("galaxyline.condition")
local Section = GalaxyLine.section

local Buffer = require("galaxyline.provider_buffer")
local FileInfo = require("galaxyline.provider_fileinfo")
local Extension = require("galaxyline.provider_extensions")
local Whitespace = require("galaxyline.provider_whitespace")
-- the galaxyline icon providers are FUBAR, so we need this
local DevIcons = require("nvim-web-devicons")
local LuapadInfo = require("luapad.statusline")

-- Short line for special buffer types. Specify these without any styles to disable them. (NOTE As a result of 'Hacky providers', this is not needed because, without specifying short_line_list, it applies to all the buffers, including inactive buffers.)
-- GalaxyLine.short_line_list = {"NvimTree", "packer", "dbui", "term", "toggleterm"}


-- Hack providers --------------------------------

-- Hacky workaround to hide inactive non-editor buffer (e.g. NvimTree and terminal buffer). NOTE It's set for both active and inactive buffers so that when switching between active and inactive buffers, all statusline items are the same.
-- NOTE LSP providers are not needed due to NvimTree and terminal don't have these items.

local function is_active_buf()
    local file = vim.fn.expand('%:t')
    local is_tmux = vim.fn.stridx(file, 'tmux') > 0

    if file == 'NvimTree' or is_tmux then
        return false
    else
        return true
    end
end


local function leftMostSeparator_provider()
    if is_active_buf() then
        return '▎'
    else
        return ''
    end
end

local function fileIcon_provider()
    if is_active_buf() then
        n, e = vim.fn.expand("%:t"), vim.fn.expand("%:e")
        return DevIcons.get_icon(n, e, {default=true})
    else
        return ''
    end
end

local function fileName_provider()
    if is_active_buf() then
        return vim.fn.expand('%:t')
    else
        return ''
    end
end

local function fileIsReadOnly_provider()
    if is_active_buf() then
        if vim.bo.readonly then return "" end
        return " "
    else
        return ''
    end
end

local function lineInfo_provider()
    if is_active_buf() then
        local n = vim.fn.line("$")
        return string.format("⌊%3d ", n)
    else
        return ''
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

table.insert(Section.left, {
    LeftMostSeparator = {
        provider = leftMostSeparator_provider,
        highlight = {co.standout, co.slightly_lighter_bg},
    }
})

table.insert(Section.left, {
    FileIcon = {
        provider = fileIcon_provider,
        separator = ' ',
        highlight = {co.bg_3, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(Section.left, {
    FileName = {
        provider = fileName_provider,
        separator = ' ',
        highlight = {co.standout_special_1, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(Section.left, {
    FileIsReadOnly = {
        provider = fileIsReadOnly_provider,
        separator = " ",
        highlight = {co.standout_more, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(Section.right, {
    DiagnosticError = {
        provider = "DiagnosticError",
        icon = "  ",
        highlight = {co.standout, co.slightly_lighter_bg},
    },
})
table.insert(Section.right, {
    DiagnosticWarn = {
        provider = "DiagnosticWarn",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(Section.right, {
    DiagnosticInfo = {
        provider = "DiagnosticInfo",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(Section.right, {
    DiagnosticHint = {
        provider = "DiagnosticHint",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(Section.right, {
    ShowLspClient = {
        provider = getlspclient,
        condition = lspcondition,
        icon = " ",
        separator = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(Section.right, {
    LineInfo = {
        provider = lineInfo_provider,
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})


-- Inactive buffer -------------------------------

table.insert(Section.short_line_left, {
    LeftMostSeparator = {
        provider = leftMostSeparator_provider,
        highlight = {co.standout, co.slightly_lighter_bg},
    }
})

table.insert(Section.short_line_left, {
    FileIcon = {
        provider = fileIcon_provider,
        separator = ' ',
        highlight = {co.bg_3, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(Section.short_line_left, {
    FileName = {
        provider = fileName_provider,
        separator = ' ',
        highlight = {co.standout_special_1, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(Section.short_line_left, {
    FileIsReadOnly = {
        provider = fileIsReadOnly_provider,
        separator = " ",
        highlight = {co.standout_more, co.slightly_lighter_bg},
        separator_highlight = {co.dark_bg_1, co.slightly_lighter_bg},
    },
})

table.insert(Section.short_line_right, {
    DiagnosticError = {
        provider = "DiagnosticError",
        icon = "  ",
        highlight = {co.standout, co.slightly_lighter_bg},
    },
})
table.insert(Section.short_line_right, {
    DiagnosticWarn = {
        provider = "DiagnosticWarn",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(Section.short_line_right, {
    DiagnosticInfo = {
        provider = "DiagnosticInfo",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(Section.short_line_right, {
    DiagnosticHint = {
        provider = "DiagnosticHint",
        icon = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(Section.short_line_right, {
    ShowLspClient = {
        provider = getlspclient,
        condition = lspcondition,
        icon = " ",
        separator = "  ",
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})

table.insert(Section.short_line_right, {
    LineInfo = {
        provider = lineInfo_provider,
        highlight = {co.bg_3, co.slightly_lighter_bg},
    },
})
