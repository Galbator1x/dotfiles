vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  { src = 'https://github.com/nvim-telescope/telescope.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
}

local actions = require 'telescope.actions'

require('telescope').setup {
  defaults = {
    file_ignore_patterns = {
      'bundle_cache',
      'vendor/cache',
      '%.git/',
    },
    mappings = {
      i = {
        ['<c-enter>'] = 'to_fuzzy_refine',
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-f>'] = actions.preview_scrolling_down,
        ['<C-b>'] = actions.preview_scrolling_up,
        ['<C-u>'] = false,
        ['<C-s>'] = actions.delete_buffer,
      },
      n = {
        ['<C-s>'] = actions.delete_buffer,
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
      '--hidden',
    },
  },
  pickers = {
    grep_string = {
      use_regex = true, -- Skip Telescope's regex escaping; rg already uses --fixed-strings.
    },
    find_files = {
      hidden = true,
    },
    buffers = {
      ignore_current_buffer = true,
      sort_mru = true,
    },
  },
}

require('telescope').load_extension 'fzf'

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = '[S]earch Files' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>,', builtin.buffers, { desc = 'Find existing buffers' })
vim.keymap.set('n', '<leader>uC', '<cmd>Telescope colorscheme enable_preview=true<cr>', { desc = 'Change colorscheme' })

vim.keymap.set('n', '<leader>sw', function()
  builtin.grep_string {
    word_match = '-w',
  }
end, { desc = '[S]earch current [W]ord' })

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

vim.keymap.set('x', '<leader>s', function()
  local text = table.concat(vim.fn.getregion(vim.fn.getpos 'v', vim.fn.getpos '.', { type = vim.fn.mode() }), '') -- Read the selection without changing registers.
  builtin.live_grep { default_text = text }
end, { desc = 'Search selected text', silent = true })
