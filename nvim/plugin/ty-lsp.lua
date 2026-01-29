-- ty (Astral) language server for Python
-- Uses the Nix-provided binary if available; falls back to PATH
local ty_bin = "${pkgs.ty}/bin/ty"
if vim.fn.filereadable(ty_bin) == 0 then
  local path_bin = vim.fn.exepath("ty")
  if path_bin == "" then
    vim.notify("[ty] 'ty' executable not found; skipping Ty LSP setup", vim.log.levels.WARN)
    return
  end
  ty_bin = path_bin
end

local function ty_root(bufnr)
  return vim.fs.root(bufnr, {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
end

local function set_lsp_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
end

local ty_cfg = {
  name = "ty",
  filetypes = { "python" },
  root_dir = ty_root(0),
  settings = {
    ty = {
      -- Enable language services (hover, completion, definition, references)
      disableLanguageServices = false,
      -- diagnosticMode = "workspace",
    },
  },
  on_attach = function(_, bufnr)
    set_lsp_keymaps(bufnr)
  end,
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(args)
    local root = ty_root(args.buf)
    if not root or root == "" then return end
    local cmd = { ty_bin, "server" }
    vim.lsp.start(vim.tbl_extend("force", ty_cfg, {
      root_dir = root,
      cmd = cmd,
    }))
  end,
})
