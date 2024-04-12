" Install vim-plug if not found

set encoding=UTF-8
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear
autocmd BufRead,BufNewFile tsconfig.json set filetype=jsonc


call plug#begin('~/.vim/plugged')
let g:coc_disable_startup_warning = 1

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Core
Plug 'nvim-neotest/nvim-nio'
Plug 'sirtaj/vim-openscad'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'
Plug 'microsoft/vscode-js-debug', { 'do': 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out' }


Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-neo-tree/neo-tree.nvim'
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'kdheepak/lazygit.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.4' }
Plug 'f-person/git-blame.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-neotest/neotest'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'startup-nvim/startup.nvim'
Plug 'github/copilot.vim'
Plug 'mfussenegger/nvim-dap'
Plug 'mxsdev/nvim-dap-vscode-js'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'williamboman/mason.nvim'
Plug 'jay-babu/mason-nvim-dap.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}

" themes
Plug 'ayu-theme/ayu-vim'
Plug 'sainnhe/everforest'
Plug 'jaredgorski/spacecamp'
Plug 'folke/tokyonight.nvim'

let g:coc_global_extensions = [
  \ 'coc-java',
  \ 'coc-tsserver',
  \ 'coc-go',
  \ 'coc-eslint',
  \ 'coc-pyright',
  \ 'coc-flutter',
  \ 'coc-rust-analyzer',
  \ 'coc-xml',
  \ 'coc-json',
  \ 'coc-prettier'
  \ ]

call plug#end()
let mapleader = " "

" colo onedark
colo tokyonight-day
highlight LineNr ctermfg=grey
let g:airline#extensions#tabline#enabled = 1


syntax on

set title
" set bg=dark
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,**/node_modules/**,**/coverage/**     " MacOSX/Linux
set wildmode=list:longest,full
set wildmenu
set nu
set tabstop=2
set shiftwidth=2
set expandtab
set laststatus=2

lua <<EOF
require('config')
EOF
"  set clipboard+=unnamed

"  " REMAP ESC
"  " esc in insert mode
"  " inoremap kj <esc>
"  " esc in visual mode
"  " vnoremap kj <esc>
"  " esc in command mode
"  " cnoremap kj <C-C>
"  
"  " Enable pasting register in terminal mode
"  tnoremap <expr> <C-V> '<C-\><C-N>"'.nr2char(getchar()).'pi'
"  
"  
"  
"  " set autochdir
"  
"  if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
"    let g:coc_global_extensions += ['coc-eslint']
"  endif
"  
"  " key mappings for Coc
"  
"  
"  " TextEdit might fail if hidden is not set.
"  set hidden
"  
"  " Some servers have issues with backup files, see #649.
"  set nobackup
"  set nowritebackup
"  
"  " Give more space for displaying messages.
"  set cmdheight=2
"  
"  " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
"  " delays and poor user experience.
"  set updatetime=300
"  
"  " Don't pass messages to |ins-completion-menu|.
"  set shortmess+=c
"  
"  " Always show the signcolumn, otherwise it would shift the text each time
"  " diagnostics appear/become resolved.
"  if has("patch-8.1.1564")
"    " Recently vim can merge signcolumn and number column into one
"    set signcolumn=number
"  else
"    set signcolumn=yes
"  endif
"  
"  
"  
"  function! s:check_back_space() abort
"    let col = col('.') - 1
"    return !col || getline('.')[col - 1]  =~# '\s'
"  endfunction
"  
"  if has('nvim')
"    inoremap <silent><expr> <c-space> coc#refresh()
"  else
"    inoremap <silent><expr> <c-@> coc#refresh()
"  endif
"  
"  " ------- Keymaps --------
"  " Use tab for trigger completion with characters ahead and navigate.
"  " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
"  " other plugin before putting this into your config.
"  "
"  
"  noremap <leader>ee <Cmd>CocCommand eslint.executeAutofix<CR>
"  noremap <leader>dd <Cmd>lua require("dapui").toggle()<CR>
"  noremap <leader>bb <Cmd>lua require('dap').toggle_breakpoint()<CR>
"  noremap <leader>si <Cmd>lua require('dap').step_into()<CR>
"  noremap <leader>so <Cmd>lua require('dap').step_over()<CR>
"  noremap <leader>su <Cmd>lua require('dap').step_out()<CR>
"  noremap <F1> <Cmd>lua require('dap').step_over()<CR>
"  noremap <F2> <Cmd>lua require('dap').step_into()<CR>
"  noremap <F3> <Cmd>lua require('dap').step_out()<CR>
"  noremap <F9> <Cmd>lua require('dap').continue()<CR>
"  noremap <F4> <Cmd>lua require('dapui').toggle({ reset = true })<CR>
"  noremap <F5> <Cmd>lua require('dap').toggle_breakpoint()<CR>
"  noremap <Leader>dsc <Cmd>lua require('dap').continue()<CR>
"  noremap <leader>e <Cmd>Neotree reveal toggle position=left<cr>
"  noremap <leader>b <Cmd>Neotree buffers position=right toggle<cr>
"  
"  " Split navigation
"  nnoremap <leader>l <C-w>l
"  nnoremap <leader>h <C-w>h
"  nnoremap <leader>j <C-w>j
"  nnoremap <leader>k <C-w>k
"  
"  " Splitting
"  noremap <leader>s <Cmd>split<CR>
"  noremap <leader>v <Cmd>vsplit<CR>
"  noremap <leader>tn <Cmd>tabnew<CR>
"  
"  " ToggleTerm keymaps
"  noremap <leader>tt <Cmd>ToggleTerm<CR>
"  noremap <leader>tl <Cmd>ToggleTerm direction=vertical size=100<CR>
"  
"  " Terminal normal mode shortcut
"  
"  if has('nvim')
"    tnoremap <Esc> <C-\><C-n>
"    tnoremap <M-[> <Esc>
"    tnoremap <C-v><Esc> <Esc>
"  endif
"  
"  
"  " Use `[g` and `]g` to navigate diagnostics
"  " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
"  
"  
"  nmap <silent> [g <Plug>(coc-diagnostic-prev)
"  nmap <silent> ]g <Plug>(coc-diagnostic-next)
"  nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
"  nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
"  nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
"  nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
"  nnoremap <leader>fw <cmd>lua require('telescope.builtin').live_grep()<cr>
"  
"  " GoTo code navigation.
"  nmap <silent> gd <Plug>(coc-definition)
"  nmap <silent> gy <Plug>(coc-type-definition)
"  nmap <leader>gi <Plug>(coc-implementation)
"  nmap <silent> gr <Plug>(coc-references)
"  
"  " Symbol renaming.
"  nmap <leader>rn <Plug>(coc-rename)
"  
"  " Formatting selected code.
"  xmap <leader>cf  <Plug>(coc-format-selected)
"  nmap <leader>cf  <Plug>(coc-format-selected)
"  
"  " Applying codeAction to the selected region.
"  " Example: `<leader>aap` for current paragraph
"  xmap <leader>a  <Plug>(coc-codeaction-selected)
"  nmap <leader>a  <Plug>(coc-codeaction-selected)
"  nmap <leader>as  <Plug>(coc-format)
"  nmap <leader>rr  <Plug>(coc-codeaction)
"  nnoremap <silent> <leader>gg :LazyGit<CR>
"  nnoremap <silent> <leader>qq :q<CR>
"  
"  
"  " Remap keys for applying codeAction to the current buffer.
"  nmap <leader>ac  <Plug>(coc-codeaction)
"  " Apply AutoFix to problem on the current line.
"  nmap <leader>qf  <Plug>(coc-fix-current)
"  
"  " Use CTRL-S for selections ranges.
"  " Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
"  nmap <silent> <C-s> <Plug>(coc-range-select)
"  " Mappings for CoCList
"  " Show all diagnostics.
"  nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
"  " Manage extensions.
"  " nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
"  " Show commands.
"  nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
"  " Find symbol of current document.
"  nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
"  " Search workspace symbols.
"  " nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
"  " Do default action for next item.
"  " nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
"  " Do default action for previous item.
"  " nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
"  xmap <silent> <C-s> <Plug>(coc-range-select)
"  " Remap keys for applying refactor code actions
"  nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
"  xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
"  nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
"  
"  " Run the Code Lens action on the current line
"  nmap <leader>cl  <Plug>(coc-codelens-action)
"  " Resume latest coc list.
"  nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
"  function! ShowDocIfNoDiagnostic(timer_id)
"    if (coc#util#has_float() == 0)
"      silent call CocActionAsync('doHover')
"    endif
"  endfunction
"  nnoremap <silent> K :call <SID>show_documentation()<CR>
"  function! s:show_documentation()
"    if (index(['vim','help'], &filetype) >= 0)
"      execute 'h '.expand('<cword>')
"    else
"      call CocAction('doHover')
"    endif
"  endfunction
"  
"  inoremap <silent><expr> <TAB>
"        \ coc#pum#visible() ? coc#pum#next(1) :
"        \ CheckBackspace() ? "\<Tab>" :
"        \ coc#refresh()
"  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
"  inoremap <silent><expr> <Tab>
"        \ coc#pum#visible() ? coc#pum#next(1) :
"        \ CheckBackspace() ? "\<Tab>" :
"        \ coc#refresh()
"  inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
"  
"  " use <tab> to trigger completion and navigate to the next complete item
"  function! CheckBackspace() abort
"    let col = col('.') - 1
"    return !col || getline('.')[col - 1]  =~# '\s'
"  endfunction
"  
"  " -------- Commands ---------
"  " Add `:Format` command to format current buffer.
"  command! -nargs=0 Format :call CocAction('format')
"  
"  " Add `:Fold` command to fold current buffer.
"  command! -nargs=? Fold :call CocAction('fold', <f-args>)
"  
"  " Add `:OR` command for organize imports of the current buffer.
"  command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
"  
"  " Run Eslint
"  command! -nargs=0 EL :call CocAction('runCommand', 'eslint.lintProject')
"  
"  
