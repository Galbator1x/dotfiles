-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local bind = vim.keymap.set

vim.keymap.del('n', 'H')
vim.keymap.del('n', 'L')
vim.keymap.del('n', '<leader>qq')
vim.keymap.del('n', '<leader>qd')
vim.keymap.del('n', '<leader>ql')
vim.keymap.del('n', '<leader>qs')

bind("n", "<leader>q", "<cmd>q<cr>", { silent = true, noremap = true, nowait = true }) -- TODO: slow closing in case of which-key mappings <leader>qq...
bind("n", "n", "nzzzv")

bind("n", "<leader>c", "<cmd>let @+ = expand('%')<cr>")
bind("n", "<leader>re", ":%s///g<left><left>")

bind({'n', 'v'}, "<leader>y", '"ay', { noremap = true, silent = true })
bind({'n', 'v'}, "<leader>p", '"ap', { noremap = true, silent = true })

local function select_pasted()
  return '`[' .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. '`]'
end
bind('n', 'gb', select_pasted, { expr = true, noremap = true, silent = true })
