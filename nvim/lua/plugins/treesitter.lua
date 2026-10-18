vim.pack.add { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } }

require('nvim-treesitter').install {
  'ruby',
  'bash',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
}

local treesitter = require 'nvim-treesitter'

local function attach(buf, language)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if not vim.treesitter.language.add(language) then return end

  vim.treesitter.start(buf, language)
  if vim.bo[buf].filetype == 'ruby' then
    vim.bo[buf].syntax = 'ruby' -- Preserve regex syntax needed by Ruby's native indentation.
  elseif language ~= 'lua' and vim.treesitter.query.get(language, 'indents') then -- Use native Lua indentation for nested callbacks.
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local available = treesitter.get_available()
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable Treesitter highlighting and indentation',
  group = vim.api.nvim_create_augroup('treesitter-highlight', { clear = true }),
  callback = function(ev)
    local language = vim.treesitter.language.get_lang(ev.match)
    if not language then return end

    if vim.tbl_contains(treesitter.get_installed 'parsers', language) then
      attach(ev.buf, language)
    elseif vim.tbl_contains(available, language) then
      treesitter.install(language):await(function() attach(ev.buf, language) end) -- Attach after asynchronous installation completes.
    else
      attach(ev.buf, language) -- Also support parsers bundled with Neovim.
    end
  end,
})
