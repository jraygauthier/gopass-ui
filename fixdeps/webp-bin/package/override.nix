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

    post_install_vendor_bin_script_patch() {
      local pkg_dir="''${1?}"
      local vendor_bin_in="''${2?}"
      local vendor_bin_out="''${3?}"

      mkdir -p "$pkg_dir/vendor"
      ln -f -s -T "$vendor_bin_in" "$vendor_bin_out"

      mv "$pkg_dir/package.json" "$pkg_dir/package-old.json"
      cat "$pkg_dir/package-old.json" | jq 'del(.scripts)' > "$pkg_dir/package.json"
      rm "$pkg_dir/package-old.json"
    }

    cwebp_post_install_script_patch() {
      local pkg_dir="."
      # local pkg_dir="./node_modules/cwebp-bin"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pkgs.libwebp}/bin/cwebp" "$pkg_dir/vendor/cwebp"
    }

    cwebp_post_install_script_patch
    '';
  };
}


/*
nix-shell -p nodePackages.npm -p nodePackages.webpack -p nodePackages.node2nix -p electron_5 -p nodejs-10_x -p tree
node2nix --nodejs-10 -i package.json
nix-build override.nix -A package


node_modules/pngquant-bin

*/