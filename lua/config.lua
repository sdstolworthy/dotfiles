-- NVIM Tree setup
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

require('neo-tree').setup({})

-- DAP

require("dap-vscode-js").setup({
  -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  debugger_path = "/Users/sstol/.vim/plugged/vscode-js-debug", -- Path to vscode-js-debug installation.
  -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
  adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
  -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
  -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
  -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
})

local dap = require("dap")

for _, language in ipairs({ "typescript", "javascript" }) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require'dap.utils'.pick_process,
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
    }
  }
end
require("dapui").setup()


-- Telescope
require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '-u' -- thats the new thing
    },
  },
  pickers = {
    find_files = {
      hidden = true
    },
    live_grep = {
      additional_args = function(opts)
          return {"--hidden"}
      end
    },
  },
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      ".git"
    }
  }
}

-- Startup
require("startup").setup({ theme = "startify" }) -- put theme name here

-- ToggleTerm
require("toggleterm").setup()
