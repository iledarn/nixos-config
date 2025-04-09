require("dapui").setup()
vim.keymap.set("n", "\\do", "<cmd>lua require('dapui').open()<CR>", { silent = true })
vim.keymap.set("n", "\\dc", "<cmd>lua require('dapui').close()<CR>", { silent = true })
