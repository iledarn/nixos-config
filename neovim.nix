{pkgs, ...}:
{
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
    extraPackages = [
      pkgs.pyright
    ];
    plugins = [ pkgs.vimPlugins.lazy-nvim ];
    extraLuaConfig =
      # lua
      ''
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
      '';
  };
}
