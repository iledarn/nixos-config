{pkgs, ...}: let
  screenshotRegion = pkgs.writeShellScript "hypr-screenshot-region" ''
    set -eu
    region="$(${pkgs.slurp}/bin/slurp)"
    [ -n "$region" ] || exit 0
    ${pkgs.grim}/bin/grim -g "$region" - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
    ${pkgs.libnotify}/bin/notify-send "Screenshot copied"
  '';
in {
  home.packages = with pkgs; [
    networkmanagerapplet
    bluetuith
    polkit_gnome
    brightnessctl
    playerctl
    hyprlock
    xfce.thunar
  ];

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      default-timeout = 5000;
      border-radius = 6;
      background-color = "#101010dd";
      border-color = "#3a3a3a";
      text-color = "#e6e6e6";
      margin = "12";
    };
  };

  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
      no_fade_in = true
      no_fade_out = true
    }

    background {
      color = rgba(16, 16, 16, 1.0)
    }

    input-field {
      size = 260, 48
      outline_thickness = 2
      dots_size = 0.2
      dots_spacing = 0.2
      dots_center = true
      inner_color = rgba(26, 26, 26, 0.9)
      outer_color = rgba(58, 58, 58, 0.8)
      font_color = rgba(230, 230, 230, 1.0)
      fade_on_empty = false
      placeholder_text = "Password"
      position = 0, -80
      halign = center
      valign = center
    }

    label {
      text = "$TIME"
      font_size = 44
      font_family = "Hack Nerd Font Mono"
      color = rgba(230, 230, 230, 1.0)
      position = 0, 80
      halign = center
      valign = center
    }
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      monitor = [",preferred,auto,1"];

      env = [
        "XCURSOR_THEME,Adwaita"
        "HYPRCURSOR_THEME,Adwaita"
        "HYPRCURSOR_SIZE,24"
        "NIXOS_OZONE_WL,1"
        "GTK_CSD,0"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
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
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      bind = [
        "$mod, Return, exec, $term"
        "$mod, D, workspace, 2"
        "$mod, B, exec, brave"
        "$mod, E, exec, emacsclient -c -a emacs"
        "$mod, R, exec, thunar"
        "$mod, P, exec, ${screenshotRegion}"
        "$mod SHIFT, R, exec, hyprctl reload"
        "$mod, Q, killactive"
        "$mod SHIFT, F, fullscreen, 0"
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
        "$mod, X, workspace, 1"
        "$mod, F, workspace, 3"
        "$mod, G, workspace, 4"
        "$mod, W, workspace, 5"
        "$mod, T, workspace, 6"

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

        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", Print, exec, ${screenshotRegion}"
        "SUPER, L, exec, hyprlock"
        "SUPER, Super_L, exec, $menu"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

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
      modules-right = ["cpu" "memory" "network" "bluetooth" "pulseaudio" "battery" "clock" "tray"];
      cpu.format = "cpu {usage}%";
      memory.format = "ram {}%";
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
      #cpu,
      #memory,
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
