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
        desc = "Find Plugin File",
      },
      {
        "<leader>sb",
        function() require("telescope.builtin").current_buffer_fuzzy_find() end,
        desc = "Find Plugin File",
      },
      {
        "<leader>sg",
        function() require("telescope.builtin").live_grep() end,
        desc = "Find Plugin File",
      },
      {
        "<leader>sd",
        function() require("telescope.builtin").diagnostics() end,
        desc = "Find Plugin File",
      },
      {
        "<leader>sc",
        function() require("telescope.builtin").git_commits() end,
        desc = "Find Plugin File",
      },
      {
        "<leader>sr",
        function() require("telescope.builtin").lsp_references() end,
        desc = "Find Plugin File",
      },
      {
        "<leader>so",
        function() require("telescope.builtin").lsp_document_symbols() end,
        desc = "Find Plugin File",
      },
      {
        "<leader>sh",
        function() require("telescope.builtin").help_tags() end,
        desc = "Find Plugin File",
      },
      {
        "<leader><leader>",
        false,
      },
      -- stylua: ignore end
    },

    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },
}
