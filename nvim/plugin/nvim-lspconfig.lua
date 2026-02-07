-- Nil language server setup
local lspconfig = require('lspconfig')

local function resolve_bin(name, fallback)
  local exe = vim.fn.exepath(name)
  if exe ~= "" then
    return exe
  end
  return fallback or name
end

local nil_bin = resolve_bin("nil")
lspconfig.nil_ls.setup {
  cmd = { nil_bin },
  on_attach = on_attach,
  capabilities = capabilities,
}
local lua_lsp_bin = resolve_bin("lua-language-server")
lspconfig.lua_ls.setup {
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
}

-- TOML language server (great for pyproject.toml)
local taplo_bin = resolve_bin("taplo")
lspconfig.taplo.setup {
  cmd = { taplo_bin, "lsp", "stdio" },
  on_attach = on_attach,
  capabilities = capabilities,
}
