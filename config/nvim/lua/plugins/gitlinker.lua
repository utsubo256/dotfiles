-- TODO: This is a workaround for two issues in gitlinker's default rev resolution:
--   1. On detached HEAD at a tag, it walks back to the nearest remote-reachable commit
--      (e.g. `git checkout v4.0.3` yields v4.0.2's hash instead of the tag).
--   2. On a named branch whose tip is tagged, it uses the tag instead of the commit hash.
-- Ideally these should be fixed in gitlinker.nvim itself.
--
-- Current behavior: use tag only on detached HEAD, always use commit hash on a named branch.
local function git_rev()
  local is_detached = vim.trim(vim.fn.system 'git symbolic-ref --quiet HEAD 2>/dev/null') == ''
  if is_detached then
    local tag = vim.trim(vim.fn.system 'git describe --tags --exact-match HEAD 2>/dev/null')
    if vim.v.shell_error == 0 and tag ~= '' then
      return tag
    end
  end
  return vim.trim(vim.fn.system 'git rev-parse HEAD')
end

return {
  'linrongbin16/gitlinker.nvim',
  cmd = 'GitLink',
  opts = {},
  keys = {
    {
      '<leader>gy',
      function()
        vim.cmd('GitLink rev=' .. git_rev())
      end,
      mode = { 'n', 'v' },
      desc = 'Yank git link',
    },
    {
      '<leader>gY',
      function()
        vim.cmd('GitLink! rev=' .. git_rev())
      end,
      mode = { 'n', 'v' },
      desc = 'Open git link',
    },
  },
}
