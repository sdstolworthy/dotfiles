-- DAP
local dap = require('dap')
dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = { os.getenv('HOME') .. '/dev/microsoft/vscode-node-debug2/out/src/nodeDebug.js' },
}
dap.configurations.typescript = {
  {
    name = 'Amplify',
    type = 'node2',
    request = 'launch',
    program = function()
      return os.getenv('HOME') .. '/.yarn/bin/amplify-dev'
    end,
    args = function()
      local argument_string = vim.fn.input('Program arguments: ')
      return vim.fn.split(argument_string, " ", true)
    end,
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
  {
    name = 'Launch',
    type = 'node2',
    request = 'launch',
    program = '$HOME/.yarn/bin/amplify-dev',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
  {
    name = 'Attach to process',
    type = 'node2',
    request = 'attach',
    processId = require 'dap.utils'.pick_process,
  },
}
dap.configurations.default = dap.configurations.typescript

dap.configurations.netrw = dap.configurations.typescript
dap.configurations["neo-tree"] = dap.configurations.typescript

local dapui = require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Telescope
require('telescope').setup { defaults = { file_ignore_patterns = { "node_modules" } } }

-- Startup
require("startup").setup({ theme = "startify" }) -- put theme name here

-- Neo-Tree
require("neo-tree").setup({
  window = {
    mappings = {
      ["P"] = { "toggle_preview", config = { use_float = false } },
    }
  },
})

-- ToggleTerm
require("toggleterm").setup()
