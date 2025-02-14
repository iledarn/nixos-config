require('lualine').setup({
  extensions = { "fugitive", "fzf", "quickfix" },
  options = {
    icons_enabled = true,
    theme = 'auto',
  },
  tabline = {},
})
