require("lazy").setup({
  -- disable all update / install features
  -- this is handled by nix
  rocks = { enabled = false },
  pkg = { enabled = false },
  install = { missing = false },
  change_detection = { enabled = false },
  spec = {
    -- TODO
  },
})
