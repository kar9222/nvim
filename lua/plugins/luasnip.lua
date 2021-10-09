local ls = require('luasnip')
local s  = ls.snippet
local sn = ls.snippet_node
local t  = ls.text_node
local i  = ls.insert_node
local f  = ls.function_node
local c  = ls.choice_node
local d  = ls.dynamic_node

local le = require('luasnip.extras')
local l  = le.lambda
local r  = le.rep
local p  = le.partial
local m  = le.match
local n  = le.nonempty
local dl = le.dynamic_lambda

local types = require('luasnip.util.types')

ls.config.set_config({  -- Every unspecified option will be set to the default.
	history = true,
	updateevents = 'TextChanged,TextChangedI',  -- Update more often, :h events for more info.
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { 'choiceNode', 'Comment' } },
			},
		},
	},
	ext_base_prio = 300,  -- Treesitter-hl has 100, use something higher (default is 200).
	ext_prio_increase = 1,  -- Minimal increase in priority.
	enable_autosnippets = true,
})

-- When trying to expand a snippet, luasnip first searches the tables for
-- each filetype specified in 'filetype' followed by 'all'.
-- If ie. the filetype is 'lua.c'
--     - luasnip.lua
--     - luasnip.c
--     - luasnip.all
-- are searched in that order.
ls.snippets = {
    -- all = {
    -- },

	r = {
        s({trig = 'fun', name = 'R function', dscr = 'R function block'}, {
            i(1), t(' <- function('), i(2), t({') {', ''}),
            t('  '), i(0),
            t({'', '}'})
        }),

        -- for, while
        s({trig = 'for', name = 'R for', dscr = 'R for block'}, {
            t('for ('), i(1), t({') {', ''}),
            t('  '), i(0),
            t({'', '}'})
        }),
        s({trig = 'whi', name = 'R while', dscr = 'R while block'}, {
            t('while ('), i(1), t({') {', ''}),
            t('  '), i(0),
            t({'', '}'})
        }),

        -- if, elseif, else
        s({trig = 'if', name = 'R if', dscr = 'R if block'}, {
            t('if ('), i(1), t({') {', ''}),
            t('  '), i(0),
            t({'', '}'})
        }),
        s({trig = 'elseif', name = 'R elseif', dscr = 'R elseif block'}, {
            t('else if ('), i(1), t({') {', ''}),
            t('  '), i(0),
            t({'', '}'})
        }),
        s({trig = 'else', name = 'R else', dscr = 'R else block'}, {
            t('else ('), i(1), t({') {', ''}),
            t('  '), i(0),
            t({'', '}'})
        }),
    },


	julia = {
        s({trig = 'fun', name = 'Julia function', dscr = 'Julia function block'}, {
            t('function '), i(1), t('('), i(2), t({')', ''}),
            t('    '), i(0),
            t({'', 'end'}),
        }),

        -- struct, mutable struct
        s({trig = 'str', name = 'Julia struct', dscr = 'Julia struct block'}, {
            t('struct '), i(1),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),
        s({trig = 'mut', name = 'Julia mutable struct', dscr = 'Julia mutable struct block'}, {
            t('mutable struct '), i(1),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),

        -- if, elseif, else
        s({trig = 'if', name = 'Julia if', dscr = 'Julia if block'}, {
            t('if '), i(1),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),
        s({trig = 'elseif', name = 'Julia elseif', dscr = 'Julia elseif block'}, {
            t('elseif '), i(1),
            t({'', '    '}), i(0),
        }),
        s({trig = 'else', name = 'Julia else', dscr = 'Julia else block'}, {
            t('else'),
            t({'', '    '}), i(0),
        }),

        -- Loop, begin, do
        s({trig = 'for', name = 'Julia for', dscr = 'Julia for block'}, {
            t('for '), i(1),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),
        s({trig = 'whi', name = 'Julia while', dscr = 'Julia while block'}, {
            t('while '), i(1),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),
        s({trig = 'beg', name = 'Julia begin', dscr = 'Julia begin block'}, {
            t('begin '),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),
        s({trig = 'do', name = 'Julia do', dscr = 'Julia do block'}, {
            t('do '), i(1),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),

        -- Others
        s({trig = 'R', name = 'R block', dscr = 'R block'}, {
            t({'R"', ''}),
            i(0),
            t({'', '"'})
        }),
	},


    rmd = {
        s({trig = 'cc', name = 'Code chunk', dscr = 'Code chunk'}, {
            t('```{'), i(1), t({'}', ''}),
            i(0),
            t({'', '```'})
        }),
        s({trig = 'r', name = 'R code chunk', dscr = 'R code chunk'}, {
            t({'```{r}', ''}),
            i(0),
            t({'', '```'})
        }),
        s({trig = 'j', name = 'Julia code chunk', dscr = 'Julia code chunk'}, {
            t({'```{julia}', ''}),
            i(0),
            t({'', '```'})
        }),
        s({trig = 'e', name = 'Bread, olive and oil event', dscr = 'Event'}, {
            t('## '), i(1), t(' | '), i(2), t(' | '), i(0),
        })
    },

	lua = {
        s({trig = 'fun', name = 'Lua function', dscr = 'Lua function block'}, {
            t('function '), i(1), t('('), i(2), t({')', ''}),
            t('  '), i(0),
            t({'', 'end'}),
        }),

        -- if, elseif, else
        s({trig = 'if', name = 'Lua if', dscr = 'Lua if block'}, {
            t('if '), i(1), t(' then'),
            t({'', '  '}), i(0),
            t({'', 'end'}),
        }),
        s({trig = 'elseif', name = 'Lua elseif', dscr = 'Lua elseif block'}, {
            t('elseif '), i(1), t(' then'),
            t({'', '  '}), i(0),
        }),
        s({trig = 'else', name = 'Lua else', dscr = 'Lua else block'}, {
            t('else'),
            t({'', '  '}), i(0),
        }),

        -- for, while
        s({trig = 'for', name = 'Lua for', dscr = 'Lua for block'}, {
            t('for '), i(1), t(' do'),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),
        s({trig = 'whi', name = 'Lua while', dscr = 'Lua while block'}, {
            t('while '), i(1), t(' do'),
            t({'', '    '}), i(0),
            t({'', 'end'}),
        }),
    },
}

-- Autotriggered snippets have to be defined in a separate table, luasnip.autosnippets.
ls.autosnippets = {
	all = {
		s('autotrigger', {
			t('autosnippet'),
		}),
	},
}
