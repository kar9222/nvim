local neorg = require('neorg')

-- TODO Temporary solution
require'compe'.setup {
    source = {neorg = true}
}

-- NOTE Lazy loading is not recommened due to potential breaking of TreeSitter/etc. neorg practically lazy loads itself - only a few lines of code are run on startup, these lines check whether the current extension is .norg, if it's not then nothing else loads. You shouldn't have to worry about performance issues.
neorg.setup {
    load = {  -- Load modules
        ['core.defaults'] = {},
        ["core.highlights"] = {},
        ["core.integrations.telescope"] = {},
        ['core.norg.dirman'] = {  -- Directory management
            config = {
                workspaces = {
                    org = "~/neorg",
                },
                autodetect = true,
                autochdir = true,
            },
        },
        ["core.integrations.treesitter"] = {
            config = {
                highlights = {
                    Heading = {
                        ['1'] = {
                            Title = '+TSTitle',
                            Prefix = '+TSTitle',
                        },
                    },
                },
            },
        },
        ['core.norg.concealer'] = { -- For icons
            config = {
                workspaces = {
                    my_workspace = '~/neorg'
                },
                icons = {
                    heading = {
                        level_1 = {
                            icon = "◉",
                        },
                        level_2 = {
                            icon = "◎",
                        },
                        level_3 = {
                            icon = "○",
                        },
                        level_4 = {
                            icon = "✺",
                        },
                    },
                },
            }
        },
        -- ['core.norg.completion'] = {
        --     config = {
        --         -- engine = 'nvim-cmp',  -- TODO
        --         engine = 'nvim-compe',
        --     },
        -- },
    },
}
