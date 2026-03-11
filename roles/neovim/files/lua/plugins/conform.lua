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
			python = { "isort", "black" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			json = { "prettier" },
			java = { "google-java-format" },
			kotlin = { "ktlint" },
		},
	},
}
