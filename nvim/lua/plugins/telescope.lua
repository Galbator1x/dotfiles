return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<C-p>",
        function() require("telescope.builtin").find_files() end,
        desc = "Find Files(cwd)",
      },
      {
        "<leader><leader>",
        function() require("telescope.builtin").find_files() end,
        desc = "Find Files(cwd)",
      },
    },

    opts = {
      defaults = {
         mappings = {
           -- restore default behavior
           i = {
             ["<C-u>"] = false,
             -- ["<C-d>"] = false,
           },
           -- n = {},
         },
      },
      pickers = {
        buffers = {
          ignore_current_buffer = true,
          sort_mru = true,
        },
      },
    },
  },
}
