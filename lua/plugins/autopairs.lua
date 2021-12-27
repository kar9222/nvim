-- NOTE Setup nvim-cmp before this
local autopairs = require('nvim-autopairs')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
local vimp = require('vimp')

autopairs.setup{
    fast_wrap = {
      map = '<m-s>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      hightlight = 'Search'
    },
}

-- local map_bs = true  -- map the <BS> key
-- local disable_filetype = { "TelescopePrompt" }
-- local ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]],"%s+", "")
-- local enable_moveright = true
-- local enable_afterquote = true  -- add bracket pairs after quote
-- local enable_check_bracket_line = true  --- check bracket in same line
-- local check_ts = false

-- For nvim-cmp: Auto insert `(` after selecting function or method item
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

vimp.imap('<c-h>', '<bs>')  -- Auto-remove pairs
