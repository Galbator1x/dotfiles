return {
  {
    "0x00-ketsu/autosave.nvim",
    opts = {},
    config = function()
      require("autosave").setup({
        prompt_message = function()
          return ""
        end,
        events = { "InsertLeave", "TextChanged" },
      })
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {},
  },
}
