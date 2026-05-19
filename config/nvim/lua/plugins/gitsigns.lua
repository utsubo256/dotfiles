-- Hunk/line level git operations
-- ──────────────────────────────────────────────────────────────
-- ]c          next hunk
-- [c          prev hunk
-- <leader>gs  stage hunk  (visual: stage selected lines)
-- <leader>gr  reset hunk  (visual: reset selected lines)
-- <leader>gS  stage buffer
-- <leader>gR  reset buffer
-- <leader>gu  undo stage hunk
-- <leader>gp  preview hunk
-- <leader>gb  blame line (inline)
-- <leader>gB  blame line (full)
-- ih          select hunk (text object, o/x mode)
-- ──────────────────────────────────────────────────────────────
return {
  'lewis6991/gitsigns.nvim',
  opts = {
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Hunk navigation
      map('n', ']c', gs.next_hunk, 'Next hunk')
      map('n', '[c', gs.prev_hunk, 'Prev hunk')

      -- Stage / reset
      map('n', '<leader>gs', gs.stage_hunk, 'Git: stage hunk')
      map('n', '<leader>gr', gs.reset_hunk, 'Git: reset hunk')
      map('v', '<leader>gs', function() gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'Git: stage selected hunk')
      map('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'Git: reset selected hunk')
      map('n', '<leader>gS', gs.stage_buffer, 'Git: stage buffer')
      map('n', '<leader>gR', gs.reset_buffer, 'Git: reset buffer')
      map('n', '<leader>gu', gs.undo_stage_hunk, 'Git: undo stage hunk')

      -- Preview / blame
      map('n', '<leader>gp', gs.preview_hunk, 'Git: preview hunk')
      map('n', '<leader>gb', gs.blame_line, 'Git: blame line')
      map('n', '<leader>gB', function() gs.blame_line { full = true } end, 'Git: blame line (full)')

      -- Text object: ih = inner hunk (use in operator-pending / visual)
      map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
    end,
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    signs_staged = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
  },
}
