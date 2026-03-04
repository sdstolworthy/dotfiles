local function find_kiro_cli()
  local explicit = vim.env.KIRO_CLI_PATH
  if explicit then
    return explicit
  end
  local found = vim.fn.exepath("kiro-cli")
  if found ~= "" then
    return found
  end
  return nil
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions" },
  },
  cond = function()
    return find_kiro_cli() ~= nil
  end,
  opts = function()
    return {
      adapters = {
        kiro = function()
          return require("codecompanion.adapters").extend("acp", {
            command = find_kiro_cli(),
            args = { "acp" },
          })
        end,
      },
      strategies = {
        chat = { adapter = "kiro" },
        inline = { adapter = "kiro" },
        agent = { adapter = "kiro" },
      },
    }
  end,
}
