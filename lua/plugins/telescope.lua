-- TODO Check if desired default pickers are used e.g. fd, rg

local telescope = require("telescope")
local builtin = require('telescope.builtin')
local sorters = require("telescope/sorters")
local previewers = require("telescope/previewers")
local actions = require('telescope.actions')

local delta = require('helpers.delta')
local trouble = require('trouble.providers.telescope')

local fn = vim.fn

-- Path display in format: {file_basename} {file_dir}
-- Query directory with `dir_1/dir_2/`
local function path_display(opts, path)  -- opts is required by telescope
    local dir = require('utils').dirname(path, false)  -- Keep trailing sep for querying directory
    if dir == nil then dir = '' end
    local tail = require('telescope.utils').path_tail(path)
    return string.format('%s   %s', tail, dir)
end


-- CLI and nvim integration for finding files, live grep, etc using telescope.
-- Call CLI commands defined in ZSHRC, for example, `ff` and `aff`. These commands
-- 1. Save the directory to nvim's register
-- 2. Call nvim telescope for finding files, live grep, etc in the directory saved in register.
-- After the first call, the directory is saved in the register. Hence, they can be called subsequently with keybinds, no need to call it again from CLI.
-- To change the saved directory, call CLI commands.
-- NOTE Use `cwd` instead of `search_dirs` for better path name where `cwd` respects `path_display`.
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
        prompt_prefix = prompt .. ' ',
        selection_caret = prompt,
        entry_prefix = " ",
        multi_icon = "",
        initial_mode = "insert",
        selection_strategy = "reset",
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = 'top',
            },
            vertical = {
                height = vim.o.lines - 10,
                width = vim.o.columns - 40,
                preview_height = 30,
            },
            center = {
                preview_cutoff = 40
            },
            cursor = {
                preview_cutoff = 40
            },
        },
        file_sorter = sorters.get_fuzzy_file,
        file_ignore_patterns = {},
        generic_sorter = sorters.get_generic_fuzzy_sorter,
        winblend = 0,
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
                ['<c-b>'] = { '<c-s-w>', type = 'command' },  -- Kill backward word
                ['<c-w>'] = { '<c-u>',   type = 'command' },  -- Kill backward line (remap original <c-u>)
                ['<c-v>'] = { '<c-r>*',  type = 'command' },  -- Paste

                ['<m-k>'] = actions.move_selection_previous,
                ['<m-j>'] = actions.move_selection_next,
                ['<f10>'] = actions.close,
                ['<c-p>'] = actions.results_scrolling_up,
                ['<c-n>'] = actions.results_scrolling_down,
                ['<c-k>'] = actions.cycle_history_prev,
                ['<c-j>'] = actions.cycle_history_next,
                ['<c-e>'] = actions.select_vertical,  -- Default key is <c-v>

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

telescope.load_extension('fzf')  -- Call after setting up telescope

-- AHKREMAP <c-3>
-- vimp.nnoremap('<c-m-f2>', '<cmd>Telescope find_files<CR>')  -- <C-3>
-- vimp.inoremap('<c-m-f2>', '<cmd>Telescope find_files<CR>')  -- <C-3>
-- vimp.tnoremap('<c-m-f2>', [[<c-\><c-n><c-w>h<cmd>Telescope find_files<CR>]])  -- NOTE <c-w>h only works in specific cases, for example, when cursor is at main terminal buffer

vimp.nnoremap('<leader>f', '<cmd>Telescope find_files<CR>')

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
    d = {"<cmd>Telescope live_grep<CR>", "live grep"},
    D = {'<cmd>lua live_grep_custom_dir()<CR>', 'live grep in custom dir'},
    s = {"<cmd>Telescope current_buffer_fuzzy_find<CR>", "search current buffer"},
    w = {"<cmd>Telescope grep_string<cr>", "search for string under cursor"},

    -- Marks, registers, search history
    m     = {"<cmd>Telescope marks<cr>", "search marks"},
    r     = {"<cmd>Telescope registers<CR>", "search vim registers"},
    ['/'] = {"<cmd>Telescope search_history<CR>", "find files"},

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
    [';'] = {'<cmd>lua start_shell_placeholder()<CR>', 'start shell and placeholder buffer'},

}, {prefix='<leader>s', noremap=true})


whichkey.register({  -- NOTE Similar keybinds as gitsigns
    name = 'git',
    b  = {function() delta.diff_current_buf() end, 'diff preview current buffer'},
    d  = {function() delta.diff() end,             'diff preview'},
    ls = {function() delta.status() end,           'status with diff preview'},
    la = {function() delta.commits() end,          'commits for current directory with diff preview'},
    lb = {function() delta.bcommits() end,         'commits for current buffer with diff preview'},
}, {prefix = '<leader>g', noremap = true})
