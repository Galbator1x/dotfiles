vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>q', '<cmd>q<cr>', { silent = true, noremap = true, nowait = true })

vim.keymap.set('n', '<leader>cp', "<cmd>let @+ = expand('%:~:.')<cr>") -- TODO search other options
vim.keymap.set('n', '<leader>re', ':%s///g<left><left>')
vim.keymap.set('v', '<leader>re', ':s///g<left><left>')

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>Y', '"+y$', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+P', { noremap = true, silent = true })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<C-q>', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('n', '+', '<C-w>+', { noremap = true, silent = true })
vim.keymap.set('n', '-', '<C-w>-', { noremap = true, silent = true })
vim.keymap.set('n', '<C->>', '<C-w>>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-<>', '<C-w><', { noremap = true, silent = true })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

local function select_pasted()
  return '`[' .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. '`]'
end
vim.keymap.set('n', 'gb', select_pasted, { expr = true, noremap = true, silent = true })

vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', { desc = 'Toggle Spectre' })
vim.keymap.set('n', '<leader>Sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = 'Search current word' })
vim.keymap.set('v', '<leader>Sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = 'Search current word' })
