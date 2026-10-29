# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Allow Unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hardware Enablement (RTX 5080 / AM5 CPU)
  #boot.blacklistedKernelModules = [ "nouveau" "nvidiafb" ];
  # boot.initrd.kernelModules = [ "nvidia" ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  
  # CRUCIAL NVIDIA DRM BOOT FLAGS... fixed waitpid / child process crashes
  #boot.initrd.kernelModules = [ "nvidia" "nvidia_modset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
  

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  # Correct RTX 5080 module setting 
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };

  # Enable Hyprland Natively
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  imports = [
    inputs.umbriel.nixosModules.default
  ];

  # Enable the compositor system-wide
  programs.umbriel.enable = true;

  # Set up Cachix to grab pre-built binaries
  nix.settings = {
    extra-substituters = [ 
      "https://umbriel.cachix.org" 
      "https://noctalia.cachix.org" 
    ];
    extra-trusted-public-keys = [ 
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw=" 
      "noctalia.cachix.org-1: (if applicable, or omitted if relying on nixpkgs unstable)" 
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
  };
}

  # Network (wired ethernet auto-dhcp)
  networking.hostName = "warhammer";
  networking.useDHCP = pkgs.lib.mkDefault true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
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
    # Note: you can add default user packages here later
    #packages = with pkgs; [
    #  tree
    #];
  };

  # System Components and Shell Environment Assets
  environment.systemPackages = [
    # Core Script runtime engines for the bar/shell pipeline
    # pull the live, compiled upstream ags package from out flake inputs
    #inputs.ags.packages.${pkgs.system}.io
    #inputs.ags.packages.${pkgs.system}.gtk3
    inputs.ags.packages.${pkgs.system}.default
    #inputs.ags.packages.${pkgs.system}.agsFull

    # Core Script runtime engine built with the explicit library bindings embedded
    #(inputs.ags.packages.${pkgs.system}.default.override {
    #  extraPackages = [
    #    inputs.ags.packages.${pkgs.system}.io
    #    inputs.ags.packages.${pkgs.system}.astal3
    #  ];
    #})
  ] ++ (with pkgs; [  
    gjs                 # Gnome JavaScript bindings for widget processing
    bun                 # Blazing fast JS/TS engine to compile the assets

  # required background assets for modern bars
  kitty                 # Blazing fast GPU-Accelerated terminal
  git
  rofi                  # Application launcher block
  swww                  # High-performance hardware accelerated wallpaper
  networkmanagerapplet  # Network panel moitoring engine
  libnotify             # Notification transmission protocol
  firefox
  discord

  # Declarative Vim & Custom global .vimrc profile
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
   ]);
  


  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false

  system.stateVersion = "26.05"; # Did you read the comment?

}

