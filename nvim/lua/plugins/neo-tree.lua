return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>fj", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
    opts = {
      filesystem = {
        -- follow_current_file = { enabled = false },
        bind_to_cwd = true,
        window = {
          mappings = {
            ["/"] = "none",
          },
        },
      },
    },
  },
}
