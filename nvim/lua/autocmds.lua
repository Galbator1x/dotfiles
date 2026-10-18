vim.api.nvim_create_autocmd({
  'InsertLeave',
  'CursorHold',
  'FocusLost',
  'BufLeave',
}, {
  desc = 'Save modified file buffers',
  group = vim.api.nvim_create_augroup('auto-save', { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local opts = vim.bo[buf]
    if opts.buftype ~= '' or not opts.modifiable or opts.readonly or not opts.modified then return end
    if vim.api.nvim_buf_get_name(buf) == '' then return end

    vim.api.nvim_buf_call(buf, function() vim.cmd 'silent update' end)
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.hl_op() end,
})

vim.api.nvim_create_autocmd('User', {
  desc = 'Close Neo-tree before saving the session',
  group = vim.api.nvim_create_augroup('session-close-neotree', { clear = true }),
  pattern = 'PersistenceSavePre',
  callback = function() vim.cmd 'Neotree close' end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Remove backgrounds from line numbers and Git signs',
  group = vim.api.nvim_create_augroup('transparent-gutter', { clear = true }),
  callback = function()
    vim.cmd 'hi LineNr guibg=none'

    vim.cmd 'hi GitSignsAdd guibg=none'
    vim.cmd 'hi GitSignsChange guibg=none'
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
