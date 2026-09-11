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
    # Force the classic renderer (no alternate screen buffer) so the conversation
    # stays in the terminal's native scrollback and tmux copy-mode scrolling works.
    export CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1
    exec ${claudeCodeNix.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/claude --mcp-config "$HOME/.config/claude/mcp.json" "$@"
  '';
  # Wrapper to expose GitHub token for gh CLI
  ghWithToken = pkgs.writeShellScriptBin "gh" ''
    export GH_TOKEN="$(cat ${config.sops.secrets.github_pat.path})"
    exec ${pkgs.gh}/bin/gh "$@"
  '';
  googleDriveHealthCheck = pkgs.writeShellScript "google-drive-health-check" ''
    mountpoint="$HOME/GoogleDrive"
    configfile="$HOME/.gdfuse/default/config"
    statefile="$HOME/.gdfuse/default/state"

    # Check both that FUSE owns the path and that the daemon answers a basic
    # metadata request. A wedged FUSE daemon can remain mounted and look alive
    # to systemd indefinitely.
    if ${pkgs.util-linux}/bin/findmnt -rn -T "$mountpoint" -o FSTYPE \
        | ${pkgs.gnugrep}/bin/grep -qx 'fuse.google-drive-ocamlfuse' \
      && ${pkgs.coreutils}/bin/timeout --kill-after=5 15 \
        ${pkgs.coreutils}/bin/stat "$mountpoint" >/dev/null
    then
      exit 0
    fi

    # A wedged daemon and dead OAuth credentials are indistinguishable from the
    # mountpoint -- both fail with EIO -- but only the wedge is fixable by
    # remounting. Google expires the refresh token after 7 days while the OAuth
    # client sits in "Testing" publishing status, and restarting on an expired
    # grant just churns every 5 minutes for a week without surfacing the real
    # problem. So probe the grant before deciding what to do.
    client_id=""
    client_secret=""
    refresh_token=""
    if [ -r "$configfile" ] && [ -r "$statefile" ]; then
      client_id=$(${pkgs.gnugrep}/bin/grep -oP '^client_id=\K.*' "$configfile" || true)
      client_secret=$(${pkgs.gnugrep}/bin/grep -oP '^client_secret=\K.*' "$configfile" || true)
      refresh_token=$(${pkgs.gnugrep}/bin/grep -oP '^refresh_token=\K.*' "$statefile" || true)
    fi

    if [ -n "$client_id" ] && [ -n "$client_secret" ] && [ -n "$refresh_token" ]; then
      response=$(${pkgs.curl}/bin/curl -s --max-time 20 \
        -X POST https://oauth2.googleapis.com/token \
        -d "client_id=$client_id" \
        -d "client_secret=$client_secret" \
        -d "refresh_token=$refresh_token" \
        -d grant_type=refresh_token || true)

      case "$response" in
        *invalid_grant*)
          message="Google refused the stored refresh token (invalid_grant). Remounting cannot fix this -- run 'google-drive-ocamlfuse' to re-authorize. To stop it recurring every 7 days, switch the OAuth consent screen to 'In production' (or 'Internal')."

          # Warn once per credential generation rather than every 5 minutes.
          # Re-authorizing rewrites the state file, which makes it newer than
          # the marker and re-arms the warning if it is still broken.
          marker="''${XDG_RUNTIME_DIR:-/tmp}/google-drive-auth-warned"
          if [ ! -e "$marker" ] || [ "$statefile" -nt "$marker" ]; then
            ${pkgs.libnotify}/bin/notify-send --urgency=critical \
              "Google Drive: re-authorization required" "$message" || true
            ${pkgs.coreutils}/bin/touch "$marker"
          fi

          echo "$message" >&2
          exit 0
          ;;
      esac
    fi

    ${pkgs.systemd}/bin/systemctl --user restart google-drive-mount.service
  '';
  # google-drive-ocamlfuse rewrites ~/.gdfuse/default/config in full on every
  # startup. That path used to be a symlink straight at the sops-rendered
  # secret, so the daemon wrote its ~70 default settings *through* the link and
  # clobbered the secret, while every sops re-render threw the daemon's own
  # settings away. Keep the config a plain file the daemon owns, and inject
  # just the credentials into it here before each start.
  gdfuseConfigSeed = pkgs.writeShellScript "gdfuse-config-seed" ''
    set -eu
    configdir="$HOME/.gdfuse/default"
    configfile="$configdir/config"
    credentials="${config.sops.templates."gdfuse-credentials".path}"

    ${pkgs.coreutils}/bin/mkdir -p "$configdir"

    # Migrate away from the old symlink-at-the-secret layout.
    if [ -L "$configfile" ]; then
      ${pkgs.coreutils}/bin/rm -f "$configfile"
    fi
    ${pkgs.coreutils}/bin/touch "$configfile"
    ${pkgs.coreutils}/bin/chmod 0600 "$configfile"

    # Rebuild the file instead of editing in place: the secret can contain
    # characters that are significant to sed.
    tmp=$(${pkgs.coreutils}/bin/mktemp "$configdir/.config.XXXXXX")
    ${pkgs.coreutils}/bin/chmod 0600 "$tmp"
    ${pkgs.gnugrep}/bin/grep -v -E '^(client_id|client_secret)=' "$configfile" > "$tmp" || true
    ${pkgs.gnugrep}/bin/grep -E '^(client_id|client_secret)=' "$credentials" >> "$tmp"
    ${pkgs.coreutils}/bin/mv -f "$tmp" "$configfile"
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
      # mysql80
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
      copier # Copier project-template renderer (nixodoo-copier-template etc.)
      icloudpd
      flameshot
      digikam
      nodejs
      python3 # bare interpreter + stdlib on PATH for tools that call `python3` (use uv/uvx for PyPI pkgs)
      python3Packages.nwdiag # nwdiag/rackdiag/packetdiag — draw network diagrams from text
      aichat # terminal LLM chat client; configured for the PGX vLLM endpoint (see ~/.config/aichat/config.yaml)
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
        After = [
          "network-online.target"
          "sops-nix.service"
        ];
        Wants = ["network-online.target"];
        # Authorization creates this file. Do not enter a restart loop before
        # the one-time OAuth flow has completed.
        ConditionPathExists = "%h/.gdfuse/default/state";
        StartLimitIntervalSec = "5min";
        StartLimitBurst = 3;
      };

      Service = {
        Type = "forking";
        # First clear any stale FUSE endpoint left by an unclean previous exit
        # ("Transport endpoint is not connected"); the leading "-" ignores the
        # error when nothing is mounted. Then (re)create the mountpoint, because
        # google-drive-ocamlfuse refuses to mount unless the directory already
        # exists ("Mountpoint ... should be an existing directory").
        ExecStartPre = [
          # Inject the sops-managed credentials into the daemon-owned config
          # file before the daemon starts and rewrites that file itself.
          "${gdfuseConfigSeed}"
          # The package binary in /nix/store is not setuid. NixOS exposes the
          # privileged helper through /run/wrappers, which lets the mount owner
          # detach a dead FUSE endpoint. -z also handles a wedged filesystem.
          "-/run/wrappers/bin/fusermount -uz %h/GoogleDrive"
          "${pkgs.coreutils}/bin/mkdir -p %h/GoogleDrive"
        ];
        ExecStart = "${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse %h/GoogleDrive";
        ExecStop = "-/run/wrappers/bin/fusermount -uz %h/GoogleDrive";
        # Detaching a FUSE mount does not guarantee that a wedged daemon will
        # exit. Bound shutdown and kill every process left in the unit cgroup.
        KillMode = "control-group";
        TimeoutStopSec = "20s";
        SendSIGKILL = true;
        Restart = "on-failure";
        RestartSec = "30s";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    google-drive-health-check = {
      Unit = {
        Description = "Check Google Drive FUSE mount responsiveness";
        After = ["google-drive-mount.service"];
        ConditionPathExists = "%h/.gdfuse/default/state";
      };

      Service = {
        Type = "oneshot";
        ExecStart = googleDriveHealthCheck;
        TimeoutStartSec = "30s";
      };
    };
  };

  systemd.user.timers.google-drive-health-check = {
    Unit.Description = "Periodically check Google Drive FUSE mount";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      RandomizedDelaySec = "30s";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
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

  # Deliberately NOT ~/.gdfuse/default/config -- see gdfuseConfigSeed above.
  # Written in the daemon's own "key=value" form (no spaces) so the seed script
  # can match the lines exactly.
  sops.templates."gdfuse-credentials" = {
    path = "${config.home.homeDirectory}/.config/gdfuse/credentials";
    content = ''
      client_id=${config.sops.placeholder."google_client_id"}
      client_secret=${config.sops.placeholder."google_client_secret"}
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
  # programs.ssh.settings replaced the deprecated matchBlocks. Attribute names are
  # Host patterns; values use OpenSSH directive names (HostName/User/IdentityFile/...).
  programs.ssh.settings = {
    "*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
    odoo-16-prod = {
      HostName = "46.137.245.154";
      User = "ubuntu";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    odoo-12-prod = {
      HostName = "122.248.203.73";
      User = "ubuntu";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    work-github = {
      HostName = "github.com";
      User = "git";
      IdentityFile = "/home/${username}/.ssh/id_ed25519work-github";
    };
    odoo-test = {
      header = "Host 10.10.10.11 10.10.10.12";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    grafana-reports = {
      HostName = "192.168.1.109";
      ForwardAgent = true;
    };
    odoo-16-project-test = {
      HostName = "192.168.0.32";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kts-box-server = {
      HostName = "192.168.1.38";
      User = "proddb";
      Port = 2020;
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kms-linode-prod = {
      HostName = "139.162.25.216";
      User = "ildar";
      Port = 2205;
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kms-linode-prod-web = {
      HostName = "139.162.25.216";
      User = "kms-web";
      Port = 2205;
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kts-prod-new = {
      HostName = "192.168.20.110";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kts-prod-new-root = {
      HostName = "192.168.20.110";
      User = "root";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kms-prod-new = {
      HostName = "192.168.20.111";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    kms-prod-new-root = {
      HostName = "192.168.20.111";
      User = "root";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    lenovo_pgx = {
      HostName = "192.168.20.199";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    # Per-developer Odoo 16 test CTs (odoo1.kepi .. odoo4.kepi), CT 112-115.
    # DHCP-reserved IPs on the office LAN; all share CT 101 PostgreSQL.
    odoo1_kepi = {
      HostName = "192.168.20.112";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    odoo2_kepi = {
      HostName = "192.168.20.113";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    odoo3_kepi = {
      HostName = "192.168.20.114";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    odoo4_kepi = {
      HostName = "192.168.20.115";
      User = "kaertech";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    # Proxmox hypervisor nodes. Proxmox is administered as root, so there is
    # no unprivileged account to fall back to here.
    pve1_kepi = {
      HostName = "192.168.20.100";
      User = "root";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
    };
    pve2_kepi = {
      HostName = "192.168.20.200";
      User = "root";
      ForwardAgent = true;
      IdentityFile = "/home/${username}/.ssh/id_ed25519";
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

  # aichat: terminal LLM chat client pointed at the Lenovo PGX vLLM endpoint (KAI-1).
  # Managed declaratively (read-only symlink); roles/sessions still write to ~/.config/aichat/.
  home.file.".config/aichat/config.yaml".text = ''
    model: pgx:nvidia/nemotron-3-super
    clients:
    - type: openai-compatible
      name: pgx
      api_base: http://192.168.20.199:8000/v1
      api_key: dummy
      models:
      - name: nvidia/nemotron-3-super
  '';

  # Flameshot launcher for the GNOME custom shortcut (Shift+Alt+P, see dconf.nix).
  # GNOME's media-keys spawns the command without a shell, so the pipe below needs
  # its own script. `--raw | wl-copy` is the Wayland-friendly clipboard path;
  # flameshot's built-in copy is unreliable on GNOME/Wayland. Managed declaratively
  # so it can't go missing (the old hand-placed ~/configfiles path did).
  home.file."configfiles/flameshot-launch.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Use Wayland-friendly clipboard path for flameshot.
      ${pkgs.flameshot}/bin/flameshot gui --raw | ${pkgs.wl-clipboard}/bin/wl-copy
    '';
  };

  home.stateVersion = stateVersion;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
