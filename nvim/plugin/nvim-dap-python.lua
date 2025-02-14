require('dap-python').setup('python3')
vim.keymap.set("n", "\\b", "<cmd>lua require('dap').toggle_breakpoint()<CR>", { silent = true })
vim.keymap.set("n", "\\l", "<cmd>lua require('dap').list_breakpoints()<CR>", { silent = true })
vim.keymap.set("n", "\\L", "<cmd>lua require('dap').clear_breakpoints()<CR>", { silent = true })

vim.keymap.set("n", "\\;", "<cmd>lua require('dap').run_last()<CR>", { silent = true })
vim.keymap.set("n", "\\.", "<cmd>lua require('dap').run_to_cursor()<CR>", { silent = true })
vim.keymap.set("n", "\\x", "<cmd>lua require('dap').terminate()<CR>", { silent = true })
vim.keymap.set("n", "\\r", "<cmd>lua require('dap').restart()<CR>", { silent = true })

vim.keymap.set("n", "<leader>ro", "<cmd>lua require('dap').repl.open()<CR>", { silent = true })
vim.keymap.set("n", "<leader>rc", "<cmd>lua require('dap').repl.close()<CR>", { silent = true })

vim.keymap.set("n", "\\c", "<cmd>lua require('dap').continue()<CR>", { silent = true })
vim.keymap.set("n", "\\s", "<cmd>lua require('dap').step_over()<CR>", { silent = true })
vim.keymap.set("n", "\\i", "<cmd>lua require('dap').step_into()<CR>", { silent = true })
vim.keymap.set("n", "\\o", "<cmd>lua require('dap').step_out()<CR>", { silent = true })
