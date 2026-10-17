vim.pack.add {
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' },
}

require('blink.cmp').setup {
  keymap = {
    preset = 'default',
    ['<C-l>'] = { 'snippet_forward', 'fallback' }, -- Preserve the previous snippet navigation key.
  },
  sources = { default = { 'lsp', 'path' } },
  completion = {
    list = { selection = { preselect = false, auto_insert = false } }, -- Keep completion text unchanged until selection is accepted.
  },
  fuzzy = { implementation = 'lua' }, -- Avoid downloading a separate native matcher.
  signature = { enabled = true },
}
