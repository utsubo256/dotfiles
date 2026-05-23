return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'suketa/nvim-dap-ruby',
  },
  keys = {
    { '<leader>dc', function() require('dap').continue() end, desc = 'Debug: [C]ontinue' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle [B]reakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Conditional [B]reakpoint' },
    { '<leader>dr', function() require('dap').repl.open({ height = math.floor(vim.o.lines / 4) }) end, desc = 'Debug: Open [R]EPL' },
    { '<F5>',  function() require('dap').continue() end,  desc = 'Debug: Continue',        mode = { 'n', 'i', 't' } },
    { '<F10>', function() require('dap').step_over() end,  desc = 'Debug: Next (Step Over)', mode = { 'n', 'i', 't' } },
    { '<F11>', function() require('dap').step_into() end,  desc = 'Debug: Step Into',        mode = { 'n', 'i', 't' } },
    { '<F12>', function() require('dap').step_out() end,   desc = 'Debug: Step Out',         mode = { 'n', 'i', 't' } },
  },
  config = function()
    local dap = require 'dap'

    -- Ruby (rdbg via debug.gem)
    require('dap-ruby').setup()

    -- C (GDB MI mode)
    dap.adapters.gdb = {
      type = 'executable',
      command = 'gdb',
      args = {
        '--interpreter=dap', '--quiet',
        '-iex', 'set $color_type = ""',
        '-iex', 'set $color_highlite = ""',
        '-iex', 'set $color_end = ""',
      },
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'dap-repl',
      callback = function() vim.wo.wrap = true end,
    })

    -- Disable built-in .vscode/launch.json loader (used by VS Code; nvim-dap uses root launch.json)
    dap.providers.configs['dap.launch.json'] = nil

    -- root-level launch.json provider (cwd/launch.json)
    dap.providers.configs['root_launch_json'] = function()
      local path = vim.fn.getcwd() .. '/launch.json'
      local ok, configs = pcall(require('dap.ext.vscode').getconfigs, path)
      if not ok or not configs then return {} end
      -- nvim-dap has no global default; stopAtBeginningOfMainSubprogram is a GDB DAP extension
      -- that stops at main() instead of _start (which has no source info)
      for _, config in ipairs(configs) do
        if config.stopAtBeginningOfMainSubprogram == nil then
          config.stopAtBeginningOfMainSubprogram = true
        end

      end
      return configs
    end

  end,
}
