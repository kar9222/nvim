-- Startup and (auto) save, restore and delete sessions.
-- Restore as minimal things as possible to avoid breaks, especially buffer-local options/mappings.
-- Only auto-save commonly used directories (e.g. project). For other directories, manually save and restore them.

-- NOTE If things break, debug vim.o.sessionoptions (see details below).

-- TODO Only can save two buffers? 
-- TODO Markdown and Rmarkdown bugs?
-- TODO For vertical splits, due to minimum window width, it breaks right_most_win_width of terminal buffer.
-- TODO Remove unused sessions older than e.g. 1 year? Sessions picker?


local api = vim.api
local fn  = vim.fn
local M = {}

local auto_save_restore_dirs = {
    '~/project',
    '~/libs',
}

local function enable_auto_save_restore()
    local cwd = fn.getcwd()
    for _, v in ipairs(auto_save_restore_dirs) do
        if string.match(cwd, fn.expand(v)) then
            return true  -- else return nil
        end
    end
end

function M.session_info()
    local file = M.session_file()
    local t = {}

    if fn.filereadable(file) == 1 then
        t.has_session = true
        t.session_file = file
    else
        t.has_session = false
    end
    return t
end

-- NOTE
-- - It's not recommended to restore `globals`.
-- - Don't restore `localoptions` and `options` because they save buffer-local options/mappings, which breaks plugins like gitsigns/autopairs, for example, the session file save `inoremap <buffer> ...`
vim.o.sessionoptions='blank,curdir,winpos,winsize,resize,folds,tabpages'

local function escape_path(path)
    return path:gsub('/', '__')
end

local function unescape_path(path)
    return path:gsub('__', '/')
end

local function session_dir()
    return fn.stdpath('data') .. '/sessions'
end

-- Save directory name as session file e.g. .../my_project_dir.vim
-- @param read_write Reading or writing session file. Internally, it's used for escaping/unescaping directory as file name.
function M.session_file(read_write)
    local file = escape_path(fn.getcwd())
    return session_dir() .. '/' .. file .. '.vim'
end

local function open_file_explorer()
    vim.cmd([[
        NvimTreeOpen
        wincmd p
    ]])
end

local function print_no_session()
    print('No previous session has been found.')
end

function handle_tabpages_issues()  -- `tabpages` set for `sessionoptions`
    local tabpages = api.nvim_list_tabpages()
    local tab_num = vim.tbl_count(tabpages)

    if tab_num >= 2 then  -- Else do nothing
        -- Open file explorer from the second tabpage onwards
        local second_tabpages_onward = vim.tbl_filter(function(x) return x >= 2 end,
                                                      tabpages)
        for _, v in ipairs(second_tabpages_onward) do
            api.nvim_set_current_tabpage(v)
            open_file_explorer()
        end
        api.nvim_set_current_tabpage(1)  -- Startup's default to the first tabpage

        -- TODO Bug: Unnamed buffers appear when more than one tabpages are restored. Workaround by removing them, only when more than one tabs are restored, else another bug appears where file isn't restored properly if only one tab exists.
        local unnamed_bufs = fn.filter(fn.range(1, fn.bufnr('$')),
                                       'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])')
        if unnamed_bufs ~= nil then
            vim.cmd('bw ' .. fn.join(unnamed_bufs, ' '))
        end
    end
end

function M.save_session()
    api.nvim_set_current_tabpage(1)  -- TODO Hotfix buggy tabpage results in unnamed buffer. Currently only save the 1st tab.
    -- Remove non-normal buffers, including terminal, nofile (file explorer, search panel, outline, git UI, etc), etc
    for _, buf in ipairs(api.nvim_list_bufs()) do
        local buftype = fn.getbufvar(buf, '&buftype')
        if buftype ~= '' then
            vim.cmd(buf .. 'bwipe!')
        end
    end
    vim.cmd('mks! ' .. M.session_file())
    print('Saved session.')
end

-- Restore session and also return whether it has previous session for downstream usage.
function M.restore_session()
    local t = M.session_info()
    if t.has_session then
        vim.cmd('source ' .. t.session_file)
        handle_tabpages_issues()
        print('Restored session.')
        return true
    else
        return false
    end
end

function M.save_session_open_file_explorer()
    M.save_session()
    open_file_explorer()
end

function M.restore_session_open_file_explorer()
    local has_session = M.restore_session()  -- Attempt to restore session
    if has_session then
        open_file_explorer()
    else
        print_no_session()
    end
end

function M.auto_save_session()
    if enable_auto_save_restore() then M.save_session() end
end

function M.auto_restore_session()
    if enable_auto_save_restore() then M.restore_session() end
end

function M.delete_session()
    local t = M.session_info()
    if t.has_session then
        vim.cmd('silent! !rm ' .. M.session_file())
        print('Delete session!')
    else
        print_no_session()
    end
end

-- TODO Two VimEnter correct?
vim.cmd([[
  augroup AutoSession
    au!
    au VimEnter * nested lua require('startup_session').auto_restore_session()
    au VimEnter * nested lua require('startup')
    au VimLeave * lua require('startup_session').auto_save_session()
  augroup end
]])


-- Keybinds -------------------------------------

whichkey.register({
    ['\\s'] = {
        name = 'session',
        s = {'<cmd>lua require"startup_session".save_session_open_file_explorer()<CR>',    'save session',    noremap=true},
        r = {'<cmd>lua require"startup_session".restore_session_open_file_explorer()<CR>', 'restore session', noremap=true},
        d = {'<cmd>lua require"startup_session".delete_session()<CR>',                     'delete session',  noremap=true},
    }
})

return M









-- Backup ---------------------------------------

-- Close all windows except the 'middle' one to avoid messing up windows layout.
--[[ local function close_all_wins_except_middle()
    -- Only trigger when `placeholder` buffer exists, indicating R/Julia project session with terminal buffers opened on the right.
    if fn.bufname(placeholder_buf_name) ~= '' then
        local middle_win = fn.win_getid(middle_win_nr)
        for _, win in ipairs(api.nvim_list_wins()) do
            if win ~= middle_win then
                api.nvim_win_close(win, false)
            end
        end
    end
end ]]

