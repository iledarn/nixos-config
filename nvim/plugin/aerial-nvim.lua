require("aerial").setup({
  on_attach = function(bufnr)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '{', '<cmd>AerialPrev<CR>', {})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '}', '<cmd>AerialNext<CR>', {})
  end,
})
vim.keymap.set("n", "<leader>ae", "<cmd>AerialToggle!<CR>")
