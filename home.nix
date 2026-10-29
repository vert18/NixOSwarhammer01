{ inputs, pkgs, ... }: {

  imports = [
    inputs.umbriel.homeModules.default
    inputs.noctalia.homeModules.default
  ];

  # Configure the Umbriel Tiling Compositor
  programs.umbriel = {
    enable = true;
    settings = {
      general.autostart = [ "noctalia" ]; # Fires up Noctalia automatically
      layout.gap = 8;
      
      keybinds = {
        "Mod+Return" = "spawn:kitty";
        "Mod+Q" = "window-close";
        "Mod" = "spawn:noctalia msg panel-toggle launcher"; # Binds launcher to Super key
      };
    };
  };

  # Configure the Noctalia Bar and Shell
  programs.noctalia = {
    enable = true;
    systemd.enable = true; # Launches as a user systemd service
    
    settings = {
      bar = {
        density = "compact";
        position = "top";
        widgets = {
          left = [ { id = "ControlCenter"; useDistroLogo = true; } { id = "Network"; } ];
          center = [ { id = "Workspace"; } ];
          right = [ { id = "Clock"; } ];
        };
      };
    };
  };
}
