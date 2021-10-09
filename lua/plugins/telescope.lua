-- TODO Check if desired default pickers are used e.g. fd, rg

local telescope = require("telescope")
local builtin = require('telescope.builtin')
local sorters = require("telescope/sorters")
local previewers = require("telescope/previewers")
local actions = require('telescope.actions')

local delta = require('helpers.delta')
local trouble = require('trouble.providers.telescope')

local fn = vim.fn

-- TODO make sure dotfiles can install bat

-- Path display in format: {file_basename} {file_dir}. It's also possible to query directory e.g. via `my_dir/ ...`
local function path_display(opts, path)  -- opts is required by telescope
    local dir = require('utils').dirname(path, false)  -- Keep trailing sep for query e.g. my_dir/
    if dir == nil then dir = '' end
    local tail = require('telescope.utils').path_tail(path)
    return string.format('%s   %s', tail, dir)
end

-- Find files/live grep in directory specified in terminal and sent to register `"`. Also see XXX.
-- NOTE Use `cwd` instead of `search_dirs` for better path name where `cwd` respects `path_display`.
-- NOTE These affects zshrc's bindings of `ff`, `aff` and `ge`
function find_files_custom_dir()
    builtin.find_files { cwd = fn.getreg('z') }
end
function find_files_hidden_custom_dir()
    builtin.find_files { cwd = fn.getreg('z'), hidden = true }
end
function find_files_hidden_ignore_custom_dir()
    builtin.find_files { cwd = fn.getreg('z'), hidden = true, no_ignore = true }
end
function live_grep_custom_dir()
    builtin.live_grep { cwd = fn.getreg('z') }
end

telescope.setup({
    defaults = {
        path_display = path_display,
        sorting_strategy = "ascending",
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
        },
        prompt_prefix = "❯ ",
        selection_caret = "❯",
        entry_prefix = " ",
        initial_mode = "insert",
        selection_strategy = "reset",
        layout_strategy = "horizontal",
        layout_config = {
            -- height = 0.9,
            -- width = 0.8,
            horizontal = {
                prompt_position = 'top',
                -- preview_width = vim.o.columns - 10,
                -- preview_cutoff = 120,
            },
            vertical = {
                height = vim.o.lines - 10,
                width = vim.o.columns - 40,
                preview_height = 30,
                -- preview_cutoff = 40
            },
            center = {
                preview_cutoff = 40
            },
            cursor = {
                preview_cutoff = 40
            },
        },
        file_sorter = sorters.get_fuzzy_file,  -- TODO Use fzf?
        file_ignore_patterns = {},
        generic_sorter = sorters.get_generic_fuzzy_sorter,
        winblend = 0,  -- TODO Does this affect performance?
        results_hight = 42,
        border = {},
        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        color_devicons = true,
        use_less = true,
        set_env = {['COLORTERM'] = 'truecolor'},
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,

        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = false, -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                                      -- the default case_mode is "smart_case"
          }
        },

        mappings = {
            i = {
                ['<m-k>'] = actions.move_selection_previous,  -- TODO What is this
                ['<m-j>'] = actions.move_selection_next,
                ['<f10>'] = actions.close,
                ['<c-o>'] = trouble.open_with_trouble,
            },
            n = {
                ['<m-k>'] = actions.move_selection_previous,
                ['<m-j>'] = actions.move_selection_next,
                ['<f10>'] = actions.close,
                ['<c-o>'] = trouble.open_with_trouble,
            }
        }
    }
})
-- NOTE To get fzf loaded and working with telescope, you need to call load_extension, somewhere after setup function:
telescope.load_extension('fzf')

-- AHKREMAP <c-3>
vimp.nnoremap('<c-m-f2>', '<cmd>Telescope find_files<CR>')  -- <C-3>
vimp.inoremap('<c-m-f2>', '<cmd>Telescope find_files<CR>')  -- <C-3>
vimp.tnoremap('<c-m-f2>', [[<c-\><c-n><c-w>h<cmd>Telescope find_files<CR>]])  -- NOTE <c-w>h only works in specific cases, for example, when cursor is at main terminal buffer

whichkey.register({
    name = "telescope",

    -- Find files
    o = {'<cmd>Telescope oldfiles<CR>',                              'find previously opened files'},
    f = {'<cmd>Telescope find_files<CR>',                            'find files'},
    a = {'<cmd>Telescope find_files hidden=true<CR>',                'find files (inc. hidden)'},
    i = {'<cmd>Telescope find_files hidden=true no_ignore=true<CR>', 'find files (inc. hidden & ignored)'},
    F = {'<cmd>lua find_files_custom_dir()<CR>',                     'find files in custom directory'},
    A = {'<cmd>lua find_files_hidden_custom_dir()<CR>',              'find files (inc. hidden) in custom directory'},
    I = {'<cmd>lua find_files_hidden_ignore_custom_dir()<CR>',       'find files (inc. hidden & ignored) in custom directory'},

    -- Search
    g = {"<cmd>Telescope live_grep<CR>", "live grep"},
    G = {'<cmd>lua live_grep_custom_dir()<CR>', 'live grep in custom dir'},
    q = {"<cmd>Telescope current_buffer_fuzzy_find<CR>", "search current buffer"},
    w = {"<cmd>Telescope grep_string<cr>", "search for string under cursor"},

    -- Marks, registers, search history
    m = {"<cmd>Telescope marks<cr>", "search marks"},
    r = {"<cmd>Telescope registers<CR>", "search vim registers"},
    s = {"<cmd>Telescope search_history<CR>", "find files"},

    -- Buffer, filetypes
    b = {"<cmd>Telescope buffers<CR>", "search buffers"},
    t = {"<cmd>Telescope filetypes<CR>", "search and set filetype"},

    -- Resize file explorer. NvimTree's width defaults to R's size, hence use `w` for ease of setting width for Julia
    z = {"<cmd>vertical 1resize " .. file_explorer_width_R     .. "<CR>", "resize file explorer for R"},
    Z = {"<cmd>vertical 1resize " .. file_explorer_width_julia .. "<CR>", "resize file explorer for Julia"},

    -- Vim's stuffs
    h = {"<cmd>Telescope help_tags<CR>", "search help tags"},
    k = {"<cmd>Telescope keymaps<CR>", "search key mappings"},
    c = {"<cmd>Telescope command_history<CR>", "search vim commands"},
    C = {"<cmd>Telescope commands<CR>", "search vim commands"},
    V = {"<cmd>Telescope vim_options<cr>", "search vim options"},
    H = {"<cmd>Telescope highlights<CR>", "search nvim highlight groups"},

    -- Others
    S = {'<cmd>lua start_shell_placeholder()<CR>', 'start shell and placeholder buffer'},
    -- S = {"<cmd>SearchSession<CR>", "search sessions"},

}, {prefix='<leader>f', noremap=true}) 


whichkey.register({  -- NOTE Similar keybinds as gitsigns
    name = 'git',
    b  = {function() return delta.diff_current_buf() end, 'diff preview current buffer'},
    d  = {function() return delta.diff() end,             'diff preview'},
    ls = {function() return delta.status() end,           'status with diff preview'},
    la = {function() return delta.commits() end,          'commits for current directory with diff preview'},
    lb = {function() return delta.bcommits() end,         'commits for current buffer with diff preview'},
}, {prefix = '<leader>g', noremap = true})
