{pkgs, ...}: {
  home.packages = with pkgs; [
    networkmanagerapplet
    blueman
    polkit_gnome
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      monitor = [",preferred,auto,1"];

      env = [
        "XCURSOR_SIZE,32"
        "NIXOS_OZONE_WL,1"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:shifts_toggle,ctrl:nocaps";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = false;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 6;
        blur.enabled = false;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      "$mod" = "CTRL ALT";
      "$term" = "foot";
      "$menu" = "wofi --show drun";

      exec-once = [
        "waybar"
        "nm-applet --indicator"
        "blueman-applet"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      bind = [
        "$mod, Return, exec, $term"
        "$mod, D, exec, $menu"
        "$mod, B, exec, brave"
        "$mod, E, exec, emacsclient -c -a emacs"
        "$mod, Q, killactive"
        "$mod, F, fullscreen, 0"
        "$mod, Space, togglefloating"
        "$mod, Tab, cyclenext"
        "$mod SHIFT, Tab, cyclenext, prev"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "CTRL SHIFT, 1, movetoworkspace, 1"
        "CTRL SHIFT, 2, movetoworkspace, 2"
        "CTRL SHIFT, 3, movetoworkspace, 3"
        "CTRL SHIFT, 4, movetoworkspace, 4"
        "CTRL SHIFT, 5, movetoworkspace, 5"
        "CTRL SHIFT, 6, movetoworkspace, 6"
        "CTRL SHIFT, 7, movetoworkspace, 7"
        "CTRL SHIFT, 8, movetoworkspace, 8"
        "CTRL SHIFT, 9, movetoworkspace, 9"
        "CTRL SHIFT, 0, movetoworkspace, 10"

        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 8;
      modules-left = ["hyprland/workspaces"];
      modules-center = ["hyprland/window"];
      modules-right = ["network" "bluetooth" "pulseaudio" "battery" "clock" "tray"];
      network = {
        format-wifi = "wifi {essid}";
        format-ethernet = "eth";
        format-disconnected = "offline";
        tooltip-format-wifi = "{essid} {signalStrength}%";
        tooltip-format-ethernet = "{ipaddr}/{cidr}";
      };
      bluetooth = {
        format = "bt {status}";
        format-disabled = "bt off";
        format-connected = "bt on";
        tooltip-format = "{controller_alias}";
      };
      pulseaudio.format = "vol {volume}%";
      battery.format = "bat {capacity}%";
      clock.format = "{:%Y-%m-%d %H:%M}";
      tray.spacing = 8;
    };
    style = ''
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
  };

  programs.wofi = {
    enable = true;
    style = ''
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
  };
}
