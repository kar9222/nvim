require'quarto'.setup{
  debug = false,
  closePreviewOnExit = true,
  lspFeatures = {
    enabled = true,
    chunks = 'curly',
    languages = { 'r', 'julia', 'python', 'bash' },
    diagnostics = {
      enabled = true,  -- TODO
      triggers = { 'BufWritePost' },
    },
    completion = {
      enabled = true,
    },
  },
  codeRunner = {
    enabled = false,
    default_method = nil, -- e.g. slime
    ft_runners = {}, -- filetype to runner, ie. `{ python = 'molten' }`. Takes precedence over `default_method`
    never_run = { 'yaml' }, -- filetypes which are never sent to a code runner
  },
  keymap = {  -- set whole section or individual keys to `false` to disable
    hover = 'K',
    document_symbols = 'go',
    definition = 'gd',
    type_definition = 'gD',
    rename = '<leader>lR',
    format = '<leader>lf',
    references = 'gR',
  }
}
