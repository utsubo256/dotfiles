-- set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- disable the spacebar key's default behavior in normal and visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- default options for keymaps
local ops = { noremap = true, silent = true }

-- save file without auto-formatting
vim.keymap.set('n', '<leader>ns', '<cmd>noautocmd w<CR>', ops)

-- buffers
vim.keymap.set('n', '<Tab>', ':bnext<CR>', ops)
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', ops)
vim.keymap.set('n', '<leader>x', ':Bdelete!<CR>', ops)
vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', ops)

-- windows
vim.keymap.set('n', '<leader>v', '<C-w>v', ops)
vim.keymap.set('n', '<leader>h', '<C-w>s', ops)
vim.keymap.set('n', '<leader>se', '<C-w>=', ops)
vim.keymap.set('n', '<leader>xs', ':close<CR>', ops)

-- navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', ops)
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', ops)
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', ops)
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', ops)

-- tabs
vim.keymap.set('n', '<leader>to', ':tabnew<CR>', ops)
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', ops)
vim.keymap.set('n', '<leader>tn', ':tabn<CR>', ops)
vim.keymap.set('n', '<leader>tp', ':tabp<CR>', ops)

-- toggle line wrapping
vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', ops)

-- stay in indent mode
vim.keymap.set('v', '<', '<gv', ops)
vim.keymap.set('v', '>', '>gv', ops)

-- diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })
