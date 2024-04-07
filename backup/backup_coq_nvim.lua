-- To use coq_nvim, disable cmp.lua and autopairs.lua
-- Defaults config at https://github.com/ms-jpq/coq_nvim/blob/coq/config/defaults.yml

local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false })

vim.g.coq_settings = {
    auto_start = 'shut-up',  -- Auto-start and suppress message
    limits = {
        completion_auto_timeout = 250,  -- TODO
        completion_manual_timeout = 250,
        idle_timeout = 250,
    },
    match = {
        exact_matches = 3,
        unifying_chars = {'Z'},
    },
    clients = {
        lsp = {
            enabled = true,
            short_name = '',
            resolve_timeout = 250,
            -- weight_adjust = 0.3,
        },
    },
    keymap = {
        recommended = false,  -- Disable default
        pre_select = true,
        manual_complete = '<m-space>',
        bigger_preview = '<c-k>',
        -- -- repeat = '.',  -- TODO
        -- eval_snips = true,  -- TODO
        jump_to_mark = '<leader><tab>',  -- Dummy key for mapping <tab> defined below. TODO Tmp workaround. See issues #242
    },
    display = {  -- TODO
        pum = {
            fast_close = false
        },
    },

}

-- these mappings are coq recommended mappings unrelated to nvim-autopairs
-- TODO <c-e> issues
remap('i', '<esc>',   [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
remap('i', '<c-c>',   [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]],       { expr = true, noremap = true })
-- remap('i', '<tab>',   [[pumvisible() ? "<c-n>" : "<tab>"]],      { expr = true, noremap = true })

-- skip it, if you use another global object
_G.MUtils= {}

MUtils.CR = function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
      return npairs.esc('<c-y>')
    else
      return npairs.esc('<c-e>') .. npairs.autopairs_cr()
    end
  else
    return npairs.autopairs_cr()
  end
end
remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

MUtils.BS = function()
  if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
    return npairs.esc('<c-e>') .. npairs.autopairs_bs()
  else
    return npairs.autopairs_bs()
  end
end
remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })
remap('i', '<c-h>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })
-- vimp.imap('<c-h>', '<bs>')  -- Auto-remove pairs


local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.tab_complete = function()
    if _G.COQ.Marks_available() == true then  -- Wrong?
        return t '<leader><tab>'  -- TODO
    elseif vim.fn.pumvisible() == 1 then
        return MUtils.CR()
        -- return t '<c-n>'
    else
        return t '<tab>'
    end
end

vim.api.nvim_set_keymap('n', '<tab>', 'v:lua.tab_complete()', {expr = true})
vim.api.nvim_set_keymap('i', '<tab>', 'v:lua.tab_complete()', {expr = true})
vim.api.nvim_set_keymap('s', '<tab>', 'v:lua.tab_complete()', {expr = true})


