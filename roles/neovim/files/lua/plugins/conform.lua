return {
	"stevearc/conform.nvim",
	keys = {
		{
			"<space>as",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			desc = "Format buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform will run multiple formatters sequentially
			python = { "isort", "black" },
			-- Use a sub-list to run only the first available formatter
			javascript = { "prettier" },
			typescript = { "prettier" },
			json = { "prettier" },
		},
	},
}
