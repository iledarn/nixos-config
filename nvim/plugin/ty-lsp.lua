-- Resolves from PATH
local ty_bin = vim.fn.exepath("ty")
if ty_bin == "" then
  vim.notify("[ty] 'ty' executable not found; skipping Ty LSP setup", vim.log.levels.WARN)
  return
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
  -- Diagnostics: float for cursor, loclist for current buffer
  vim.keymap.set("n", "<leader>td", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>tD", function()
    vim.diagnostic.setloclist({ open = true })
  end, opts)
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
