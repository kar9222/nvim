require'harpoon'.setup({
    global_settings = {
        save_on_toggle = false,  -- Sets the marks upon calling `toggle` on the ui, instead of require `:w`.
        save_on_change = true,  -- Saves the harpoon file upon every change. Disabling is unrecommended.
        enter_on_sendcmd = false,  -- Sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
        excluded_filetypes = { 'harpoon' }  -- Filetypes that you want to prevent from adding to the harpoon list menu.
    }
})

require'telescope'.load_extension('harpoon')  -- Register as telescope extension

vimp.nnoremap('<c-[>', "<cmd>lua require'harpoon.ui'.nav_prev()<CR>")
vimp.nnoremap('<c-]>', "<cmd>lua require'harpoon.ui'.nav_next()<CR>")

whichkey.register({
    name = 'harpoon',
    o = {"<cmd>Telescope harpoon marks<CR>", 'telescope marks'},
    i = {"<cmd>lua require'harpoon.ui'.toggle_quick_menu()<CR>", 'view and manage marks'},
    a = {"<cmd>lua require'harpoon.mark'.add_file()<CR>", 'mark file'},
}, {prefix = '<leader>o', noremap = true})

whichkey.register({
    name = 'navigate to harpoon file',
    ['1'] = {"<cmd>lua require'harpoon.ui'.nav_file(1)<CR>", 'navigate to harpoon file 1'},
    ['2'] = {"<cmd>lua require'harpoon.ui'.nav_file(2)<CR>", 'navigate to harpoon file 2'},
    ['3'] = {"<cmd>lua require'harpoon.ui'.nav_file(3)<CR>", 'navigate to harpoon file 3'},
    ['4'] = {"<cmd>lua require'harpoon.ui'.nav_file(4)<CR>", 'navigate to harpoon file 4'},
    ['5'] = {"<cmd>lua require'harpoon.ui'.nav_file(5)<CR>", 'navigate to harpoon file 5'},
    ['6'] = {"<cmd>lua require'harpoon.ui'.nav_file(6)<CR>", 'navigate to harpoon file 6'},
    ['7'] = {"<cmd>lua require'harpoon.ui'.nav_file(7)<CR>", 'navigate to harpoon file 7'},
    ['8'] = {"<cmd>lua require'harpoon.ui'.nav_file(8)<CR>", 'navigate to harpoon file 8'},
    ['9'] = {"<cmd>lua require'harpoon.ui'.nav_file(9)<CR>", 'navigate to harpoon file 9'},
}, {prefix = '<leader>', noremap = true})
