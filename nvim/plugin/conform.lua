local conform = require("conform")

conform.setup({
  -- Which formatter(s) to use per filetype
  formatters_by_ft = {
    python = { "ruff_format" },
    toml = { "taplo" },
  },

  -- Format on save (fast + predictable)
  -- format_on_save = function(bufnr)
  --   local ft = vim.bo[bufnr].filetype
  --   if ft == "python" or ft == "toml" then
  --     return {
  --       timeout_ms = 2000,
  --       lsp_fallback = true,
  --     }
  --   end
  --   return nil
  -- end,
})

-- Manual format key (normal + visual)
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  conform.format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

local function ruff_fix()
  if vim.fn.executable("ruff") ~= 1 then
    vim.notify("ruff not found in PATH", vim.log.levels.ERROR)
    return
  end

  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to run ruff on", vim.log.levels.WARN)
    return
  end

  -- Save before running ruff, then refresh if it changes the file.
  vim.cmd("update")
  local result = vim.fn.system({ "ruff", "check", "--fix", "--quiet", file })
  if vim.v.shell_error ~= 0 then
    vim.notify(result ~= "" and result or "ruff check --fix failed", vim.log.levels.ERROR)
    return
  end

  vim.cmd("checktime")
  vim.notify("Ruff check --fix complete", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("RuffFix", ruff_fix, {})
vim.keymap.set("n", "<leader>rf", ruff_fix, { desc = "Ruff check --fix --quiet" })

-- :Format command
vim.api.nvim_create_user_command("Format", function()
  conform.format({ lsp_fallback = true })
end, {})
