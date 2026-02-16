return {
  'renerocksai/telekasten.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    local base_path = vim.fn.expand '~/ghq/github.com/utsubo256/zett'
    local notes_path = base_path .. '/notes'
    local project_path = notes_path .. '/projects'
    local schedule_path = notes_path .. '/schedules'
    -- ファイルの1行目が # 見出しならタイトルとして取得
    local function get_first_heading(filepath)
      local ok, lines = pcall(vim.fn.readfile, filepath, '', 1)
      if not ok or #lines == 0 then
        return nil
      end
      return lines[1]:match '^# (.+)'
    end

    -- [[filename#heading]] 形式のリンクを生成
    local function make_link(filepath)
      local fname = vim.fn.fnamemodify(filepath, ':t:r')
      local heading = get_first_heading(filepath)
      if heading then
        return '[[' .. fname .. '#' .. heading .. ']]'
      else
        return '[[' .. fname .. ']]'
      end
    end

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
    -- Vimium-like URL link hints: show alphabet labels on [text](url) links, open in browser
    vim.keymap.set('n', '<leader>zf', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local ns = vim.api.nvim_create_namespace('telekasten_url_hints')

      -- Collect all [text](url) links
      local links = {}
      for lnum, line in ipairs(lines) do
        local col = 1
        while true do
          local s, e, text, url = line:find('%[([^%]]+)%]%(([^%)]+)%)', col)
          if not s then
            break
          end
          table.insert(links, { lnum = lnum - 1, col = s - 1, text = text, url = url })
          col = e + 1
        end
      end

      if #links == 0 then
        vim.notify('No URL links found', vim.log.levels.WARN)
        return
      end

      -- Generate hint labels
      local chars = 'asdfghjklqwertyuiopzxcvbnm'
      local use_two = #links > #chars
      local labels = {}
      for i = 1, #links do
        local label
        if use_two then
          local a = math.floor((i - 1) / #chars) + 1
          local b = ((i - 1) % #chars) + 1
          label = chars:sub(a, a) .. chars:sub(b, b)
        else
          label = chars:sub(i, i)
        end
        labels[i] = label
      end

      -- Display hints with extmarks
      local label_to_link = {}
      for i, link in ipairs(links) do
        local label = labels[i]
        label_to_link[label] = link
        vim.api.nvim_buf_set_extmark(bufnr, ns, link.lnum, link.col, {
          virt_text = { { ' ' .. label .. ' ', 'TelekastenHint' } },
          virt_text_pos = 'overlay',
        })
      end

      vim.cmd('redraw')

      -- Capture user input
      local input = ''
      local ok, char = pcall(vim.fn.getcharstr)
      if not ok or char == '\27' then
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        return
      end
      input = char

      if use_two then
        local ok2, char2 = pcall(vim.fn.getcharstr)
        if not ok2 or char2 == '\27' then
          vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
          return
        end
        input = input .. char2
      end

      -- Clear hints
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

      local matched = label_to_link[input]
      if not matched then
        vim.notify('No matching hint', vim.log.levels.WARN)
        return
      end

      -- Open URL in browser
      vim.ui.open(matched.url)
    end, { desc = 'Vimium-like URL link hints (open in browser)' })
    vim.keymap.set('n', '<leader>zg', function()
      local builtin = require 'telescope.builtin'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      builtin.live_grep {
        prompt_title = 'Search in notes',
        cwd = notes_path,
        search_dirs = { notes_path },
        default_text = vim.fn.expand '<cword>',
        attach_mappings = function(_, map)
          -- Ctrl+i: [[filename#heading]] リンクを挿入
          map('i', '<C-i>', function(prompt_bufnr)
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then
              return
            end
            local filepath = selection.filename or selection.value
            local link = make_link(filepath)
            vim.api.nvim_put({ link }, '', true, true)
            vim.api.nvim_feedkeys('a', 'm', false)
          end)
          -- Ctrl+y: [[filename#heading]] リンクをヤンク
          map('i', '<C-y>', function(prompt_bufnr)
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then
              return
            end
            local filepath = selection.filename or selection.value
            local link = make_link(filepath)
            vim.fn.setreg('"', link)
            vim.notify('yanked ' .. link)
          end)
          return true
        end,
      }
    end, { desc = 'Search notes (insert [[filename#heading]] link)' })
    vim.keymap.set('n', '<leader>zt', function()
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      -- 全 .md ファイルからタイトル一覧を収集
      local scan = require 'plenary.scandir'
      local files = scan.scan_dir(notes_path, { search_pattern = '%.md$' })
      local entries = {}
      for _, filepath in ipairs(files) do
        local heading = get_first_heading(filepath)
        if heading then
          table.insert(entries, { heading = heading, filepath = filepath })
        end
      end

      -- タイトル降順（新しいファイルが上に来る）
      table.sort(entries, function(a, b)
        return a.filepath > b.filepath
      end)

      pickers
        .new({}, {
          prompt_title = 'Search by title',
          finder = finders.new_table {
            results = entries,
            entry_maker = function(entry)
              local fname = vim.fn.fnamemodify(entry.filepath, ':t:r')
              return {
                value = entry.filepath,
                display = entry.heading .. '  (' .. fname .. ')',
                ordinal = entry.heading .. ' ' .. fname,
              }
            end,
          },
          sorter = conf.generic_sorter {},
          previewer = conf.file_previewer {},
          attach_mappings = function(_, map)
            -- Enter: ファイルを開く
            actions.select_default:replace(function(prompt_bufnr)
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                vim.cmd('edit ' .. vim.fn.fnameescape(selection.value))
              end
            end)
            -- Ctrl+i: [[filename#heading]] リンクを挿入
            map('i', '<C-i>', function(prompt_bufnr)
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if not selection then
                return
              end
              local link = make_link(selection.value)
              vim.api.nvim_put({ link }, '', true, true)
              vim.api.nvim_feedkeys('a', 'm', false)
            end)
            -- Ctrl+y: [[filename#heading]] リンクをヤンク
            map('i', '<C-y>', function(prompt_bufnr)
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if not selection then
                return
              end
              local link = make_link(selection.value)
              vim.fn.setreg('"', link)
              vim.notify('yanked ' .. link)
            end)
            return true
          end,
        })
        :find()
    end, { desc = 'Search notes by title' })
    vim.keymap.set('n', '<leader>zd', function()
      local dailies_dir = schedule_path .. '/dailies'
      local today = os.date('%Y-%m-%d')
      local today_file = dailies_dir .. '/' .. today .. '.md'
      local is_new = vim.fn.filereadable(today_file) == 0

      if is_new then
        -- 最も新しい過去の日報を探す
        local files = vim.fn.glob(dailies_dir .. '/*.md', false, true)
        table.sort(files)

        local prev_file = nil
        for i = #files, 1, -1 do
          local fname = vim.fn.fnamemodify(files[i], ':t:r')
          if fname < today then
            prev_file = files[i]
            break
          end
        end

        -- 前日の未完了 TODO を抽出
        local todos = {}
        if prev_file then
          local lines = vim.fn.readfile(prev_file)
          local in_todo = false
          for _, line in ipairs(lines) do
            if line:match('^## TODO') then
              in_todo = true
            elseif line:match('^## ') then
              in_todo = false
            elseif in_todo and line:match('^%- %[ %]') then
              table.insert(todos, line)
            end
          end
        end

        -- 未完了 TODO があればテンプレートに注入したファイルを先に作成
        if #todos > 0 then
          local template_file = base_path .. '/templates/daily.md'
          local template_lines = vim.fn.readfile(template_file)
          local new_lines = {}
          for _, line in ipairs(template_lines) do
            table.insert(new_lines, line)
            if line:match('^## TODO') then
              table.insert(new_lines, '')
              for _, todo in ipairs(todos) do
                table.insert(new_lines, todo)
              end
            end
          end
          vim.fn.writefile(new_lines, today_file)

          -- goto_today はファイルが既にあるのでそのまま開く
          vim.cmd('Telekasten goto_today')

          local prev_date = vim.fn.fnamemodify(prev_file, ':t:r')
          vim.notify(
            string.format('%d件の未完了TODOを %s から引き継ぎました', #todos, prev_date),
            vim.log.levels.INFO
          )
          return
        end
      end

      vim.cmd('Telekasten goto_today')
    end, { desc = 'Go to today (with TODO carry-over)' })
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

    -- Vimium-like link hints: show alphabet labels on [[links]], open in new tab
    vim.api.nvim_set_hl(0, 'TelekastenHint', { fg = '#ffffff', bg = '#ff5d62', bold = true })

    vim.keymap.set('n', '<leader>zl', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local ns = vim.api.nvim_create_namespace('telekasten_hints')

      -- Collect all [[...]] links
      local links = {}
      for lnum, line in ipairs(lines) do
        local col = 1
        while true do
          local s, _, target = line:find('%[%[([^%]#|]+)', col)
          if not s then
            break
          end
          table.insert(links, { lnum = lnum - 1, col = s - 1, target = target })
          col = s + 1
        end
      end

      if #links == 0 then
        vim.notify('No links found', vim.log.levels.WARN)
        return
      end

      -- Generate hint labels
      local chars = 'asdfghjklqwertyuiopzxcvbnm'
      local use_two = #links > #chars
      local labels = {}
      for i = 1, #links do
        local label
        if use_two then
          local a = math.floor((i - 1) / #chars) + 1
          local b = ((i - 1) % #chars) + 1
          label = chars:sub(a, a) .. chars:sub(b, b)
        else
          label = chars:sub(i, i)
        end
        labels[i] = label
      end

      -- Display hints with extmarks
      local label_to_link = {}
      for i, link in ipairs(links) do
        local label = labels[i]
        label_to_link[label] = link
        vim.api.nvim_buf_set_extmark(bufnr, ns, link.lnum, link.col, {
          virt_text = { { ' ' .. label .. ' ', 'TelekastenHint' } },
          virt_text_pos = 'overlay',
        })
      end

      vim.cmd('redraw')

      -- Capture user input
      local input = ''
      local ok, char = pcall(vim.fn.getcharstr)
      if not ok or char == '\27' then
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        return
      end
      input = char

      if use_two then
        local ok2, char2 = pcall(vim.fn.getcharstr)
        if not ok2 or char2 == '\27' then
          vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
          return
        end
        input = input .. char2
      end

      -- Clear hints
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

      local matched = label_to_link[input]
      if not matched then
        vim.notify('No matching hint', vim.log.levels.WARN)
        return
      end

      -- Resolve link target to file path
      local target = matched.target
      local files = vim.fn.glob(notes_path .. '/**/' .. target .. '.md', false, true)
      if #files == 0 then
        files = vim.fn.glob(notes_path .. '/' .. target .. '.md', false, true)
      end

      if #files > 0 then
        vim.cmd('tabedit ' .. vim.fn.fnameescape(files[1]))
      else
        vim.notify('File not found: ' .. target, vim.log.levels.WARN)
      end
    end, { desc = 'Vimium-like link hints (open in new tab)' })
  end,
}
