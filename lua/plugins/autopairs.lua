-- NOTE Setup nvim-cmp before this
local autopairs = require('nvim-autopairs')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
local vimp = require('vimp')

autopairs.setup{
    fast_wrap = {
      map = '<m-w>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      hightlight = 'Search'
    },
}

-- See README for default values

-- For nvim-cmp: Auto insert `(` after selecting function or method item
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

vimp.imap('<c-h>', '<bs>')  -- Auto-remove pairs
