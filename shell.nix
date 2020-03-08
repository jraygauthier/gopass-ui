{ nixpkgsSrc ? <nixpkgs>
, pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
, nodejs ? import ./custom-nodejs.nix {inherit nixpkgsSrc pkgs system;}
}:

with pkgs;

mkShell {
  buildInputs = [
    dieHook
    nodejs
    nodePackages.npm
    nodePackages.node2nix

    # gifsicle
    autoconf automake

    electron_5
  ];

  /*
  shellHook = ''
    dev_node_modules="$devDeps/lib/node_modules/gopass-ui/node_modules"
    export NODE_PATH="$dev_node_modules"
    export PATH="$dev_node_modules/.bin:$PATH"

    shell_dir="${toString ./.}"
    if ! ln -fs -t "$shell_dir" "$dev_node_modules"; then
      printf -v "error_msg" "%s\n -> %s\n -> %s\n" \
        "ERROR: Non symlink '$shell_dir/node_modules' directory in the way." \
        "Cannot proceed with '$shell_dir/shell.nix'." \
        "Please move / remove '$shell_dir/node_modules' manually."
      die "$error_msg"
    fi

  */

  shellHook = ''
    npm_install() {
      npm install
    }

    build() {
      NODE_OPTIONS="--max-old-space-size=8192" npm run build
    }

    run() {
      electron "$shell_dir"
    }
  '';
}
