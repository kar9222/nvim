-- Boostrapping: Automatically ensure that packer.nvim is installed on any machine
-- TODO Put this at Makefile?
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', 'git@github.com:wbthomason/packer.nvim.git', install_path})
    vim.cmd('packadd packer.nvim')
end

-- Auto-compile when there are changes in `plugins.lua`
vim.cmd('autocmd BufWritePost plugins.lua PackerCompile')

-- TODO All commented out plugins
Packer = require('packer')
Packer.startup(function()
    use 'wbthomason/packer.nvim'  -- Packer can manage itself

    -- Utils
    use 'svermeulen/vimpeccable'
    use 'nvim-lua/plenary.nvim'  -- TODO Need?
    use 'nvim-lua/popup.nvim'  -- Required by (at least) telescope.nvim
    use 'rafcamlet/nvim-luapad'  -- Required by (at least) galaxyline.nvim

    -- Appearance
    use '~/libs/minimalist.nvim'
    use 'ryanoasis/vim-devicons'
    use { 'kyazdani42/nvim-web-devicons', commit = '0922d7d' } -- use 'yamatsum/nvim-nonicons'  -- TODO
    -- use 'mortepau/codicons.nvim'  -- TODO might solve codicons https://github.com/mortepau/codicons.nvim#configuration
    use 'kyazdani42/nvim-tree.lua'     -- File explorer TODO ms-jpq/chadtree
    use '~/libs/feline.nvim'  -- Statusline TODO 'famiu/feline.nvim'
    use 'akinsho/nvim-bufferline.lua'  -- Buffer bar

    -- Window/buffer
    use 'moll/vim-bbye'  -- TODO famiu/bufdelete.nvim
    -- TODO https://github.com/nrobinaubertin/dotfiles/blob/master/.config/nvim/init.vim#L47

    -- Editing
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            { 'https://gitlab.com/ExpandingMan/cmp-latex', commit = '88d7618a' },  -- Julia's (incomplete) latex list is sufficient for me
            -- 'hrsh7th/cmp-buffer',  -- Buffer completion source
        }
    }
    use 'ray-x/lsp_signature.nvim'  -- Signature
    use 'windwp/nvim-autopairs'
    use 'saadparwaiz1/cmp_luasnip'  -- Snippets
    use 'L3MON4D3/LuaSnip'          -- Snippets
    use 'folke/trouble.nvim'  -- List for diagnostics/references/etc
    -- use {'zeertzjq/coq_nvim', branch = 'coq-marks-available'}  -- TODO Issue #242 {'ms-jpq/coq_nvim', branch = 'coq'}
    -- Manually `:COQdeps` install all deps (including python's) locally in .../packer/start/coq_nvim/.vars.
    -- To remove deps, remove .../coq_nvim/

    use 'ggandor/lightspeed.nvim'
    use 'easymotion/vim-easymotion'
    use 'tpope/vim-surround'
    use 'wellle/targets.vim'
    use 'junegunn/vim-easy-align'
    use 'chaoren/vim-wordmotion'
    use 'sk1418/Join'
    use 'tpope/vim-repeat'
    use 'b3nj5m1n/kommentary'
    -- use "godlygeek/tabular"
    -- Family of {vim-easyclip}
    use 'svermeulen/vim-cutlass'
    use 'svermeulen/vim-subversive'
    use '~/libs/vim-yoink'  -- TODO 'svermeulen/vim-yoink' See arch_wsl_3

    -- Language and files
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'JuliaEditorSupport/julia-vim'
    use 'eigenfoo/stan-vim'
    use 'cespare/vim-toml'
    use "chrisbra/csv.vim"
    -- use "gennaro-tedesco/nvim-jqx"
    -- Pandoc, markdown TODO Do I need all?
    use 'vim-pandoc/vim-pandoc'
    use 'vim-pandoc/vim-pandoc-syntax'
    use '~/libs/vim-rmarkdown'  -- TODO 'vim-pandoc/vim-rmarkdown'

    use 'simrat39/symbols-outline.nvim'

    -- use 'SirVer/ultisnips'  -- Snippets

    -- LSP. TODO Explore nvim-lsputils
    use 'neovim/nvim-lspconfig'
    use 'tami5/lspsaga.nvim'  -- TODO Use maintained fork of glepnir/lspsaga.nvim
    use 'onsails/lspkind-nvim'  -- TODO Use my own scripts
    use 'folke/neodev.nvim'
    -- use 'jose-elias-alvarez/null-ls.nvim'  -- TODO

    -- Terminal, REPL
    use 'kassio/neoterm'  -- TODO voldikss/vim-floaterm
    use 'akinsho/nvim-toggleterm.lua'  -- TODO Remove toggleterm
    use 'nikvdp/neomux'

    use 'folke/which-key.nvim'

    -- Search
    use 'nvim-telescope/telescope.nvim'
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'}  -- Use fzf sorter for performance and better sorting algo
    use 'ThePrimeagen/harpoon'
    use 'windwp/nvim-spectre'

    -- todo comments
    -- use 'folke/todo-comments.nvim'

    -- Git TODO Wrap delta
    use 'TimUntersberger/neogit'  -- TODO rcarriga/nvim-notify
    use 'lewis6991/gitsigns.nvim'

    use 'axelf4/vim-strip-trailing-whitespace'  -- NOTE See config at startup.lua

    -- Others
    -- use 'lewis6991/foldsigns.nvim'  -- TODO
    -- use 'nvim-colorizer.lua'

    -- use 'hrsh7th/nvim-compe'  -- TODO

    use({
      'epwalsh/obsidian.nvim',
      tag = '*',  -- recommended, use latest release instead of latest commit
      requires = {  -- see below for full list of optional dependencies
        'nvim-lua/plenary.nvim',
      },
    })

end)
