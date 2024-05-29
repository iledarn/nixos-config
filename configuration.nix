# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      <sops-nix/modules/sops>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-64eebff0-b9bb-4833-a70c-696d7625edbf".device = "/dev/disk/by-uuid/64eebff0-b9bb-4833-a70c-696d7625edbf";
  networking.hostName = "nixos"; # Define your hostname.
  networking.extraHosts = ''
    127.0.0.1 doodba12
    127.0.0.1 doodba13
    127.0.0.1 doodba14
    127.0.0.1 doodba15
    127.0.0.1 doodba16
    127.0.0.1 doodba17
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

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us,ru";
    xkbVariant = "";
    xkbOptions = "ctrl:nocaps";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
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

  virtualisation.docker.enable = true;

  # Garbage collection can be automated
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ildar = {
    isNormalUser = true;
    description = "ildar";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      #  thunderbird
    ];
  };

  home-manager.users.ildar = { pkgs, lib, config, ... }: {
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    imports = [
      ./dconf.nix
      ./neovim.nix
    ];

    home.packages = with pkgs; [
      atool
      inetutils
      httpie
      tmux
      telegram-desktop
      wmctrl
      alacritty
      brave
      htop
      emacs
      git
      keepassxc
      surfraw
      jq
      yq
      fzf
      nerdfonts
      microsoft-edge
      enlightenment.terminology
      foot
      xsel
      wl-clipboard
      docker-compose
      gnupg
      sops
      mc
      libreoffice
      feh
      teams-for-linux
      dconf2nix
      dropbox
      ripgrep
      fd
      gimp
      gparted
      ntfs3g
      nixpkgs-fmt
      bat
      tcpdump
      ngrok
      openvpn
      awscli2
      s3fs
    ];
    programs.bash = {
      enable = true;
      sessionVariables = {
        EDITOR = "nvim";
	GOOGLE_CLIENT_SECRET_JSON_FILE="${config.home.homeDirectory}/client_secrets.json";
	GOOGLE_CREDENTIALS_FILE="${config.home.homeDirectory}/drivecreds.json";
      };
    };
    programs.fzf.enable = true;
    programs.starship.enable = true;
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        brettm12345.nixfmt-vscode
        mkhl.direnv
        dracula-theme.theme-dracula
        vscodevim.vim
        yzhang.markdown-all-in-one
        bbenoist.nix
        ms-azuretools.vscode-docker
        ms-python.black-formatter
        ms-python.python
        ms-python.isort
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vsc-invoke";
          publisher = "dchanco";
          version = "0.0.12";
          sha256 = "sha256-+YpNftJ9qIfZqGQXZAb4+E0V8/aa8zWTjRSphddQw68=";
        }
        {
          name = "tasks";
          publisher = "actboy168";
          version = "0.16.0";
          sha256 = "sha256-btYWdOuxqSBclBHKyICo2yNmTjB7tOpiKNFNASPgihU=";
        }
        {
          name = "aws-toolkit-vscode";
          publisher = "AmazonWebServices";
          version = "2.20.0";
          sha256 = "sha256-65Sspi2DZUcWHWcOvnWWWliX/sSozWiSg9ptXdbFNV8=";
        }
        {
          name = "prettier-vscode";
          publisher = "esbenp";
          version = "10.4.0";
          sha256 = "sha256-8+90cZpqyH+wBgPFaX5GaU6E02yBWUoB+T9C2z2Ix8c=";
        }
      ];
    };

    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      historyLimit = 100000;
      plugins = with pkgs;
        [
          tmuxPlugins.yank
          tmuxPlugins.vim-tmux-navigator
          tmuxPlugins.sensible
          tmuxPlugins.sessionist
          tmuxPlugins.resurrect
          tmuxPlugins.pain-control
          tmuxPlugins.gruvbox
          tmuxPlugins.tmux-fzf
          tmuxPlugins.fzf-tmux-url
        ];
      extraConfig = ''
        setw -g mode-keys vi
        unbind C-b
        set -g prefix C-a
        bind C-a send-prefix
        bind-key C-a last-window
        set-option -sa terminal-features ',foot:RGB'
      '';
    };

    services.emacs.enable = true;

    programs.gpg.enable = true;
    services.gpg-agent.enable = true;

    programs.git = {
      enable = true;
      userName = "Ildar Nasyrov";
      userEmail = "iledarnp@gmail.com";
      aliases = {
        co = "checkout";
        st = "status";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
      };
    };

    home.sessionPath = [
      "/home/ildar/.config/emacs/bin"
    ];

    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
      kepiProd = {
        hostname = "139.162.11.95";
        user = "prod";
        identityFile = "/home/ildar/.ssh/id_ed25519";
      };
      kepiOdoo16 = {
        hostname = "18.138.129.123";
        user = "ubuntu";
        identityFile = "/home/ildar/.ssh/id_ed25519";
      };
    };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.11";

    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "Hack Nerd Font Mono";
          dpi-aware = "yes";
        };
      };
    };
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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
  system.stateVersion = "23.11"; # Did you read the comment?

}
