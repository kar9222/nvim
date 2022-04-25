-- Neovim's minimal config template for debugging/testing/etc. Starts nvim with
-- nvim --clean -u ~/.config/nvim/dev/test_init.lua

-- Add plugins to `load_plugins` (see tag 'PLUGINS') and config to `_G.load_config` (see tag 'CONFIG'), as appropriate. For more robust debugging/testing/etc, add as minimal things as possible. For more complicated debugging, if needed, create and source another file in dev/ directory.

-- When done, remove everything (e.g. git checkout this file).


-- Initial setup ---------------------------------

-- Init and load config towards the end

local fn = vim.fn
local api = vim.api

vim.cmd [[set runtimepath=$VIMRUNTIME]]
vim.cmd [[set packpath=/tmp/nvim/site]]

local package_root = '/tmp/nvim/site/pack'
local install_path = package_root .. '/packer/start/packer.nvim'

local function load_plugins()
  require('packer').startup {
    {
      'wbthomason/packer.nvim',
      '~/libs/minimalist.nvim',
      -- PLUGINS
      'kyazdani42/nvim-tree.lua',
    },
    config = {
      package_root = package_root,
      compile_path = install_path .. '/plugin/packer_compiled.lua',
    },
  }
end


-- Config ----------------------------------------

_G.load_config = function()
  require('minimalist').set()

  -- Convenience options and keybinds
  vim.g.mapleader = ' '
  vim.o.splitright = true
  opts = {noremap = true, silent = true}
  vim.g.mapleader = ' '
  api.nvim_set_keymap('n', ';', ':', opts)
  api.nvim_set_keymap('i', '<f10>', '<esc>', opts)

  -- CONFIG
  -- pcall(require, 'plugins/nvimtree')
  require('nvimtree')
end


-- Init and load config --------------------------

if fn.isdirectory(install_path) == 0 then
  fn.system {
    'git', 'clone', 'git@github.com:wbthomason/packer.nvim.git', install_path
  }
  load_plugins()
  require('packer').sync()
  vim.cmd [[au User PackerComplete ++once lua load_config()]]
else
  load_plugins()
  require('packer').sync()
  _G.load_config()
end
