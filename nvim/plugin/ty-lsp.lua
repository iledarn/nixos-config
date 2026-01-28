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

-- compute an extra search path: sibling "odoo" directory next to the project root, if present

-- local function sibling_odoo_path(root)
--   if not root or root == "" then return nil end
--   local parent = vim.fs.dirname(root)
--   if not parent or parent == "" then return nil end
--   local candidate = parent .. "/odoo"
--   return vim.fn.isdirectory(candidate) == 1 and candidate or nil
-- end

local ty_cfg = {
  name = "ty",
  filetypes = { "python" },
  root_dir = ty_root(0),
  settings = {
    ty = {
      -- If you already use pyright/pylance for hover/completions,
      -- keep ty focused on diagnostics:
      -- disableLanguageServices = true,
      -- diagnosticMode = "openFilesOnly",
      -- diagnosticMode = "workspace",
    },
  },
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(args)
    local root = ty_root(args.buf)
    if not root or root == "" then return end
    -- local extra = sibling_odoo_path(root)
    local cmd = { ty_bin, "server" }
    -- if extra then
    --   table.insert(cmd, "--extra-search-path")
    --   table.insert(cmd, extra)
    -- end
    vim.lsp.start(vim.tbl_extend("force", ty_cfg, {
      root_dir = root,
      cmd = cmd,
    }))
  end,
})
