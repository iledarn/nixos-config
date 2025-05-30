-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- optionally enable 24-bit colour
vim.opt.termguicolors = true
-- empty setup using defaults
require('nvim-tree').setup()
vim.api.nvim_set_keymap('n', '<leader>\\', [[<cmd>NvimTreeToggle<CR>]], { })
vim.api.nvim_set_keymap('n', '<leader>\\\\', [[<cmd>NvimTreeFindFile<CR>]], { })

