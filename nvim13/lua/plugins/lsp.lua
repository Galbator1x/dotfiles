vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/folke/lazydev.nvim',
  'https://github.com/j-hui/fidget.nvim',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' },
}

require('mason').setup()
require('mason-lspconfig').setup { ensure_installed = { 'lua_ls' }, automatic_enable = false }
require('mason-tool-installer').setup { ensure_installed = { 'stylua' } }
-- Load plugin libraries once to avoid transient undefined globals during LuaLS workspace reloads.
-- Preloading all plugin libraries may increase initial indexing time and memory usage.
require('lazydev').setup {
  library = vim.fn.globpath(vim.fn.stdpath 'data' .. '/site/pack/*/opt', '*/lua', false, true),
}
require('fidget').setup {}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(ev)
    local function map(keys, action, desc, mode)
      vim.keymap.set(mode or 'n', keys, action, { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end
    local function picker(name)
      return function() require('telescope.builtin')[name]() end
    end

    map('gd', picker 'lsp_definitions', 'Go to definition')
    map('gr', picker 'lsp_references', 'Go to references')
    map('gI', picker 'lsp_implementations', 'Go to implementation')
    map('<leader>D', picker 'lsp_type_definitions', 'Type definition')
    map('<leader>ds', picker 'lsp_document_symbols', 'Document symbols')
    map('<leader>ws', picker 'lsp_dynamic_workspace_symbols', 'Workspace symbols')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', ev.buf) then
      local group = vim.api.nvim_create_augroup('lsp-highlight-' .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = group,
        buffer = ev.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = group,
        buffer = ev.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
    if client and client:supports_method('textDocument/inlayHint', ev.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = ev.buf }, { bufnr = ev.buf })
      end, 'Toggle inlay hints')
    end
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
  callback = function(ev)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then return end
      for _, client in ipairs(vim.lsp.get_clients { bufnr = ev.buf }) do
        if client:supports_method('textDocument/documentHighlight', ev.buf) then return end
      end
      vim.api.nvim_buf_call(ev.buf, vim.lsp.buf.clear_references)
      pcall(vim.api.nvim_del_augroup_by_name, 'lsp-highlight-' .. ev.buf)
    end)
  end,
})

vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
      format = { enable = false }, -- Conform formats Lua with StyLua.
    },
  },
})
vim.lsp.enable { 'lua_ls', 'solargraph' }
