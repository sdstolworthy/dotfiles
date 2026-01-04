return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"joerdav/templ.vim",
		"mfussenegger/nvim-jdtls",
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
				exclude = { "rust_analyzer" }, -- Handled by rustaceanvim
			},
		})


		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach-keybinds", { clear = true }),
			callback = function(e)
				local keymap = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = e.buf, desc = desc })
				end
				local builtin = require("telescope.builtin")

				keymap("gd", vim.lsp.buf.definition, "Go to definition")
				keymap("gD", vim.lsp.buf.declaration, "Go to declaration")
				keymap("gr", builtin.lsp_references, "Find references")
				keymap("gI", builtin.lsp_implementations, "Find implementations")
				keymap("<leader>D", builtin.lsp_type_definitions, "Type definition")
				keymap("<leader>ds", builtin.lsp_document_symbols, "Document symbols")
				keymap("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
				keymap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				keymap("<leader>ca", vim.lsp.buf.code_action, "Code action")
				keymap("K", vim.lsp.buf.hover, "Hover docs")
				keymap("<C-s>", vim.lsp.buf.signature_help, "Signature help")

				-- Enable inlay hints if supported
				local client = vim.lsp.get_client_by_id(e.data.client_id)
				if client and client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = e.buf })
				end
			end,
		})
	end,
}
