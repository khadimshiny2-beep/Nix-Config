# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

let
  # Shell aliases defined once, shared by fish, zsh and bash
  aliases = {
    # --- Nix & NixOS ---
    nors  = "sudo nixos-rebuild switch";
    nosf  = "sudo nixos-rebuild switch --flake .";
    nob   = "sudo nixos-rebuild boot";
    testnix = "sudo nixos-rebuild test";
    nup   = "nix flake update";
    ncg   = "sudo nix-collect-garbage -d"; # collect garbage (sudo so old system generations go too)
    ndgen_3 = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system"; # Deletes old generations (keeping last 3, adjust as needed)
    ndgen_old = "nix-env --delete-generations old"; # Also clean user profile generations
    nopt  = "sudo nix-store --optimise"; # Optimizes store (dedup identical files via hardlinks) — can free a surprising amount
    nshell  = "nix-shell -p";
    nupdate = "sudo nix-channel --update";
    nedit   = "nvim /etc/nixos/configuration.nix";
    ncat    = "cat /etc/nixos/configuration.nix";
    fetch   = "fetch --infinite";
    # --- Disk cleanup ---
    # Empties the trash, wipes the nix eval cache, trims the journal to 100M,
    # then deletes old system generations and unused store paths.
    # `command rm` skips the `rm -iv` alias so it doesn't prompt for every file.
    nclean = "command rm -rf ~/.local/share/Trash/* ~/.cache/nix && sudo journalctl --vacuum-size=100M && sudo nix-collect-garbage -d";

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
    grep = "grep -rn -i";

    # Safety & Quick Commands
    cp  = "cp -iv";
    mv  = "mv -iv";
    rm  = "rm -iv";
    cls = "clear";

    # --- TMUX ---
    tmux = "tmux new -s";
    # --- DMS ---
    binds = "nvim ~/.config/hypr/dms/binds.conf";

    # --- Glances ---
    glances-fetch = "glances --fetch --fetch-template ~/.config/glances/battery-fetch.jinja";
      # --- PostgreSQL ---
    # Connect to the local server as khadim on mydb (asks for the password)
    psql = "sudo -u postgres psql`";
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # --- Bootloader & Networking ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --- Enabling Flakes ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    nerd-fonts.jetbrains-mono
    monocraft
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "BigBlueTerminal Nerd Font Mono" ];

  # --- Users ---
  users.users."hopemaxxer221" = {
    isNormalUser = true;
    description = "Ahmadoul Khadim Gueye";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
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
    github-cli
    fastfetch
    fetch
    alacritty
    fish
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    tldr
    vscode
    chromium
    firefox
    discord
    obsidian
    starship
    blender
    gimp
    libreoffice
    drawio
    neovim
    yazi
    vlc
    python3
    python3Packages.pip
    python314Packages.conda
    gcc
    bitwarden-desktop
    mangohud
    lm_sensors
    mission-center
    intel-gpu-tools
    #pgadmin4-desktopmode
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
    ghostty
    obs-studio
    wine
    statix
    rofi
    poppler-utils # pdf thumbnail generation (pdftoppm) for yazi preview
    ueberzugpp    # image preview rendering in terminal (needed for Hyprland/Kitty/Ghostty)
    zathura
    zathuraPkgs.zathura_pdf_poppler
    supabase-cli  # poppler backend for zathura
    tty-clock
    tmux
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
    kdePackages.ark         # archive manager
    kdePackages.kclock
    kdePackages.kdbusaddons
    # Kvantum engine — one build for Qt6/Plasma6 apps, one for Qt5 apps
    (catppuccin-kvantum.override {
      accent = "mauve";
      variant = "mocha";
    })
    (catppuccin-kde.override {
      flavour = [ "mocha" ];
      accents = [ "mauve" ];
    })
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    # Kvantum theme — includes a Mauve/purple variant
    catppuccin-kvantum
    # Icons: Papirus base + Catppuccin folder recolor
    papirus-icon-theme
    catppuccin-papirus-folders
    chezmoi
    llvmPackages.clang-tools
    tree-sitter
    fzf
    aria2
    wmctrl
    xdotool
    sqls
    sqlfluff
    glances
    alsa-utils
    pulseaudio
    pulseaudioFull
    ffmpeg
    jp2a
    uv
    rustc
    cargo
    # optional but common additions:
    rust-analyzer   # LSP for Rust, useful since you're using LazyVim
    rustfmt
    clippy
    cargo-edit      # cargo add/rm/upgrade
    cargo-watch     # cargo watch -x run
    pkg-config
    stdenv.cc.cc.lib
    zlib
    openssl         # many crates need this + pkg-config to build
    jetbrains.datagrip
    zed-editor
    vopono
    inxi
    rustnet
    mapscii
    binsider
    
  ];
  # --- Programs ---
  programs.fish.enable = true;
  programs.fish.shellAliases = aliases;
  programs.zsh.shellAliases = aliases;
  programs.bash.shellAliases = aliases;

  # --- For more compatibility ---
  programs.nix-ld.enable = true;

  # --- For temperature in Glances ---
  hardware.sensor.iio.enable = true;
  boot.kernelModules = [ "coretemp" ];

  # --- Display World Clock on Terminal ---
  environment.variables.TZDIR = "/etc/zoneinfo";

  # --- Display & Desktop Environment (Plasma) ---
  services.desktopManager.plasma6.enable = true;

  # --- Hyprland DMS powerbutton ---
  services.logind.settings.Login.HandlePowerKey = "ignore";


  # --- Zsh ---
  programs.zsh.enable = true;
  programs.zsh.promptInit = "";
  programs.zsh.interactiveShellInit = ''
    fetch --infinite
    eval "$(starship init zsh)"
  '';

  # --- Fish ---
  programs.fish.interactiveShellInit = ''
    fetch --infinite
    starship init fish | source
  '';

  # --- Steam ---
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.vscode = {
    enable = true;
    package = (pkgs.vscode.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--disable-gpu-rasterization"
      ];
    });
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
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true; # needed so it accepts 127.0.0.1 connections, not just Unix sockets
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host  all all 127.0.0.1/32 scram-sha-256
      host  all all ::1/128      scram-sha-256
    '';
  };

  # --- Audio & Hardware ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;

  # --- XDG Portals ---
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk       # Cinnamon
    pkgs.xdg-desktop-portal-hyprland  # Hyprland
  ];

  # --- State Version ---
  system.stateVersion = "26.05";
}
