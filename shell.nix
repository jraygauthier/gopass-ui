{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { inherit system; }
, system ? builtins.currentSystem
} @ args:

with pkgs;

mkShell rec {
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
  '';
}
