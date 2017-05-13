set nocompatible
" filetype off

let $PATH = $PATH . ':' . expand("~/.local/bin")

" { Plugins
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
    " Plug 'dyng/ctrlsf.vim' " Powered code search and view tool
    Plug 'jlanzarotta/bufexplorer'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'jasoncodes/ctrlp-modified.vim'
    Plug 'scrooloose/nerdtree'
    " Plug 'godlygeek/tabular' " Text filtering and alignment
    " Plug 'jeetsukumaran/vim-buffergator' " Vim plugin to list, select and switch between buffers
    " Plug 'tpope/vim-projectionist' " Provides granular project configuration

    " Autocomplete
    Plug 'jiangmiao/auto-pairs'
    Plug 'tpope/vim-unimpaired'
    " Plug 'Valloric/YouCompleteMe'
    Plug 'ervandew/supertab' " Perform all your vim insert mode completions with Tab
    Plug 'reedes/vim-lexical' " Build on Vim’s spell/thes/dict completion

    " Advanced
    Plug 'vim-airline/vim-airline' " status/tabline
    " Plug 'vim-airline/vim-airline-themes'
    Plug 'airblade/vim-gitgutter'
    Plug 'majutsushi/tagbar' " F8. Displays tags in a window, ordered by scope
    Plug 'mbbill/undotree' " The ultimate undo history visualizer
    Plug 'Valloric/MatchTagAlways' " Always highlight enclosing tags
    " Plug 'terryma/vim-multiple-cursors'
    " Plug 'Shougo/vimproc.vim' " Interactive command execution in Vim
    Plug 'shime/vim-livedown'
    " Plug 'joonty/vdebug' " Multi-language DBGP debugger client
    Plug 'xolox/vim-misc' " Miscellaneous auto-load Vim scripts
    Plug 'xolox/vim-easytags' " Automated tag file generation and syntax highlighting of tags
    " Plug 'Shougo/vimshell.vim' " Powerful shell implemented by vim
    " Plug 'SirVer/ultisnips' "The ultimate snippet solution for Vim
    " Plug 'w0rp/ale' " Asynchronous Lint Engine
    Plug 'skywind3000/asyncrun.vim' " Run Async Shell Commands

    " Tools integration
    " Plug 'hashivim/vim-vagrant'

    " Languages support
    " Plug 'chase/vim-ansible-yaml'
    Plug 'othree/html5.vim' " HTML5 omnicomplete and syntax
    " Plug 'tpope/vim-haml' " Vim runtime files for Haml, Sass, and SCSS
    Plug 'plasticboy/vim-markdown'
    Plug 'tmux-plugins/vim-tmux'
    Plug 'Glench/Vim-Jinja2-Syntax'
    Plug 'fatih/vim-go'
    Plug 'elzr/vim-json' " A better JSON for Vim: distinct highlighting of keywords vs values
    Plug 'stephpy/vim-yaml'
    Plug 'chrisbra/csv.vim' " A Filetype plugin for csv files
    Plug 'ekalinin/Dockerfile.vim'
    Plug 'tpope/vim-ragtag' " A set of mappings for HTML...
    " Plug 'editorconfig/editorconfig-vim' " http://editorconfig.org/
    Plug 'mattn/emmet-vim'
    " Plug 'wlangstroth/vim-racket'

    " Python

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
    " Plug 'maxmellon/vim-jsx-pretty' " React JSX syntax pretty highlighting

    " Themes
    Plug 'nanotech/jellybeans.vim'

    " Other
    " Plug 'nathanaelkane/vim-indent-guides' " visually displaying indent levels in code

    call plug#end()
    " filetype plugin indent on
" }

augroup lexical
  autocmd!
  autocmd FileType markdown,mkd call lexical#init()
  autocmd FileType textile call lexical#init()
  autocmd FileType text call lexical#init({ 'spell': 0 })
augroup END

let mapleader = "\<Space>"
" let mapleader=","

" Sets how many lines of history VIM has to remember
set history=500

" Configure backspace so it acts as it should act
set backspace=eol,start,indent

" enhanced command completion
set wildmenu

set visualbell

if has('mouse')
  set mouse=a
endif

" Don't redraw while executing macros (good performance config)
set lazyredraw

set cursorline
set hidden
set nofoldenable
"set modelines=0
" set clipboard=unnamed
"set synmaxcol=128
"set ttyscroll=10
"set encoding=utf-8
set nowrap
set number
set hlsearch
set ignorecase
set smartcase

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

set autoindent
set expandtab
set softtabstop=4
set shiftwidth=4
" set smarttab

set t_Co=256
colorscheme jellybeans

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_aggregate_errors = 1

let g:syntastic_check_on_wq = 0

let g:vim_json_syntax_conceal = 0

let g:lexical#spelllang = ['en_us', 'ru_ru']

let g:easytags_async = 1

" Automatically removing all trailing whitespace
autocmd BufWritePre * :%s/\s\+$//e

let g:vim_markdown_folding_disabled = 1

nmap <F8> :TagbarToggle<CR>
" nnoremap <F5> :UndotreeToggle<cr>

" Toggle paste mode
nmap <silent> <F4> :set invpaste<CR>:set paste?<CR>
imap <silent> <F4> <ESC>:set invpaste<CR>:set paste?<CR>

" format the entire file
nnoremap <leader>fef :normal! gg=G``<CR>

" set text wrapping toggles
nmap <silent> <leader>tw :set invwrap<CR>:set wrap?<CR>

" find merge conflict markers
nmap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>

" upper/lower word
nmap <leader>u mQviwU`Q
nmap <leader>l mQviwu`Q

nnoremap <Leader>o :CtrlP<CR>
nnoremap <Leader>w :w<CR>

" Хуй знает что это
" vmap <Leader>y "+y
" vmap <Leader>d "+d
" nmap <Leader>p "+p
" nmap <Leader>P "+P
" vmap <Leader>p "+p
" vmap <Leader>P "+P

nmap <C-\> :NERDTreeFind<CR>
nmap <silent> <leader><leader> :NERDTreeToggle<CR>

let NERDTreeIgnore = ['\.pyc$', '\.retry$', '^activate', '^easy_install', '^pip$', '^pip3', '^python$', '^python3', 'migrations', '__pycache__', '^flask$',]

let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

nmap <silent> // :nohlsearch<CR>
noremap ,hl :set hlsearch! hlsearch?<CR>

" Allows you to enter sudo pass and save the file
" " when you forgot to open your file with sudo
cmap w!! %!sudo tee > /dev/null %

" Allow to copy/paste between VIM instances
" "copy the current visual selection to ~/.vbuf
vmap <Leader>y :w! ~/.vbuf<CR>
" "copy the current line to the buffer file if no visual selection
nmap <Leader>y :.w! ~/.vbuf<CR>
" "paste the contents of the buffer file
nmap <Leader>p :r ~/.vbuf<CR>

" Map ctrl-movement keys to window switching
map <C-k> <C-w><Up>
map <C-j> <C-w><Down>
map <C-l> <C-w><Right>
map <C-h> <C-w><Left>
nnoremap <silent> <bs> <C-w><Left>

" Russian lang in insert mode
" Use Ctrl+^ to switch keyboard layout
set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0
highlight lCursor guifg=NONE guibg=Cyan

let g:bufExplorerDisableDefaultKeyMapping=1
let g:bufExplorerShowRelativePath=1
nnoremap <leader>b :BufExplorer<CR>

let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_silent = 1  " do not display the auto-save notification
let g:auto_save_events = ["InsertLeave", "TextChanged"]

" let g:livedown_browser = "chrome"
let g:livedown_autorun = 0
let g:livedown_open = 1

" let g:ycm_python_binary_path = '/usr/bin/python3.6'
" let g:ycm_server_keep_logfiles = 1
" let g:ycm_server_log_level = 'debug'

autocmd FileType python setlocal ts=4 sts=4 sw=4 et autoindent
autocmd Filetype html setlocal ts=2 sts=2 sw=2 et autoindent
autocmd Filetype htmldjango setlocal ts=2 sts=2 sw=2 et autoindent
autocmd Filetype css setlocal ts=2 sts=2 sw=2 et autoindent
"autocmd! BufWritePost * Neomake

autocmd FileType python nnoremap <Leader>i :!isort %<CR><CR>

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

if filereadable(expand("~/.vimrc.after"))
  source ~/.vimrc.after
endif
