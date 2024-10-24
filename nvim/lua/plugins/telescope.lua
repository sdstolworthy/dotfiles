return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        local keymap = function(keys, func)
            vim.keymap.set("n", keys, func, {})
        end

        require("telescope").setup({})
        local builtin = require("telescope.builtin")

        keymap("<leader>ff", builtin.find_files)
        keymap("<leader>sn", function()
            builtin.find_files {
                cwd = vim.fn.stdpath "config"
            }
        end)
        keymap("<leader><leader>", builtin.buffers)
        keymap("<leader>fw", builtin.live_grep)
        keymap("<leader>/", function()
            builtin.current_buffer_fuzzy_find(
                require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                }
            )
        end)
    end
}
