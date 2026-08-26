{ config, pkgs, ... }:

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
      reload = "killall -SIGUSR2 waybar";
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

  programs.starship = {
    enable = true;
	enableZshIntegration = true;

	settings = pkgs.lib.importTOML ./config/starship.toml;
  };

  home.packages = with pkgs; [
  	# Productivity
    neovim
    gcc
	gdb
	go

	# Apps
    discord
    steam
    spotify
	lutris
	localsend
	collision
	vlc

	# Funny apps
	hieroglyphic

	# System
    rofi
	pavucontrol
	kdePackages.knewstuff
	kdePackages.qqc2-desktop-style
	kdePackages.frameworkintegration

	# Customization
	kora-icon-theme

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

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

}
