vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '<C-m>', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  filesystem = {
    bind_to_cwd = true,
    filtered_items = {
      hide_dotfiles = false,
    },
    hide_by_name = {
      'node_modules',
      '.git',
      '.ruby-lsp',
    },
    window = {
      mappings = {
        ['l'] = 'open', -- was focus_preview
        ['h'] = 'toggle_hidden',
        ['Z'] = 'close_all_nodes',
        ['z'] = 'none',
        ['H'] = 'none',
        ['/'] = 'none', -- was fuzzy_finder
      },
    },
  },
  buffers = {
    window = {
      mappings = {
        ['l'] = 'open',
        ['/'] = 'none',
      },
    },
  },
  git_status = {
    window = {
      mappings = {
        ['l'] = 'open',
        ['/'] = 'none',
      },
    },
  },
}
