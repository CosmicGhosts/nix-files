# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  lockIcon = ./lockicon.png;

  comptonStart =
    (pkgs.writeScriptBin "compton-start" ''
      ${pkgs.compton}/bin/compton -b --config $HOME/.compton.conf
    '');

  comptonToggle =
    (pkgs.writeScriptBin "compton-toggle" ''
      killall compton || ${comptonStart}/bin/compton-start
    '');

  lockScreen =
    (pkgs.writeScriptBin "lock-screen" ''
      revert() {
        ${pkgs.xlibs.xset}/bin/xset -dpms
      }

      trap revert SIGHUP SIGINT SIGTERM
      ${pkgs.xlibs.xset}/bin/xset +dpms dpms 600
      tmpdir=/run/user/$UID/lock-screen
      [ -d $tmpdir ] || mkdir $tmpdir
      ${pkgs.scrot}/bin/scrot $tmpdir/screen.png
      # ${pkgs.i3lock}/bin/i3lock -n -i $tmpdir/screen.png &
      # temp_pid=$!
      ${pkgs.imagemagick}/bin/convert $tmpdir/screen.png -scale 10% -scale 1000% $tmpdir/screen.png
      # ${pkgs.imagemagick}/bin/convert -blur 0x2 $tmpdir/screen.png $tmpdir/screen.png
      ${pkgs.imagemagick}/bin/convert -gravity center -composite -matte \
        $tmpdir/screen.png ${lockIcon} $tmpdir/screen.png
      ${pkgs.i3lock}/bin/i3lock -n -i $tmpdir/screen.png &
      i3pid=$!
      # kill $temp_pid
      wait $i3pid
      rm $tmpdir/screen.png
      revert
    '');
in
{
  imports =
    [
      ./apps/24bit-apps.nix
      ./apps/libxslt-python.nix
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

  environment = {
    extraInit = ''
      export GTK_PATH=$GTK_PATH:${pkgs.gtk-engine-murrine}/lib/gtk-2.0
      export GTK_DATA_PREFIX=~/.nix-profile/

      # SVG loader for pixbuf (needed for svg icon themes) nixpkgs issue #11259
      export GDK_PIXBUF_MODULE_FILE=$(echo "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/*/loaders.cache")
    '';

    pathsToLink = [
      "/share/themes"
      "/share/icons"
      "/share/pixmaps"
    ];
  };

  environment.systemPackages = with pkgs; [
    # atk
    acpi
    arandr
    atom
    autoconf
    automake
    bazaar
    bomi
    cabal2nix
    chromium
    chromium
    clipit
    compton
    dmenu2
    emacs-24bit
    feh
    firefox
    firefoxWrapper
    gcc
    gettext
    gitFull
    glxinfo
    gnome3.gnome-tweak-tool
    gnumake
    gparted
    hexchat
    htop
    i3lock
    lci
    lshw
    lxappearance
    networkmanagerapplet
    neovim
    nodejs-5_x
    pasystray
    patchelf
    pavucontrol
    physlock
    pianobar
    powertop
    python
    ruby
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
    xlibs.xev
    xlibs.xkill
    xorg.xmessage
    xlibs.xmodmap
    xlibs.xset
    xlibs.xwininfo
    xorg.libXrandr
    xorg.xbacklight
    xorg.xf86inputkeyboard
    xorg.xmodmap
    xsel
    yi
    zip

    haskellPackages.cabal-install
    haskellPackages.hindent
    # haskellPackages.purescript
    haskellPackages.stack
    haskellPackages.stylish-haskell
    haskellPackages.taffybar
    haskellPackages.xmonad
    (haskellPackages.ghcWithPackages (self : [
      self.ghc
      self.cabal-install
      self.ghc-mod
      self.xmonad
      self.xmonad-contrib
      self.xmonad-extras
      self.taffybar
      self.xmobar
    ]))

    gtk-engine-murrine
    gtk_engines
    numix-gtk-theme
    numix-icon-theme
    numix-icon-theme-circle
    hicolor_icon_theme
    gnome.gnomeicontheme
    # screencloud

    lockScreen
    comptonStart
    comptonToggle
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
    tlp.enable = true;
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

      displayManager = {
        lightdm.enable = true;
        sessionCommands = ''
          ${pkgs.xlibs.xset}/bin/xset r rate 250 42
          ${pkgs.xlibs.xset}/bin/xset -b
          ${pkgs.xlibs.xset}/bin/xset -dpms
          ${pkgs.xlibs.xset}/bin/xset s off
          ${pkgs.xlibs.xmodmap}/bin/xmodmap ~/.Xmodmap
          ${comptonStart}
          eval `${pkgs.dbus_daemon}/bin/dbus-launcher --auto-syntax`
        '';
      };

      windowManager.default = "xmonad";
      windowManager.xmonad.enable = true;
      windowManager.xmonad.enableContribAndExtras = true;
      windowManager.xmonad.extraPackages = haskellPackages: [
        haskellPackages.taffybar
        haskellPackages.xmobar
      ];

      synaptics = {
        enable = true;
        palmDetect = true;
        twoFingerScroll = true;
        vertEdgeScroll = false;
      };
    };
  };
}
