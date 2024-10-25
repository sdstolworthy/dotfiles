return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    'WhoIsSethDaniel/mason-tool-installer.nvim',
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
    local lspconfig = require("lspconfig")
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local default_capabilities = vim.lsp.protocol.make_client_capabilities()

    default_capabilities = vim.tbl_deep_extend(
      "force",
      default_capabilities,
      cmp_nvim_lsp.default_capabilities()
    )

    local server_configs = {
      ts_ls = {},

      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              disable = {
                "missing-fields"
              }
            },
          },
        },
      },
    }

    mason.setup()

    local mason_ensure_installed = vim.tbl_keys(server_configs or {})
    vim.list_extend(
      mason_ensure_installed,
      {
        {
          "stylua",
          "jdtls",
        }
      }
    )
    mason_tool_installer.setup({
      ensure_installed = mason_ensure_installed
    })

    mason_lspconfig.setup({
      handlers = {
        ['jdtls'] = function() end,
        function(server_name)
          local server_config = server_configs[server_name] or {}
          server_config.capabilities = vim.tbl_deep_extend(
            "force",
            default_capabilities,
            server_config.capabilities or {}
          )
          lspconfig[server_name].setup(server_config)
        end
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach-keybinds", { clear = true }),
      callback = function(e)
        local keymap = function(keys, func)
          vim.keymap.set("n", keys, func, { buffer = e.buf })
        end
        local builtin = require("telescope.builtin")

        keymap("gd", builtin.lsp_definitions)
        keymap("gD", vim.lsp.buf.declaration)
        keymap("gr", builtin.lsp_references)
        keymap("gI", builtin.lsp_implementations)
        keymap("<leader>D", builtin.lsp_type_definitions)
        keymap("<leader>ds", builtin.lsp_document_symbols)
        keymap("<leader>ws", builtin.lsp_dynamic_workspace_symbols)
        keymap("<leader>rn", vim.lsp.buf.rename)
        keymap("<leader>ca", vim.lsp.buf.code_action)
        keymap("K", vim.lsp.buf.hover)
      end
    })
  end
}