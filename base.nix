# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./24bit-apps.nix
    ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  # time zone
  time.timeZone = "US/Pacific";

  # boot loader
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_4_3;

  # networking
  networking.networkmanager.enable = true;

  # sound
  hardware.pulseaudio.enable = true;

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

  # Unfree :(
  # Todo: Don't depend on Flash, use free alternatives.
  nixpkgs.config = {
    allowUnfree = true;
    firefox  = { enableAdobeFlash  = true; };
    chromium = { enablePepperFlash = true; };
  };

  # packages
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    vim
    emacs-24bit
    yi
    tmux-24bit
    gitFull
    bazaar
    htop
    which
    rxvt_unicode
    chromium
    firefox
    utillinuxCurses
    xorg.libXrandr
    arandr
    networkmanagerapplet
    pavucontrol
    pasystray
    stow
    zip
    unzip
    ruby
    python
    nodejs-5_x
    dmenu2
    haskellPackages.stack
    haskellPackages.hindent
    haskellPackages.stylish-haskell
    (haskellPackages.ghcWithPackages (self : [
      self.ghc
      self.ghc-mod
    ]))
    physlock
    xorg.xev
    xorg.xmodmap
    xorg.xf86inputkeyboard
    xcape
    neovim
    clipit
    xclip
    lci
    termite
    xorg.xbacklight
    automake
    autoconf
    gcc
    tor
    thunderbird
  ];

  # services
  services = {
    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;
    # Enable CUPS to print documents.
    # services.printing.enable = true;
    ntp.enable = true;
    dbus.enable = true;
    dnsmasq.enable = true;
    dnsmasq.servers = ["8.8.8.8" "8.8.4.4"];
    udisks2.enable = true;
    upower.enable = true;
    redshift = {
      enable = true;
      latitude = "36.325583";
      longitude = "-115.289685";
    };

    acpid.enable = true;
    acpid.lidEventCommands = ''
      LID_STATE=/proc/acpi/button/lid/LID0/state
      STATE=$(/usr/bin/env awk '{print $2}' $LID_STATE)
      if [ $STATE = 'closed' ]; then
        systemctl suspend
      fi
    '';

    # Configure X11
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "colemak";
      xkbOptions = "ctrl:nocaps";

      desktopManager.default = "none";

      windowManager.default = "awesome";
      windowManager.awesome.enable = true;

      synaptics = {
        enable = true;
        palmDetect = true;
        twoFingerScroll = true;
        vertEdgeScroll = false;
      };
    };
  };
}
