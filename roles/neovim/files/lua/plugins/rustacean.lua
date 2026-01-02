return {
  'mrcjkb/rustaceanvim',
  version = '^6',
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              features = "all",
              allFeatures = true,
            },
          },
        },
      },
      dap = {
        adapter = require("rustaceanvim.config").get_codelldb_adapter(
          vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.dylib"
        ),
      },
    }
  end,
}
