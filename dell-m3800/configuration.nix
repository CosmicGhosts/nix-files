{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../base.nix
    ];

  # networking
  networking.hostName = "sn-m3800-nixos";

  # sound card
  boot.extraModprobeConfig = "options snd_hda_intel index=1";

  # encrypted disks
  boot.initrd.luks.devices = [
    { name = "rootfs";
      device = "/dev/sda3";
      preLVM = true; }
  ];

  # graphics
  services.xserver.videoDrivers = [ "nouveau" "intel" ];
  services.xserver.vaapiDrivers = [ pkgs.vaapiIntel ];
  services.xserver.deviceSection = ''
    #Identifier "Intel Graphics"
    Option "AccelMethod" "sna"
    Option "Backlight" "intel_backlight"
    BusID "PCI:0:2:0"
  '';
}
