{pkgs, ...}: {
  home.packages = with pkgs; [
    waybar
    wofi
    networkmanagerapplet
    blueman
    polkit_gnome
  ];

  xdg.configFile."hypr/hyprland.conf".text = ''
    monitor=,preferred,auto,1

    env = XCURSOR_SIZE,32
    env = NIXOS_OZONE_WL,1

    input {
      kb_layout = us,ru
      kb_options = grp:shifts_toggle,ctrl:nocaps
      follow_mouse = 1
      touchpad {
        natural_scroll = false
      }
      sensitivity = 0
    }

    general {
      gaps_in = 4
      gaps_out = 8
      border_size = 2
      layout = dwindle
    }

    decoration {
      rounding = 6
      blur {
        enabled = false
      }
    }

    dwindle {
      pseudotile = true
      preserve_split = true
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
    }

    exec-once = waybar
    exec-once = nm-applet --indicator
    exec-once = blueman-applet
    exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1

    $mod = CTRL ALT
    $term = foot
    $menu = wofi --show drun

    bind = $mod, Return, exec, $term
    bind = $mod, D, exec, $menu
    bind = $mod, B, exec, brave
    bind = $mod, E, exec, emacsclient -c -a emacs
    bind = $mod, Q, killactive
    bind = $mod, F, fullscreen, 0
    bind = $mod, Space, togglefloating
    bind = $mod, Tab, cyclenext
    bind = $mod SHIFT, Tab, cyclenext, prev

    bind = $mod, 1, workspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod, 9, workspace, 9
    bind = $mod, 0, workspace, 10

    bind = CTRL SHIFT, 1, movetoworkspace, 1
    bind = CTRL SHIFT, 2, movetoworkspace, 2
    bind = CTRL SHIFT, 3, movetoworkspace, 3
    bind = CTRL SHIFT, 4, movetoworkspace, 4
    bind = CTRL SHIFT, 5, movetoworkspace, 5
    bind = CTRL SHIFT, 6, movetoworkspace, 6
    bind = CTRL SHIFT, 7, movetoworkspace, 7
    bind = CTRL SHIFT, 8, movetoworkspace, 8
    bind = CTRL SHIFT, 9, movetoworkspace, 9
    bind = CTRL SHIFT, 0, movetoworkspace, 10

    bind = $mod, H, movefocus, l
    bind = $mod, L, movefocus, r
    bind = $mod, K, movefocus, u
    bind = $mod, J, movefocus, d

    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow
  '';

  xdg.configFile."waybar/config".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 30,
      "spacing": 8,
      "modules-left": ["hyprland/workspaces"],
      "modules-center": ["hyprland/window"],
      "modules-right": ["network", "bluetooth", "pulseaudio", "battery", "clock", "tray"],
      "network": {
        "format-wifi": "wifi {essid}",
        "format-ethernet": "eth",
        "format-disconnected": "offline",
        "tooltip-format-wifi": "{essid} {signalStrength}%",
        "tooltip-format-ethernet": "{ipaddr}/{cidr}"
      },
      "bluetooth": {
        "format": "bt {status}",
        "format-disabled": "bt off",
        "format-connected": "bt on",
        "tooltip-format": "{controller_alias}"
      },
      "pulseaudio": {
        "format": "vol {volume}%"
      },
      "battery": {
        "format": "bat {capacity}%"
      },
      "clock": {
        "format": "{:%Y-%m-%d %H:%M}"
      },
      "tray": {
        "spacing": 8
      }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
    * {
      font-family: "Hack Nerd Font Mono";
      font-size: 13px;
      min-height: 0;
    }

    window#waybar {
      background: rgba(18, 18, 18, 0.92);
      color: #e6e6e6;
    }

    #workspaces button {
      color: #e6e6e6;
      padding: 0 6px;
      margin: 4px 2px;
      border: none;
      border-radius: 0;
      background: transparent;
    }

    #workspaces button.active {
      background: #3a3a3a;
    }

    #window,
    #network,
    #bluetooth,
    #pulseaudio,
    #battery,
    #clock,
    #tray {
      margin: 0 6px;
    }
  '';

  xdg.configFile."wofi/style.css".text = ''
    * {
      font-family: "Hack Nerd Font Mono";
      font-size: 14px;
    }

    window {
      background-color: #101010;
      color: #e6e6e6;
    }

    #input {
      margin: 8px;
      border-radius: 0;
      border: 1px solid #3a3a3a;
      background-color: #1a1a1a;
      color: #e6e6e6;
    }

    #entry {
      padding: 6px 8px;
    }

    #entry:selected {
      background-color: #3a3a3a;
    }
  '';
}
