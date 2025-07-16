return {
	"stevearc/conform.nvim",
	opts = function()
		local conform = require("conform")

		vim.keymap.set("n", "<space>as", function()
			conform.format({ async = true, lsp_fallback = true })
		end)
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- Use a sub-list to run only the first available formatter
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
			},
		})
	end,
}
