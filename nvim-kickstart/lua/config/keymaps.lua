-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set('n', '<leader>q', '<cmd>q<cr>', { silent = true, noremap = true, nowait = true }) -- TODO: slow closing in case of which-key mappings <leader>qq...

vim.keymap.set('n', '<leader>cp', "<cmd>let @+ = expand('%')<cr>")                               -- TODO: search other options
vim.keymap.set('n', '<leader>re', ':%s///g<left><left>')

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { noremap = true, silent = true })

local function select_pasted()
  return '`[' .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. '`]'
end
vim.keymap.set('n', 'gb', select_pasted, { expr = true, noremap = true, silent = true })
