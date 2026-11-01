{ inputs, pkgs, config, ... }: {

  home.username = "fearless";
  home.homeDirectory = "/home/fearless";
  home.stateVersion = "26.05";

  imports = [
    inputs.umbriel.homeModules.default
    inputs.noctalia.homeModules.default
  ];

  # 1. Disable strict automatic generation to avoid syntax battles
  programs.umbriel.enable = false;
  programs.noctalia.enable = false;

  # 2. Tell Home Manager to link to normal, writeable files in your config directory
  # This lets you edit themes, scales, and windows on the fly without running rebuilds!
  # xdg.configFile."umbriel/config.toml".source =
  #  config.lib.file.mkOutOfStoreSymlink "/home/fearless/nixos-config/umbriel-config.toml";
  #
  # xdg.configFile."noctalia/config.toml".source =
  #  config.lib.file.mkOutOfStoreSymlink "/home/fearless/nixos-config/noctalia-config.toml";
  #
  #  Out-of-store flat link for the Yazi file manager core configuration profile
  # xdg.configFile."yazi/yazi.toml".source = 
  #  config.lib.file.mkOutOfStoreSymlink "/home/fearless/nixos-config/yazi.toml";

 xdg.configFile = {
    "umbriel/config.toml".source = ./dotfiles/umbriel/umbriel-config.toml;
    "umbriel/display-config.toml".source = ./dotfiles/umbriel/af-pro-display-config.toml;
    "noctalia/config.toml".source = ./dotfiles/noctalia/noctalia-config.toml;
    "yazi/yazi.toml".source = ./dotfiles/yazi/yazi.toml;
  };

  # Write standalone configuration maps forcing Adwaita-dark system-wide
  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    style=adwaita-dark
  '';

  # RESTORED: Vital for modern Qt6 applications like Dolphin
  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    style=adwaita-dark
  '';

  # FORCES DOLPHIN'S LAYOUT PARSER TO LOAD BREEZE DARK OVERRIDES
  xdg.configFile."dolphinrc".text = ''
    [UiSettings]
    ColorScheme=BreezeDark
  '';

  # FORCES DOLPHIN INTO THE NATIVE ADWAITA DARK MODE COLOR PROFILE WITH WHITE TYPOGRAPHY
  xdg.configFile."kdeglobals".text = ''
    [Colors:View]
    BackgroundNormal=30,30,30
    BackgroundAlternate=40,40,40
    ForegroundNormal=255,255,255
    ForegroundLink=41,128,185
    ForegroundVisited=127,140,141

    [Colors:Window]
    BackgroundNormal=30,30,30
    ForegroundNormal=255,255,255

    [Colors:Button]
    BackgroundNormal=45,45,45
    ForegroundNormal=255,255,255

    [Colors:Selection]
    BackgroundNormal=14,112,192
    ForegroundNormal=255,255,255

    [Colors:Header]
    BackgroundNormal=35,35,35
    ForegroundNormal=255,255,255
  '';

  # FORCES ALL CORES SYSTEMS AND QT6 PORTALS INTO HARD DARK MODE NATIVELY
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Set Vim as the universal default editor across Yazi and your shell profile
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Automatically creates a convenient ~/Storage symlink pointing to your LVM drive
  home.file."Storage".source = config.lib.file.mkOutOfStoreSymlink "/mnt/mylm";  

  # FORCES SYSTEMD TO GENERATE AND ENABLE THE ANTEC DISPLAY SERVICE DIRECTLY
  xdg.configFile."systemd/user/antec-display.service".text = ''
    [Unit]
    Description=Antec Flux Pro Case Screen Temp Tracker
    After=graphical-session.target

    [Service]
    Type=simple
    Environment=LD_LIBRARY_PATH=/run/opengl-driver/lib
    # FIXED: Cleared out the unknown argument so the binary runs cleanly
    ExecStart=/home/fearless/nixos-config/bin/af-pro-display
    Restart=always
    RestartSec=5sec

    [Install]
    WantedBy=graphical-session.target
  '';

  # Out-of-store link for the case display config file
  xdg.configFile."af-pro-display/config.toml".source = 
    config.lib.file.mkOutOfStoreSymlink "/home/fearless/nixos-config/af-pro-display-config.toml";

  # DEPLOY NEOVIM WITH LOCAL AI AUTO-SUGGESTIONS BINDINGS
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # Restores your high-contrast eye-comfort editor defaults
    extraConfig = ''
      syntax on
      colorscheme desert
      set number
      set relativenumber
      set expandtab
      set shiftwidth=4
      set tabstop=4
      set smartindent
    '';

    # Automatically fetches the asynchronous local AI compilation plugin
    plugins = with pkgs.vimPlugins; [
      {
        plugin = gen-nvim;
        type = "lua";
        config = ''
          require('gen').setup({
            model = 'qwen2.5-coder:14b', -- Locks onto your ultra-fast 14B model natively
            display = true,              -- Streams the code output live right into a split pane
            show_prompt = true,          -- Displays what the AI is analyzing
          })
          
          -- INSTANT ACCESS HOTKEY: Press 'Space + a' in visual highlight mode to call Qwen
          vim.keymap.set({'v', 'n'}, '<space>a', ':gen<CR>', { silent = true })
        '';
      }
    ];
  };

  # QUICK BUILD ALIASES
  programs.bash = {
    enable = true;
    shellAliases = {
      remake = "cd ~/nixos-config && git add . && sudo nixos-rebuild switch --flake .#warhammer";
    };
  };

}
