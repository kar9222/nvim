local delta = require('custom_plugins.delta.lua.init')

whichkey.register({  -- NOTE Similar keybinds as gitsigns
    name = 'git delta',
    b  = {function() delta.diff_current_buf() end,               'diff preview current buffer'},
    z  = {function() delta.diff() end,                           'diff preview'},
    f  = {function() delta.diff_current_buf__side_by_side() end, 'diff preview current buffer side-by-side'},
    d  = {function() delta.diff__side_by_side() end,             'diff preview side-by-side'},
    ls = {function() delta.status() end,                         'status with diff preview'},
    la = {function() delta.commits() end,                        'commits for current directory with diff preview'},
    lb = {function() delta.bcommits() end,                       'commits for current buffer with diff preview'},
}, {prefix = '<leader>g', noremap = true})
