{ config, lib, pkgs, ... }:

let
  sddm-astronaut = (pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";  # or any other theme
    themeConfig = {
      # Customize colors and settings
      HeaderTextColor = "#d5c4a1";
      # Background = "Backgrounds/your-custom-background.png";
      # ... other theme configuration options
    };
  });
in
{
  imports =
    [
      # /mnt/etc/nixos/hardware-configuration.nix
      ./hardware-configuration.nix
    ];

  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
	priority = 100;
	algorithm = "zstd";
	memoryPercent = 50;
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16 * 1024; # 16 GB fallback size (adjust as needed)
    priority = 1;     # Lower priority so it's only used after zram fills up
  } ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
  };

  systemd.oomd.enable = true;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # Kills process if free RAM drops below 5%
  };

  networking.hostName = "eis-btw";

  # Network Manager with OpenVPN
  networking.networkmanager = {
    enable = true;
	plugins = with pkgs; [
	  networkmanager-openvpn
	];
  };


  # Localsend ports
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  # GTA V Battleye
  networking.extraHosts = "
    0.0.0.0 paradise-s1.battleye.com
    0.0.0.0 test-s1.battleye.com
    0.0.0.0 paradiseenhanced-s1.battleye.com
  ";
  # Start arguments:
  # gamemoderun PROTON_BATTLEYE_RUNTIME="~/.local/share/Steam/steamapps/common/Proton BattlEye Runtime" %command%

  time.timeZone = "Europe/Warsaw";

  services.libinput.enable = true;

  services.udisks2.enable = true;

  # services.desktopManager.plasma6.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.zsh.enable = true;

  programs.steam.enable = true;
  programs.gamemode.enable = true;

  services.ollama = {
    enable = true;
    loadModels = [ "ornith-1.5:9b" "deepseek-r1:8b"];
  };

  users.users.piotr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    sbctl
    kitty
    quickshell
    git
    hyprpaper
    kdePackages.breeze
	kdePackages.breeze-gtk
	kdePackages.dolphin
	kdePackages.dolphin-plugins
	kdePackages.baloo
	kdePackages.baloo-widgets
	kdePackages.kio
	kdePackages.kde-cli-tools
	kdePackages.kate
	kdePackages.gwenview
	kdePackages.ark
	kdePackages.partitionmanager
    xdg-desktop-portal
    hyprpolkitagent
    ntfs3g
    librewolf
	sddm-astronaut
  ];

  # qmlls lsp
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
	brotli
	unixodbc
	glib
  ];

  environment.pathsToLink = [ "/share/icons" ];

  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";

  # ============< NVIDIA >=================

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ==============< SDDM >=================
  
  services.displayManager.sddm = {
    enable = true;
	wayland.enable = true;
    extraPackages = with pkgs; [
	  numix-cursor-theme
      kdePackages.qtmultimedia # Required for video backgrounds/audio
    ];
    theme = "sddm-astronaut-theme";
  };

  environment.variables = {
    XCURSOR_THEME = "numix_cursor";
    XCURSOR_SIZE = "24";
  };
}

