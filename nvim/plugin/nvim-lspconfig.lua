-- Nil language server setup via the new vim.lsp.config API (nvim 0.11+)
local nil_bin = "${pkgs.nil}/bin/nil"
vim.lsp.config("nil_ls", {
  cmd = { nil_bin },
  on_attach = on_attach,
  capabilities = capabilities,
})
vim.lsp.enable("nil_ls")

local lua_lsp_bin = "${pkgs.lua-language-server}/bin/lua-language-server"
vim.lsp.config("lua_ls", {
  cmd = { lua_lsp_bin, "-E", "-e", "LANG=en" },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})
vim.lsp.enable("lua_ls")
