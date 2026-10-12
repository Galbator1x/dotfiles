vim.pack.add {
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/folke/persistence.nvim',
}

require('persistence').setup()

local function restore_session()
  local persistence = require 'persistence'
  if vim.fn.filereadable(persistence.current()) == 0 and vim.fn.filereadable(persistence.current { branch = false }) == 0 then
    vim.notify('No saved session for ' .. vim.fn.getcwd() .. '. Open files and exit Neovim to save one.', vim.log.levels.INFO)
    return
  end
  persistence.load()
end

local starter = require 'mini.starter'
vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('StarterTelescopeMapping', { clear = true }),
  pattern = 'MiniStarterOpened',
  callback = function(args)
    vim.keymap.del('n', '<C-p>', { buffer = args.buf }) -- Keep the global Telescope mapping available in Starter.
  end,
})

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

starter.setup {
  evaluate_single = true, -- Execute the unique matching action when typing s or q.
  header = logo,
  items = {
    { name = 'Session restore', action = restore_session, section = '' },
    { name = 'Quit', action = 'qa', section = '' },
  },
  footer = function() return tostring(vim.version()) end,
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning('center', 'center'),
  },
}
