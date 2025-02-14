require('oil').setup()
vim.keymap.set("n", "<leader>o", require("oil").open, { desc = "Open parent directory" })
