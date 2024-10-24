local telescope = require('telescope')
telescope.setup {
  defaults = {
    file_ignore_patterns = {
      --      "lib",
      --      "dist",
      --      "build",
      --      "target",
      --      "cdk.out",
      --      "package-lock.json",
      --      "node_modules",
      --      ".git"
    }
  },
  pickers = {
  },
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fw', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
