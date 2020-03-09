{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { inherit system; }
, system ? builtins.currentSystem
} @ args:

with pkgs;

rec {
  # electron_5 = callPackage ./pkgs/electron/5.nix {};
  electron-chromedriver_3 = callPackage ./pkgs/electron-chromedriver/3.nix {};
  nodejs_10_12 = lib.callPackageWith args ./pkgs/nodejs/10.12.nix {};
  release = callPackage ./. {
    inherit electron_5 electron-chromedriver_3;
    # nodejs-10_x = nodejs_10_12;
  };
}