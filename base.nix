# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
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
  lockIcon = ./lockicon.png;
  arc-theme = with pkgs; stdenv.mkDerivation rec {
    version = "20151002";
    name = "arc-gtk-theme-${version}";

    src = fetchFromGitHub {
      owner = "horst3180";
      repo = "Arc-theme";
      rev = version;
      sha256 = "0ks6dgcrhbks73nn3x8zj7lwbkf5alr97ii6v6chy2x2q19h30kv";
    };

    buildInputs = [ autoconf automake pkgconfig ];

    dontBuild = true;

    installPhase = ''
      ./autogen.sh --prefix=$out
      make install
    '';

    meta = {
      description = "Arc GTK theme";
      homepage =  https://github.com/horst3180/Arc-theme;
      license = stdenv.lib.licenses.gpl3;
      platforms = stdenv.lib.platforms.all;
    };
  };

  bamf = with pkgs; stdenv.mkDerivation rec {
    name = "bamf";
    version = "0.5.1";
    majorVersion = "0.5";
    src = pkgs.fetchurl {
      url = "http://launchpad.net/bamf/${majorVersion}/${version}/+download/bamf-${version}.tar.gz";
      sha256 = "fb65e6d0d7330f06626e43b0f3828bdeb5678d69133396e770a8781b9988fd16";
    };

    makeFlags = "INTROSPECTION_GIRDIR=$(out)/share/gir-1.0/ INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository-1.0";

    configureFlags = [
      "--prefix=\${out}"
      "--libexecdir=\${out}/lib"
      "--localstatedir=/var"
      "--sysconfdir=/etc"
      "-disable-static"
      "--disable-webapps"
    ];

    installFlags = [
      "localstatedir=\${out}/var"
      "sysconfdir=\${out}/etc"
    ];

    buildInputs = with gnome3; [
      pkgconfig vala_0_28 gobjectIntrospection libwnck3 libgtop
      libxslt libxml2 python libxml2Python libxsltPython
    ];
  };

  plank = with pkgs; stdenv.mkDerivation rec {
    name = "plank";
    src = pkgs.fetchurl {
      url = "https://launchpad.net/plank/1.0/0.10.1/+download/plank-0.10.1.tar.xz";
      sha256 = "04cf4205fb7fce035bf537395fbfc3cf79aea9692fb4186345fe6a06ce2ebf36";
    };

    buildPhase = ''
      cd $src
      ./configure \
        --prefix=$out
        --sysconfdir=/etc
      make
    '';

    installPhase = ''
      cd $src
      make DESTDIR=$out sysconfdir=$(out)/etc install
    '';

    buildInputs = with gnome3; [
      gdk_pixbuf cairo pango bamf atk dbus_glib glib glibc gtk3
      libwnck3 libgee xorg.libX11 xorg.libXi xorg.libXfixes
      perl cmake vala_0_28 pkgconfig makeWrapper
      gsettings_desktop_schemas defaultIconTheme
    ];
  };

  pantheon-files = with pkgs; stdenv.mkDerivation rec {
    majorVersion = "0.3";
    minorVersion = "1.3";
    name = "pantheon-files";
    src = pkgs.fetchurl {
      url = "https://launchpad.net/pantheon-files/0.2.x/0.2.4/+download/pantheon-files-0.2.4.tar.xz";
      # url = "https://launchpad.net/pantheon-terminal/${majorVersion}.x/${majorVersion}.${minorVersion}/+download/${name}.tgz";
      sha256 = "7eaf1ecd076d46bc2e43373982dd02b62663c2d2f1d4430ff771314cf4366b81";
      # sha256 = "0bfrqxig26i9qhm15kk7h9lgmzgnqada5snbbwqkp0n0pnyyh4ss";
    };

    preConfigure = ''
      export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:${granite}/lib64/pkgconfig"
    '';

    preFixup = ''
      for f in $out/bin/*; do
        wrapProgram $f \
          --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH:$XDG_ICON_DIRS:$out/share"
      done
    '';

    buildInputs = with gnome3; [
      perl cmake vala pkgconfig glib gtk3 granite libnotify gettext makeWrapper
      libgee gsettings_desktop_schemas defaultIconTheme

      sqlite dbus_glib zeitgeist plank
    ];
    meta = {
      description = "elementary OS's terminal";
      longDescription = "A super lightweight, beautiful, and simple terminal. It's designed to be setup with sane defaults and little to no configuration. It's just a terminal, nothing more, nothing less. Designed for elementary OS.";
      homepage = https://launchpad.net/pantheon-terminal;
      license = stdenv.lib.licenses.gpl3;
      platforms = stdenv.lib.platforms.linux;
      maintainers = [ stdenv.lib.maintainers.vozz ];
    };
  };

in
{
  imports =
    [
      ./apps/24bit-apps.nix
      ./apps/libxslt-python.nix
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
  hardware.bluetooth.enable = false;

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

  # Unfree :(
  # Todo: Don't depend on Flash, use free alternatives.
  nixpkgs.config = {
    allowUnfree = true;
    firefox  = { enableAdobeFlash  = true; };
    chromium = { enablePepperFlash = true; };
    # packageOverrides = pkgs: rec {
    #   qt4 = pkgs.qt4.override { gtkStyle = true; };
    #   qt5.base = pkgs.qt5.base.override { gtkStyle = true; };
    # };
  };

  environment = {
    variables = {
      GTK_DATA_PREFIX = "/run/current-system/sw";
    };

    extraInit = ''
      # SVG loader for pixbuf (needed for svg icon themes) nixpkgs issue #11259
      export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg}/lib/gdk-pixbuf-2.0/*/loaders.cache)

      # numixIconPaths=${pkgs.numix-icon-theme}:${pkgs.numix-icon-theme-circle}
      #
      # # GTK2 theme
      #
      # export GTK_PATH=$GTK_PATH:${pkgs.gtk-engine-murrine}/lib/gtk-2.0:$numixIconPaths
      # export GTK2_RC_FILES=${pkgs.numix-gtk-theme}/share/themes/Numix/gtk-2.0/gtkrc:$GTK2_RC_FILES
      #
      # # GTK3 theme
      # export GTK_DATA_PREFIX=${pkgs.numix-gtk-theme}:$GTK_DATA_PREFIX
      # export GTK_THEME="Numix"
    '';


    # pathsToLink = [
    #   "/share/themes"
    #   "/share/icons"
    #   "/share/pixmaps"
    # ];
  };

  # packages
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    emacs-24bit
    yi

    tmux-24bit
    # pantheon-files

    wget
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
    compton
    feh
    xlibs.xset
    xorg.xmessage
    openbox
    (pkgs.writeScriptBin "temp-openbox" ''
      openbox
      ~/.xmonad/xmonad-x86_64-linux "$@"
    '')
    haskellPackages.taffybar
    haskellPackages.xmonad
    haskellPackages.stack
    haskellPackages.hindent
    haskellPackages.stylish-haskell
    haskellPackages.cabal-install
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

      gtk-engine-murrine
      gtk_engines
      numix-gtk-theme
      arc-theme
      numix-icon-theme
      numix-icon-theme-circle
      hicolor_icon_theme
      gnome.gnomeicontheme


      audacity
      dropbox
      evince
      firefoxWrapper
      chromium
      kde4.quasselClient
      libreoffice
      # screencloud
      skype
      teamspeak_client
      vlc
      pavucontrol
      lxappearance
      networkmanagerapplet
      compton
      i3lock

      glxinfo
      rxvt_unicode

      xbrightness
      xlibs.xbacklight
      xlibs.xev
      xlibs.xkill
      xlibs.xmodmap
      xlibs.xwininfo
      xsel

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
