vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = false,
  formatters_by_ft = {
    lua = { 'stylua' },
  },
}

vim.keymap.set({ 'n', 'x' }, '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = 'Format buffer or selection' })
