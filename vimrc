syntax on

filetype on

set tabstop=2
colorscheme codedark
set expandtab
set shiftwidth=2
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
let g:lsc_server_commands = {'dart': 'dart_language_server','javascript':{'command':'typescript-language-server --stdio'},'typescript':'typescript-language-server --stdio', 'typescript.tsx':'typescript-language-server --stdio'}

let g:lsc_enable_autocomplete = v:true

call plug#begin('~/.vim/plugged')
Plug 'natebosch/vim-lsc'
Plug 'natebosch/vim-lsc-dart'
Plug 'dart-lang/dart-vim-plugin'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
call plug#end()

augroup SyntaxSettings
  autocmd!
  autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx
augroup END

let g:lsc_auto_map = v:true
function! GitBranch()
      return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
    let l:branchname = GitBranch()
    return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 
