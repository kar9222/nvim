local function zotero_db_path(file)
  local win_username = 'kar'  -- TODO
  return '/mnt/c/users/' .. win_username .. '/Zotero/' .. file
end

-- NOTE Adapted from source
local M = {}
M.quarto = {}
M.tex = {}
M['quarto.cached_bib'] = nil
local function locate_quarto_bib()
  if M['quarto.cached_bib'] then
    return M['quarto.cached_bib']
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    local location = string.match(line, [[bibliography:[ "']*(.+)["' ]*]])
    if location then
      M['quarto.cached_bib'] = vim.fn.expand('%:p:h') .. '/' .. location  -- TODO
      return M['quarto.cached_bib']
    end
  end
  -- no bib locally defined
  -- test for quarto project-wide definition
  local fname = vim.api.nvim_buf_get_name(0)
  local root = require('lspconfig.util').root_pattern '_quarto.yml'(fname)
  if root then
    local file = root .. '/_quarto.yml'
    for line in io.lines(file) do
      local location = string.match(line, [[bibliography:[ "']*(.+)["' ]*]])
      if location then
      M['quarto.cached_bib'] = vim.fn.expand('%:p:h') .. '/' .. location  -- TODO
        return M['quarto.cached_bib']
      end
    end
  end
end

require'zotero'.setup{
  zotero_db_path        = zotero_db_path('zotero.sqlite'),
  better_bibtex_db_path = zotero_db_path('better-bibtex.sqlite'),

  ft = {
    quarto = {
      insert_key_formatter = function(citekey)
        return '@' .. citekey
      end,
      locate_bib = locate_quarto_bib,
    },
  }
}

vim.keymap.set('n', '<leader>sz', ':Telescope zotero<CR>', { desc = '[z]otero' })
