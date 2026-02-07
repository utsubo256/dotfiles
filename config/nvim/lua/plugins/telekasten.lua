return {
  'renerocksai/telekasten.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    local base_path = vim.fn.expand '~/ghq/github.com/utsubo256/zett'
    local notes_path = base_path .. '/notes'
    local project_path = notes_path .. '/projects'
    local schedule_path = notes_path .. '/schedules'
    require('telekasten').setup {
      -- Main paths
      home = notes_path,
      backlog = project_path .. 'backlog/',
      doing = project_path .. 'doing/',
      done = project_path .. 'done/',
      dailies = schedule_path .. '/dailies',
      weeklies = schedule_path .. '/weeklies',
      templates = base_path .. '/templates',
      template_new_daily = base_path .. '/templates/daily.md',

      tag_notation = '@tag',

      -- Enable subdirectories in links
      subdirs_in_links = true,

      -- Extension for markdown files
      extension = '.md',

      -- Take subdirectories into account when linking
      take_over_my_home = true,

      media_previewer = 'viu-previewer',
      auto_set_syntax = true,
      auto_set_filetype = true,
      conceallevel = 2,
    }
    -- Launch panel if nothing is typed after <leader>z
    vim.keymap.set('n', '<leader>z', '<cmd>Telekasten panel<CR>')

    -- Most used functions
    vim.keymap.set('n', '<leader>zf', '<cmd>Telekasten find_notes<CR>')
    vim.keymap.set('n', '<leader>zg', '<cmd>Telekasten search_notes<CR>')
    vim.keymap.set('n', '<leader>zd', '<cmd>Telekasten goto_today<CR>')
    vim.keymap.set('n', '<leader>zz', '<cmd>Telekasten follow_link<CR>')
    vim.keymap.set('n', '<leader>zn', function()
      vim.ui.input({ prompt = 'Note title: ' }, function(title)
        if not title or title == '' then
          return
        end
        local script = base_path .. '/scripts/new-note.sh'
        local file = vim.fn.system({ script, title }):gsub('%s+$', '')
        if vim.v.shell_error == 0 then
          vim.cmd('edit ' .. file)
        else
          vim.notify('Note creation failed', vim.log.levels.ERROR)
        end
      end)
    end, { desc = 'New Note' })
    vim.keymap.set('n', '<leader>zc', '<cmd>Telekasten show_calendar<CR>')
    vim.keymap.set('n', '<leader>zb', '<cmd>Telekasten show_backlinks<CR>')
    vim.keymap.set('n', '<leader>zI', '<cmd>Telekasten insert_img_link<CR>')

    -- Project management
    vim.keymap.set('n', '<leader>zi', function()
      vim.ui.input({ prompt = 'Issue title: ' }, function(title)
        if not title or title == '' then
          return
        end
        local script = base_path .. '/scripts/new-issue.sh'
        local file = vim.fn.system({ script, title }):gsub('%s+$', '')
        if vim.v.shell_error == 0 then
          vim.cmd('edit ' .. file)
        else
          vim.notify('Issue creation failed', vim.log.levels.ERROR)
        end
      end)
    end, { desc = 'New Issue' })
    vim.keymap.set('n', '<leader>ze', function()
      vim.ui.input({ prompt = 'Epic title: ' }, function(title)
        if not title or title == '' then
          return
        end
        local script = base_path .. '/scripts/new-epic.sh'
        local file = vim.fn.system({ script, title }):gsub('%s+$', '')
        if vim.v.shell_error == 0 then
          vim.cmd('edit ' .. file)
        else
          vim.notify('Epic creation failed', vim.log.levels.ERROR)
        end
      end)
    end, { desc = 'New Epic' })
  end,
}
