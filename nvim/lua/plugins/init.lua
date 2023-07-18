local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { 
    'Galbator1x/solarized.nvim', 
    config = function()
      vim.cmd('colorscheme solarized')
      require('solarized').set()
    end
  },
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('nvim-tree').setup {}
    end
  },

  {
    'numToStr/Comment.nvim',
    config = function()
      local ts_comment_integration = require('ts_context_commentstring.integrations.comment_nvim')
      require('Comment').setup({
        pre_hook = ts_comment_integration.create_pre_hook(),
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = require('plugins.treesitter'),
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
  },
  {
    'kylechui/nvim-surround',
    version = '*',
    config = function()
      require('nvim-surround').setup({})
    end
  },
  {
    'Pocco81/auto-save.nvim',
    config = function()
      require('auto-save').setup {
        execution_message = {
	  message = function() return '' end,
	  cleaning_interval = 1,
	},
      }
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          theme = 'solarized'
        }
      }
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    config = function()
      local telescope = require('telescope')

      telescope.setup {
        pickers = {
          buffers = {
            ignore_current_buffer = true,
            sort_mru = true
          }
        },
      }
    end,
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
}

local opts = {}

require('lazy').setup(plugins, opts)
