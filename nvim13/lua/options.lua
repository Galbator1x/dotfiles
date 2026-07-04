vim.loader.enable() -- Enable faster startup by caching compiled Lua modules

-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.spelllang = 'ru_ru,en_us'

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

vim.g.have_nerd_font = true

vim.g.autoformat = false

vim.opt.number = true -- Make line numbers default
vim.opt.signcolumn = 'yes'
vim.opt.showmode = false -- Don't show the mode, since it's already in the status line
vim.opt.breakindent = true
vim.opt.cursorline = true
vim.opt.scrolloff = 3

vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.inccommand = 'split' -- Preview substitutions live in bottom buffer, as you type!

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.updatetime = 250 -- Used for CursorHold event

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- Plugins -------------------------
vim.g.solarized_italics = 0
