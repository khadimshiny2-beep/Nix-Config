# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
  let
    hyprglass = pkgs.callPackage ./hyprglass.nix { };
  in {
      imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
      ];

  


  # --- Bootloader & Networking ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --- Time & Localization ---
  time.timeZone = "Africa/Dakar";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # --- Display & Desktop Environment (Cinnamon) ---
  services.xserver.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # --- Fonts ---
  fonts.packages = with pkgs; [
    nerd-fonts.bigblue-terminal
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "BigBlueTerminal Nerd Font Mono" ];

  # --- Users ---
  users.users."hopemaxxer221" = {
    isNormalUser = true;
    description = "Ahmadoul Khadim Gueye";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

  # --- Nixpkgs Config ---
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    fastfetch
    alacritty
    fish
    vscode
    chromium
    discord
    obsidian
    starship
    blender
    gimp
    libreoffice-fresh
    drawio
    neovim
    yazi
    vlc
    python3
    python3Packages.pip
    gcc
    bitwarden-desktop
    mangohud
    lm_sensors
    mission-center
    intel-gpu-tools
    pgadmin4-desktopmode
    zoxide
    lolcat
    cowsay
    cava
    cmatrix
    zip
    unzip
    lazygit
    pyright
    clang-tools
    lua-language-server
    ripgrep      # needed for telescope live_grep
    fd           # needed for telescope file finding
    imv
    eza
    bat
    polkit_gnome # polkit auth agent for the Hyprland session
    kitty
    obs-studio
    hyprglass
    wine
    statix
    rofi
    poppler-utils # pdf thumbnail generation (pdftoppm) for yazi preview
    ueberzugpp    # image preview rendering in terminal (needed for Hyprland/Kitty/Ghostty)
    zathura
    zathuraPkgs.zathura_pdf_poppler
    supabase-cli# poppler backend for zathura
    tty-clock
    peaclock
    unimatrix
    pipes-rs
    figlet
    gotop
    quota
    wl-clipboard
    ani-cli
    anime4k
    htop 
    btop
    kdePackages.kate        # full-featured text editor (KWrite's bigger sibling)
    kdePackages.konsole     # KDE terminal emulator
    kdePackages.dolphin     # KDE file manager, if you want it
    kdePackages.ark # archive manager
    chezmoi
    llvmPackages.clang-tools
    tree-sitter
    fzf
    aria2 
  ];
  # --- Display & Desktop Environment (Cinnamon) ---
  services.desktopManager.plasma6.enable = true;

  # --- Programs ---
  programs.fish.enable = true;
  programs.fish.shellAliases = {
    # --- Nix & NixOS ---
    nors  = "sudo nixos-rebuild switch";
    nosf = "sudo nixos-rebuild switch --flake .";
    nob  = "sudo nixos-rebuild boot";
    testnix = "sudo nixos-rebuild test";
    nup  = "nix flake update";
    ncg  = "nix-collect-garbage -d";
    np   = "nix-shell -p";
    nupdate  = "sudo nix-channel --update";
    nedit  = "nvim /etc/nixos/configuration.nix";

    # --- Git ---
    g   = "git";
    gs  = "git status";
    gsb = "git status -s";
    ga  = "git add";
    gaa = "git add --all";
    gc  = "git commit -m";
    gca = "git commit --amend";
    gb  = "git branch";
    gco = "git checkout";
    gcb = "git checkout -b";
    gp  = "git push";
    gpl = "git pull";
    gd  = "git diff";
    gl  = "git log --oneline --graph --decorate";
    nf  = "touch";

    # --- Navigation & Utilities ---
    ".."   = "cd ..";
    "..."  = "cd ../..";
    "...." = "cd ../../..";
    mkdir  = "mkdir -pv";

    # Modern CLI tools (eza / bat)
    ls   = "eza --icons --group-directories-first";
    ll   = "eza -la --icons --octal-permissions";
    tree = "eza --tree --icons";
    cat  = "bat --paging=never";

    # Safety & Quick Commands
    cp  = "cp -iv";
    mv  = "mv -iv";
    rm  = "rm -iv";
    cls = "clear";
  };

  programs.fish.interactiveShellInit = ''
    fastfetch
    starship init fish | source
  '';

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true; # creates hyprland-session.target / graphical-session.target, required for dms.service
    xwayland.enable = true;
  };

  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true; # needed so it accepts 127.0.0.1 connections, not just Unix sockets
  };

  # --- Audio & Hardware ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  hardware.pulseaudio.enable = false;

  # --- XDG Portals ---
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk       # Cinnamon
    pkgs.xdg-desktop-portal-hyprland  # Hyprland
  ];

  # --- State Version ---
  system.stateVersion = "26.05";
}
