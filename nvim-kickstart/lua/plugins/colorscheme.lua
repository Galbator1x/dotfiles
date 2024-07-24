return {
  {
    'ishan9299/nvim-solarized-lua',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'solarized'
    end,
  },

  -- {
  --   'ellisonleao/gruvbox.nvim',
  --   priority = 1000,
  --   config = true,
  --   init = function()
  --     -- vim.cmd.colorscheme 'gruvbox'
  --   end,
  -- },
  -- {
  --   'rebelot/kanagawa.nvim',
  --   priority = 1000,
  --   init = function()
  --     -- vim.cmd.colorscheme 'kanagawa'
  --   end,
  -- },
  -- {
  --   'catppuccin/nvim',
  --   name = 'catppuccin',
  --   priority = 1000,
  --   init = function()
  --     -- vim.cmd.colorscheme 'catppuccin'
  --   end,
  -- },
  -- {
  --   'Tsuzat/NeoSolarized.nvim',
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     -- vim.cmd.colorscheme 'NeoSolarized'
  --   end,
  -- },
  -- {
  --   'maxmx03/solarized.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.o.background = 'light'
  --     -- vim.cmd.colorscheme 'solarized'
  --   end,
  -- },

  -- {
  --   'Galbator1x/solarized.nvim', -- 'shaunsingh/solarized.nvim',
  --   init = function()
  --     vim.cmd.colorscheme 'solarized'
  --   end,
  -- },

  -- {
  --   'rose-pine/neovim',
  --   name = 'rose-pine',
  --   init = function()
  --     -- vim.cmd.colorscheme 'rose-pine'
  --   end,
  -- },
  -- {
  --   'lifepillar/vim-solarized8',
  --   branch = 'neovim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   init = function()
  --     -- vim.cmd.colorscheme 'solarized8'
  --   end,
  -- },
  -- {
  --   'folke/tokyonight.nvim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   -- init = function()
  --   --   vim.cmd.colorscheme 'tokyonight-day'
  --   --
  --   --   -- You can configure highlights by doing something like:
  --   --   vim.cmd.hi 'Comment gui=none'
  --   -- end,
  -- },
}
