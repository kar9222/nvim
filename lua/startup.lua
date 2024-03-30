-- Called by startup_session.lua

local fn = vim.fn

-- vim-strip-trailing-whitespace ----------------

-- Disable for certain filetypes for reasons such as some formats (e.g. markdown) require trailing whitespaces.

-- The plugin only disable for filetypes 'diff' and 'markdown'. Disable default, then add extra filetypes to the autocmd.
-- NOTE Source the config here because this chunk doesn't work when sourced in other files. TODO
vim.cmd('au! strip_trailing_whitespace_filetype')

-- Copied from vim-strip-trailing-whitespace
vim.cmd([[
    augroup strip_trailing_whitespace_filetype
        au!
        au FileType * let b:strip_trailing_whitespace_enabled = index(['diff', 'markdown', 'pandoc', 'rmarkdown'], &filetype) == -1
    augroup END
]])


-- neomux ----------------------------------------

-- NOTE Env variables are set in options.lua but neomux overrides `EDITOR`, hence, set it's set here to override neomux's settings.
local cmd = "nvr -cc '" .. middle_win_nr .. "wincmd w' --remote-wait +'set bufhidden=wipe'"
fn.setenv("EDITOR", cmd)
fn.setenv("VISUAL", cmd)


-- Helpers --------------------------------------

-- NOTE `botright vertical` for overriding horizontally split windows on startup
local function start_term()
    vim.cmd([[
        wincmd l
        botright vertical Tnew
    ]])
    right_most_win_id__autocmd()
end

local function start_R_repl()
    start_term()
    vim.cmd([[
        sleep 400m  " NOTE Same as toggleterm.lua
        T radian -q
    ]])
end

-- NOTE Also see keybind <m-1> at keybindings.lua
local function start_placeholder()
    vim.cmd('spl ' .. placeholder_buf_name)
    vim.cmd([[
      setlocal nomodifiable nobuflisted noswapfile nonumber nocursorline buftype=nofile
      au BufEnter <buffer> let g:prev_non_term_win_nr = winnr('#')
    ]])
    vim.cmd('resize ' .. placeholder_buf_size)
    vim.cmd([[
        wincmd h
        stopinsert
    ]])
end

-- For session without initial startup of REPL. NOTE This is used by toggleterm.lua
function start_shell_placeholder()
    start_term()
    start_placeholder()
end

-- Start REPL -----------------------------------

-- NOTE Hacky workaround. Without this, the very 1st terminal buffer opened has different color.
vim.cmd('sleep 1m')

-- If directory is a R project as identified by existence of DESCRIPTION...
local cwd = fn.getcwd()
local is_project_dir = cwd:find('^/home/kar/project') ~= nil
local not_mythings   = cwd:find('mythings$') == nil
local is_project = fn.filereadable('DESCRIPTION') == 1

-- Start R REPL and placeholder
-- NOTE Manually start NvimTree to avoid some quirks
if is_project_dir and is_project and not_mythings then

    -- Main buffer
    vim.cmd('vsp')
    vim.g.main_buffer_win_id = fn.win_getid()

    -- Aerial window.
    -- NOTE Setting width (file_explorer_width_julia) here doesn't work
    -- possibly due to it being overridden by config.
    -- Hence, use the config's width as per plugins/aerial.lua
    vim.cmd('wincmd h')
    vim.g.aerial_win_id = fn.win_getid()

    require'aerial'.open_in_win(  -- Options are not table
        vim.g.aerial_win_id,      -- Option is `target_win`
        vim.g.main_buffer_win_id  -- Option is `soruce_win`
    )

    -- NvimTree window
    vim.g.nvim_tree_height = fn.string(0.6 * fn.winheight('%'))
    vim.cmd('split | resize ' .. vim.g.nvim_tree_height)
    vim.g.nvim_tree_win_id = fn.win_getid()

    -- It opens file in window from which I last opened the tree.
    -- Here, Aerial would be the "last opened" window.
    -- To workaround, jump to the "main" buffer just before opening NvimTree
    vim.cmd('wincmd l')  -- To main buffer
    require'nvim-tree.api'.tree.open({ winid = vim.g.nvim_tree_win_id })

    start_R_repl()
    start_placeholder()
else
    vim.cmd('NvimTreeOpen')
    vim.cmd('wincmd l')
end










-- Backup ---------------------------------------

-- -- NOTE Hacky workaround. Without this, the very 1st terminal buffer opened has different color.
-- vim.cmd('sleep 1m')

-- vim.cmd('NvimTreeOpen')  -- NOTE Manually start to avoid some quirks.

-- -- If directory is a R project as identified by existence of DESCRIPTION...
-- local cwd = fn.getcwd()
-- local is_project_dir = cwd:find('^/home/kar/project') ~= nil
-- local not_mythings   = cwd:find('mythings$') == nil
-- local is_project = fn.filereadable('DESCRIPTION') == 1

-- -- Start R REPL and placeholder
-- if is_project_dir and is_project and not_mythings then
--     start_R_repl()
--     start_placeholder()
-- else
--     vim.cmd('wincmd l')
-- end
