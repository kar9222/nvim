-- Implement delta as previewer for diffs

-- NOTE `delta --paging=always` is required to prevent exiting `less` and causing various bugs in nvim.

-- TODO See telescope.nvim issues 605 and 609

-- TODO If no diff, return nothing.

local previewers = require('telescope.previewers')
local builtin = require('telescope.builtin')
local conf = require('telescope.config')

local fn  = vim.fn
local api = vim.api
local M = {}

local delta = previewers.new_termopen_previewer {
  get_command = function(entry)
    -- this is for status
    -- You can get the AM things in entry.status. So we are displaying file if entry.status == '??' or 'A '
    -- just do an if and return a different command
    if entry.status == '??' or 'A ' then
      return { 'git',
               '-c', 'core.pager=delta',
               '-c', 'delta.side-by-side=false',
               '-c', 'delta.paging=always',
               'diff', entry.value }
    end

    -- note we can't use pipes
    -- this command is for git_commits and git_bcommits
    return { 'git',
             '-c', 'core.pager=delta',
             '-c', 'delta.side-by-side=false',
             '-c', 'delta.paging=always',
             'diff', entry.value .. '^!' }

  end
}

local layout_config = {
    height = 0.95,
    width = 0.97,
    preview_width = .75,
}

-- Setup options and mappings. NOTE After git actions, gitsigns.nvim are not updated. To close the terminal buffer, use <c-q> mapping in terminal mode (see configs).
--
-- @param buf_name If provided (not `nil`), buffer-local git actions mappings are bound
-- - `q` close buffer
-- - `<c-s>` stage current buffer
-- - `<c-u>` unstage current buffer
-- - `<c-s-s>` stage unstage
-- - `<c-s-u>` unstage stage
local function setup(buf_name)
    vim.cmd('set bufhidden=wipe')
    opts = {noremap = true, silent = true}

    -- Since quitting the diff preview terminal buffer is used everytime, map it to easily accessed
    -- key `q`, which is also consistent with other keybinds. For literal `q`, e.g. for searching, remap it to <m-q>.
    api.nvim_buf_set_keymap(0, 't', 'q', [[<c-\><c-n><c-w>c]], opts)
    api.nvim_buf_set_keymap(0, 't', '<m-q>', 'q', opts)

    if buf_name == 'all' then
        local stage_unstage = '<cmd>!git add -u<CR>'
        local unstage_stage = '<cmd>!git reset<CR>'
        api.nvim_buf_set_keymap(0, 't', '<c-ms-f5>', stage_unstage, opts)  -- AHKREMAP <c-s-s>
        api.nvim_buf_set_keymap(0, 't', '<c-m-f10>', unstage_stage, opts)  -- AHKREMAP <c-s-u>

    elseif buf_name ~= nil then  -- Current buffer TODO More robust conditional check
        local stage   = '<cmd>!git add '   .. buf_name .. '<CR>'
        local unstage = '<cmd>!git reset ' .. buf_name .. '<CR>'
        api.nvim_buf_set_keymap(0, 't', '<c-s>', stage, opts)
        api.nvim_buf_set_keymap(0, 't', '<c-u>', unstage, opts)
    end
end

function M.diff_current_buf()
    local buf_name = fn.shellescape(fn.expand('%'))
    open_float(0, _opts)
    vim.cmd('exe "term git diff -- " . shellescape(expand("%")) . " | delta --paging=always" | startinsert')
    setup(buf_name)
end

function M.diff()
    local buf_name = 'all'
    open_float(0, _opts)
    vim.cmd('exe "term git diff | delta --paging=always" | startinsert"')
    setup(buf_name)
end

M.status = function(opts)
  opts = opts or {}
  opts.layout_config = layout_config
  opts.previewer = delta

  builtin.git_status(opts)
end

M.commits = function(opts)
  opts = opts or {}
  opts.layout_config = layout_config
  opts.previewer = {
    delta,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }

  builtin.git_commits(opts)
end

M.bcommits = function(opts)
  opts = opts or {}
  opts.layout_config = layout_config
  opts.previewer = {
    delta,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }

  builtin.git_bcommits(opts)
end

return M

