vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

require('mini.ai').setup { -- Better Around/Inside textobjects.
  n_lines = 500,
  mappings = {
    inside_last = '', -- Disable previous inner textobject (il); keep native inner line.
    around_last = '', -- Disable previous outer textobject (al); keep native all lines.
  },
}

require('mini.surround').setup { -- See :help MiniSurround-vim-surround-config.
  mappings = {
    add = 'ys',
    delete = 'ds',
    replace = 'cs',
    find = '', -- Disable jumping to the right surrounding edge (default: sf).
    find_left = '', -- Disable jumping to the left surrounding edge (default: sF).
    highlight = '', -- Disable highlighting the surrounding (default: sh).
    suffix_last = '', -- Disable the suffix for targeting the previous surrounding (default: l).
    suffix_next = '', -- Disable the suffix for targeting the next surrounding (default: n).
  },
  search_method = 'cover_or_next',
}

vim.keymap.del('x', 'ys') -- Replace Visual-mode ys with S (for example, viwS").
vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true }) -- Clear the Visual range, then surround the selection.
vim.keymap.set('n', 'yss', 'ys_', { remap = true }) -- Surround the current line; remap=true invokes the custom ys operator.
