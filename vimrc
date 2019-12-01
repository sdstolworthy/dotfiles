syntax on

colorscheme desert
set path+=**
set wildmenu
set splitright
set splitbelow
set number
let g:lsc_server_commands = {'dart': 'dart_language_server','javascript':{'command':'typescript-language-server --stdio'}}

let g:lsc_enable_autocomplete = v:true

call plug#begin('~/.vim/plugged')
Plug 'natebosch/vim-lsc'
Plug 'natebosch/vim-lsc-dart'

Plug 'dart-lang/dart-vim-plugin'
Plug 'tomasiser/vim-code-dark'


call plug#end()

let g:lsc_auto_map = v:true
