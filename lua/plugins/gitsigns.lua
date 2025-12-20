local gitsigns = require('gitsigns')

gitsigns.setup {
    signs = {  -- TODO Customize M.apply_word_diff of manager.lua?
    add          = {hl = 'GitSignsAdd'   , text = '▎', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '▎', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '▎', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '▎', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '▎', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  signcolumn = true,  -- Toggle with `:gitsigns toggle_signs`
  numhl      = false,  -- Toggle with `:gitsigns toggle_numhl`
  linehl     = false,  -- Toggle with `:gitsigns toggle_linehl`
  word_diff  = false,  -- Toggle with `:gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
  },
  current_line_blame_formatter_opts = {
    relative_time = false
  },
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {  -- Options passed to nvim_open_win
    border = border,
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  -- diff_opts.internal = true,  -- If vim.diff or luajit is present TODO See pull #357. No need anymore?
  yadm = { enable = false },

  on_attach = function(bufnr)  -- NOTE Similar keybinds as telescope's git actions
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Text objects -----------------------------

    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

    -- Navigation -------------------------------

    map('n', '<m-b>', function()
      if vim.wo.diff then
        vim.cmd.normal({ '<m-b>', bang = true })
      else
        gs.nav_hunk('prev', { wrap = false })
      end
    end)

    map('n', '<m-n>', function()
      if vim.wo.diff then
        vim.cmd.normal({ '<m-n>', bang = true })
      else
        gs.nav_hunk('next', { wrap = false })
      end
    end)

    map('n', '<m-s-b>', function()
      if vim.wo.diff then
        vim.cmd.normal({ '<m-s-b>', bang = true })
      else
        gs.nav_hunk('prev', { preview = true, wrap = false })
      end
    end)

    map('n', '<m-s-n>', function()
      if vim.wo.diff then
        vim.cmd.normal({ '<m-s-n>', bang = true })
      else
        gs.nav_hunk('next', { preview = true, wrap = false })
      end
    end)

    -- Git actions ------------------------------

    map('n', '<leader>gs', gs.stage_hunk)
    map('v', '<leader>gs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<leader>gu', gs.undo_stage_hunk)
    map('n', '<leader>gr', gs.reset_hunk)
    map('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<leader>gR', gs.reset_buffer)
    map('n', '<leader>gU', gs.reset_buffer_index)
    map('n', '<leader>gS', gs.stage_buffer)

    map('n', '<leader>gtd', gs.diffthis)
    map('n', '<leader>gtD', function() gs.diffthis('~') end)


    -- Git decoration ---------------------------

    -- toggle_linehl overrides toggle_word_diff, hence this two can't work together
    -- but toggle_word_diff and toggle_deleted can work together
    -- Hence I use these two combinations:

    -- Toggle line highlight, word diff, deleted lines and num highlight
    -- This is almost the same as git delta, except:
    -- - git delta is still a better diffs visualizer
    -- - Word resolutions are not visible for changed lines
    map('n', '<leader>gn',  function()
        gs.toggle_linehl()
        gs.toggle_word_diff()
        gs.toggle_deleted()
        gs.toggle_numhl()
    end )

    -- When the above key is triggered, to see word diff for changed lines,
    -- use this key to turn off line highlight (because line highlight overrides word diffs)
    -- This results in only word diffs + deleted lines + num highlights are visible.
    -- To return to the combination above, toggle this key again to show line highlight, but word diffs for changed lines are not visible.
    -- Hence, this key and the key above can be used together.
    map('n', '<leader>gw',  gs.toggle_linehl)

    map('n', '<leader>gf',  gs.preview_hunk_inline)
    map('n', '<leader>gg',  gs.preview_hunk)

    map('n', '<leader>gtb', gs.toggle_current_line_blame)
    map('n', '<leader>gB',  function() gs.blame_line({true, true}) end)

    map('n', '<leader>gd',  gs.toggle_deleted)
    map('n', '<leader>gtn', gs.toggle_numhl)
    map('n', '<leader>gts', gs.toggle_signs)
  end
}









-- Backup ---------------------------------------

-- Toggle word diff and deleted lines. For checking word diff, use this.
-- This is almost the same as git delta, except:
-- - git delta is still a better diffs visualizer
-- - Changed lines are not highlighted (only word diffs are highlighted)
-- - Added lines are not highlighted
-- map('n', '<leader>gw',  function()
--     gs.toggle_word_diff()
--     gs.toggle_deleted()
-- end )
