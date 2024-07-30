return {
  'nvimdev/dashboard-nvim',
  lazy = false,
  opts = function()
    local logo = [[
   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          
    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       
          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     
           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    
          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   
   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  
  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   
 ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  
 ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ 
      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     
       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     
      ]]

    logo = string.rep('\n', 7) .. logo .. '\n\n'

    local function get_nvim_version()
      local v = vim.version()

      return string.format('v%d.%d.%d-%s+%s', v.major, v.minor, v.patch, v.prerelease, v.build)
    end

    local lazy_stats = require('lazy').stats()

    local opts = {
      theme = 'doom',
      config = {
        header = vim.split(logo, '\n'),
        center = {
          { action = 'lua require("persistence").load()', desc = ' Restore Session', icon = ' ', key = 's' },
          {
            action = function()
              vim.api.nvim_input '<cmd>qa<cr>'
            end,
            desc = ' Quit',
            icon = ' ',
            key = 'q',
          },
        },
        footer = {
          '',
          '',
          'Startuptime: ' .. lazy_stats.startuptime .. ' ms',
          'Plugins: ' .. lazy_stats.loaded .. ' loaded / ' .. lazy_stats.count .. ' installed',
          '',
          '',
          get_nvim_version(),
        },
      },
    }
    return opts
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
