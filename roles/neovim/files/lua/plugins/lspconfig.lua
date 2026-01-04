return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- Load luvit types when the `vim.uv` word is found
					{ path = "luvit-meta/library", words = { "vim%.uv" } },
				},
			},
		},
		-- optional `vim.uv` typings for lazydev
		{ "Bilal2453/luvit-meta", lazy = true },
	},

	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local default_capabilities = vim.lsp.protocol.make_client_capabilities()

		default_capabilities = vim.tbl_deep_extend("force", default_capabilities, cmp_nvim_lsp.default_capabilities())

		local configs = {
			lua_ls = {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							disable = {
								"missing-fields",
							},
						},
					},
				},
			},
			kotlin_language_server = {
				single_file_support = true,
				filetypes = { "kotlin" },
				root_markers = { "build.gradle", "build.gradle.kts", "pom.xml" },
			},
			ts_ls = {},
			templ = {},
		}

		for server, config in pairs(configs) do
			config.capabilities = default_capabilities
			vim.lsp.config(server, config)
		end

		mason.setup()

		local mason_ensure_installed =
			{ "ts_ls", "templ", "rust_analyzer", "lua_ls", "stylua", "jdtls", "kotlin-language-server", "codelldb" }

		mason_tool_installer.setup({
			ensure_installed = mason_ensure_installed,
		})

		mason_lspconfig.setup({
			automatic_enable = {
				exclude = { "rust_analyzer", "jdtls" }, -- Handled separately
			},
		})

		vim.diagnostic.config({ update_in_insert = false })

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach-keybinds", { clear = true }),
			callback = function(e)
				local keymap = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = e.buf, desc = desc })
				end

				keymap("gd", vim.lsp.buf.definition, "Go to definition")
				keymap("gD", vim.lsp.buf.declaration, "Go to declaration")
				keymap("gr", function() require("telescope.builtin").lsp_references() end, "Find references")
				keymap("gI", function() require("telescope.builtin").lsp_implementations() end, "Find implementations")
				keymap("<leader>D", function() require("telescope.builtin").lsp_type_definitions() end, "Type definition")
				keymap("<leader>ds", function() require("telescope.builtin").lsp_document_symbols() end, "Document symbols")
				keymap("<leader>ws", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "Workspace symbols")
				keymap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				keymap("<leader>ca", vim.lsp.buf.code_action, "Code action")
				keymap("K", vim.lsp.buf.hover, "Hover docs")
				keymap("<C-s>", vim.lsp.buf.signature_help, "Signature help")
				keymap("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
				keymap("]d", vim.diagnostic.goto_next, "Next diagnostic")
				keymap("<leader>e", vim.diagnostic.open_float, "Show diagnostic")

				-- Enable inlay hints if supported
				local client = vim.lsp.get_client_by_id(e.data.client_id)
				if client and client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = e.buf })
				end
			end,
		})
	end,
}
