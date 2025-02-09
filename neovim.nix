{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true;
    extraPython3Packages = pkgs:
      with pkgs; [
        python-lsp-server
        # Other Python packages for Neovim...
        black
        pyyaml
      ];
    extraPackages = with pkgs; [
      pyright
      lua-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      lazydev-nvim
      lualine-nvim
      nvim-web-devicons
      (nvim-treesitter.withPlugins (p: [
        p.tree-sitter-nix
        p.tree-sitter-vim
        p.tree-sitter-bash
        p.tree-sitter-lua
        p.tree-sitter-python
        p.tree-sitter-json
      ]))
      {
        plugin = gruvbox-nvim;
        config = "colorscheme gruvbox";
      }
    ];
    extraLuaConfig =
      # lua
      ''
        ${builtins.readFile ./nvim/options.lua}
      '';
  };
}
