" Self-contained vim defaults (no plugins, no ~/.vim_runtime). Neovim reads
" ~/.config/nvim instead and is not managed here.
set nocompatible
syntax on
filetype plugin indent on

set encoding=utf-8
set number
set ruler
set laststatus=2
set showcmd
set wildmenu
set scrolloff=5
set hidden
set mouse=a
set backspace=indent,eol,start

" Search
set incsearch
set hlsearch
set ignorecase
set smartcase

" Indentation: 2 spaces
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2
set autoindent

" No backup/swap clutter; keep undo across sessions (dir created by install.sh)
set nobackup
set nowritebackup
set noswapfile
if isdirectory($HOME . '/.vim/undo')
  set undofile
  set undodir=$HOME/.vim/undo
endif
