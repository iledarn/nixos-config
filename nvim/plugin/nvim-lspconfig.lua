-- Nil language server setup
local lspconfig = require('lspconfig')
-- Get the Nil binary path from the Nix store
local nil_bin = "${pkgs.nil}/bin/nil"
lspconfig.nil_ls.setup {
  cmd = { nil_bin },
  on_attach = on_attach,
  capabilities = capabilities,
}
local lua_lsp_bin = "${pkgs.lua-language-server}/bin/lua-language-server"
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

