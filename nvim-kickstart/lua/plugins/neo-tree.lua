return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<C-m>',      ':Neotree reveal<CR>', { desc = 'NeoTree reveal' } },
  },
  opts = {
    filesystem = {
      bind_to_cwd = true,
      window = {
        mappings = {
          ['l'] = 'open',
          ['/'] = 'none',
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
  },
}
