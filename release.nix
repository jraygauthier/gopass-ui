{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { inherit system; }
, system ? builtins.currentSystem
} @ args:

with pkgs;

rec {
  # electron_5 = callPackage ./pkgs/electron/5.nix {};
  # electron-chromedriver_3 = callPackage ./pkgs/electron-chromedriver/3.nix {};
  nodejs_10_12 = lib.callPackageWith args ./pkgs/nodejs/10.12.nix {};
  release = callPackage ./. {
    # inherit electron_5;
    # inherit electron-chromedriver_3;
    # electron-chromedriver_3 = chromedriver;
    # nodejs-10_x = nodejs_10_12;
  };

  shell = mkShell rec {
    buildInputs = [
      dieHook
      nodejs
      nodePackages.npm
      nodePackages.node2nix
      squashfsTools
    ];

    unfilteredSrc = ./.;

    nodeDeps = (lib.callPackageWith args ./release.nix {
      }).release.nodeDeps;

    shellHook = ''
      dev_node_modules="$nodeDeps/lib/node_modules/gopass-ui/node_modules"
      export NODE_PATH="$dev_node_modules"
      export PATH="$dev_node_modules/.bin:$PATH"

      shell_dir="${toString unfilteredSrc}"
      if ! ln -fs -t "$shell_dir" "$dev_node_modules"; then
        printf -v "error_msg" "%s\n -> %s\n -> %s\n" \
          "ERROR: Non symlink '$shell_dir/node_modules' directory in the way." \
          "Cannot proceed with '$shell_dir/shell.nix'." \
          "Please move / remove '$shell_dir/node_modules' manually."
        die "$error_msg"
      fi

      clean() {
        rm -fr "$shell_dir/dist/"
      }

      build() {
        npm run build
      }

      run() {
        electron "$shell_dir"
      }

      patch_electron_build_mksquashfs() {
        ln -f -s -t "$HOME/.cache/electron-builder/appimage/appimage-9.1.0/linux-x64" "${squashfsTools}/bin/mksquashfs"
      }

      release() {
         electron-builder --dir
      }

      release_all() {
        electron-builder --publish onTag
      }

      export USE_SYSTEM_MKSQUASHFS=1
    '';
  };
}