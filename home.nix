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
  xdg.configFile."umbriel/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/home/fearless/nixos-config/umbriel-config.toml";

  xdg.configFile."noctalia/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/home/fearless/nixos-config/noctalia-config.toml";

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

  # FORCES DOLPHIN INTO THE NATIVE ADWAITA DARK MODE COLOR PROFILE
  xdg.configFile."kdeglobals".text = ''
    [Colors:View]
    BackgroundNormal=30,30,30
    BackgroundAlternate=40,40,40
    ForegroundNormal=255,255,255

    [Colors:Window]
    BackgroundNormal=30,30,30
    ForegroundNormal=255,255,255

    [Colors:Button]
    BackgroundNormal=45,45,45
    ForegroundNormal=255,255,255

    [Colors:Selection]
    BackgroundNormal=14,112,192
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
    EDITOR = "vim";
  };

  # Automatically creates a convenient ~/Storage symlink pointing to your LVM drive
  home.file."Storage".source = config.lib.file.mkOutOfStoreSymlink "/mnt/mylm";  

}
