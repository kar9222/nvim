-- TODO `labels`, etc

lightspeed = require("lightspeed")
local vimp = require('vimp')

lightspeed.setup({
    jump_to_first_match = true,
    jump_on_partial_input_safety_timeout = 400,
    highlight_unique_chars = true,  -- NOTE Might lag for large search area
    grey_out_search_area = true,
    match_only_the_start_of_same_char_seqs = true,
    limit_ft_matches = 5,
    x_mode_prefix_key = '<c-x>',
    cycle_group_fwd_key = '<tab>',
    cycle_group_bwd_key = '<s-tab>',
    instant_repeat_fwd_key = 'f',  -- Default `s` and `S` are also useable
    instant_repeat_bwd_key = 'F',
    labels = nil,
})

-- TODO? See docs: In order to preserve your custom settings after changing the colorscheme,

-- Use `s` and `S` for 1-character search. Use `f` and `F` for 2-character search.
vimp.nmap('f', '<plug>Lightspeed_s')  -- Forward 2-char
vimp.nmap('F', '<plug>Lightspeed_S')  -- Backward 2-char
vimp.xmap('f', '<plug>Lightspeed_s')
vimp.xmap('F', '<plug>Lightspeed_S')

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
