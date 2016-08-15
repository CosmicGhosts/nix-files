{ config, pkgs, ... }:

{
  services.xserver = {
    windowManager.default = "xmonad";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    windowManager.xmonad.extraPackages = haskellPackages: [
      haskellPackages.taffybar
      haskellPackages.xmobar
    ];
  };
}
