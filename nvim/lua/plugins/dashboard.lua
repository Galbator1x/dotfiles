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
local function set_starter_highlights()
  for _, group in ipairs { 'Header', 'Footer', 'Item', 'ItemBullet', 'ItemPrefix', 'Query', 'Current' } do
    vim.api.nvim_set_hl(0, 'MiniStarter' .. group, { link = 'Normal' })
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('StarterHighlights', { clear = true }),
  callback = set_starter_highlights,
})

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

local function dashboard_layout(content, buf_id)
  local widths, kinds, result = {}, {}, {}
  for _, line in ipairs(content) do
    local unit = line[1]
    kinds[line] = unit.type
    if unit.type == 'item' then
      local is_session = unit.string == 'Session restore'
      table.insert(line, 1, { string = is_session and '↻  ' or '⇥  ', type = 'empty', hl = 'MiniStarterItem' })
      table.insert(line, { string = string.rep(' ', 20 - vim.fn.strdisplaywidth(unit.string)) .. (is_session and '[s]' or '[q]'), type = 'empty', hl = 'MiniStarterItem' })
      table.insert(result, { { string = '', type = 'empty' } }) -- Separate menu actions with a blank line.
    end
    widths[unit.type] = math.max(widths[unit.type] or 0, vim.fn.strdisplaywidth(starter.content_to_lines { line }[1]))
    table.insert(result, line)
  end

  -- Center each block horizontally and place the dashboard three rows above vertical center.
  local win_id = vim.fn.bufwinid(buf_id)
  local width = math.max(unpack(vim.tbl_values(widths)))
  local left = math.max(math.floor((vim.api.nvim_win_get_width(win_id) - width) / 2), 0)
  for _, line in ipairs(result) do
    local block_width = widths[kinds[line]]
    if block_width and block_width > 0 then
      table.insert(line, 1, { string = string.rep(' ', left + math.floor((width - block_width) / 2)), type = 'empty' })
    end
  end
  local top = math.max(math.floor((vim.api.nvim_win_get_height(win_id) - #result) / 2) - 3, 0)
  return starter.gen_hook.padding(0, top)(result)
end

starter.setup {
  evaluate_single = true, -- Execute the unique matching action when typing s or q.
  header = logo,
  items = {
    { name = 'Session restore', action = restore_session, section = '' },
    { name = 'Quit', action = 'qa', section = '' },
  },
  footer = function() return '\nv' .. tostring(vim.version()) end,
  content_hooks = { dashboard_layout },
}
set_starter_highlights()
