return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- use latest release, remove to use latest commit
  event = 'VeryLazy',
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in 4.0.0
    ui = { enable = false },
    frontmatter = { enabled = false },
    workspaces = {
      {
        name = 'zett',
        path = '~/ghq/github.com/utsubo256/zett',
      },
    },
    notes_subdir = 'notes',
    daily_notes = {
      folder = 'notes/schedules/dailies',
    },
    templates = {
      folder = 'templates',
    },
    picker = {
      name = 'fzf-lua',
      note_mappings = {
        insert_link = '<C-i>', -- telekasten の <C-i> と同じ
      },
    },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)

    vim.api.nvim_set_hl(0, 'ObsidianHint', { fg = '#ffffff', bg = '#ff5d62', bold = true })

    local function make_hint_labels(n)
      local chars = 'asdfghjklqwertyuiopzxcvbnm'
      local use_two = n > #chars
      local labels = {}
      for i = 1, n do
        if use_two then
          local a = math.floor((i - 1) / #chars) + 1
          local b = ((i - 1) % #chars) + 1
          labels[i] = chars:sub(a, a) .. chars:sub(b, b)
        else
          labels[i] = chars:sub(i, i)
        end
      end
      return labels, use_two
    end

    local function capture_hint(use_two, bufnr, ns)
      local ok, char = pcall(vim.fn.getcharstr)
      if not ok or char == '\27' then
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        return nil
      end
      local input = char
      if use_two then
        local ok2, char2 = pcall(vim.fn.getcharstr)
        if not ok2 or char2 == '\27' then
          vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
          return nil
        end
        input = input .. char2
      end
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      return input
    end

    -- <leader>zf: Vimium-like URL hints (open in browser)
    vim.keymap.set('n', '<leader>zf', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local ns = vim.api.nvim_create_namespace 'obsidian_url_hints'

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

      local labels, use_two = make_hint_labels(#links)
      local label_to_link = {}
      for i, link in ipairs(links) do
        label_to_link[labels[i]] = link
        vim.api.nvim_buf_set_extmark(bufnr, ns, link.lnum, link.col, {
          virt_text = { { ' ' .. labels[i] .. ' ', 'ObsidianHint' } },
          virt_text_pos = 'overlay',
        })
      end
      vim.cmd 'redraw'

      local input = capture_hint(use_two, bufnr, ns)
      if not input then
        return
      end

      local matched = label_to_link[input]
      if not matched then
        vim.notify('No matching hint', vim.log.levels.WARN)
        return
      end
      vim.ui.open(matched.url)
    end, { desc = 'URL hints (open in browser)' })

    -- <leader>zl: Vimium-like [[wiki link]] hints (open in new tab)
    vim.keymap.set('n', '<leader>zl', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local ns = vim.api.nvim_create_namespace 'obsidian_link_hints'

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

      local labels, use_two = make_hint_labels(#links)
      local label_to_link = {}
      for i, link in ipairs(links) do
        label_to_link[labels[i]] = link
        vim.api.nvim_buf_set_extmark(bufnr, ns, link.lnum, link.col, {
          virt_text = { { ' ' .. labels[i] .. ' ', 'ObsidianHint' } },
          virt_text_pos = 'overlay',
        })
      end
      vim.cmd 'redraw'

      local input = capture_hint(use_two, bufnr, ns)
      if not input then
        return
      end

      local matched = label_to_link[input]
      if not matched then
        vim.notify('No matching hint', vim.log.levels.WARN)
        return
      end

      local vault_path = tostring(Obsidian.dir)
      local target = matched.target
      local files = vim.fn.glob(vault_path .. '/**/' .. target .. '.md', false, true)
      if #files == 0 then
        files = vim.fn.glob(vault_path .. '/' .. target .. '.md', false, true)
      end

      if #files > 0 then
        vim.cmd('tabedit ' .. vim.fn.fnameescape(files[1]))
      else
        vim.notify('File not found: ' .. target, vim.log.levels.WARN)
      end
    end, { desc = 'Wiki link hints (open in new tab)' })

    -- <leader>zd: Today's daily note with TODO carry-over
    vim.keymap.set('n', '<leader>zd', function()
      local today = os.date('%Y-%m-%d')
      local vault_path = tostring(Obsidian.dir)
      local daily_dir = vault_path .. '/notes/schedules/dailies'
      local filepath = daily_dir .. '/' .. today .. '.md'

      if vim.fn.filereadable(filepath) == 0 then
        local todos = {}
        local files = vim.fn.glob(daily_dir .. '/*.md', false, true)
        table.sort(files)
        local prev_file
        for i = #files, 1, -1 do
          if vim.fn.fnamemodify(files[i], ':t:r') < today then
            prev_file = files[i]
            break
          end
        end
        if prev_file then
          local in_todo = false
          for _, line in ipairs(vim.fn.readfile(prev_file)) do
            if line:match('^## TODO') then
              in_todo = true
            elseif line:match('^## ') then
              in_todo = false
            elseif in_todo and line:match('^%- %[ %]') then
              table.insert(todos, line)
            end
          end
        end

        local lines = { '# ' .. today, '', '## TODO' }
        for _, todo in ipairs(todos) do
          table.insert(lines, todo)
        end
        table.insert(lines, '')
        table.insert(lines, '## メモ')
        vim.fn.writefile(lines, filepath)

        if #todos > 0 then
          local prev_date = vim.fn.fnamemodify(prev_file, ':t:r')
          vim.notify(
            string.format('%d件の未完了TODOを %s から引き継ぎました', #todos, prev_date),
            vim.log.levels.INFO
          )
        end
      end

      vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
    end, { desc = "Today's note" })

    vim.keymap.set('n', '<leader>zz', '<cmd>Obsidian follow_link<CR>', { desc = 'Follow link' })
    vim.keymap.set('n', '<leader>zn', function()
      vim.ui.input({ prompt = 'Title: ' }, function(title)
        if not title or title == '' then return end
        local stamp = os.date('%Y%m%d%H%M%S')
        local vault_path = tostring(Obsidian.dir)
        local filepath = vault_path .. '/notes/' .. stamp .. '.md'
        vim.fn.writefile({ '# ' .. title }, filepath)
        vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
      end)
    end, { desc = 'New note' })
    vim.keymap.set('n', '<leader>zb', '<cmd>Obsidian backlinks<CR>', { desc = 'Show backlinks' })
    vim.keymap.set('n', '<leader>zI', '<cmd>Obsidian paste_img<CR>', { desc = 'Paste image link' })
    vim.keymap.set('n', '<leader>zt', '<cmd>Obsidian quick_switch<CR>', { desc = 'Search notes by title' })
    vim.keymap.set('n', '<leader>zg', '<cmd>Obsidian search<CR>', { desc = 'Search in notes' })
  end,
}
