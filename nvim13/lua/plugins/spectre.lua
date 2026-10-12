vim.pack.add {
  'https://github.com/nvim-pack/nvim-spectre',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
}

require('spectre').setup {
  replace_engine = {
    sed = { cmd = 'sed', args = { '-i', '', '-E' } }, -- BSD sed on macOS needs an explicit empty backup suffix.
  },
  mapping = {
    send_to_qf = { map = '<leader>q', cmd = '<cmd>q<cr>', desc = 'Close' },
  },
}

vim.keymap.set('n', '<leader>S', function() require('spectre').toggle() end, { desc = 'Toggle Spectre' })
vim.keymap.set('n', '<leader>Sw', function() require('spectre').open_visual { select_word = true } end, { desc = 'Search current word' })
vim.keymap.set('x', '<leader>Sw', '<Esc><cmd>lua require("spectre").open_visual()<cr>', { desc = 'Search selected text' })
