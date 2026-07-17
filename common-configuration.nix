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
  '';
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Hand DNS to systemd-resolved so split DNS for the Kaertech LAN
  # zones works (see services.resolved block below).
  networking.networkmanager.dns = "systemd-resolved";

  # Split DNS for Kaertech LAN: resolve *.odoo.local and the whole .kepi TLD
  # (odoo1.kepi .. odoo4.kepi per-developer boxes, etc.) via dnsmasq on
  # CT 108 (192.168.20.108). All other queries continue through
  # NetworkManager's normal upstream. The leading ~ marks each as a
  # routing-only domain (not a search domain / default resolver); ~kepi
  # covers every *.kepi name, ~odoo.local the legacy test hostnames.
  services.resolved = {
    enable = true;
  #  extraConfig = ''
  #    DNS=192.168.20.108
  #    Domains=~odoo.local ~kepi
  #  '';
  };

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
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.udev.packages = with pkgs; [gnome-settings-daemon];

  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = ["org.telegram.desktop"];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us,ru";
    xkb.variant = "";
    xkb.options = "ctrl:nocaps";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable firmware updates via fwupd.
  services.fwupd.enable = true;
  services.thermald.enable = true;

  services.timesyncd.enable = false;
  services.chrony = {
    enable = true;
    servers = ["pool.ntp.org" "time.google.com"];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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
    extensions = ps: with ps; [pgvector];
    enableTCPIP = true; # if you need TCP/IP connections
    authentication = pkgs.lib.mkForce ''
      # Configuration for authentication
      local all all trust
      host  all all 127.0.0.1/32 md5
      host  all all localhost md5
      host  all all 172.18.0.1/16 md5
      host  all all 172.20.0.1/16 md5
    '';
    # Optional: Initialize with some databases/roles
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE USER odoo WITH PASSWORD 'mypassword' CREATEDB;
    '';
  };

  # Native MySQL for local KMS (Kaertech Monitoring System) dev — the non-Docker
  # restore target used by the nixkms Django envs. Mirrors services.postgresql
  # above. NO credentials live here. Admin is `root@localhost`, which mysql80
  # leaves passwordless over the world-readable unix socket (and which has
  # WITH GRANT OPTION) — that's what bootstraps the app user. The app/restore
  # user `kt_admin` and its password are created OUTSIDE nix (so the secret never
  # enters the world-readable nix store) and live only in ~/.my.cnf — the
  # ~/.pgpass analog. Bootstrap kt_admin with the restore-dev-db-kms skill's
  # scripts/bootstrap-native-mysql.sh after the first `nixos-rebuild`.

  #services.mysql = {
#    enable = true;
#    package = pkgs.mysql80;
#    settings.mysqld.bind-address = "127.0.0.1"; # TCP on 3306 (matches Docker db + nixkms DB_PORT)
#  };

  # Native Redis for local KMS dev — the cache/broker backend the nixkms Django
  # envs expect alongside MySQL. Mirrors services.mysql above. No credentials:
  # loopback only, no password (dev). The empty-name "" is the default instance,
  # which runs as redis.service.
  services.redis.servers."" = {
    enable = true;
    bind = "127.0.0.1"; # loopback only
    port = 6379; # TCP on 6379 (matches Docker redis + nixkms REDIS_PORT)
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
    gnome-tweaks
    adwaita-icon-theme
    gnomeExtensions.appindicator
    wget
    unzip
    nmap
    openssl
  ];

  # Point non-nixpkgs interpreters (uv/python-build-standalone, used by uvx-launched
  # MCP servers, etc.) at the system CA bundle. Their compiled-in default cafile path
  # doesn't exist here, so without this they can't verify TLS (CERTIFICATE_VERIFY_FAILED).
  # OpenSSL reads SSL_CERT_FILE at runtime regardless of the interpreter.
  environment.variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  specialisation.hyprland.configuration = {
    # Hyprland session via greetd (Wayland-native DM).
    services.xserver.enable = lib.mkForce false;
    services.displayManager.gdm.enable = lib.mkForce false;
    services.desktopManager.gnome.enable = lib.mkForce false;

    programs.hyprland.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
    };

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "${username}";
      };
    };
  };

  system.activationScripts.playwrightChrome = ''
    mkdir -p /opt/google/chrome
    ln -sfn ${pkgs.google-chrome}/bin/google-chrome-stable /opt/google/chrome/chrome
  '';

  nix.settings = {
    auto-optimise-store = true;
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root" username];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://codex-cli.cachix.org"
      "https://claude-code.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };

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

  systemd = {
    coredump.enable = false;
  };

  zramSwap = {
    enable = true;
    # zstd compresses ~3.5x, so over-committing zram past 100% of RAM is nearly
    # free and buys real headroom.
    memoryPercent = 150;
    # algorithm = "zstd"; # Default is lz4
  };

  # zram is fast, so page out to it aggressively instead of holding cold pages in RAM.
  boot.kernel.sysctl."vm.swappiness" = 180;

  # Disk swapfile as an OOM backstop for runaway Odoo/DB restores. Lives on the
  # LUKS-encrypted ext4 root, so it inherits full-disk encryption.
  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024; # MiB
    }
  ];

  # fstrim.timer is enabled by default, but discards only reach the NVMe if the
  # LUKS layer passes them through. lat5531-specific device UUID.
  boot.initrd.luks.devices."luks-7c78c455-b342-4f1e-9581-d450e15e00f9".allowDiscards = true;

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
  };

  #sops = {
  #  defaultSopsFile = ./sops/secrets.yaml;
  #  secrets.openai_api_key = {
  #    owner = "${username}";
  #  };
  #  age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  #};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
