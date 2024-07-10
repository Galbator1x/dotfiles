return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>fj', ':Neotree toggle<CR>', { desc = 'NeoTree toggle' } },
  },
  opts = {
    filesystem = {
      bind_to_cwd = true,
      window = {
        mappings = {
          ['/'] = 'none',
        },
      },
    },
  },
}
-- return {
--   {
--     "nvim-neo-tree/neo-tree.nvim",
--     keys = {
--       { "<leader>fj", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
--     },
--     opts = {
--       filesystem = {
--         -- follow_current_file = { enabled = false },
--         bind_to_cwd = true,
--         window = {
--           mappings = {
--             ["/"] = "none",
--           },
--         },
--       },
--     },
--   },
-- }
