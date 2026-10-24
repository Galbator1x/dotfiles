vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
}

vim.keymap.set('n', '<C-m>', function()
  local is_file = vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) ~= '' -- Skip Starter and other special or unnamed buffers.
  require('neo-tree.command').execute { action = 'focus', source = 'filesystem', reveal = is_file }
end, { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  window = {
    mappings = {
      ['<C-]>'] = function() vim.cmd.nohlsearch() end,
    },
  },
  filesystem = {
    bind_to_cwd = true,
    filtered_items = {
      hide_dotfiles = false,
      hide_by_name = {
        'node_modules',
        '.git',
        '.ruby-lsp',
      },
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
