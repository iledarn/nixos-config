require("dapui").setup()
vim.keymap.set("n", "\\do", "<cmd>lua require('dapui').open()<CR>", { silent = true })
vim.keymap.set("n", "\\dc", "<cmd>lua require('dapui').close()<CR>", { silent = true })
vim.keymap.set("n", "\\dh", function()
  require("dapui").eval(nil, {
    width = math.floor(vim.o.columns * 0.8),
    height = 10,
    enter = true,
  })
end, { silent = true })
vim.keymap.set("n", "<leader>dh", function()
  require("dapui").eval(nil, {
    width = math.floor(vim.o.columns * 0.8),
    height = 10,
    enter = true,
  })
end, { silent = true })
