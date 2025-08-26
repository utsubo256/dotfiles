return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function ()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
        ensure_installed = { "awk", "bash", "c", "css", "csv", "diff", "dockerfile", "elixir", "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore", "go", "gpg", "graphql", "heex", "html", "javascript", "jq", "json", "lua", "make", "markdown", "markdown_inline", "mermaid", "nginx", "sql", "todotxt", "toml", "tsx", "typescript", "udev", "query", "vim", "vimdoc", "yaml" },
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
          additional_vim_regex_highlighting = { "ruby" },
        },
        indent = { enable = true, disable = { "ruby" } },
      })
  end
}
