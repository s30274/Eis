{ config, pkgs, spicetify-nix, figma-linux-next, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  
  configs = {
    hypr = "hypr";
    nvim = "nvim";
    rofi = "rofi";
    kitty = "kitty";
    quickshell = "quickshell";
  };

  catppuccin-kvantum = pkgs.catppuccin-kvantum.override {
    accent = "blue";
    variant = "macchiato";
  };
in
{
  home.username = "piotr";
  home.homeDirectory = "/home/piotr";
  home.stateVersion = "26.05";
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Your History Config
    history = {
      size = 1000000; # 100M causes heavy lag on NixOS; 1M is highly recommended
      save = 1000000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      expireDuplicatesFirst = true;
      share = true; # Replaces INC_APPEND_HISTORY natively
    };

    # Your Custom Aliases
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      vim = "nvim";
      don = "nvim";
	  update = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#eis-btw";
      s = "kitten ssh";
    };

    # Plugins managed natively by Nix
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    # Extra configuration lines that don't fit native options
    initContent = ''
      # If not running interactively, don't do anything
      [[ $- != *i* ]] && return

      # Extra history options
      setopt HIST_FIND_NO_DUPS

      # Environment Variables
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    '';
  };

  services.udiskie = {
    enable = true;
    settings = {
        program_options = {
        file_manager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
      };
    };
  };


  programs.starship = {
    enable = true;
	enableZshIntegration = true;
	settings = pkgs.lib.importTOML ./config/starship.toml;
  };

  # Packages
  home.packages = with pkgs; [
  	# Productivity
    neovim
    gcc
	gdb
	go
	python3
	nodejs_26 # ONLY FOR NEOVIM LSP
	unzip
	openvpn
	grim
	libnotify
	wl-clipboard
	jetbrains.clion
	virtualbox

	# Utilities
	brightnessctl
	lm_sensors
	proton-vpn
	networkmanagerapplet

	# Apps
    discord
	lutris
	localsend
	collision
	vlc
	gimp
	anki
	darktable
	anydesk
	kdePackages.kcalc

	# Funny apps
	hieroglyphic

	# System
    rofi
	pavucontrol
	kdePackages.knewstuff
	kdePackages.qqc2-desktop-style
	kdePackages.frameworkintegration

	# Customization
    catppuccin-kvantum
	libsForQt5.qt5ct
	kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
	kora-icon-theme
	numix-cursor-theme

	# Nix Search TV
	(pkgs.writeShellApplication {
    name = "ns";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
    ];
    text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
    })
  ];

  # Cursor
  home.pointerCursor = {
    gtk.enable = true;
	x11.enable = true;
    package = pkgs.numix-cursor-theme;
    name = "Numix-Cursor";
    size = 24;
  };

  # Theme and icons
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    # style.name = "kvantum";
  };

  gtk = {
    enable = true;
    
    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  xdg.configFile = {
	"kdeglobals".text = ''
	  [General]
	  WidgetStyle=kvantum

	  [Icons]
	  Theme=kora
	'';

    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=catppuccin-macchiato-blue
    '';

    "Kvantum/catppuccin-macchiato-blue".source = "${catppuccin-kvantum}/share/Kvantum/catppuccin-macchiato-blue";
    "Kvantum/breeze-dark".source = "${pkgs.kdePackages.breeze}/share/Kvantum/breeze-dark";
  } // (builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs);
}
