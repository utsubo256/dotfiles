return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostic disable: missing-fields
  opts = {
    git = {
      branches = {
        cmd_add = { "git", "checkout", "-b" }, -- ctrl-a: create + checkout (default: create only)
      },
    },
    previewers = {
      builtin = {
        treesitter = {
          enabled = true,
          context = false,
        },
      },
    },
    keymap = {
      builtin = {
        ['<C-d>'] = 'preview-page-down',
        ['<C-u>'] = 'preview-page-up',
      },
      fzf = {
        ['ctrl-d'] = 'preview-page-down',
        ['ctrl-u'] = 'preview-page-up',
      },
    },
  },
  ---@diagnostic enable: missing-fields
  config = function(_, opts)
    local fzf = require('fzf-lua')
    fzf.setup(opts)
    fzf.register_ui_select()
  end,
  keys = {
    { '<leader>sf', '<cmd>FzfLua files<CR>', desc = '[S]earch [F]iles' },
    { '<leader>sg', '<cmd>FzfLua live_grep<CR>', desc = '[S]earch by [G]rep' },
    { '<leader>sw', '<cmd>FzfLua grep_cword<CR>', desc = '[S]earch current [W]ord' },
    { '<leader>sh', '<cmd>FzfLua help_tags<CR>', desc = '[S]earch [H]elp' },
    { '<leader>sk', '<cmd>FzfLua keymaps<CR>', desc = '[S]earch [K]eymaps' },
    { '<leader>ss', '<cmd>FzfLua builtin<CR>', desc = '[S]earch [S]elect FzfLua' },
    { '<leader>sd', '<cmd>FzfLua diagnostics_workspace<CR>', desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', '<cmd>FzfLua resume<CR>', desc = '[S]earch [R]esume' },
    { '<leader>s.', '<cmd>FzfLua oldfiles<CR>', desc = '[S]earch Recent Files' },
    { '<leader><leader>', '<cmd>FzfLua buffers<CR>', desc = 'Find existing buffers' },
    { '<leader>/', '<cmd>FzfLua blines<CR>', desc = '[/] Fuzzily search in current buffer' },
    { '<leader>s/', '<cmd>FzfLua grep_open_buffers<CR>', desc = '[S]earch [/] in Open Files' },
    { '<leader>gw', '<cmd>FzfLua git_branches<CR>',     desc = 'Git: switch branch' },
    {
      '<leader>sn',
      function()
        require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })
      end,
      desc = '[S]earch [N]eovim files',
    },
    { '<leader>sq', '<cmd>FzfLua quickfix<CR>', desc = '[S]earch [Q]uickfix' },
  },
}
