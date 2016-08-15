{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cabal2nix
    # yi

    haskellPackages.cabal-install
    haskellPackages.hindent
    # haskell.packages.purescript
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
      # self.xmobar
    ]))
  ];
}
