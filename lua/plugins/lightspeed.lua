-- TODO `labels`, etc

-- TODO? See docs: In order to preserve your custom settings after changing the colorscheme,

-- Explore inclusive keys `<Plug>Lightspeed_x` and `<Plug>Lightspeed_X`

lightspeed = require("lightspeed")
local vimp = require('vimp')

lightspeed.setup({
    jump_to_unique_chars = { safety_timeout = 400 },  -- NOTE Might lag for large search area
    match_only_the_start_of_same_char_seqs = true,
    limit_ft_matches = 5,
    special_keys = {  -- Captured directly by the plugin at runtime
        next_match_group = '<tab>',
        prev_match_group = '<s-tab>',
    },

    -- Smart shifting between Sneak and EasyMotion mode, except for operator-pending mode
    -- NOTE Keys mapped to `<plug>Lightspeed_;_sx` and `<plug>Lightspeed_,_sx` shouldn't be used as labels
    safe_labels = {
      "f", "s", "n",
      "u", "t",
      "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z",
    },
    labels = {
      "f", "s", "n",
      "j", "k", "l", "o", "i", "w", "e", "h", "g",
      "u", "t",
      "m", "v", "c", "a", ".", "z",
      "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z",
    },
})

-- Use `s` and `S` for 1-character search. Use `f` and `F` for 2-character search.

-- Combined keys for (TODO `f` and `F` shouldn't be used?)
-- - forward/backword 2-char search
-- - instant repeat forward/backey key (additional keys in addition to default `s` and `S`)
vim.cmd([[
    augroup lightspeed_active
        au!
        au user LightspeedFtEnter let g:lightspeed_active = 1
        au user LightspeedFtLeave unlet g:lightspeed_active
    augroup END

    nmap <expr> f exists('g:lightspeed_active') ? '<plug>Lightspeed_;_ft' : '<plug>Lightspeed_s'
    nmap <expr> F exists('g:lightspeed_active') ? '<plug>Lightspeed_,_ft' : '<plug>Lightspeed_S'
    xmap <expr> f exists('g:lightspeed_active') ? '<plug>Lightspeed_;_ft' : '<plug>Lightspeed_s'
    xmap <expr> F exists('g:lightspeed_active') ? '<plug>Lightspeed_,_ft' : '<plug>Lightspeed_S'
]])

vimp.nmap('s', '<plug>Lightspeed_f')  -- Forward 1-char
vimp.nmap('S', '<plug>Lightspeed_F')  -- Backward 1-char
vimp.xmap('s', '<plug>Lightspeed_f')
vimp.xmap('<c-s>', '<plug>Lightspeed_F')  -- TODO `S` clashes. Temporarily use this.

vimp.nmap('t', '<plug>Lightspeed_t')  -- Exclusive forward 1-char
vimp.nmap('T', '<plug>Lightspeed_T')  -- Exclusive backward 1-char
vimp.xmap('t', '<plug>Lightspeed_t')
vimp.xmap('T', '<plug>Lightspeed_T')

vimp.omap('s', '<plug>Lightspeed_f')  -- TODO Validate these
vimp.omap('S', '<plug>Lightspeed_F')
vimp.omap('t', '<plug>Lightspeed_t')
vimp.omap('T', '<plug>Lightspeed_T')
-- Mapping these results in errors. Leave them as default anyway.
-- vimp.omap('z', '<plug><Lightspeed_s')
-- vimp.omap('Z', '<plug><Lightspeed_S')
-- vimp.omap('x', '<plug><Lightspeed_x')  -- Forward 2-char X-mode
-- vimp.omap('X', '<plug><Lightspeed_X')  -- Backward 2-char X-mode


-- Repeat the last motion search (s/x or f/t) in forward/backward direction
vim.cmd([[
    let g:lightspeed_last_motion = ''
    augroup lightspeed_last_motion
        au!
        au user LightspeedSxEnter let g:lightspeed_last_motion = 'sx'
        au user LightspeedFtEnter let g:lightspeed_last_motion = 'ft'
    augroup END

    map <expr> , g:lightspeed_last_motion == 'sx' ? '<plug>Lightspeed_;_sx' : '<plug>Lightspeed_;_ft'
    map <expr> ' g:lightspeed_last_motion == 'sx' ? '<plug>Lightspeed_,_sx' : '<plug>Lightspeed_,_ft'
]])
