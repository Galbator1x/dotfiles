vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'PersistenceSavePre',
  callback = function()
    vim.cmd 'Neotree close'
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

    vim.cmd 'hi MiniStatuslineModeNormal guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineModeInsert guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineModeVisual guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineModeReplace guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineModeCommand guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineModeOther guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineDevinfo guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineFilename guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineFileinfo guibg=#eee8d5'
    vim.cmd 'hi MiniStatuslineInactive guibg=#eee8d5'
  end,
})
