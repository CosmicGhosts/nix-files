{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    libxsltPython = pkgs.libxslt.overrideDerivation
      (oldAttr: {
        configureFlags = [
          "--with-libxml-prefix=${pkgs.libxml2}"
          "--with-python=${pkgs.python}"
          "--without-crypto"
          "--without-debug"
          "--without-mem-debug"
          "--without-debugger"
        ];
      });
  };
}
