vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = true,
  formatters_by_ft = {
    lua = { 'stylua' },
    ruby = { 'rubocop' },
  },
  formatters = {
    rubocop = {
      args = { '--server', '-A', '-f', 'quiet', '--stderr', '--stdin', '$FILENAME' },
    },
  },
}

vim.keymap.set({ 'n', 'x' }, '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = 'Format buffer or selection' })
