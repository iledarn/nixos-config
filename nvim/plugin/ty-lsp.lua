-- ty (Astral) language server for Python
-- Requires: `ty` installed and available in PATH
-- Neovim will spawn: `ty server`

vim.lsp.config("ty", {
  cmd = { "ty", "server" },
  filetypes = { "python" },

  -- Optional but recommended: set root detection
  -- (adjust if you have a different project layout)
  root_dir = vim.fs.root(0, {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  }),

  settings = {
    ty = {
      -- If you already use pyright/pylance for hover/completions,
      -- keep ty focused on diagnostics:
      -- disableLanguageServices = true,

      -- Choose diagnostics scope:
      -- "openFilesOnly" (faster/less noisy) or "workspace" (more thorough)
      -- diagnosticMode = "openFilesOnly",
      -- diagnosticMode = "workspace",
    },
  },
})
