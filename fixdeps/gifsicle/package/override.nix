{pkgs ? import <nixpkgs> {
  inherit system;
}, system ? builtins.currentSystem}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };

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

    gifsicle_post_install_script_patch() {
      local pkg_dir="."
      # local pkg_dir="./node_modules/gifsicle"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pkgs.gifsicle}/bin/gifsicle" "$pkg_dir/vendor/gifsicle"
    }

    gifsicle_post_install_script_patch
  '';

in
nodePackages // {
  package = nodePackages.package.override {
    inherit buildInputs preRebuild;
  };

  shell = nodePackages.shell.override {
    inherit buildInputs preRebuild;
  };
}


/*
nix-shell -p nodePackages.npm -p nodePackages.webpack -p nodePackages.node2nix -p electron_5 -p nodejs-10_x -p tree
node2nix --nodejs-10 -i package.json
nix-build override.nix -A package


```bash
$ nix-shell default.nix -A shell
#
> fsevents@1.2.7 install /nix/store/7xc82h3xp7z6drrcbh5jdlkkk952dirj-node-dependencies-gopass-ui-0.6.0/gopass-ui/node_modules/jest-haste-map/node_modules/fsevents
> node install

...............] | : info lifecycle fsevents@1.2.7~install: fsevents@1.2.7[0m
> gifsicle@4.0.1 postinstall /nix/store/7xc82h3xp7z6drrcbh5jdlkkk952dirj-node-dependencies-gopass-ui-0.6.0/gopass-ui/node_modules/gifsicle
> node lib/install.js

  ⚠ getaddrinfo ENOTFOUND raw.githubusercontent.com raw.githubusercontent.com:443
  ⚠ gifsicle pre-build test failed
  ℹ compiling from source
  ✖ Error: Command failed: /bin/sh -c autoreconf -ivf
/bin/sh: autoreconf: not found


    at Promise.all.then.arr (/nix/store/7xc82h3xp7z6drrcbh5jdlkkk952dirj-node-dependencies-gopass-ui-0.6.0/gopass-ui/node_modules/execa/index.js:231:11)
    at process._tickCallback (internal/process/next_tick.js:68:7)
npm ERR! code ELIFECYCLE
npm ERR! errno 1
npm ERR! gifsicle@4.0.1 postinstall: `node lib/install.js`
npm ERR! Exit status 1
npm ERR!
npm ERR! Failed at the gifsicle@4.0.1 postinstall script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     /build/.npm/_logs/2020-03-05T12_00_08_176Z-debug.log

builder for '/nix/store/cz2ma3mffn52qz24c97zdwr3fzin36xm-node-dependencies-gopass-ui-0.6.0.drv' failed with exit code 1
error: build of '/nix/store/cz2ma3mffn52qz24c97zdwr3fzin36xm-node-dependencies-gopass-ui-0.6.0.drv' failed
```

*/