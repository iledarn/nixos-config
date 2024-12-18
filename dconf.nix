# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "apps/seahorse/listing" = {
      keyrings-selected = ["gnupg://"];
    };

    "apps/seahorse/windows/key-manager" = {
      height = 476;
      width = 600;
    };

    "org/gnome/Connections" = {
      first-run = false;
    };

    "org/gnome/Console" = {
      font-scale = 1.1;
      last-window-size = mkTuple [652 480];
      theme = "night";
    };

    "org/gnome/Snapshot" = {
      capture-mode = "video";
      is-maximized = false;
      play-shutter-sound = true;
      show-composition-guidelines = false;
      window-height = 640;
      window-width = 800;
    };

    "org/gnome/TextEditor" = {
      custom-font = "Monospace 12";
      use-system-font = false;
    };

    "org/gnome/Totem" = {
      active-plugins = ["rotation" "vimeo" "apple-trailers" "open-directory" "save-file" "autoload-subtitles" "mpris" "skipto" "recent" "screenshot" "screensaver" "movie-properties" "variable-rate"];
      subtitle-encoding = "UTF-8";
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = true;
      window-size = mkTuple [768 600];
    };

    "org/gnome/control-center" = {
      last-panel = "keyboard";
      window-state = mkTuple [960 1048 false];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = ["Utilities" "YaST" "Pardus"];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = ["X-Pardus-Apps"];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = ["gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop"];
      categories = ["X-GNOME-Utilities"];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = ["X-SuSE-YaST"];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [(mkTuple ["xkb" "en"])];
      sources = [(mkTuple ["xkb" "us"]) (mkTuple ["xkb" "ru"])];
      xkb-options = ["terminalte:ctrl_alt_bksp" "lv4:ralt_switch" "ctrl:nocaps" "grp:shifts_toggle"];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-light";
      enable-hot-corners = false;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/notifications" = {
      application-children = ["gnome-power-panel" "org-gnome-nautilus" "org-gnome-epiphany" "org-gnome-console" "org-telegram-desktop" "gnome-network-panel" "org-keepassxc-keepassxc" "firefox" "org-gnome-settings" "brave-browser"];
      show-banners = false;
    };

    "org/gnome/desktop/notifications/application/alacritty" = {
      enable = true;
    };

    "org/gnome/desktop/notifications/application/brave-browser" = {
      application-id = "brave-browser.desktop";
    };

    "org/gnome/desktop/notifications/application/calc" = {
      application-id = "calc.desktop";
    };

    "org/gnome/desktop/notifications/application/code-url-handler" = {
      application-id = "code-url-handler.desktop";
    };

    "org/gnome/desktop/notifications/application/dropbox" = {
      application-id = "dropbox.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-network-panel" = {
      application-id = "gnome-network-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/microsoft-edge" = {
      application-id = "microsoft-edge.desktop";
    };

    "org/gnome/desktop/notifications/application/org-flameshot-flameshot" = {
      enable = true;
    };

    "org/gnome/desktop/notifications/application/org-gnome-characters" = {
      application-id = "org.gnome.Characters.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-epiphany" = {
      application-id = "org.gnome.Epiphany.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-extensions" = {
      application-id = "org.gnome.Extensions.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-keepassxc-keepassxc" = {
      application-id = "org.keepassxc.KeePassXC.desktop";
    };

    "org/gnome/desktop/notifications/application/org-telegram-desktop" = {
      application-id = "org.telegram.desktop.desktop";
    };

    "org/gnome/desktop/notifications/application/teams-for-linux" = {
      application-id = "teams-for-linux.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = ["org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop"];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/desktop/wm/keybindings" = {
      maximize = [];
      move-to-workspace-1 = ["<Ctrl><Alt>1"];
      move-to-workspace-2 = ["<Ctrl><Alt>2"];
      move-to-workspace-3 = ["<Ctrl><Alt>3"];
      move-to-workspace-4 = ["<Ctrl><Alt>4"];
      move-to-workspace-5 = ["<Ctrl><Alt>5"];
      move-to-workspace-6 = ["<Ctrl><Alt>6"];
      move-to-workspace-7 = ["<Ctrl><Alt>7"];
      move-to-workspace-8 = ["<Ctrl><Alt>8"];
      move-to-workspace-9 = ["<Ctrl><Alt>9"];
      switch-to-workspace-1 = ["<Shift><Alt>1" "<Shift><Alt>x"];
      switch-to-workspace-2 = ["<Shift><Alt>2" "<Shift><Alt>d"];
      switch-to-workspace-3 = ["<Shift><Alt>3" "<Shift><Alt>f"];
      switch-to-workspace-4 = ["<Shift><Alt>4" "<Shift><Alt>e"];
      switch-to-workspace-5 = ["<Shift><Alt>5" "<Shift><Alt>w"];
      switch-to-workspace-6 = ["<Shift><Alt>6" "<Shift><Alt>t"];
      switch-to-workspace-7 = ["<Shift><Alt>7"];
      switch-to-workspace-8 = ["<Shift><Alt>8" "<Shift><Alt>v"];
      switch-to-workspace-9 = ["<Shift><Alt>9" "<Shift><Alt>k"];
      unmaximize = [];
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:close";
      num-workspaces = 9;
    };

    "org/gnome/epiphany" = {
      ask-for-default = false;
      default-search-engine = "DuckDuckGo";
      restore-session-policy = "crashed";
    };

    "org/gnome/epiphany/web" = {
      enable-user-js = false;
    };

    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = true;
      enable-spellchecking = true;
      fullscreen = false;
      inverted-colors = false;
      show-sidebar = true;
      sidebar-page = "thumbnails";
      sidebar-size = 132;
      sizing-mode = "automatic";
      window-ratio = mkTuple [1.008471 0.712657];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/file-roller/dialogs/extract" = {
      recreate-folders = true;
      skip-newer = false;
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 250;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 480;
      window-width = 600;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      edge-tiling = false;
      overlay-key = "Super_L";
      workspaces-only-on-primary = false;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [];
      toggle-tiled-right = [];
    };

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "extra-large";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [890 550];
      maximized = true;
    };

    "org/gnome/nm-applet/eap/45afec42-34bd-3d10-8e17-9c1e6c7cfc2c" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/690f3c55-faee-3a17-b980-29a4b6d4fccc" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/927f3162-6ee2-3db1-a96c-75d76318da11" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = false;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Shift><Alt>c";
      command = "bash /home/ildar/configfiles/launchtool.sh emacs";
      name = "emacs";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Shift><Alt>r";
      command = "emacsclient -cF \"((visibility . nil))\" -e \"(emacs-counsel-launcher)\"";
      name = "emacs-run-launcher";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = false;
      sleep-inactive-ac-timeout = 7200;
      sleep-inactive-battery-timeout = 3600;
    };

    "org/gnome/shell" = {
      command-history = ["lg"];
      disable-user-extensions = false;
      disabled-extensions = [];
      enabled-extensions = ["workspace-indicator@gnome-shell-extensions.gcampax.github.com" "appindicatorsupport@rgcjonas.gmail.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "clipboard-indicator@tudmotu.com" "caffeine@patapon.info" "drive-menu@gnome-shell-extensions.gcampax.github.com" "tiling-assistant@leleat-on-github"];
      last-selected-power-profile = "power-saver";
      remember-mount-password = false;
      welcome-dialog-last-shown-version = "45.3";
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = false;
    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = ["org.codeberg.dnkl.foot.desktop:1" "org.telegram.desktop.desktop:6" "brave-browser.desktop:2" "microsoft-edge.desktop:4" "firefox.desktop:3" "emacs.desktop:7" "org.keepassxc.KeePassXC.desktop:9" "org.gnome.Epiphany.desktop:5"];
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position-max = 2;
      toggle-shortcut = ["<Shift><Alt>i"];
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      strip-text = true;
    };

    "org/gnome/shell/extensions/tiling-assistant" = {
      active-window-hint-color = "rgb(53,132,228)";
      last-version-installed = 44;
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 140;
      sort-column = "modified";
      sort-directories-first = true;
      sort-order = "descending";
      type-format = "category";
      view-type = "list";
      window-size = mkTuple [959 372];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 170;
      sort-column = "modified";
      sort-directories-first = false;
      sort-order = "descending";
      type-format = "category";
      window-position = mkTuple [26 23];
      window-size = mkTuple [1203 902];
    };
  };
}
