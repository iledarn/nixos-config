-- nvim-treesitter `main` branch: the old `require('nvim-treesitter.configs').setup{}`
-- API was removed. Grammars are provided by Nix (withPlugins) and are already on
-- the runtimepath, so no install/setup call is needed. Highlighting and indentation
-- are enabled per-buffer through Neovim's core treesitter API.
--
-- Note: the `incremental_selection` module no longer ships with nvim-treesitter's
-- main branch and has no core equivalent, so those keymaps (gnn/grn/grc/grm) are
-- gone. Re-add via a dedicated plugin if you still want them.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    -- Only enable where a parser is actually available; pcall keeps unsupported
    -- filetypes from throwing during startup.
    if pcall(vim.treesitter.start, args.buf) then
      -- Treesitter-based indentation (experimental upstream). Note the quoting.
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
