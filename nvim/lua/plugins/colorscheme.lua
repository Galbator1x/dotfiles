vim.pack.add {
  'https://github.com/ishan9299/nvim-solarized-lua',
  { src = 'https://github.com/rose-pine/neovim', name = 'rose-pine' },
}

vim.g.solarized_italics = 0

require('rose-pine').setup { styles = { italic = false } }

local function system_background()
  local result = vim.system({ 'defaults', 'read', '-g', 'AppleInterfaceStyle' }, { text = true }):wait(1000)
  if result.code ~= 0 and result.code ~= 1 then return vim.o.background end
  return vim.trim(result.stdout or '') == 'Dark' and 'dark' or 'light' -- Light mode has no preference key.
end

local function apply_colorscheme()
  vim.o.background = system_background()
  local colorscheme = vim.o.background == 'dark' and 'rose-pine' or 'solarized'
  if vim.g.colors_name == colorscheme then return end

  vim.cmd 'highlight clear' -- Solarized only clears old highlights on its first load.
  vim.cmd.colorscheme(colorscheme)
  vim.g.colors_name = colorscheme -- Solarized only sets this when its Lua module is first loaded.
end

vim.api.nvim_create_autocmd('FocusGained', {
  desc = 'Follow system appearance',
  group = vim.api.nvim_create_augroup('system-colorscheme', { clear = true }),
  nested = true, -- Run ColorScheme highlight customizations when focus returns.
  callback = apply_colorscheme,
})

apply_colorscheme()
