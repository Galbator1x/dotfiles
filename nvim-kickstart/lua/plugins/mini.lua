return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 } -- Better Around/Inside textobjects
    require('mini.pairs').setup()

    local statusline = require 'mini.statusline'
    statusline.setup {
      use_icons = true,
      content = {
        active = function()
          if vim.bo.filetype == 'neo-tree' then
            return MiniStatusline.combine_groups {{ hl = 'MiniStatuslineFilename', strings = { '' } }}
          end

          local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
          local git = MiniStatusline.section_git { trunc_width = 40 }
          local diff = MiniStatusline.section_diff { trunc_width = 75 }
          local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
          local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
          local filename = MiniStatusline.section_filename { trunc_width = 300 }
          local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
          local location = MiniStatusline.section_location { trunc_width = 75 }
          local search = MiniStatusline.section_searchcount { trunc_width = 75 }

          return MiniStatusline.combine_groups {
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
            return MiniStatusline.combine_groups {{ hl = 'MiniStatuslineFilename', strings = { '' } }}
          end

          local filename = MiniStatusline.section_filename { trunc_width = 300 }

          return MiniStatusline.combine_groups {
            { hl = 'MiniStatuslineFilename', strings = { filename } },
          }
        end,
      },
    }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end
  end,
}
