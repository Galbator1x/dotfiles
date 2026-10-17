vim.pack.add {
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' },
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = 'master' }, -- Use the vim.nonnil compatibility fix for Nvim 0.13.
}

require('luasnip.config').setup {}
require('blink.cmp').setup {
  keymap = {
    preset = 'default',
    ['<C-l>'] = { 'snippet_forward', 'fallback' }, -- Preserve the previous snippet navigation key.
  },
  sources = { default = { 'lsp', 'path', 'snippets' } },
  snippets = { preset = 'luasnip' },
  completion = {
    list = { selection = { preselect = false, auto_insert = false } }, -- Keep completion text unchanged until selection is accepted.
  },
  fuzzy = { implementation = 'lua' }, -- Avoid downloading a separate native matcher.
  signature = { enabled = true },
}
