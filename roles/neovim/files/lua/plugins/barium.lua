-- Barium LSP for Brazil Config files
vim.filetype.add({
	filename = {
		["Config"] = function()
			vim.b.brazil_package_Config = 1
			return "brazil-config"
		end,
	},
})

vim.lsp.config("barium", {
	cmd = { "barium" },
	filetypes = { "brazil-config" },
	root_markers = { ".git" },
})

vim.lsp.enable("barium")

return {}
