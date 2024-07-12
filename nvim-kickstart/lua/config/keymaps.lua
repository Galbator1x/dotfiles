vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>q', '<cmd>q<cr>', { silent = true, noremap = true, nowait = true })

vim.keymap.set('n', '<leader>cp', "<cmd>let @+ = expand('%')<cr>") -- TODO: search other options
vim.keymap.set('n', '<leader>re', ':%s///g<left><left>')

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { noremap = true, silent = true })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

local function select_pasted()
  return '`[' .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. '`]'
end
vim.keymap.set('n', 'gb', select_pasted, { expr = true, noremap = true, silent = true })
