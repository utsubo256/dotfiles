return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  ft = { 'markdown', 'telekasten' },
  config = function()
    vim.treesitter.language.register('markdown', 'telekasten')
    require('render-markdown').setup {
      file_types = { 'markdown', 'telekasten' },
      heading = {
        icons = {},
        sign = false,
        backgrounds = {},
      },
    }
  end,
}
