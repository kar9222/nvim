local fn = vim.fn

local win_username = 'kar'  -- TODO
fn.setenv('ZoteroSQLpath',
          '/mnt/c/users/' .. win_username .. '/Zotero/zotero.sqlite')

fn.setenv('ZCitationTemplate', '{Authors}_{Year}_{Title}')


-- Completion source for nvim-cmp ---------------

require'cmp_zotcite'.setup({
    filetypes = { 'markdown', 'quarto', }
})
