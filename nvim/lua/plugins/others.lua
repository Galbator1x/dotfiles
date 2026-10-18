vim.pack.add {
  'https://github.com/Galbator1x/vim-indent-object',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/chentoast/marks.nvim',
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/RRethy/nvim-treesitter-endwise',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
}

require('marks').setup {}
require('guess-indent').setup {}
require('treesitter-context').setup { mode = 'topline' }
vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>', { desc = 'Git status' })
