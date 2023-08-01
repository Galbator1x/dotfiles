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
}
