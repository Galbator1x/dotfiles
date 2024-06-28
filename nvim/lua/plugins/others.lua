return {
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      execution_message = {
        enabled = false
      }
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>fj", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {},
  },
  { "michaeljsmith/vim-indent-object" },
  { "tpope/vim-fugitive" },
  -- {
  --   "Wansmer/langmapper.nvim",
  --   lazy = false,
  --   config = function()
  --     require("langmapper").setup({})
  --   end,
  -- },
}
