vim.pack.add {
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
}

require('which-key').setup {
  spec = {
    { '<leader>c', group = 'Code' },
    { '<leader>g', group = 'Git' },
    { '<leader>r', group = 'Replace', mode = { 'n', 'x' } },
    { '<leader>s', group = 'Search' },
    { '<leader>u', group = 'UI' },
  },
}
