{pkgs ? import <nixpkgs> {
  inherit system;
}, system ? builtins.currentSystem}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };
in
nodePackages // {
  package = nodePackages.package.override {
    buildInputs = with pkgs; [
      tree
      jq
    ];
    preRebuild = ''

    optipng_dir="."
    # optipng_dir="./node_modules/pngquant-bin"
    # TODO: Improve by downloading the same version as the package.
    mkdir -p "$optipng_dir/vendor"
    ln -f -s -T "${pkgs.optipng}/bin/optipng" "$optipng_dir/vendor/optipng"

    mv "$optipng_dir/package.json" "$optipng_dir/package-old.json"
    cat "$optipng_dir/package-old.json" | jq 'del(.scripts)' > "$optipng_dir/package.json"
    rm "$optipng_dir/package-old.json"
    '';
  };
}


/*
nix-shell -p nodePackages.npm -p nodePackages.webpack -p nodePackages.node2nix -p electron_5 -p nodejs-10_x -p tree
node2nix --nodejs-10 -i package.json
nix-build override.nix -A package


node_modules/pngquant-bin

*/