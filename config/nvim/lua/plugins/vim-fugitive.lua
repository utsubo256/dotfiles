-- Commit / branch / remote operations
-- ──────────────────────────────────────────────────────────────
-- <leader>gg  git status (`:Git`)
-- <leader>gc  git commit
-- <leader>gC  git commit -a (stage all + commit)
-- <leader>gP  git push
-- <leader>gL  git pull
-- <leader>gf  git fetch
-- ──────────────────────────────────────────────────────────────
return {
  'tpope/vim-fugitive',
  keys = {
    { '<leader>gg', '<cmd>Git<CR>',          desc = 'Git: status' },
    { '<leader>gc', '<cmd>Git commit<CR>',    desc = 'Git: commit' },
    { '<leader>gC', '<cmd>Git commit -a<CR>', desc = 'Git: commit all' },
    { '<leader>gP', '<cmd>Git push<CR>',      desc = 'Git: push' },
    { '<leader>gL', '<cmd>Git pull<CR>',      desc = 'Git: pull' },
    { '<leader>gf', '<cmd>Git fetch<CR>',     desc = 'Git: fetch' },
  },
}
