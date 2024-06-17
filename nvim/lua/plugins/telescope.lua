return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- stylua: ignore start
      {
        "<C-p>",
        function() require("telescope.builtin").find_files() end,
        desc = "Find Plugin File",
      },
      {
        "<leader>b",
        function() require("telescope.builtin").buffers() end,
        desc = "Find Buffer",
      },
      {
        "<leader>sb",
        function() require("telescope.builtin").current_buffer_fuzzy_find() end,
        desc = "Find TODO",
      },
      {
        "<leader>sg",
        function() require("telescope.builtin").live_grep() end,
        desc = "Live Grep",
      },
      {
        "<leader>sd",
        function() require("telescope.builtin").diagnostics() end,
        desc = "Diagnostics",
      },
      {
        "<leader>sc",
        function() require("telescope.builtin").git_commits() end,
        desc = "Find Git Commits",
      },
      {
        "<leader>sr",
        function() require("telescope.builtin").lsp_references() end,
        desc = "Find lsp references",
      },
      {
        "<leader>so",
        function() require("telescope.builtin").lsp_document_symbols() end,
        desc = "Find lsp document symbols",
      },
      {
        "<leader>sh",
        function() require("telescope.builtin").help_tags() end,
        desc = "Find Help Tags",
      },
      {
        "<leader><leader>",
        false,
      },
      -- stylua: ignore end
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
