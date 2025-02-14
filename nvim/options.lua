vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>fs", "<cmd>w<cr>")
vim.keymap.set("n", "<leader><Tab>", "<cmd>b#<cr>")

vim.g.gruvbox_material_enable_italic = true
-- vim.cmd.colorscheme('gruvbox-material')
vim.cmd.colorscheme('codedark')
