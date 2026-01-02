return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "vimdoc",
      "go",
      "lua",
      "java",
      "rust",
      "typescript",
    },
    sync_install = false,
    auto_install = true,
    indent = {
      enable = true
    },
    highlight = {
      enable = true,
    },
  },
}
