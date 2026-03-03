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
    export UV_PYTHON="${pkgs.python312}/bin/python3.12"
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
  flameshotPkg = pkgs.flameshot.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [])
      ++ [
        "-DUSE_WAYLAND_GRIM=ON"
        "-DUSE_WAYLAND_CLIPBOARD=ON"
      ];
  });
  flameshotWrapped = pkgs.writeShellScriptBin "flameshot-wrapped" ''
    # Avoid Qt HiDPI scaling mismatch in Flameshot selection overlay.
    export QT_QPA_PLATFORM=wayland
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    # Inverse of Hyprland monitor scale (1/1.25).
    export QT_SCALE_FACTOR=0.8
    exec ${pkgs.bash}/bin/bash -c '
      "${flameshotPkg}/bin/flameshot" gui --raw "$@" \
        | "${pkgs.wl-clipboard}/bin/wl-copy" --type image/png
    ' -- "$@"
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
      btop
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
      flameshotPkg
      digikam
      nodejs
      grim
      slurp
      foot
      wofi
      swww
      hyprlock
      playerctl
      xfce.thunar
      polkit_gnome
      material-symbols
      nerd-fonts.caskaydia-cove
      pkgsUnstable.claude-code
    ])
    ++ [
      codexWithMcpTokens
      kiroWithGitHub
      kiroCliWrapped
      flameshotWrapped
    ];

  programs.brave = {
    enable = true;
    extensions = [];
    commandLineArgs = [
      "--enable-features=TabScrolling,VerticalTabsFeature"
    ];
  };

  home.file."Pictures/wallpapers/minimal.ppm".text = ''
P3
1 1
255
16 16 16
'';

  xdg = {
    enable = true;
    configFile."waybar/config".text = ''
      {
        "layer": "top",
        "position": "top",
        "height": 32,
        "spacing": 6,
        "modules-left": ["hyprland/workspaces", "hyprland/window"],
        "modules-center": ["custom/media", "clock"],
        "modules-right": ["cpu", "memory", "temperature", "battery", "bluetooth", "network", "pulseaudio", "tray"],

        "custom/media": {
          "format": "{}",
          "exec": "playerctl metadata --format '{{ artist }} - {{ title }}'",
          "interval": 2,
          "max-length": 40,
          "tooltip": true,
          "return-type": "string"
        },
        "clock": {
          "format": "{:%a %b %d  %H:%M}"
        },
        "cpu": {
          "format": "CPU {usage}%"
        },
        "memory": {
          "format": "RAM {used:0.1f}G"
        },
        "temperature": {
          "format": "TEMP {temperatureC}C",
          "critical-threshold": 85
        },
        "battery": {
          "format": "BAT {capacity}%",
          "format-charging": "BAT {capacity}% AC",
          "format-plugged": "BAT {capacity}% AC"
        },
        "pulseaudio": {
          "format": "VOL {volume}%",
          "format-muted": "MUTE"
        }
      }
    '';
    configFile."waybar/style.css".text = ''
      * {
        font-family: "JetBrains Mono", "Hack Nerd Font Mono", monospace;
        font-size: 12px;
        min-height: 0;
        border: none;
      }

      window#waybar {
        background: rgba(0, 0, 0, 0.21);
        color: #ffffff;
      }

      #workspaces {
        margin: 2px 6px;
      }

      #workspaces button {
        background: rgba(0, 0, 0, 0.3);
        color: #cbd5f5;
        border-radius: 999px;
        margin: 6px 3px;
        min-width: 16px;
        padding: 0 6px;
        transition: 120ms linear;
      }

      #workspaces button.active {
        background: #9d5b7a;
        color: #ffffff;
        min-width: 32px;
      }

      #workspaces button.urgent {
        background: #f38ba8;
        color: #111111;
      }

      #window {
        padding: 0 10px;
        margin: 6px 6px;
        color: #ffffff;
      }

      #custom-media {
        padding: 0 10px;
        margin: 6px 6px;
        color: #f9e2af;
      }

      #clock,
      #cpu,
      #memory,
      #temperature,
      #battery,
      #bluetooth,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
        margin: 6px 3px;
        background: rgba(255, 255, 255, 0.12);
        border-radius: 12px;
      }

      #tray button {
        background: none;
        border-radius: 999px;
        padding: 0 6px;
      }

      #battery.charging {
        color: #a6e3a1;
      }

      #battery.critical:not(.charging) {
        color: #f38ba8;
      }

      #temperature.critical {
        color: #f38ba8;
      }

      #pulseaudio.muted {
        color: #cbd5f5;
      }
    '';
    configFile."gtk-3.0/gtk.css".text = ''
      * {
        border-radius: 0;
        box-shadow: none;
      }

      decoration, window, headerbar, .titlebar {
        border-radius: 0;
        box-shadow: none;
      }
    '';
    configFile."gtk-4.0/gtk.css".text = ''
      * {
        border-radius: 0;
        box-shadow: none;
      }

      decoration, window, headerbar, .titlebar {
        border-radius: 0;
        box-shadow: none;
      }
    '';
    desktopEntries.kiro = {
      name = "Kiro";
      genericName = "Coding agent";
      exec = "${kiroWithGitHub}/bin/kiro";
      icon = "${pkgsUnstable.kiro}/share/pixmaps/kiro.png";
      terminal = false;
      categories = ["Development" "Utility"];
      comment = "Launch Kiro with GITHUB_PAT available";
    };
    configFile."hypr/hyprlock.conf".text = ''
      general {
        no_fade_in = true
        no_fade_out = true
      }

      background {
        color = rgba(14, 16, 19, 1.0)
      }

      input-field {
        size = 260, 48
        outline_thickness = 2
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        inner_color = rgba(20, 23, 28, 0.9)
        outer_color = rgba(60, 68, 80, 0.6)
        font_color = rgba(220, 224, 232, 1.0)
        fade_on_empty = false
        placeholder_text = "Password"
        position = 0, -80
        halign = center
        valign = center
      }

      label {
        text = "$TIME"
        font_size = 48
        font_family = JetBrains Mono
        color = rgba(220, 224, 232, 1.0)
        position = 0, 80
        halign = center
        valign = center
      }
    '';
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.vterm
    ];
  };

  programs.caelestia = {
    enable = true;
    cli.enable = true;
    settings = {
      appearance = {
        transparency = {
          enabled = true;
          base = 0.85;
          layers = 0.4;
        };
        rounding = {
          scale = 0;
        };
        font = {
          family = {
            sans = "Ubuntu";
            mono = "CaskaydiaCove NF";
            clock = "Ubuntu";
            material = "Material Symbols Rounded";
          };
          size = {scale = 0.7;};
        };
      };
      paths = {
        wallpaperDir = "~/Pictures/wallpapers";
      };
      bar = {
        persistent = true;
        showOnHover = true;
        entries = [
          {
            id = "logo";
            enabled = true;
          }
          {
            id = "workspaces";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "activeWindow";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "tray";
            enabled = true;
          }
          {
            id = "clock";
            enabled = true;
          }
          {
            id = "statusIcons";
            enabled = true;
          }
          {
            id = "power";
            enabled = true;
          }
        ];
        status = {
          showBattery = true;
          showBluetooth = true;
          showNetwork = true;
          showWifi = true;
        };
      };
      launcher = {
        useFuzzy = {
          apps = true;
          actions = true;
        };
      };
      border = {
        rounding = 0;
        thickness = 0;
      };
      general = {
        idle = {
          lockBeforeSleep = true;
          inhibitWhenAudio = true;
          timeouts = [
            {
              timeout = 1800;
              idleAction = "lock";
            }
            {
              timeout = 2100;
              idleAction = "dpms off";
              returnAction = "dpms on";
            }
            {
              timeout = 3600;
              idleAction = ["systemctl" "suspend-then-hibernate"];
            }
          ];
        };
      };
      services = {
        smartScheme = true;
      };
    };
    cli.settings = {
      theme = {
        enableGtk = false;
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      env = [
        "NIXOS_OZONE_WL,1"
        "XCURSOR_SIZE,24"
        "KDEWALLET_DISABLE,1"
        "GTK_CSD,0"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      ];
      monitor = [
        "eDP-1, preferred, auto, 1.25"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "terminalte:ctrl_alt_bksp,lv4:ralt_switch,ctrl:nocaps,grp:shifts_toggle";
      };

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 0;
      };

      decoration = {
        rounding = 0;
        shadow = {
          enabled = false;
        };
      };

      exec-once = [
        "swww-daemon"
        "swww img $HOME/Pictures/wallpapers/minimal.ppm --transition-type fade --transition-duration 1"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "flameshot-wrapped"
      ];

      bind = [
        "$mod, Return, exec, foot"
        "$mod, D, exec, wofi --show drun"
        "$mod, Space, exec, wofi --show run"
        "$mod, L, exec, hyprlock"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen,"
        "$mod, V, togglefloating,"
        "$mod, E, exec, thunar"
        "$mod, M, exit,"
        "$mod SHIFT, R, exec, hyprctl reload"
        "SHIFT ALT, P, exec, flameshot-wrapped"
        "CTRL SHIFT, P, exec, flameshot-wrapped"

        "CTRL ALT, 1, workspace, 1"
        "CTRL ALT, 2, workspace, 2"
        "CTRL ALT, 3, workspace, 3"
        "CTRL ALT, 4, workspace, 4"
        "CTRL ALT, 5, workspace, 5"
        "CTRL ALT, 6, workspace, 6"
        "CTRL ALT, 7, workspace, 7"
        "CTRL ALT, 8, workspace, 8"
        "CTRL ALT, 9, workspace, 9"
        "CTRL ALT, G, workspace, 10"
        "CTRL ALT, S, workspace, 11"
        "CTRL ALT, O, workspace, 12"
        "CTRL ALT, X, workspace, 1"
        "CTRL ALT, D, workspace, 2"
        "CTRL ALT, F, workspace, 3"
        "CTRL ALT, E, workspace, 4"
        "CTRL ALT, W, workspace, 5"
        "CTRL ALT, T, workspace, 6"
        "CTRL ALT, C, workspace, 7"
        "CTRL ALT, V, workspace, 8"
        "CTRL ALT, K, workspace, 9"

        "CTRL SHIFT, 1, movetoworkspace, 1"
        "CTRL SHIFT, 2, movetoworkspace, 2"
        "CTRL SHIFT, 3, movetoworkspace, 3"
        "CTRL SHIFT, 4, movetoworkspace, 4"
        "CTRL SHIFT, 5, movetoworkspace, 5"
        "CTRL SHIFT, 6, movetoworkspace, 6"
        "CTRL SHIFT, 7, movetoworkspace, 7"
        "CTRL SHIFT, 8, movetoworkspace, 8"
        "CTRL SHIFT, 9, movetoworkspace, 9"
        "CTRL SHIFT, G, movetoworkspace, 10"
        "CTRL SHIFT, S, movetoworkspace, 11"
        "CTRL SHIFT, O, movetoworkspace, 12"
      ];


      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      misc = {
        disable_hyprland_logo = true;
      };

      workspace = [
        "1, persistent:true, default:true"
        "2, persistent:true"
        "3, persistent:true"
        "4, persistent:true"
        "5, persistent:true"
        "6, persistent:true"
        "7, persistent:true"
        "8, persistent:true"
        "9, persistent:true"
        "10, persistent:true"
        "11, persistent:true"
        "12, persistent:true"
      ];
    };
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

  home.activation.codexConfigMerge = lib.hm.dag.entryAfter ["writeBoundary"] ''
    install -m 700 -d "$HOME/.codex"
    cfg="$HOME/.codex/config.toml"
    tmp="$(mktemp)"
    cat > "$tmp" <<'EOF'
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
      UV_PYTHON = "${pkgs.python312}/bin/python3.12",
      DATABASE_URI = "postgresql://odoo:mypassword@localhost:5432/erp2026_01_15",
    }
    EOF

    if [ -f "$cfg" ]; then
      echo "" >> "$tmp"
      ${pkgs.gawk}/bin/awk '
        BEGIN { inblock=0 }
        /^\[projects\./ { inblock=1 }
        /^\[.*\]/ && $0 !~ /^\[projects\./ { inblock=0 }
        { if (inblock) print }
      ' "$cfg" >> "$tmp"
    fi

    chmod 600 "$tmp"
    mv "$tmp" "$cfg"
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
