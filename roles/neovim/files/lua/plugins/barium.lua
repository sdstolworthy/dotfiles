-- Barium LSP for Brazil Config files
local configs = require("lspconfig.configs")
local lspconfig = require("lspconfig")

vim.filetype.add({
	filename = {
		["Config"] = function()
			vim.b.brazil_package_Config = 1
			return "brazil-config"
		end,
	},
})

configs.barium = {
	default_config = {
		cmd = { "barium" },
		filetypes = { "brazil-config" },
		root_dir = function(fname)
			return lspconfig.util.find_git_ancestor(fname)
		end,
		settings = {},
	},
}

lspconfig.barium.setup({})
