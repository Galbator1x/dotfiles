vim.pack.add { 'https://github.com/lewis6991/gitsigns.nvim' }

require('gitsigns').setup {
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    vim.keymap.set('n', '<leader>gb', gitsigns.blame, { buffer = bufnr, desc = 'Git blame' })

    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true } -- Preserve native navigation in diff windows.
      else
        gitsigns.nav_hunk 'next'
      end
    end, { buffer = bufnr, desc = 'Next Git change' })

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true } -- Preserve native navigation in diff windows.
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { buffer = bufnr, desc = 'Previous Git change' })
  end,
}
