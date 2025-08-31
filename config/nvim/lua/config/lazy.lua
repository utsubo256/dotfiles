-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require('lazy').setup {
  require 'plugins.nord', -- a colorscheme
  require 'plugins.neo-tree', -- a file manager
  require 'plugins.bufferline', -- a buffer line
  require 'plugins.lualine', -- a statusline
  require 'plugins.treesitter', -- a Tree-sitter powered syntax parsing framework
  require 'plugins.telescope', -- a fuzzy finder
  require 'plugins.lspconfig', -- a configuration helper for Neovim's built-in LSP client
  require 'plugins.cmp', -- a completion engine
  require 'plugins.none-ls', -- a bridge external formatters/linters into Neovim through the LSP client
  require 'plugins.gitsigns', -- a git integration
  require 'plugins.alpha', -- a greeter
  require 'plugins.indent-blankline', -- an indentation guides
}
