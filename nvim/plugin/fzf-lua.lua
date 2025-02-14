vim.keymap.set("n", "<leader>ff", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
vim.keymap.set("n", "<leader>tt", "<cmd>lua require('fzf-lua').tabs()<CR>", { silent = true })
vim.keymap.set("n", "<leader>lg", "<cmd>lua require('fzf-lua').live_grep_glob()<CR>", { silent = true })
vim.keymap.set("n", "<leader>lG", "<cmd>lua require('fzf-lua').fzf_live('rg --no-ignore-vcs --column --line-number --no-heading --color=always --smart-case', { previewer = 'builtin' })<CR>", { silent = true })
vim.keymap.set("n", "<leader>Lg", "<cmd>lua require('fzf-lua').live_grep()<CR>", { silent = true })
vim.keymap.set("n", "<leader>gg", "<cmd>lua require('fzf-lua').grep()<CR>", { silent = true })
vim.keymap.set("n", "<leader>gl", "<cmd>lua require('fzf-lua').grep_last()<CR>", { silent = true })
vim.keymap.set("n", "<leader>gp", "<cmd>lua require('fzf-lua').grep_project()<CR>", { silent = true })
vim.keymap.set("n", "<leader>gC", "<cmd>lua require('fzf-lua').grep_cword()<CR>", { silent = true })
vim.keymap.set("n", "<leader>gc", "<cmd>lua require('fzf-lua').grep_cWORD()<CR>", { silent = true })
vim.keymap.set("n", "<leader>gb", "<cmd>lua require('fzf-lua').lgrep_curbuf()<CR>", { silent = true })
vim.keymap.set("n", "<leader>jj", "<cmd>lua require('fzf-lua').jumps()<CR>", { silent = true })
vim.keymap.set("n", "<leader>rr", "<cmd>lua require('fzf-lua').registers()<CR>", { silent = true })
vim.keymap.set("n", "<leader>cc", "<cmd>lua require('fzf-lua').changes()<CR>", { silent = true })
vim.keymap.set("n", "<leader>bb", "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })

local actions = require "fzf-lua.actions"

require'fzf-lua'.setup{
  files = {
    toggle_ignore_flag = "--no-ignore-vcs",
    actions = {
      ["ctrl-i"] = { actions.toggle_ignore },
    },
  },
}
