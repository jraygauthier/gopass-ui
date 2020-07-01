{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { inherit system; }
, system ? builtins.currentSystem
} @ args:

with pkgs;

let
  darwinElectron = fetchzip {
    stripRoot = false;
    url = "https://github.com/electron/electron/releases/download/v7.3.1/electron-v7.3.1-darwin-x64.zip";
    sha256 = "0nx8r9h7nigfrymsf04mf6zlm2am2z170zbins0gcsi99h8194zr";
    passthru = {
      version = "7.3.1";
    };
  };

  darwinSymlinkedElectron = symlinkJoin {
    name = "symlinked-electron";
    paths = [ darwinElectron ];
  };

  electron = electron_7;

  symlinkedElectron = symlinkJoin {
    name = "symlinked-electron";
    paths = [ electron ];
    postBuild = ''
      declare elec_wrap="$out/lib/electron/electron"
      # As we will later edit this file in place, transform the
      # symlink into a real file.
      cp --remove-destination "$(readlink "$elec_wrap")" "$elec_wrap"
    '';
  };
in

rec {
  # electron_5 = callPackage ./pkgs/electron/5.nix {};
  # electron-chromedriver_3 = callPackage ./pkgs/electron-chromedriver/3.nix {};
  nodejs_10_12 = lib.callPackageWith args ./pkgs/nodejs/10.12.nix {};
  release = callPackage ./. {
    # inherit electron_5;
    # inherit electron-chromedriver_3;
    # electron-chromedriver_3 = chromedriver;
    # nodejs-12_x = nodejs_10_12;
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

      release_darwin_dir() {
        declare darwin_out="$PWD/release/darwin-out"
        rm -rf "$darwin_out"
        rm -rf "$PWD/release/electron-dist"
        declare out_elec_bundle_dir="$darwin_out/Applications/Gopass UI"
        declare out_elec_exe="$out_elec_bundle_dir/Contents/MacOS/Gopass UI"
        mkdir -p "$(dirname "$out_elec_bundle_dir")"

        declare nix_elec_path="$PWD/release/electron-dist"
        mkdir -p "$nix_elec_path"
        cp -r -t "$nix_elec_path/" "${darwinSymlinkedElectron}/Electron.app"
        chmod -R u+rw "$nix_elec_path"
        while read -s f; do
          declare fsl
          if fsl="$(readlink "$f")"; then
            cp --remove-destination "$fsl" "$f"
            chmod u+rw "$f"
          fi
        done < <(find "$nix_elec_path" -name '*.plist')

        declare nix_elec_v
        nix_elec_v="${electron.version}"
        unpacked_elec_bundle="$PWD/release/mac/Gopass UI.app"
        electron-builder build --dir --mac -c.electronVersion="$nix_elec_v" -c.electronDist="$nix_elec_path"
        mv "$unpacked_elec_bundle" "$out_elec_bundle_dir"


        rm -rf "$darwin_out/bin"
        mkdir -p "$darwin_out/bin"
        ln -s -t "$darwin_out/bin" "$out_elec_exe"
      }

      release_linux_dir() {
         # electron-builder --linux --dir
         declare nix_elec_path="${symlinkedElectron}/lib/electron"
         declare nix_elec_v
         nix_elec_v="$(cat "$nix_elec_path/version")"
         # -c.npmRebuild=false
         electron-builder build --dir --linux -c.electronVersion="$nix_elec_v" -c.electronDist="$nix_elec_path"
         rel_out="$PWD/release"
         # mv "$rel_out/linux-unpacked/resources/app.asar" "$rel_out/linux-unpacked/resources/default_app.asar"
         sed -i -E -e "s#(.electron-wrapped\" )#\1\"$rel_out/linux-unpacked/resources/app.asar\"#g" "$rel_out/linux-unpacked/gopass-ui"
         # rm "$rel_out/linux-unpacked/gopass-ui"
         # mv "$nix_elec_path" "$rel_out/linux-unpacked/gopass-ui"
      }

      release_all() {
        electron-builder --publish onTag
      }

      print_electron_path() {
        echo "${darwinSymlinkedElectron}"
      }

      export USE_SYSTEM_MKSQUASHFS=1
    '';
  };
}
