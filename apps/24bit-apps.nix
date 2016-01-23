
{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    emacs-24bit = pkgs.emacs.overrideDerivation
      (oldAttr: {
       patches = [ ./patches/emacs-24bit.patch ];
      });

    tmux-24bit = pkgs.tmux.overrideDerivation
      (oldAttr: {
       name = "tmux-2.1";
       version = "2.1";
       src = pkgs.fetchurl {
         url = "https://github.com/tmux/tmux/releases/download/2.1/tmux-2.1.tar.gz";
         sha256 = "31564e7bf4bcef2defb3cb34b9e596bd43a3937cad9e5438701a81a5a9af6176";
       };
       patches = [ ./patches/tmux-24bit.patch ];
      });
  };
}
