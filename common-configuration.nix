# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  hostname,
  username,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hosts/${hostname}/hardware-configuration.nix
    # <sops-nix/modules/sops>
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.initrd.luks.devices."luks-4608edec-17fe-4266-acd3-ea1acb4a1a60".device = "/dev/disk/by-uuid/4608edec-17fe-4266-acd3-ea1acb4a1a60";
  networking.hostName = hostname; # Define your hostname.
  networking.extraHosts = ''
    127.0.0.1 doodba12
    127.0.0.1 doodba13
    127.0.0.1 doodba14
    127.0.0.1 doodba15
    127.0.0.1 doodba16
    127.0.0.1 doodba17
    139.162.11.95 usdtest12.kaertech.com
    127.0.0.1 erp2024_12_15.localhost
    127.0.0.1 erp2024_12_02.localhost
    127.0.0.1 erp2024_12_01.localhost
    127.0.0.1 erp2025_01_06.localhost
    127.0.0.1 erp2025_01_20.localhost
    127.0.0.1 erp2025_01_20_2.localhost
    127.0.0.1 erp2025_01_26.localhost
    127.0.0.1 erp2025_02_07.localhost
  '';
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_PH.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fil_PH";
    LC_IDENTIFICATION = "fil_PH";
    LC_MEASUREMENT = "fil_PH";
    LC_MONETARY = "fil_PH";
    LC_NAME = "fil_PH";
    LC_NUMERIC = "fil_PH";
    LC_PAPER = "fil_PH";
    LC_TELEPHONE = "fil_PH";
    LC_TIME = "fil_PH";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

  # Configure keymap in X11
  services.xserver = {
    layout = "us,ru";
    xkbVariant = "";
    xkbOptions = "ctrl:nocaps";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;  # if you need TCP/IP connections
    authentication = pkgs.lib.mkForce ''
      # Configuration for authentication
      local all all trust
      host  all all 127.0.0.1/32 md5
      host  all all localhost md5
      host  all all 172.18.0.1/16 md5
    '';
    # Optional: Initialize with some databases/roles
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE USER odoo WITH PASSWORD 'mypassword' CREATEDB;
    '';
  };

  virtualisation.docker.enable = true;

  # Garbage collection can be automated
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      firefox
      #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    gnome.gnome-tweaks
    gnome.adwaita-icon-theme
    gnomeExtensions.appindicator
    wget
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
