vim.keymap.set("n", "gd", function()
  vim.cmd.RustLsp({ "hover", "actions" })
end, { buffer = true })
