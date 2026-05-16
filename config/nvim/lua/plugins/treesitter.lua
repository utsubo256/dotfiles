return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    'RRethy/nvim-treesitter-endwise',
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    local configs = require 'nvim-treesitter.configs'

    configs.setup {
      ensure_installed = {
        'awk',
        'bash',
        'c',
        'css',
        'csv',
        'diff',
        'dockerfile',
        'elixir',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gpg',
        'graphql',
        'heex',
        'html',
        'javascript',
        'jq',
        'json',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'mermaid',
        'nginx',
        'sql',
        'todotxt',
        'toml',
        'tsx',
        'typescript',
        'udev',
        'query',
        'vim',
        'vimdoc',
        'yaml',
        'ruby',
      },
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,

      ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
      -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

      -- modules (highlight, incremental selection, indentation, folding)
      highlight = {
        enable = true,

        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true, disable = { 'ruby' } },
      endwise = { enable = true },
    }

    require('nvim-treesitter-textobjects').setup { select = { lookahead = true } }

    local select = require 'nvim-treesitter-textobjects.select'
    local move = require 'nvim-treesitter-textobjects.move'

    vim.keymap.set({ 'x', 'o' }, 'im', function() select.select_textobject('@function.inner', 'textobjects') end)
    vim.keymap.set({ 'x', 'o' }, 'am', function() select.select_textobject('@function.outer', 'textobjects') end)
    vim.keymap.set({ 'x', 'o' }, 'ic', function() select.select_textobject('@class.inner', 'textobjects') end)
    vim.keymap.set({ 'x', 'o' }, 'ac', function() select.select_textobject('@class.outer', 'textobjects') end)

    vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() move.goto_next_start('@function.outer') end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() move.goto_next_end('@function.outer') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() move.goto_previous_start('@function.outer') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() move.goto_previous_end('@function.outer') end)

    -- Neovim 0.12.x changed the directive match API: match[capture_id] now returns TSNode[]
    -- instead of TSNode. nvim-treesitter's set-lang-from-info-string! hasn't been updated yet,
    -- causing "attempt to call method 'range' (a nil value)" errors in markdown injection parsing.
    vim.treesitter.query.add_directive(
      'set-lang-from-info-string!',
      function(match, _, bufnr, pred, metadata)
        local capture_id = pred[2]
        local nodes = match[capture_id]
        if not nodes or #nodes == 0 then
          return
        end
        local node = nodes[1]
        local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
        local ft_match = vim.filetype.match { filename = 'a.' .. injection_alias }
        metadata['injection.language'] = ft_match or injection_alias
      end,
      { force = true }
    )
  end,
}
