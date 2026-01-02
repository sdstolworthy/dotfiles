return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    cmd = "Telescope",
    keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>sn", function() require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") }) end, desc = "Search Neovim config" },
        { "<leader><leader>", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        { "<leader>/", function()
            require("telescope.builtin").current_buffer_fuzzy_find(
                require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                }
            )
        end, desc = "Fuzzy find in buffer" },
    },
    opts = {},
}
