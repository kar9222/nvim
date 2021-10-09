local fn = vim.fn

-- Helpers --------------------------------------

local function start_placeholder_term()
    vim.cmd('spl | lcd ~ | term')
    vim.cmd('resize ' .. placeholder_buf_size)
    vim.cmd('file ' .. placeholder_buf_name)
    vim.cmd('set nocursorline')  -- Disable `set cursorline` for `autocmd TermOpen`

    vim.cmd([[
            wincmd h
            stopinsert
    ]])
    end

function start_shell_placeholder_term()
    vim.cmd([[
            wincmd l
            Tnew
    ]])
start_placeholder_term()
    end

    -- Start REPL -----------------------------------

    -- NOTE Hacky workaround. Without this, the very 1st terminal buffer opened has different color.
    vim.cmd('sleep 1m')

    vim.cmd('NvimTreeOpen')  -- NOTE Manually start to avoid some quirks.

    -- If directory is a R project as identified by existence of DESCRIPTION...
local cwd = fn.getcwd()
    local is_project_dir = cwd:find('^/home/kar/project') ~= nil
    local not_mythings   = cwd:find('mythings$') == nil
    local is_project = fn.filereadable('DESCRIPTION') == 1

    -- Start R REPL 
    if is_project_dir and is_project and not_mythings then
    vim.cmd([[
            Tnew
            sleep 400m
            T radian -q
            Tclose
            Tnew
            Tprev
    ]])
start_placeholder_term()
    elseif is_project_dir then  -- Only open shell
start_shell_placeholder_term()
    else
    vim.cmd('wincmd l')
    end
