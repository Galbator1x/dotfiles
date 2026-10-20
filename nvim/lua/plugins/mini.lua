vim.pack.add {
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons', -- Filetype icons for mini.statusline.
}

require('mini.pairs').setup {} -- Automatically insert matching brackets and quotes.
vim.keymap.set('i', '<C-h>', 'v:lua.MiniPairs.bs()', { expr = true, replace_keycodes = false, desc = 'Delete character or empty pair' }) -- Match Backspace behavior for Ctrl+h.

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

local statusline = require 'mini.statusline'
statusline.setup {
  content = {
    active = function()
      if vim.bo.filetype == 'neo-tree' then
        return statusline.combine_groups {{ hl = 'MiniStatuslineFilename', strings = { '' } }}
      end

      local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
      local git = statusline.section_git { trunc_width = 40 }
      local diff = statusline.section_diff { trunc_width = 75 }
      local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
      local lsp = statusline.section_lsp { trunc_width = 75 }
      local filename = statusline.section_filename { trunc_width = 300 }
      local fileinfo = statusline.section_fileinfo { trunc_width = 120 }
      local location = statusline.section_location { trunc_width = 75 }
      local search = statusline.section_searchcount { trunc_width = 75 }

      return statusline.combine_groups {
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
        '%<', -- Mark general truncate point
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=', -- End left alignment
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl, strings = { search, location } },
      }
    end,

    inactive = function()
      if vim.bo.filetype == 'neo-tree' then
        return statusline.combine_groups {{ hl = 'MiniStatuslineInactive', strings = { '' } }}
      end

      local filename = statusline.section_filename { trunc_width = 300 }

      return statusline.combine_groups {
        { hl = 'MiniStatuslineInactive', strings = { filename } },
      }
    end,
  },
}
