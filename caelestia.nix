{caelestia-shell, ...}: {
  imports = [
    caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    cli.enable = true;
  };
}
