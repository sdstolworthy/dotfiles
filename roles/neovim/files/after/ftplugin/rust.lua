local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set(
  "n", 
  "<leader>a", 
  function()
    vim.cmd.RustLsp('codeAction')
  end,
  { silent = true, buffer = bufnr, desc = "Rust code action" }
)
vim.keymap.set(
  "n", 
  "K",
  function()
    vim.cmd.RustLsp({'hover', 'actions'})
  end,
  { silent = true, buffer = bufnr, desc = "Rust hover" }
)
vim.keymap.set(
  "n",
  "<leader>dd",
  function()
    vim.cmd.RustLsp('debuggables')
  end,
  { silent = true, buffer = bufnr, desc = "Rust debuggables" }
)
