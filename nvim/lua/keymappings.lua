local bind = vim.keymap.set
local opts = { silent = true, noremap = true }

bind("n", "<leader>/", ":set hlsearch! hlsearch?<CR>", opts)

-- Better window movement
bind("n", "<C-l>", "<C-w>l", opts)
bind("n", "<C-h>", "<C-w>h", opts)
bind("n", "<C-j>", "<C-w>j", opts)
bind("n", "<C-k>", "<C-w>k", opts)

bind('n', '<leader><leader>', ':NvimTreeToggle<CR>')
bind('n', '<C-m>', ':NvimTreeFindFile<CR>')

bind('v', '<leader>y', '"+y')
bind('n', '<leader>Y', '"+yg_')
bind('n', '<leader>y', '"+y')
bind('n', '<leader>yy', '"+yy')

bind('v', '<leader>p', '"+p')
bind('v', '<leader>P', '"+P')
bind('n', '<leader>p', '"+p')
bind('n', '<leader>P', '"+P')

bind("n", "<leader>q", ":q<CR>", opts)
bind("n", "n", "nzzzv")

bind('n', '<leader>w', ':set invwrap<CR>:set wrap?<CR>')

bind("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>", opts)
bind("n", "<C-p>", "<cmd>lua require('telescope.builtin').find_files()<cr>", opts)
bind("n", "<leader>sb", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>", opts)
bind("n", "<leader>sg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
bind("n", "<leader>sd", "<cmd>lua require('telescope.builtin').diagnostics()<cr>", opts)
bind("n", "<leader>sc", "<cmd>lua require('telescope.builtin').git_commits()<cr>", opts)
bind("n", "<leader>sr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", opts)
bind("n", "<leader>so", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", opts)
bind("n", "<leader>sh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", opts)
