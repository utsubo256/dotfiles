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
  },
  config = function()
    local dap = require 'dap'

    -- Ruby (rdbg via debug.gem)
    require('dap-ruby').setup()
  end,
}
