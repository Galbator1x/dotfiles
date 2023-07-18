vim.o.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
vim.o.cursorline = true --- Highlight of current line
vim.o.number = true --- Shows line number
vim.o.signcolumn = "yes:1" --- Add extra sign column next to line number
vim.o.ignorecase = true
vim.o.smartcase = true --- Uses case in search
vim.o.termguicolors = true --- Correct terminal colors
vim.o.undofile = true --- Sets undo to file
vim.o.wrap = false
-- vim.o.updatetime = 100 --- Faster completion

local globals = {
  mapleader = ' ',
  loaded = 1,
  loaded_netrw = 1,
  loaded_netrwPlugin = 1,
  -- speeddating_no_mappings = 1, --- Disable default mappings for speeddating
}


for k, v in pairs(globals) do
  vim.g[k] = v
end
