require('bufferline').setup({
  options = {
    mode = "tabs",
    numbers = "ordinal",
  },
})
vim.keymap.set("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<CR>")
vim.keymap.set("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<CR>")
vim.keymap.set("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<CR>")
vim.keymap.set("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<CR>")
vim.keymap.set("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<CR>")
vim.keymap.set("n", "<leader>6", "<cmd>BufferLineGoToBuffer 6<CR>")
vim.keymap.set("n", "<leader>7", "<cmd>BufferLineGoToBuffer 7<CR>")
vim.keymap.set("n", "<leader>8", "<cmd>BufferLineGoToBuffer 8<CR>")
vim.keymap.set("n", "<leader>9", "<cmd>BufferLineGoToBuffer 9<CR>")
