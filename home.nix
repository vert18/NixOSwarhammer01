{
  inputs,
  pkgs,
  config,
  ...
}:
{

  home.username = "fearless";
  home.homeDirectory = "/home/fearless";
  home.stateVersion = "26.05";

  imports = [
    inputs.umbriel.homeModules.default
    inputs.noctalia.homeModules.default
    inputs.nix-index-database.homeModules.nix-index
  ];

  # 1. Disable strict automatic generation to avoid syntax battles
  programs.umbriel.enable = false;
  programs.noctalia.enable = false;

xdg.portal = {
  enable = true;
  extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
  ];
  config.common = {
    default = [ "gtk" ];
    "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
  };
};

  # 2. Tell Home Manager to link to normal, writeable files in your config directory
  xdg.configFile = {
    "umbriel/config.toml".source = ./dotfiles/umbriel/umbriel-config.toml;
    "umbriel/display-config.toml".source = ./dotfiles/umbriel/af-pro-display-config.toml;
    "noctalia/config.toml".source = ./dotfiles/noctalia/noctalia-config.toml;
    "yazi/yazi.toml".source = ./dotfiles/yazi/yazi.toml;
  };

  wayland.windowManager.hyprland = {
      enable = true;
      # Add basic fallback config lines if you want to bypass your dotfiles
      settings = {
          "$mod" = "SUPER";
          bind = [
          "$mod, Return, exec, kitty"
      ];
    };
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

  # User Workspace Applications Layer
  home.packages = with pkgs; [
    # Terminal & Command-Line Shell Utilities
    kitty # Your core fast GPU-accelerated terminal
    fzf # Interactive fuzzy finder utility
    eza
    bat # High-contrast syntax highlighting cat clone
    btop # High-contrast interactive system process monitor
    fastfetch # Clean modern system specification fetch layout
    wl-clipboard # Native wayland clipboard copy/paste utilities
    libnotify # Wayland background system notification daemon

    # File Managers & Desktop Management Tools
    doublecmd # Double Commander file manager (with Kitty/VSCodium integrations)
    yazi # Fast asynchronous terminal file browser
    flameshot # Desktop snapshot/screengrab selection interface
    grim
    slurp
    networkmanagerapplet # Graphical network management utility tray panel
    lxqt.lxqt-policykit # Handles administrative visual authentication loops

    # Communication & General Applications
    firefox # Primary web browser
    #brave # Secondary privacy browser
    discord # Messaging platform
    protonmail-desktop # Dedicated desktop client application
    # vscodium # Your streamlined asynchronous IDE workspace

    # Development & Script Compilation Layers
    gjs # Gnome JavaScript platform bindings
    bun # Extremely fast JS/TS bundler engine
    aichat # Fast command-line local chat companion app

    # Gaming Frameworks, Launchers & Runners
    steam # Native Linux gaming storefront architecture
    heroic # Open-source launcher for Epic, GOG, and Amazon titles
    protonup-qt # Graphical management tool for custom Proton-GE layers
    protontricks # Essential automated runtime script engine for Wine prefixes
    wineWow64Packages.unstableFull # Comprehensive layers handling 32/64 bit system titles
    winetricks # Manual DLL dependencies component modifier tools
    steam-run # Isolates and executes standalone unmanaged binaries natively
    p7zip # Multi-format deep archive compression engine
    unrar # Archive extraction dependency tools

    # Core CLI Audio Streamers
    mpv
    yt-dlp
    yewtube

    # Desktop Privacy YouTube Client
    freetube
  ];

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
    ];
  };

  # Enable nix-index and its command-not-found hook
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true; # Set to true if you use Bash
    enableZshIntegration = true;  # Set to true if you use Zsh
    enableFishIntegration = false; # Set to true if you use Fish
  };

  # Optional: standard nix-index can conflict with the default NixOS command-not-found script.
  # If you see conflicts during activation, you may want to disable the system-wide one 
  # in your system-level configuration.nix:
  # programs.command-not-found.enable = false;

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

    # Automatically fetches local AI integration modules
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

      # NEW: Separate, isolated configuration block for gp-nvim mapping to your llama3 core
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "gp.nvim";
          version = "latest";
          src = pkgs.fetchFromGitHub {
            owner = "Robitx";
            repo = "gp.nvim";
            rev = "b32327fe4ee65d24acbab0f645747c113eb935c0";
            sha256 = "sha256-obYQyy1aHQXdf23NRNe8EPleP8KtKSisijgAQ7Ckkzo=";
          };
        };
        type = "lua";
        config = ''
          require("gp").setup({
            default_chat_agent = "LocalChat",
            default_command_agent = "LocalCode",
            
            providers = {
              openai = { disable = true; };
              
              ollama = {
                endpoint = "http://localhost:11434/v1/chat/completions";
              };
              
              copilot = { disable = true; };
              anthropic = { disable = true; };
              googleai = { disable = true; };
            },
            agents = {
              {
                name = "LocalChat",
                chat = true,
                command = false,
                provider = "ollama",
                model = { model = "llama3:latest" },
                system_prompt = "You are a helpful, concise local AI assistant.",
              },
              {
                name = "LocalCode",
                chat = false,
                command = true,
                provider = "ollama",
                model = { model = "qwen2.5-coder:14b" },
                system_prompt = "You are an expert AI programmer. Output only code changes.",
              },
            },
          })

          -- HOTKEYS: Side chat pane via Ctrl+G+C, and inline code injection changes via Ctrl+G+R
          vim.keymap.set({"n", "i"}, "<C-g>c", "<cmd>GpChatToggle<cr>", { silent = true })
          vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", { silent = true })
        '';
      }

    ];
  };

  programs.vscodium = {
    enable = true;

    # FIXED: Wrapped extensions and settings under the default profile block
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        vscodevim.vim
      ];

      # This replaces your manual settings.json file entirely!
      userSettings = {
        # "editor.fontFamily" = "'Fira Code Nerd Font', 'mononoki Nerd Font', monospace";
        "editor.fontFamily" = "'Fira Code Nerd Font', monospace";
        # "editor.fontFamily" = "'mononoki Nerd Font', monospace";
        "editor.fontLigatures" = true;

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {
              "command" = [ "nixfmt" ];
            };
            "nixos" = {
              "expr" =
                "import (builtins.getFlake \"/home/fearless/nixos-config\").nixosConfigurations.warhammer.options";
            };
            "home-manager" = {
              "expr" =
                "import (builtins.getFlake \"/home/fearless/nixos-config\").homeConfigurations.fearless.options";
            };
          };
        };

        # Auto-formatting preferences
        "editor.formatOnSave" = true;
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
        };
      };
    };
  }; # lol

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "doublecmd.desktop" ];
    };
  };

  # QUICK BUILD ALIASES
  programs.bash = {
    enable = true;
    shellAliases = {
      remake = "cd ~/nixos-config && git add -A && sudo nixos-rebuild switch --flake .#warhammer";
      ls = "eza --color=always --icons=always --group-directories-first";
      la = "eza -la --color=always --icons=always --group-directories-first";
      lt = "eza --tree --color=always --icons=always --group-directories-first";
      music = "mpv --no-video --ytdl-format=bestaudio";
    };
  };
}
