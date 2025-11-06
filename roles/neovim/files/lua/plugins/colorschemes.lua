return {
	{
		"Mofiqul/dracula.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
	{
		"morhetz/gruvbox",
		lazy = false,
		priority = 1000,
	},
	{
		"sainnhe/everforest",
	},
}
