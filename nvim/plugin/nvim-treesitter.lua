require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    -- You can disable specific languages if needed
    -- disable = { "c", "rust" },
  },
  indent = {
    enable = true,
    -- You can disable specific languages if needed
    -- disable = { "python" },
  },
  -- Optional: Enable incremental selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}

