require('nvim-treesitter.configs').setup({
  ensure_installed = {
      'r',
      'julia',
      'python',
      'bash',
      'markdown',
      'markdown_inline',
  },
  highlight = {
    enable = true,
    -- NOTE Disable for the specified filetypes but enable for quarto
    disable = { 'r', 'julia' }
  },
})
