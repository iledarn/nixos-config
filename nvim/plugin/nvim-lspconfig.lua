-- Nil language server setup
local function resolve_bin(name, fallback)
  local exe = vim.fn.exepath(name)
  if exe ~= "" then
    return exe
  end
  return fallback or name
end

local nil_bin = resolve_bin("nil")
vim.lsp.config("nil_ls", {
  cmd = { nil_bin },
  on_attach = on_attach,
  capabilities = capabilities,
})
local lua_lsp_bin = resolve_bin("lua-language-server")
vim.lsp.config("lua_ls", {
  cmd = { lua_lsp_bin, "-E", "-e", "LANG=en" },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }
      }
    }
  }
})

-- TOML language server (great for pyproject.toml)
local taplo_bin = resolve_bin("taplo")
vim.lsp.config("taplo", {
  cmd = { taplo_bin, "lsp", "stdio" },
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.enable({ "nil_ls", "lua_ls", "taplo" })
