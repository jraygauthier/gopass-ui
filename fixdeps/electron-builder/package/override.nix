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

    mozjpeg_post_install_script_patch() {
      local pkg_dir="."
      # local pkg_dir="./node_modules/mozjpeg"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pkgs.mozjpeg}/bin/cjpeg" "$pkg_dir/vendor/cjpeg"
    }

    # mozjpeg_post_install_script_patch
    '';
  };
}


/*
nix-shell -p nodePackages.npm -p nodePackages.webpack -p nodePackages.node2nix -p electron_5 -p nodejs-10_x -p tree
node2nix --nodejs-10 -i package.json
nix-build override.nix -A package

```
enhanced-resolve@4.1.0 /nix/store/h4f8bjh7r5dbxa6dqsyn1qnsgcjhcrlr-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/webpack/node_modules/enhanced-resolve
tapable@1.1.1 /nix/store/h4f8bjh7r5dbxa6dqsyn1qnsgcjhcrlr-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/webpack/node_modules/tapable
   ...........] - postinstall: sill install executeActions0mTreeK
> gopass-ui@0.6.0 postinstall /nix/store/h4f8bjh7r5dbxa6dqsyn1qnsgcjhcrlr-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui
> electron-builder install-app-deps

sh: /nix/store/h4f8bjh7r5dbxa6dqsyn1qnsgcjhcrlr-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/.bin/electron-builder: /usr/bin/env: bad interpreter: No such file or directory
npm ERR! code ELIFECYCLE
npm ERR! errno 126
npm ERR! gopass-ui@0.6.0 postinstall: `electron-builder install-app-deps`
npm ERR! Exit status 126
npm ERR!
npm ERR! Failed at the gopass-ui@0.6.0 postinstall script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     /build/.npm/_logs/2020-03-05T02_56_55_259Z-debug.log

builder for '/nix/store/zrwxyrz2gl7j6vsal0apdnzwlwpq9smm-node_gopass-ui-0.6.0.drv' failed with exit code 126
error: build of '/nix/store/zrwxyrz2gl7j6vsal0apdnzwlwpq9smm-node_gopass-ui-0.6.0.drv' failed
```

*/