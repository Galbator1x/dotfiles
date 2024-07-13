return {
  {
    'folke/tokyonight.nvim',
    opts = { style = 'day' },
  },
  {
    'okuuva/auto-save.nvim',
    event = { 'InsertLeave', 'TextChanged' },
    opts = {
      execution_message = {
        enabled = false,
      },
    },
  },
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    opts = {},
  },
  -- { 'michaeljsmith/vim-indent-object' },
  { 'tpope/vim-fugitive' },
  -- {
  --   "Wansmer/langmapper.nvim",
  --   lazy = false,
  --   config = function()
  --     require("langmapper").setup({})
  --   end,
  -- },
}
