syntax on

filetype on

colorscheme molokai
set tabstop=8
set expandtab
set shiftwidth=4
set autoindent
set smartindent
set hlsearch
set incsearch
set ignorecase
set smartcase
set backspace=indent,eol,start
filetype indent on
set path+=**
set wildmenu
set splitright
set splitbelow
set number
let g:lsc_server_commands = {'dart': 'dart_language_server','javascript':{'command':'typescript-language-server --stdio'},'typescript':'typescript-language-server --stdio'}

let g:lsc_enable_autocomplete = v:true

call plug#begin('~/.vim/plugged')
Plug 'natebosch/vim-lsc'
Plug 'natebosch/vim-lsc-dart'
Plug 'mcmartelle/vim-monokai-bold'
Plug 'dart-lang/dart-vim-plugin'
Plug 'tomasiser/vim-code-dark'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
call plug#end()

let g:lsc_auto_map = v:true
