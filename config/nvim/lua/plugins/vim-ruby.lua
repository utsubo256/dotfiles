return {
  'vim-ruby/vim-ruby',
  ft = 'ruby',
  init = function()
    -- Disable vim-ruby's motion/text-object mappings; treesitter-textobjects handles them
    vim.g.no_ruby_maps = 1
  end,
}
