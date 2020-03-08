{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { inherit system; }
, system ? builtins.currentSystem
}:

with pkgs;

/*
let
  buildNodejs = callPackage (nixpkgs + "/pkgs/development/web/nodejs/nodejs.nix") {};
in

buildNodejs {
  enableNpm = true;
  version = "10.12.0";
  sha256 = "1r0aqcxafha13ks8586x77n77zi88db259cpaix0y1ivdh6qkkfr";
}
*/
pkgs."nodejs-10_x"
