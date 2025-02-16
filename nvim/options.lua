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

vim.opt.termguicolors = true

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  pattern = '*',
})

vim.keymap.set('n', 'Zz', '<C-w>_<C-w>|', { silent = true })
vim.keymap.set('n', 'Zo', '<C-w>=', { silent = true })
