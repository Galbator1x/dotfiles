vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.cmd 'hi LineNr guibg=none'

    vim.cmd 'hi GitSignsAdd guibg=none'
    vim.cmd 'hi GitSignsChange guibg=none'
    vim.cmd 'hi GitSignsDelete guibg=none'

    vim.cmd 'hi VGitSignsAdd guibg=none'
    vim.cmd 'hi VgitSignsChange guibg=none'
    vim.cmd 'hi GitSignsDelete guibg=none'
  end,
})
