-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/kar/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?.lua;/home/kar/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?/init.lua;/home/kar/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?.lua;/home/kar/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/kar/.cache/nvim/packer_hererocks/2.0.5/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  Join = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/Join"
  },
  LuaSnip = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/LuaSnip"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/cmp-buffer"
  },
  ["cmp-latex"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/cmp-latex"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/cmp_luasnip"
  },
  ["csv.vim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/csv.vim"
  },
  ["feline.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/feline.nvim"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["julia-vim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/julia-vim"
  },
  kommentary = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/kommentary"
  },
  ["lightspeed.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/lightspeed.nvim"
  },
  ["lsp_signature.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/lsp_signature.nvim"
  },
  ["lspkind-nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/lspkind-nvim"
  },
  ["lspsaga.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/lspsaga.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/lua-dev.nvim"
  },
  ["minimalist.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/minimalist.nvim"
  },
  neogit = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/neogit"
  },
  neomux = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/neomux"
  },
  neoterm = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/neoterm"
  },
  ["nvim-autopairs"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-autopairs"
  },
  ["nvim-bufferline.lua"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-bufferline.lua"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-luapad"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-luapad"
  },
  ["nvim-spectre"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-spectre"
  },
  ["nvim-toggleterm.lua"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-toggleterm.lua"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["stan-vim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/stan-vim"
  },
  ["symbols-outline.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/symbols-outline.nvim"
  },
  ["targets.vim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/targets.vim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["trouble.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/trouble.nvim"
  },
  ["vim-bbye"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-bbye"
  },
  ["vim-cutlass"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-cutlass"
  },
  ["vim-devicons"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-devicons"
  },
  ["vim-easy-align"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-easy-align"
  },
  ["vim-easymotion"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-easymotion"
  },
  ["vim-pandoc"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-pandoc"
  },
  ["vim-pandoc-syntax"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-pandoc-syntax"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-repeat"
  },
  ["vim-rmarkdown"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-rmarkdown"
  },
  ["vim-strip-trailing-whitespace"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-strip-trailing-whitespace"
  },
  ["vim-subversive"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-subversive"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-toml"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-toml"
  },
  ["vim-wordmotion"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-wordmotion"
  },
  ["vim-yoink"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vim-yoink"
  },
  vimpeccable = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/vimpeccable"
  },
  ["which-key.nvim"] = {
    loaded = true,
    path = "/home/kar/.local/share/nvim/site/pack/packer/start/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
