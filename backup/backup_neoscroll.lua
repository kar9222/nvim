-- Slightly laggy, probably due to terminal's rendering performance.  Might revisit if a better terminal is found.

local Neoscroll = require('neoscroll')

Neoscroll.setup({
    -- All these keys will be mapped to their corresponding default scrolling animation
    mappings = {'<C-y>', '<C-e>'},
    hide_cursor = false,          -- Hide cursor while scrolling
    stop_eof = true,             -- Stop at <EOF> when scrolling downwards
    use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
    respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
    cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
    easing_function = nil,        -- Default easing function
    pre_hook = nil,              -- Function to run before the scrolling animation starts
    post_hook = nil,              -- Function to run after the scrolling animation ends
})

local t = {}
-- Syntax: t[keys] = {function, {function arguments}}
-- Pass `nil` to disable the easing animation (constant scrolling speed)
t['<C-y>'] = {'scroll', {'-0.10', 'false', '60', nil}}
t['<C-e>'] = {'scroll', { '0.10', 'false', '60', nil}}

require('neoscroll.config').set_mappings(t)
