-- ═══════════════════════════════════════════════════════════════
-- GITSIGNS - Git diff workflow for reviewing AI/OpenCode changes
-- ═══════════════════════════════════════════════════════════════
require('gitsigns').setup({
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,  -- Show git signs in the sign column
  numhl      = false, -- Don't highlight line numbers
  linehl     = false, -- Don't highlight lines
  word_diff  = false, -- Disable word diff by default
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = true,
  current_line_blame = false, -- Disable inline git blame by default
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
  },
  preview_config = {
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },

  -- ═══════════════════════════════════════════════════════════════
  -- KEY MAPPINGS - Perfect for reviewing OpenCode changes
  -- ═══════════════════════════════════════════════════════════════
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation - Jump between hunks (changed blocks)
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = 'Next git change' })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = 'Previous git change' })

    -- Actions - Accept or reject changes
    map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk (accept change)' })
    map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk (reject change)' })
    map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Stage selected lines' })
    map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Reset selected lines' })
    
    -- Stage/unstage all changes in current buffer
    map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage entire buffer' })
    map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
    map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset entire buffer' })

    -- Preview changes inline (popup window)
    map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk changes' })
    map('n', '<leader>hP', gs.preview_hunk_inline, { desc = 'Preview hunk inline' })

    -- Blame
    map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = 'Show git blame' })
    map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle inline blame' })

    -- Diff view
    map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this file' })
    map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'Diff against HEAD' })

    -- Toggle deleted lines view
    map('n', '<leader>td', gs.toggle_deleted, { desc = 'Toggle deleted lines' })

    -- Text object - operate on hunks
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
  end
})

-- ═══════════════════════════════════════════════════════════════
-- WORKFLOW SUMMARY
-- ═══════════════════════════════════════════════════════════════
-- After OpenCode makes changes:
--
-- 1. Navigate changes:    ]c / [c
-- 2. Preview change:      <leader>hp (popup) or <leader>hP (inline)
-- 3. Accept change:       <leader>hs (stage hunk)
-- 4. Reject change:       <leader>hr (reset hunk)
-- 5. Accept entire file:  <leader>hS
-- 6. Reject entire file:  <leader>hR
--
-- Visual mode workflow:
-- - Select lines in visual mode
-- - <leader>hs to accept selected lines only
-- - <leader>hr to reject selected lines only
-- ═══════════════════════════════════════════════════════════════
