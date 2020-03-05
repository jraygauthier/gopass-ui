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
      # wrapProgram $out/bin/dnschain --suffix PATH : ${pkgs.openssl.bin}/bin
      # 1>&2 tree
      # false

      pngquant_dir="."
      # pngquant_dir="./node_modules/pngquant-bin"
      # TODO: Improve by downloading the same version as the package.
      mkdir -p "$pngquant_dir/vendor"
      ln -f -s -T "${pkgs.pngquant}/bin/pngquant" "$pngquant_dir/vendor/pngquant"

      mv "$pngquant_dir/package.json" "$pngquant_dir/package-old.json"
      cat "$pngquant_dir/package-old.json" | jq 'del(.scripts)' > "$pngquant_dir/package.json"
      rm "$pngquant_dir/package-old.json"
    '';
  };
}


/*
node2nix --nodejs-10 -i package.json
nix-shell -p nodePackages.npm -p nodePackages.webpack -p nodePackages.node2nix -p electron_5 -p nodejs-10_x -p tree
node_modules/pngquant-bin
*/