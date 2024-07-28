return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = true },
  },
  config = function()
    require('telescope').setup {
      defaults = {
        file_ignore_patterns = {
          'bundle_cache',
          'vendor/cache',
        },
        mappings = {
          i = {
            ['<c-enter>'] = 'to_fuzzy_refine',
            ['<C-j>'] = require('telescope.actions').move_selection_next,
            ['<C-k>'] = require('telescope.actions').move_selection_previous,
            ['<C-f>'] = require('telescope.actions').preview_scrolling_down,
            ['<C-b>'] = require('telescope.actions').preview_scrolling_up,
            ['<C-u>'] = false,
          },
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--fixed-strings',
        },
      },
      pickers = {
        buffers = {
          ignore_current_buffer = true,
          sort_mru = true,
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = '[S]earch Files' })
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch Git Files' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>,', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>st', "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", { desc = 'Todo/Fix/Fixme' })
    vim.keymap.set('n', '<leader>sT', "<cmd>TodoTelescope<cr>", { desc = 'Todo' })
    vim.keymap.set('n', '<leader>uC', '<cmd>Telescope colorscheme enable_preview=true<cr>', { desc = 'Change colorscheme' })

    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sc', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [C]onfig files' })

    function vim.getVisualSelection()
      vim.cmd 'noau normal! "vy"'
      local text = vim.fn.getreg 'v'
      vim.fn.setreg('v', {})

      text = string.gsub(text, '\n', '')
      if #text > 0 then
        return text
      else
        return ''
      end
    end

    vim.keymap.set('v', '<leader>s', function()
      local text = vim.getVisualSelection()
      builtin.live_grep { default_text = text }
    end, { noremap = true, silent = true })
  end,
}
