-- File/commit level diff viewing and history
-- ──────────────────────────────────────────────────────────────
-- <leader>gd  open diffview (working tree changes)
-- <leader>gD  close diffview
-- <leader>gh  file history (current file)
-- <leader>gH  repo history (all files)
-- ──────────────────────────────────────────────────────────────
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<CR>',          desc = 'Git: open diffview' },
    { '<leader>gD', '<cmd>DiffviewClose<CR>',         desc = 'Git: close diffview' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'Git: file history' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<CR>',   desc = 'Git: repo history' },
  },
}
