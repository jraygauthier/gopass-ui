{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { inherit system; }
, system ? builtins.currentSystem
, nodejs ? import ./custom-nodejs.nix {inherit nixpkgs pkgs system;}
}:

with pkgs;

let
  devDeps = (import ./override.nix {
      inherit pkgs system nodejs;
    }).package;

  srcFilter = inSrc: nix-gitignore.gitignoreSourcePure [
      ./.gitignore
      ''
        .git/
        /.gitignore
        .vscode/
        node_modules
        node_modules/
        /node_modules*
        result
        result-*
        *.nix
      ''
    ] inSrc;
in

stdenv.mkDerivation rec {
  pname = "gopass-ui";
  name = "${pname}-0.6.0";

  nativeBuildInputs = [
    makeWrapper
    nodejs
    nodePackages.npm
  ];

  src = srcFilter ./.;

  buildInputs = [
    electron_5
  ];

  buildPhase = ''
    dev_node_modules="${devDeps}/lib/node_modules/gopass-ui/node_modules"
    ln -s -t "." "$dev_node_modules"

    export PATH="$dev_node_modules/.bin:$PATH"
    npm run build
  '';


  installPhase = ''
    out_app_dir="$out/share/${pname}"
    out_dist_dir="$out_app_dir/dist"
    mkdir -p "$out_dist_dir"
    find "./dist" -mindepth 1 -maxdepth 1 -exec cp -R -t "$out_dist_dir" "{}" \;
    cp -t "$out_app_dir" "./package.json"

    makeWrapper "${electron_5}/bin/electron" "$out/bin/${pname}" \
      --add-flags "$out_app_dir"
  '';
}
