-- References
-- - https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
-- TODO Improve with this? [Example mappings · hrsh7th/nvim-cmp Wiki](https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings)

-- TODO Currently, change source `core.THROTTLE_TIME = 500` but still too eager  // RStudio default 250

-- TODO See issues #231 for breaking change with tag TODO_BREAK

local cmp = require('cmp')
local map = require('cmp.config.mapping')
local compare = require('cmp.config.compare')
local types = require('cmp.types')
local luasnip = require('luasnip')

local WIDE_HEIGHT = 40

local api = vim.api
local fn = vim.fn

local check_backspace = function()
  local col = fn.col('.') - 1
  return col == 0 or fn.getline('.'):sub(col, col):match('%s')
end

local function T(str)
    return api.nvim_replace_termcodes(str, true, true, true)
end

cmp.setup({
    completion = {
      -- autocomplete = { types.cmp.TriggerEvent.TextChanged },  -- TODO
      autocomplete = false,  -- Temporarily disable this
      completeopt = 'menu,menuone,noinsert',  -- Preselect
      preselect = types.cmp.PreselectMode.Item,  -- TODO cmp.PreselectMode.None  https://github.com/hrsh7th/nvim-cmp/issues/130
      keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
      keyword_length = 3,
      get_trigger_characters = function(trigger_characters)
        return trigger_characters
      end
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end
    },

    window = {
      completion = {
        col_offset = -3,  -- For placing icon before text
        border = border,
        winhighlight = 'NormalFloat:CmpDocumentation,FloatBorder:CmpDocumentationBorder',
      },
      documentation = {
        border = border,
        winhighlight = 'NormalFloat:CmpDocumentation,FloatBorder:CmpDocumentationBorder',
        max_width = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))),
        max_height = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
      },
    },
    confirmation = {
      default_behavior = types.cmp.ConfirmBehavior.Insert,
    },
    sorting = {
      priority_weight = 2,
      comparators = {
        compare.offset,
        compare.exact,
        compare.score,
        compare.kind,
        compare.sort_text,
        compare.length,
        compare.order,
      }
    },
    event = {},

    -- TODO IMPORTANT https://github.com/hrsh7th/nvim-cmp/issues/21#issuecomment-905470207
    -- `{ "i", "s", }` ?
    -- https://github.com/hrsh7th/nvim-cmp/issues/90
    -- NOTE <CR> for `map.confirm` is handled by nvim-autopairs
    -- NOTE For custom function, use require('cmp').function, not require('cmp.mapping').function
    mapping = {
        ['<m-k>'] = map.select_prev_item(),
        ['<m-j>'] = map.select_next_item(),
        ['<c-d>'] = map.scroll_docs(4),   -- Scroll down
        ['<c-f>'] = map.scroll_docs(-4),  -- Scroll up
        ['<CR>']  = map.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
        }),
        ['<m-space>'] = function()
            if not cmp.visible() then
                cmp.complete()
            else
                cmp.close()
            end
        end,
        ['<tab>'] = function(fallback)  -- TODO Doesn't work for latex
          if luasnip.expand_or_jumpable() then
              fn.feedkeys(T('<plug>luasnip-expand-or-jump'), '')
          elseif cmp.visible() then
              cmp.confirm({
                  behavior = cmp.ConfirmBehavior.Replace,
                  select = true,
              })
          elseif check_backspace() then
              fn.feedkeys(T('<Tab>'), 'n')
          else
              cmp.complete()
          end
        end,
        ['<s-tab>'] = function(fallback)
          if luasnip.jumpable(-1) then
              fn.feedkeys(T('<plug>luasnip-jump-prev'), '')
          elseif cmp.visible() then
              cmp.select_prev_item()
          else
              fallback()
          end
        end,
        -- Toggle doc
        ['<c-g>'] = function()
          if cmp.visible_docs() then
            cmp.close_docs()
          else
            cmp.open_docs()
          end
        end
    },

    formatting = {
      fields = { 'kind', 'abbr', 'menu' },  -- kind (e.g. symbol and/or text), "text", menu
      format = function(entry, vim_item)

          local kind = require('lspkind').cmp_format({
              mode = 'symbol',
              maxwidth = 50
          })(entry, vim_item)

          kind.kind = kind.kind .. ' '

          -- Name of source
          kind.menu = ({
            nvim_lsp = ' LSP',
            luasnip  = ' Snip',
            -- buffer   = ' B',
            -- path     = ' P'
          })[entry.source.name]

          -- Handle duplicates. Set 1 to show item, set 0 to hide item.
          kind.dup = ({
            nvim_lsp = 1,
            luasnip  = 1,
            -- buffer   = 1,
            -- path     = 1,
          })[entry.source.name] or 0

          return kind
      end,
    },

    -- TODO https://github.com/hrsh7th/nvim-cmp/issues/32
    sources = {  -- NOTE Order determines priority of duplicates
        {name = 'luasnip'},
        {name = 'nvim_lsp'},
        {name = 'latex_symbols'},
        -- {name = 'path'},  -- TODO
        -- {name = 'buffer',
        --   option = {
        --     get_bufnrs = function()
        --       local bufs = {}
        --       for _, win in ipairs(vim.api.nvim_list_wins()) do
        --         bufs[vim.api.nvim_win_get_buf(win)] = true
        --       end
        --       return vim.tbl_keys(bufs)
        --     end
        --   }
        -- },
    },
})





-- Backup ----------------------------------------

-- get_trigger_characters = function(trigger_characters)
--   return vim.tbl_filter(function(char)
--     return char ~= ' '
--   end, trigger_characters)
-- end,


-- mapping = {
--   ['<CR>'] = function(fallback)
--     local complete_info = vim.fn.complete_info()
--     local selected = complete_info.selected

--     if vim.fn['vsnip#expandable']() ~= 0 then
--       vim.fn.feedkeys(utils.esc('<Plug>(vsnip-expand)'), '')
--       return
--     end

--     if vim.fn.pumvisible() ~= 0 and selected ~= -1 then
--       cmp.confirm()
--       return
--     end

--     if vim.fn.pumvisible() ~= 0 then
--       vim.fn.feedkeys(utils.esc('<C-e><Plug>delimitMateCR'), '')
--       return
--     end

--     fallback()
--   end
