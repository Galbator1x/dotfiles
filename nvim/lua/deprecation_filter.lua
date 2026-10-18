-- TODO: Remove this file and its require in init.lua once installed Plenary and Telescope versions replace vim.F.if_nil with vim.nonnil.
-- Filter known vim.F.if_nil warnings from Plenary and Telescope before plugins load.
-- Uses an internal Neovim API.
local deprecated_health = require 'vim.deprecated.health'
local add_deprecation = deprecated_health.add

---@diagnostic disable-next-line: duplicate-set-field
deprecated_health.add = function(name, version, backtrace, alternative)
  if name == 'vim.F.if_nil' then
    local caller = backtrace:match('stack traceback:\n([^\n]+)') or '' -- Match the direct caller, not plugins further down the stack.
    if caller:find('/plenary.nvim/lua/', 1, true) or caller:find('/telescope.nvim/lua/', 1, true) then return end
  end
  return add_deprecation(name, version, backtrace, alternative)
end
