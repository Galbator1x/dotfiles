-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local bind = vim.keymap.set

vim.keymap.del('n', 'H')
vim.keymap.del('n', 'L')

bind("n", "<leader>q", "<cmd>q<cr>", { silent = true, noremap = true, nowait = true }) -- TODO: nowait don't work
bind("n", "n", "nzzzv")

bind("n", "<leader>c", "<cmd>let @+ = expand('%')<cr>")
bind("n", "<leader>re", "<cmd>%s///g<left><left>")

bind({'n', 'v'}, "<leader>y", '"ay', { noremap = true, silent = true })
bind({'n', 'v'}, "<leader>p", '"ap', { noremap = true, silent = true })
