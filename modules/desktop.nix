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
  imports = [./xmonad.nix];

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
    compton
    i3lock
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

    gtk-engine-murrine
    gtk_engines
    arc-gtk-theme
    # numix-gtk-theme
    # numix-icon-theme
    # numix-icon-theme-circle
    # hicolor_icon_theme
    # gnome.gnomeicontheme
    elementary-icon-theme

    lockScreen
    comptonStart
    comptonToggle
  ];

  services = {
    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;
    # Enable CUPS to print documents.
    # services.printing.enable = true;
    ntp.enable = true;
    dbus.enable = true;
    dnsmasq.enable = true;
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

      synaptics = {
        enable = true;
        palmDetect = true;
        twoFingerScroll = true;
        vertEdgeScroll = false;
      };
    };
  };
}
