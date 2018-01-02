set nocompatible
" filetype off

let $PATH = $PATH . ':' . expand("~/.local/bin")

call plug#begin('~/.vim/plugged')

" General
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch' " Asynchronous build and test dispatcher
Plug 'tpope/vim-fugitive' " Git wrapper
Plug 'tpope/vim-git'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'janko-m/vim-test'
Plug '907th/vim-auto-save'

" Search and navigation
Plug 'dyng/ctrlsf.vim' " Powered code search and view tool
" Plug 'mileszs/ack.vim' " Search tool (need to install ack-grep)
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
Plug 'godlygeek/tabular' " Text filtering and alignment
" Plug 'jeetsukumaran/vim-buffergator' " Vim plugin to list, select and switch between buffers
" Plug 'tpope/vim-projectionist' " Provides granular project configuration

" Autocomplete
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-unimpaired'
" Plug 'Valloric/YouCompleteMe'
Plug 'ervandew/supertab' " Perform all your vim insert mode completions with Tab
Plug 'reedes/vim-lexical' " Build on Vim’s spell/thes/dict completion
" Plug 'honza/vim-snippets'

" Language client
" Plug 'autozimu/LanguageClient-neovim', { 'do': ':UpdateRemotePlugins' }
" " (Optional) Multi-entry selection UI.
" Plug 'Shougo/denite.nvim'
" " (Optional) Completion integration with deoplete.
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" " (Optional) Completion integration with nvim-completion-manager.
" Plug 'roxma/nvim-completion-manager'
" " (Optional) Showing function signature and inline doc.
" Plug 'Shougo/echodoc.vim'

" Advanced
Plug 'vim-airline/vim-airline' " status/tabline
" Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'majutsushi/tagbar' " F8. Displays tags in a window, ordered by scope
Plug 'mbbill/undotree' " The ultimate undo history visualizer
Plug 'Valloric/MatchTagAlways' " Always highlight enclosing tags
" Plug 'terryma/vim-multiple-cursors'
" Plug 'Shougo/vimproc.vim' " Interactive command execution in Vim
Plug 'shime/vim-livedown', { 'for': 'markdown' }
" Plug 'joonty/vdebug' " Multi-language DBGP debugger client
Plug 'xolox/vim-misc' " Miscellaneous auto-load Vim scripts
" Plug 'xolox/vim-easytags' " Automated tag file generation and syntax highlighting of tags
" Plug 'Shougo/vimshell.vim' " Powerful shell implemented by vim
" Plug 'SirVer/ultisnips' "The ultimate snippet solution for Vim
Plug 'w0rp/ale' " Asynchronous Lint Engine
Plug 'skywind3000/asyncrun.vim' " Run Async Shell Commands
Plug 'editorconfig/editorconfig-vim'

" Tools integration
" Plug 'hashivim/vim-vagrant'

" Languages support
Plug 'othree/html5.vim' " HTML5 omnicomplete and syntax
" Plug 'tpope/vim-haml', { 'for': 'haml' } " Vim runtime files for Haml, Sass, and SCSS
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'tmux-plugins/vim-tmux'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'fatih/vim-go'
Plug 'elzr/vim-json' " A better JSON for Vim: distinct highlighting of keywords vs values
Plug 'stephpy/vim-yaml', { 'for': 'yaml' }
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
Plug 'ekalinin/Dockerfile.vim'
Plug 'tpope/vim-ragtag' " A set of mappings for HTML...
" Plug 'editorconfig/editorconfig-vim' " http://editorconfig.org/
Plug 'mattn/emmet-vim'
" Plug 'wlangstroth/vim-racket'
Plug 'chr4/nginx.vim'

" Python
" Plug 'python-mode/python-mode'
Plug 'nvie/vim-flake8'

" Ruby
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-endwise'
Plug 'thoughtbot/vim-rspec'
Plug 'tpope/vim-rvm'
Plug 'p0deje/vim-ruby-interpolation'
" Plug 'sunaku/vim-ruby-minitest' " highlighting & completion for MiniTest

" Clojure
" Plug 'guns/vim-clojure-highlight'
" Plug 'guns/vim-clojure-static'
" Plug 'guns/vim-slamhound'
" Plug 'tpope/vim-leiningen'
" Plug 'tpope/vim-classpath' " Set 'path' from the Java class path
" Plug 'tpope/vim-fireplace' " Clojure REPL support
" Plug 'tpope/vim-salve' " static support for Leiningen and Boot
" Plug 'venantius/vim-eastwood' " Clojure's Eastwood linter
" Plug 'venantius/vim-cljfmt'
" Plug 'vim-scripts/paredit.vim' " Structured Editing of Lisp S-expressions
" Plug 'jpalardy/vim-slime' " to turn Emacs into a Lisp IDE

" Haskell
" Plug 'eagletmt/ghcmod-vim'
" Plug 'eagletmt/neco-ghc'
" Plug 'mpickering/hlint-refactor-vim'
" Plug 'neovimhaskell/haskell-vim'
" Plug 'twinside/vim-hoogle'

" JavaScript
Plug 'pangloss/vim-javascript' " Vastly improved Javascript indentation and syntax
" Plug 'mxw/vim-jsx' " React JSX syntax highlighting and indenting
" Plug 'mtscout6/vim-cjsx'
" Plug 'flowtype/vim-flow'
" Plug 'moll/vim-node' " Tools and environment to make Vim superb for developing with Node.js
" Plug 'benjie/neomake-local-eslint.vim'
" Plug 'ternjs/tern_for_vim'
" Plug 'chemzqm/vim-jsx-improve', { 'for': 'javascript' }

" Themes
Plug 'nanotech/jellybeans.vim'

" Other
Plug 'ntpeters/vim-better-whitespace'
Plug 'mitermayer/vim-prettier', {
      \ 'do': 'yarn install',
      \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss'] }
" rhysd/vim-clang-format " for clang-format, a formatter for JavaScript,...
" Plug 'ConradIrwin/vim-bracketed-paste' " need modern terminal like iTerm2
" Plug 'nathanaelkane/vim-indent-guides' " visually displaying indent levels in code

call plug#end()
" filetype plugin indent on

let mapleader = "\<Space>"

" https://github.com/vim/vim/blob/master/runtime/doc/russian.txt
" Enable hotkeys for Russian layout
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

" Sets how many lines of history VIM has to remember
set history=500

if has('mouse')
  set mouse=a
endif

if has("clipboard")
  set clipboard=unnamed " copy to the system clipboard

  if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
  endif
endif

" Don't redraw while executing macros (good performance config)
set lazyredraw
set ttyfast

set hidden
set nofoldenable
set wrap
set linebreak
set number
set hlsearch
set ignorecase
set smartcase

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowritebackup
set nowb
set noswapfile

" set autoindent
set expandtab
set softtabstop=2
set shiftwidth=2

set splitbelow
set scrolloff=3

colorscheme jellybeans

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

""" Basics Keymaps

" Turn off linewise keys. Normally, the `j' and `k' keys move the cursor down one entire line. with line wrapping on, this can cause the cursor to actually skip a few lines on the screen because it's moving from line N to line N+1 in the file. I want this to act more visually -- I want `down' to mean the next line on the screen
nmap j gj
nmap k gk

" Map ctrl-movement keys to window switching
map <C-k> <C-w><Up>
map <C-j> <C-w><Down>
map <C-l> <C-w><Right>
map <C-h> <C-w><Left>

" Auto indent pasted text
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

" Edit .vimrc
map <leader>vl :vsp $MYVIMRC<CR>
map <leader>vr :source $MYVIMRC<CR>

" Toggle paste mode TODO replace by plugin
nmap <silent> <F4> :set invpaste<CR>:set paste?<CR>
imap <silent> <F4> <ESC>:set invpaste<CR>:set paste?<CR>

" format the entire file
nnoremap ff :normal! gg=G``<CR>

" upper/lower word
nmap <leader>u mQviwU`Q
nmap <leader>l mQviwu`Q

" find merge conflict markers
nmap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>

nmap <silent> // :nohlsearch<CR>
noremap <leader>/ :set hlsearch! hlsearch?<CR>

" select last paste in visual mode
nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'

" set text wrapping toggles
nmap <silent> <leader>w :set invwrap<CR>:set wrap?<CR>

""" Plugins Keymaps

nmap <C-m> :NERDTreeFind<CR>
nmap <silent> <leader><leader> :NERDTreeToggle<CR>

nnoremap <leader>b :BufExplorer<CR>

inoremap <expr> <C-j> pumvisible() ? "\<C-N>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-P>" : "\<C-k>"

" Move between linting errors
nnoremap ]r :ALENextWrap<CR>
nnoremap [r :ALEPreviousWrap<CR>

map <Leader>a :call RunAllSpecs()<CR>

""" Plugin Settings

let g:vim_markdown_frontmatter = 1
let g:vim_markdown_toc_autofit = 1
let g:lexical#spelllang = ['en_us', 'ru_ru']

let g:ale_linters = {
      \   'markdown': [],
      \   'javascript': ['eslint', 'flow'],
      \}

let g:vim_markdown_folding_disabled = 1

nmap <F8> :TagbarToggle<CR>

" set text wrapping toggles
nmap <silent> <leader>tw :set invwrap<CR>:set wrap?<CR>

nmap <Leader>p "0p
vmap <Leader>p "0p
nmap <Leader>P "0P
vmap <Leader>P "0P

let NERDTreeIgnore = ['\.pyc$', '\.retry$', '^activate', '^easy_install', '^pip$', '^pip3', '^python$', '^python3', 'migrations', '__pycache__', '^flask$',]

" Allows you to enter sudo pass and save the file
" " when you forgot to open your file with sudo
cmap w!! %!sudo tee > /dev/null %

" Blockwise Visual
command! Vb normal! <C-v>

let g:bufExplorerDisableDefaultKeyMapping=1
let g:bufExplorerShowRelativePath=1

let g:airline#extensions#ale#enabled = 1

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

nmap <C-p> :Files<CR>

augroup common
  autocmd BufEnter * EnableStripWhitespaceOnSave
augroup END
let g:better_whitespace_enabled = 0

if filereadable(expand("~/.vimrc.after"))
  source ~/.vimrc.after
endif

let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_silent = 1  " do not display the auto-save notification
let g:auto_save_events = ["InsertLeave", "TextChanged"]

let g:livedown_autorun = 0
let g:livedown_open = 1

autocmd FileType python setlocal ts=4 sts=4 sw=4 et

autocmd FileType python nnoremap <Leader>i :!isort %<CR><CR>

set completeopt-=preview

" let g:pymode_lint_unmodified = 1
" let g:pymode_lint_checkers = ['pyflakes']
" let g:pymode_lint_write = 1
" let g:pymode_python = 'python3'
" let g:pymode_options_max_line_length = 90
" let g:pymode_options_colorcolumn = 0
" let g:pymode_indent = 1
" let g:pymode_folding = 0
" let g:pymode_run = 0
" let g:pymode_rope_vim_completion = 0
" let g:pymode_syntax_highlight_self = 0
" let g:pymode_breakpoint = 0

" { Vim-test
    let test#strategy = "dispatch"
    let test#python#runner = 'pytest'

    nmap <silent> <leader>rt :TestSuite<CR>
    nmap <silent> <leader>rf :TestFile<CR>
    nmap <silent> <leader>rn :TestNearest<CR>
    nmap <silent> <leader>rr :TestLast<CR>
    nmap <silent> <leader>g :TestVisit<CR>
" }

" { Quick run via <F5>
    nnoremap <F5> :call <SID>compile_and_run()<CR>

    augroup SPACEVIM_ASYNCRUN
        autocmd!
        " Automatically open the quickfix window
        autocmd User AsyncRunStart call asyncrun#quickfix_toggle(6, 1)
    augroup END

    function! s:compile_and_run()
        exec 'w'
        if &filetype == 'sh'
           exec "AsyncRun! time bash %"
        elseif &filetype == 'python'
           exec "AsyncRun! python3 %"
        endif
    endfunction
" }

nnoremap <leader>fj :vertical resize 60<CR>
nnoremap <leader>fk :vertical resize 65<CR>
nnoremap <leader>fl :vertical resize 70<CR>
nnoremap <silent> <leader>q :close<CR>

" autocmd FileType python map <buffer> <F3> :call Flake8()<CR>

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'

fun! DetectTemplate()
  let n = 1
  while n < line("$")
    if getline(n) =~ '{%' || getline(n) =~ '{{'
      set ft=htmldjango
      return
    endif
    let n = n + 1
  endwhile
  set ft=html "default html
endfun
autocmd BufNewFile,BufRead *.html call DetectTemplate()

" visual selection search via *
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>
function! s:VSetSearch(cmdtype)
    let temp = @s
    norm! gv"sy
    let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
    let @s = temp
endfunction
