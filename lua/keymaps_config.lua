vim.keymap.set('n', '<leader>s', ':split <CR>')
vim.keymap.set('n', '<leader>v', ':vsplit <CR>')
vim.keymap.set('n', '<leader>t', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
vim.keymap.set(
  'n', '<leader>d', ':lua vim.diagnostic.open_float()<CR>',
  { noremap = true, silent = true }
)

vim.keymap.set('n', '<leader>tt', ':ToggleTerm<CR>')
vim.keymap.set('n', '<leader>tl', ':ToggleTerm direction=vertical size=100<CR>')
