local conform = require("conform")

conform.setup({
  -- Which formatter(s) to use per filetype
  formatters_by_ft = {
    python = { "ruff_format" },
    toml = { "taplo" },
  },

  -- Format on save (fast + predictable)
  format_on_save = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft == "python" or ft == "toml" then
      return {
        timeout_ms = 2000,
        lsp_fallback = true,
      }
    end
    return nil
  end,
})

-- Manual format key (normal + visual)
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  conform.format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

-- :Format command
vim.api.nvim_create_user_command("Format", function()
  conform.format({ lsp_fallback = true })
end, {})
