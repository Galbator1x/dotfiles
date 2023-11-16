-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local bind = vim.keymap.set
local opts = { silent = true, noremap = true }

bind("n", "<leader>q", "<cmd>q<cr>", { silent = true, noremap = true, nowait = true }) -- TODO: nowait don't work
bind("n", "n", "nzzzv")

bind("n", "<leader>c", ":let @+ = expand('%')<cr>")
bind("n", "<leader>re", ":%s///g<left><left>")
