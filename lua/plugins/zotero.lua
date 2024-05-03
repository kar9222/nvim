local function zotero_db_path(file)
  local win_username = 'kar'  -- TODO
  return '/mnt/c/users/' .. win_username .. '/Zotero/' .. file
end

require'zotero'.setup{
  zotero_db_path        = zotero_db_path('zotero.sqlite'),
  better_bibtex_db_path = zotero_db_path('better-bibtex.sqlite')
}

vim.keymap.set('n', '<leader>sz', ':Telescope zotero<CR>', { desc = '[z]otero' })
