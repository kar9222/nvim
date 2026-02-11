# Fix for lspsaga.nvim Compatibility Issue

## Problem

Lspsaga.nvim fails with Neovim 0.10+ due to the removal of a private API function:

```
Error executing vim.schedule lua callback: .../lspsaga/window.lua:158: 
attempt to call field '_trim' (a nil value)
```

## Root Cause

Neovim 0.10+ removed `vim.lsp.util._trim()`, which was an internal/private function 
that lspsaga relied on. Private APIs can change or be removed without notice.

## How to Reproduce the Fix

### Step 1: Locate lspsaga installation

```bash
# Find where lspsaga is installed
ls ~/.local/share/nvim/site/pack/packer/start/lspsaga.nvim/lua/lspsaga/
```

### Step 2: Check current state

```bash
# Look for the problematic function calls
grep -n "vim.lsp.util._trim" ~/.local/share/nvim/site/pack/packer/start/lspsaga.nvim/lua/lspsaga/window.lua
grep -n "util._trim" ~/.local/share/nvim/site/pack/packer/start/lspsaga.nvim/lua/lspsaga/signaturehelp.lua
```

If these return results, the fix needs to be applied.

### Step 3: Apply Fix to window.lua

Edit `~/.local/share/nvim/site/pack/packer/start/lspsaga.nvim/lua/lspsaga/window.lua`:

**Add this function after line 1 (after `local M = {}`):**

```lua
-- FIX: vim.lsp.util._trim was removed in Neovim 0.10+
local function trim_empty_lines(lines)
  if not lines or #lines == 0 then return {} end
  local start = 1
  local finish = #lines
  while start <= finish and lines[start]:match("^%s*$") do
    start = start + 1
  end
  while finish >= start and lines[finish]:match("^%s*$") do
    finish = finish - 1
  end
  if start > finish then return {} end
  local result = {}
  for i = start, finish do
    table.insert(result, lines[i])
  end
  return result
end
```

**Replace line ~158 (becomes line 177 after adding function):**
```lua
-- FROM:
local content = vim.lsp.util._trim(contents)
-- TO:
local content = trim_empty_lines(contents)
```

**Replace line 293:**
```lua
-- FROM:
stripped = vim.lsp.util._trim(stripped)
-- TO:
stripped = trim_empty_lines(stripped)
```

**Add before `return M` (near end of file, around line 428):**
```lua
-- Export for use in other lspsaga modules
M.trim_empty_lines = trim_empty_lines
```

### Step 4: Apply Fix to provider.lua

Edit `~/.local/share/nvim/site/pack/packer/start/lspsaga.nvim/lua/lspsaga/provider.lua`:

**Replace line 422:**
```lua
-- FROM:
local current_win_lnum, last_lnum = pdata[3], pdata[4]
-- TO:
local current_win_lnum, last_lnum = pdata[2], pdata[3]
```

### Step 5: Apply Fix to signaturehelp.lua

Edit `~/.local/share/nvim/site/pack/packer/start/lspsaga.nvim/lua/lspsaga/signaturehelp.lua`:

**Replace line 54:**
```lua
-- FROM:
contents = util._trim(contents, opts)
-- TO:
contents = window.trim_empty_lines(contents)
```

### Step 6: Verify the fix

```bash
# Check no more _trim references exist
grep -r "_trim" ~/.local/share/nvim/site/pack/packer/start/lspsaga.nvim/lua/lspsaga/
# Should return nothing
```

### Step 7: Test in Neovim

```bash
# Open a Python file
nvim test_lsp.py

# Inside nvim:
# 1. Press 'K' on a function name (should show hover docs)
# 2. Type 'os.' and press <C-space> (should show completions)
# 3. Type function call like 'print(' (should show signature help)
```

## Files Modified Summary

| File | Lines Changed | Change |
|------|--------------|--------|
| `window.lua` | Add after line 1 | Add `trim_empty_lines()` function definition |
| `window.lua` | Line 177 | `vim.lsp.util._trim(contents)` → `trim_empty_lines(contents)` |
| `window.lua` | Line 293 | `vim.lsp.util._trim(stripped)` → `trim_empty_lines(stripped)` |
| `window.lua` | Before `return M` | Export function: `M.trim_empty_lines = trim_empty_lines` |
| `provider.lua` | Line 422 | Fix index bug: `pdata[3], pdata[4]` → `pdata[2], pdata[3]` |
| `signaturehelp.lua` | Line 54 | `util._trim(contents, opts)` → `window.trim_empty_lines(contents)` |

**Note:** Line numbers are AFTER applying the fix (function added at top shifts subsequent lines).

## Alternative Solutions

If fixes don't work, consider:

1. **Disable lspsaga** and use native LSP:
   ```lua
   -- In lsp.lua, change K mapping from:
   api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>Lspsaga hover_doc<CR>', opts)
   -- To:
   api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
   ```

2. **Update lspsaga** to a newer version that supports Neovim 0.10+

3. **Switch to lspsaga v2** (if available for your Neovim version)

## Date Fixed

2026-02-11

## Neovim Version

Tested on Neovim 0.10+ (where `vim.lsp.util._trim` was removed)
