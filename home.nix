{
  config,
  pkgs,
  pkgsUnstable,
  codexCliNix,
  claudeCodeNix,
  username,
  stateVersion,
  sops-nix,
  zen-browser,
  lib,
  ...
}: let
  # Wrapper to expose MCP tokens only for Codex invocations
  codexWithMcpTokens = pkgs.writeShellScriptBin "codex" ''
    export GITHUB_PAT="$(cat ${config.sops.secrets.github_pat.path})"
    export CONTEXT7="$(cat ${config.sops.secrets.context7_api_key.path})"
    exec ${codexCliNix.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/codex "$@"
  '';
  # Wrapper to expose GitHub token only for Claude Code invocations
  claudeWithGitHub = pkgs.writeShellScriptBin "claude" ''
    export GITHUB_PAT="$(cat ${config.sops.secrets.github_pat.path})"
    exec ${claudeCodeNix.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/claude --mcp-config "$HOME/.config/claude/mcp.json" "$@"
  '';
  # Wrapper to expose GitHub token for gh CLI
  ghWithToken = pkgs.writeShellScriptBin "gh" ''
    export GH_TOKEN="$(cat ${config.sops.secrets.github_pat.path})"
    exec ${pkgs.gh}/bin/gh "$@"
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
    zen-browser.homeModules.default
  ];

  home.packages = with pkgs;
    [
      nerd-fonts.hack
      atool
      inetutils
      httpie
      tmux
      # telegram-desktop
      htop
      ncdu
      bleachbit
      git
      keepassxc
      jq
      yq
      fzf
      enlightenment.terminology
      wl-clipboard
      docker-compose
      mysql80
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
      ubuntu-classic
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
      btop
      linuxPackages.cpupower
      pkgsUnstable.supabase-cli
    ]
    ++ [
      codexWithMcpTokens
      claudeWithGitHub
      ghWithToken
    ];

  programs.mpv = {
    enable = true;
    config = {
      video-output-levels = "full";
    };
  };

  programs.brave = {
    enable = true;
    extensions = [];
    commandLineArgs = [
      "--enable-features=TabScrolling,VerticalTabsFeature"
    ];
  };

  programs.zen-browser = {
    enable = true;
    policies = {
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
    };
  };

  xdg = {
    enable = true;
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
      github_pat = {};
      context7_api_key = {};
    };
  };

  programs.bash = {
    enable = true;
    sessionVariables = {
      EDITOR = "nvim";
    };
    initExtra = ''
    '';
  };

  sops.templates."gdfuse-config" = {
    path = "${config.home.homeDirectory}/.gdfuse/default/config";
    content = ''
      client_id = ${config.sops.placeholder."google_client_id"}
      client_secret = ${config.sops.placeholder."google_client_secret"}
    '';
    mode = "0600";
  };

  home.file."KAERTECH/.codex/config.toml".text = ''
    [mcp_servers.github]
    url = "https://api.githubcopilot.com/mcp/"
    bearer_token_env_var = "GITHUB_PAT"

    [mcp_servers.context7]
    url = "https://mcp.context7.com/mcp"
    bearer_token_env_var = "CONTEXT7"

    [mcp_servers.playwright]
    command = "npx"
    args = ["-y", "@playwright/mcp@latest"]
    env = { PLAYWRIGHT_HEADLESS = "false" }

    [mcp_servers."pdf-reader"]
    command = "npx"
    args = ["-y", "@sylphx/pdf-reader-mcp"]

    [mcp_servers.postgres]
    command = "uvx"
    args = ["postgres-mcp", "--access-mode=unrestricted"]
    env_vars = ["DATABASE_URI"]
  '';

  home.file.".config/claude/mcp.json".text = ''
    {
      "mcpServers": {
        "github": {
          "type": "http",
          "url": "https://api.githubcopilot.com/mcp/",
          "headers": {
            "Authorization": "Bearer ''${GITHUB_PAT}"
          }
        },
        "open-brain": {
          "type": "http",
          "url": "https://mygtjexltvrucugsvcol.supabase.co/functions/v1/open-brain-mcp",
          "headers": {
            "x-brain-key": "85f28016ed2b004e88443015c2b57677815981eb5fdc7eb9c932e244eed24df3"
          }
        },
        "teams": {
          "type": "stdio",
          "command": "npx",
          "args": [
          "-y",
          "git+https://github.com/okolovmark/teams-mcp.git#stable"
          ]
        }
      }
    }
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
    settings = {
      user = {
        name = "Ildar Nasyrov";
        email = "iledarnp@gmail.com";
      };
      alias = {
        co = "checkout";
        st = "status";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
      };
    };
  };

  # this is for doom emacs - for its utilities to be available
  home.sessionPath = [
    "/home/${username}/.config/emacs/bin"
  ];

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks = {
    "*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
    odoo-16-prod = {
      hostname = "46.137.245.154";
      user = "ubuntu";
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    odoo-12-prod = {
      hostname = "122.248.203.73";
      user = "ubuntu";
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    work-github = {
      hostname = "github.com";
      user = "git";
      identityFile = "/home/${username}/.ssh/id_ed25519work-github";
    };
    "odoo-test" = {
      host = "10.10.10.11 10.10.10.12";
      user = "kaertech";
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    grafana-reports = {
      hostname = "192.168.1.109";
      forwardAgent = true;
    };
    odoo-16-project-test = {
      hostname = "192.168.0.32";
      user = "kaertech";
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kts-box-server = {
      hostname = "192.168.1.38";
      user = "proddb";
      port = 2020;
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kms-linode-prod = {
      hostname = "139.162.25.216";
      user = "ildar";
      port = 2205;
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kms-linode-prod-web = {
      hostname = "139.162.25.216";
      user = "kms-web";
      port = 2205;
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kts-prod-new = {
      hostname = "192.168.20.110";
      user = "kaertech";
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kts-prod-new-root = {
      hostname = "192.168.20.110";
      user = "root";
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kms-prod-new = {
      hostname = "192.168.20.111";
      user = "kaertech";
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kms-prod-new-root = {
      hostname = "192.168.20.111";
      user = "root";
      forwardAgent = true;
      identityFile = "/home/${username}/.ssh/id_ed25519";
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
