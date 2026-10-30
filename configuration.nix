# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://nixos.org and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  # MERGED IMPORTS BLOCK: Combined hardware scan and Umbriel compositor module
  imports = [
    ./hardware-configuration.nix
    inputs.umbriel.nixosModules.default
  ];

  # Allow Unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # VIRTUAL IN-MEMORY SWAP: Fast, compressed block device in your RAM pool
  zramSwap = {
    enable = true;
    algorithm = "zstd";        # Fast memory compression
    memoryPercent = 50;        # Allocates up to 50% of your RAM space for compression
  };

  # Enable Ollama with native NVIDIA CUDA hardware acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # FIXED: Replaced acceleration string with direct CUDA package target
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # CRUCIAL NVIDIA DRM BOOT FLAGS... fixed waitpid / child process crashes
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  # Correct RTX 5080 module setting
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };

 # Grant unprivileged hardware access to the real Antec Flux Pro LCD hardware signatures
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2022", ATTRS{idProduct}=="0522", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2022", ATTRS{idProduct}=="0522", MODE="0666", TAG+="uaccess"
  '';

  # Automatically enforce user ownership over the LVM storage mount on boot
  system.activationScripts.mylm-permissions = {
    text = ''
      mkdir -p /mnt/mylm
      chown -R fearless:users /mnt/mylm
      chmod -R u+rwX,g+rX,o-rwx /mnt/mylm
    '';
    deps = [];
  };

  # Enable Hyprland Natively
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable the compositor system-wide
  programs.umbriel.enable = true;

  # Set up Cachix to grab pre-built binaries securely
  nix.settings = {
    extra-substituters = [
      "https://cachix.org"
    ];
    extra-trusted-public-keys = [
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
    ];
  };

  # Required daemon dependencies for Noctalia's system modules
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Nvidia specifics: ensure Wayland app compatibility
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    GTK_THEME = "Adwaita:dark";
  };

  # Network (wired ethernet auto-dhcp)
  networking.hostName = "warhammer";
  networking.useDHCP = pkgs.lib.mkDefault true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Define your personal user account
  users.users.fearless = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Force Qt applications to use standard portal settings for theming
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita-dark";
  };

  # Enables the system configuration registry pipeline
  programs.dconf.enable = true;

    # Enable FUSE for AppImages, LMO, and Mod Organizer virtualization layer routing
  boot.supportedFilesystems = [ "fuse" ];
  programs.fuse.userAllowOther = true;

  # Ensure 32-bit graphics support is explicitly active for older Wine/Steam titles
  hardware.graphics.enable32Bit = true;

  # System Components and Shell Environment Assets
  environment.systemPackages = with pkgs; [
    gjs                 # Gnome JavaScript bindings for widget processing
    bun                 # Blazing fast JS/TS engine to compile the assets
    kitty               # Blazing fast GPU-Accelerated terminal
    git
    networkmanagerapplet # Network panel monitoring engine
    libnotify           # Notification transmission protocol
    firefox
    discord
    kdePackages.dolphin
    yazi
    flameshot
    wl-clipboard
    brightnessctl
    wireplumber
    lxqt.lxqt-policykit
    fastfetch
    btop
    brave
    protonmail-desktop
    steam
    heroic
    protonup-qt
    protontricks                 # Crucial winetricks wrapper for Steam games
    wineWowPackages.unstableFull # Full Wine layer supporting both 32-bit and 64-bit windows binaries
    winetricks                   # Manual DLL installation helper tool for standalone Wine prefixes
    steam-run                    # Incredibly helpful utility to run raw binaries inside Steam's environment


    # THEME ENGINES: Restores missing assets for Dolphin dark mode
    kdePackages.breeze-icons   # Missing icon assets used by dark modes
    kdePackages.breeze         # Core dark rendering assets for Qt6 apps

    # Declarative Vim & Custom global .vimrc profile nested directly inside system packages
    (pkgs.vim-full.customize {
       name = "vim";
       vimrcConfig.customRC = ''
         filetype plugin indent on
         set expandtab
         set shiftwidth=4
         set softtabstop=4
         set tabstop=4
         set shiftwidth=4
         set number
         set relativenumber
         set smartindent
         set showmatch
         set backspace=indent,eol,start
         syntax on
         colorscheme desert
       '';
    })
  ];

  # HIGH-VISIBILITY TYPOGRAPHY PACKAGES
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono  # Crisp typography with built-in development layout icons
    nerd-fonts.fira-code       # High-readability font with clear multi-character spacing
    nerd-fonts.mononoki        # Broad visual width font family, fantastic for eyesight strain
  ];

  system.stateVersion = "26.05"; # Did you read the comment?
}
