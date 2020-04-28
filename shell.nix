{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { inherit system; }
, system ? builtins.currentSystem
} @ args:

(import ./release.nix args).shell
