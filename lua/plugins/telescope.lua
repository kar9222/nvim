-- TODO Check if desired default pickers are used e.g. fd, rg

local telescope = require("telescope")
local builtin = require('telescope.builtin')
local sorters = require("telescope/sorters")
local previewers = require("telescope/previewers")
local actions = require('telescope.actions')

local trouble = require('trouble.providers.telescope')

local live_grep_args_shortcuts = require('telescope-live-grep-args.shortcuts')
local lga_actions = require('telescope-live-grep-args.actions')

local fn = vim.fn

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
    vim.cmd([[lua require('telescope').extensions.live_grep_args.live_grep_args({ cwd = vim.fn.getreg('z') })]])
end

telescope.setup({
    defaults = {
        path_display = { 'filename_first' },  -- To search for my_directory: `my_directory/`
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
        file_ignore_patterns = { 'renv.lock' },
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

        -- TODO Explore nvim-telescope/telescope-live-grep-args.nvim
        extensions = {
          fzf = {  -- TODO
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                                      -- the default case_mode is "smart_case"
          },
          live_grep_args = {
            auto_quoting = true,
            -- also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec
            -- layout_config = { mirror=true }, -- mirror preview pane
          },
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
                ['<c-s>'] = actions.select_horizontal,
                ['<c-e>'] = actions.select_vertical,  -- Default key is <c-v>

                ['<c-o>'] = trouble.open_with_trouble,

                -- Live grep args
                -- TODO HOTFIX Map under "extensions" to avoid clashed mapping with other extensions?
                ['<m-q>'] = lga_actions.quote_prompt(),
                ['<m-f>'] = lga_actions.quote_prompt({ postfix = ' -t ' }),
                ['<m-i>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
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

-- Load extensions after setting up telescope
telescope.load_extension('fzf')
telescope.load_extension('live_grep_args')

-- AHKREMAP <c-3>
-- vimp.nnoremap('<c-m-f2>', '<cmd>Telescope find_files<CR>')  -- <C-3>
-- vimp.inoremap('<c-m-f2>', '<cmd>Telescope find_files<CR>')  -- <C-3>
-- vimp.tnoremap('<c-m-f2>', [[<c-\><c-n><c-w>h<cmd>Telescope find_files<CR>]])  -- NOTE <c-w>h only works in specific cases, for example, when cursor is at main terminal buffer

vimp.nnoremap('<leader>f', '<cmd>Telescope find_files<CR>')
vimp.vnoremap('<leader>sd', live_grep_args_shortcuts.grep_visual_selection)

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

    d = {[[<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>]], 'live grep'},
    D = {'<cmd>lua live_grep_custom_dir()<CR>', 'live grep in custom dir'},
    s = {"<cmd>Telescope current_buffer_fuzzy_find<CR>", "search current buffer"},
    w = {[[<cmd>lua require('telescope-live-grep-args.shortcuts').grep_word_under_cursor()<CR>]], 'search for string under cursor'},

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

}, {prefix='<leader>s', noremap=true})
