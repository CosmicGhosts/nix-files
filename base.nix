# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./apps/24bit-apps.nix
      ./apps/libxslt-python.nix
      ./modules/desktop.nix
      ./modules/haskell-env.nix
    ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

  # time zone
  time.timeZone = "US/Pacific";

  # boot loader
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_4_5;

  # networking
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 8080 4040 ];
  networking.firewall.allowedUDPPorts = [ 80 8080 4040 ];

  # sound
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = false;
  sound.enableMediaKeys = true;

  virtualisation.virtualbox.host.enable = true;

  # programs
  programs.zsh.enable = true;

  # internationalisation
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "colemak/en-latin9";
    defaultLocale = "en_US.UTF-8";
  };

  # fonts
  fonts = {
    enableCoreFonts = true;
    fonts = with pkgs; [
      source-code-pro
      terminus_font
      powerline-fonts
      fira
      fira-mono
      fira-code
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.seanstrom = {
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    home = "/home/seanstrom";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
    ];
  };

  users.extraGroups.vboxusers.members = [ "seanstrom" ];

  # Unfree :(
  # Todo: Don't depend on Flash, use free alternatives.
  nixpkgs.config = {
    allowUnfree = true;
    firefox  = { enableAdobeFlash  = true; };
    chromium = { enablePepperFlash = true; };
  };

  environment.systemPackages = with pkgs; [
    acpi
    arandr
    atom
    autoconf
    automake
    bazaar
    bomi
    chromium
    clipit
    dmenu2
    emacs-24bit
    feh
    firefox
    firefoxWrapper
    gcc
    gettext
    gitFull
    glxinfo
    gnumake
    gparted
    hexchat
    htop
    lci
    libnotify
    lshw
    lxappearance
    networkmanagerapplet
    neovim
    ngrok
    # nodejs-5_x
    notify-osd
    pasystray
    patchelf
    pavucontrol
    physlock
    pianobar
    powertop
    python
    rxvt_unicode
    slack
    stow
    telnet
    termite
    thunderbird
    tlp
    tmux-24bit
    tor
    transmission_gtk
    unzip
    utillinuxCurses
    vifm
    vim
    xbrightness
    xcape
    xclip
    wget
    which
    xsel
    zip
  ];
}
