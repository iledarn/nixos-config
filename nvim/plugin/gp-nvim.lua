-- gp.nvim configuration (Neovim Lua)
local ok, gp = pcall(require, "gp")
if not ok then
  return          -- plugin not found; safe‑exit to avoid errors
end

-- Main setup ---------------------------------------------------------------
gp.setup({
  openai_api_key = vim.env.OPENAI_API_KEY,   -- read from env; export it in shell
  chat_window    = { layout = "float" },
  normalize_whitespace = true,              -- tidy incoming/outgoing text

  -- Example custom hook: generate Busted unit tests for the current Lua file
  hooks = {
    tests = {
      user_message_template = "Write Lua busted tests for:\n```$code```",
      assistant_action      = "prepend",   -- insert above the current selection
    },
  },
})

-- Keymaps ------------------------------------------------------------------
-- vim.keymap.set("n", "<leader>aa", ":GpChatNew<CR>", { desc = "New AI chat" })
-- vim.keymap.set("v", "<leader>ar", ":<C-u>GpRewrite<CR>", {
--   desc   = "Rewrite with AI",
--   silent = true,
-- })
