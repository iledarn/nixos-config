{
  config,
  pkgs,
  ...
}: {
  # TODO please change the username & home directory to your own
  home.username = "ildar";
  home.homeDirectory = "/home/ildar";

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
    # sops
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
      GOOGLE_CLIENT_SECRET_JSON_FILE = "${config.home.homeDirectory}/client_secrets.json";
      GOOGLE_CREDENTIALS_FILE = "${config.home.homeDirectory}/drivecreds.json";
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
    extensions = with pkgs.vscode-extensions;
      [
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
        xyz.local-history
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
          version = "3.12.0";
          sha256 = "sha256-65Sspi2DZUcWHWcOvnWWWliX/sSozWiSg9ptXdbFNV8=";
        }
        {
          name = "amazon-q-vscode";
          publisher = "AmazonWebServices";
          version = "1.11.0";
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
    plugins = with pkgs; [
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

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font Mono";
        dpi-aware = "yes";
      };
    };
  };

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
