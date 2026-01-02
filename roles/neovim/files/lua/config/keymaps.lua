vim.keymap.set("n", "<C-f>", "<C-f>zz", { desc = "Page down" })
vim.keymap.set("n", "<C-b>", "<C-b>zz", { desc = "Page up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
vim.keymap.set("n", "<leader>s", "<C-w>s", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split vertical" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result" })

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>bf", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix" })

vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

vim.keymap.set("n", "<c-k>", ":wincmd k<CR>", { desc = "Window up" })
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>", { desc = "Window down" })
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>", { desc = "Window left" })
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>", { desc = "Window right" })
