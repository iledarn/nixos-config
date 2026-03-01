{
  config,
  pkgs,
  pkgsUnstable,
  username,
  stateVersion,
  sops-nix,
  lib,
  ...
}: let
  # Wrapper to expose MCP tokens only for Codex invocations
  codexWithMcpTokens = pkgs.writeShellScriptBin "codex" ''
    export GITHUB_PAT="$(cat ${config.sops.secrets.github_pat.path})"
    export CONTEXT7="$(cat ${config.sops.secrets.context7_api_key.path})"
    exec ${pkgsUnstable.codex}/bin/codex "$@"
  '';
  # Wrapper to expose MCP tokens only for Kiro invocations
  kiroWithGitHub = pkgs.writeShellScriptBin "kiro" ''
    export GITHUB_PAT="$(cat ${config.sops.secrets.github_pat.path})"
    export CONTEXT7="$(cat ${config.sops.secrets.context7_api_key.path})"
    exec ${pkgsUnstable.kiro-fhs}/bin/kiro "$@"
  '';
  # Avoid collision with kiro desktop app binary name.
  kiroCliWrapped = pkgs.writeShellScriptBin "kiro-cli" ''
    export GITHUB_PAT="$(cat ${config.sops.secrets.github_pat.path})"
    export CONTEXT7="$(cat ${config.sops.secrets.context7_api_key.path})"
    exec ${pkgsUnstable."kiro-cli"}/bin/kiro "$@"
  '';
in {
  # TODO please change the username & home directory to your own
  home.username = username;
  home.homeDirectory = "/home/${username}";

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  imports = [
    ./dconf.nix
    ./neovim.nix
    sops-nix.homeManagerModules.sops
  ];

  home.packages =
    (with pkgs; [
      nerd-fonts.hack
      atool
      inetutils
      httpie
      tmux
      telegram-desktop
      htop
      git
      gh
      keepassxc
      jq
      yq
      fzf
      enlightenment.terminology
      wl-clipboard
      docker-compose
      gnupg
      sops
      mc
      libreoffice
      feh
      dconf2nix
      ripgrep
      fd
      gimp
      gparted
      ntfs3g
      nixpkgs-fmt
      bat
      tcpdump
      openvpn
      awscli2
      s3fs
      gnomeExtensions.caffeine
      gnomeExtensions.tiling-assistant
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.workspace-indicator
      gnomeExtensions.system-monitor
      obs-studio
      nil
      luajitPackages.lua-lsp
      lua-language-server
      gedit
      google-drive-ocamlfuse
      google-chrome
      fuse
      jetbrains-mono
      ubuntu_font_family
      cmake
      libtool
      gcc
      slack
      obsidian
      insomnia
      age
      uv
      icloudpd
      flameshot
      digikam
      nodejs
      grim
      slurp
      pkgsUnstable.claude-code
    ])
    ++ [
      codexWithMcpTokens
      kiroWithGitHub
      kiroCliWrapped
    ];

  programs.brave = {
    enable = true;
    extensions = [];
    commandLineArgs = [
      "--enable-features=TabScrolling,VerticalTabsFeature"
    ];
  };

  xdg = {
    enable = true;
    desktopEntries.kiro = {
      name = "Kiro";
      genericName = "Coding agent";
      exec = "${kiroWithGitHub}/bin/kiro";
      icon = "${pkgsUnstable.kiro}/share/pixmaps/kiro.png";
      terminal = false;
      categories = ["Development" "Utility"];
      comment = "Launch Kiro with GITHUB_PAT available";
    };
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.vterm
    ];
  };

  fonts.fontconfig.enable = true;

  systemd.user.services = {
    google-drive-mount = {
      Unit = {
        Description = "Mount Google Drive";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        Type = "forking";
        ExecStart = "${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse %h/GoogleDrive";
        ExecStop = "${pkgs.fuse}/bin/fusermount -u %h/GoogleDrive";
        Restart = "on-failure";
        RestartSec = "30s";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };

  sops = {
    age = {
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
    defaultSopsFile = ./sops/secrets.yaml;
    secrets = {
      google_client_id = {};
      google_client_secret = {};
      openai_api_key = {};
      github_pat = {};
      context7_api_key = {};
    };
  };

  programs.bash = {
    enable = true;
    sessionVariables = {
      EDITOR = "nvim";
      OPENAI_API_KEY = "$(cat ${config.sops.secrets.openai_api_key.path})";
      GOOGLE_CLIENT_ID = "$(cat ${config.sops.secrets.google_client_id.path})";
      GOOGLE_CLIENT_SECRET = "$(cat ${config.sops.secrets.google_client_secret.path})";
    };
    initExtra = ''
    '';
  };

  home.file.".codex/config.toml".text = ''
    [mcp_servers.github]
    url = "https://api.githubcopilot.com/mcp/"
    bearer_token_env_var = "GITHUB_PAT"

    [mcp_servers.context7]
    url = "https://mcp.context7.com/mcp"
    bearer_token_env_var = "CONTEXT7"

    [mcp_servers.playwright]
    command = "npx"
    args = ["@playwright/mcp@latest"]
    env = { PLAYWRIGHT_HEADLESS = "false" }

    [mcp_servers."pdf-reader"]
    command = "npx"
    args = ["@sylphx/pdf-reader-mcp"]

    [mcp_servers.postgres]
    command = "uvx"
    args = ["postgres-mcp", "--access-mode=unrestricted"]
    env = {
      DATABASE_URI = "postgresql://odoo:mypassword@localhost:5432/erp2026_01_15"
    }
  '';

  # Disabled while kiro-cli ignores env-based MCP auth; avoid store exposure later.
  # home.file.".kiro/settings/mcp.json".text = ''
  #   {
  #     "mcpServers": {
  #       "github": {
  #         "type": "http",
  #         "url": "https://api.githubcopilot.com/mcp/",
  #         "headers": {
  #           "Authorization": "''${GITHUB_PAT}"
  #         },
  #         "disabled": false,
  #         "autoApprove": []
  #       },
  #       "context7": {
  #         "type": "http",
  #         "url": "https://mcp.context7.com/mcp",
  #         "headers": {
  #           "Authorization": "''${CONTEXT7}"
  #         },
  #         "disabled": false,
  #         "autoApprove": []
  #       }
  #     }
  #   }
  # '';

  home.activation.kiroMcpJson = lib.hm.dag.entryAfter ["writeBoundary"] ''
    install -m 700 -d "$HOME/.kiro/settings"
    # Remove any existing symlink created by prior home.file config.
    if [ -e "$HOME/.kiro/settings/mcp.json" ] || [ -L "$HOME/.kiro/settings/mcp.json" ]; then
      rm -f "$HOME/.kiro/settings/mcp.json"
    fi
    GITHUB_PAT="$(cat ${config.sops.secrets.github_pat.path})"
    CONTEXT7="$(cat ${config.sops.secrets.context7_api_key.path})"
    cat > "$HOME/.kiro/settings/mcp.json" <<EOF
    {
      "mcpServers": {
        "github": {
          "type": "http",
          "url": "https://api.githubcopilot.com/mcp/",
          "headers": {
            "Authorization": "''${GITHUB_PAT}"
          },
          "disabled": false,
          "autoApprove": []
        },
        "context7": {
          "type": "http",
          "url": "https://mcp.context7.com/mcp",
          "headers": {
            "Authorization": "''${CONTEXT7}"
          },
          "disabled": false,
          "autoApprove": []
        },
        "playwright": {
          "command": "npx",
          "args": [
            "@playwright/mcp@latest"
          ],
          "env": {
            "PLAYWRIGHT_HEADLESS": "false"
          }
        },
        "pdf-reader": {
          "command": "npx",
          "args": [
            "@sylphx/pdf-reader-mcp"
          ]
        },
        "postgres": {
          "command": "uvx",
          "args": [
            "postgres-mcp",
            "--access-mode=unrestricted"
          ],
          "env": {
            "DATABASE_URI": "postgresql://odoo:mypassword@localhost:5432/erp2026_01_15"
          }
        }
      }
    }
    EOF
    chmod 600 "$HOME/.kiro/settings/mcp.json"
  '';

  home.activation.codexBackup = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    if [ -f "$HOME/.codex/config.toml" ]; then
      mkdir -p "$HOME/.codex"
      ts=$(date -u +"%Y%m%dT%H%M%S%N")
      mv "$HOME/.codex/config.toml" "$HOME/.codex/config.toml.$ts"
    fi
  '';

  programs.fzf.enable = true;

  programs.starship.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions;
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
          sha256 = "sha256-110Hn80Nll8vO8EgeQ7coKyspjUR6TyyCTmdIdkzHZ4=";
        }
        {
          name = "amazon-q-vscode";
          publisher = "AmazonWebServices";
          version = "1.11.0";
          sha256 = "sha256-5Op1ivgeVzPvIuT5qeY67Oe8xm1wWWIaSgp4jzDBau0=";
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

  # this is for doom emacs - for its utilities to be available
  home.sessionPath = [
    "/home/${username}/.config/emacs/bin"
  ];

  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    kepiProd = {
      hostname = "139.162.11.95";
      user = "prod";
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    work-github = {
      hostname = "github.com";
      user = "git";
      identityFile = "/home/${username}/.ssh/id_ed25519work-github";
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

  home.stateVersion = stateVersion;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
