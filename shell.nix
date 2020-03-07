{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
, nodejs ? pkgs.nodejs-10_x
}:

with pkgs;

mkShell {
  buildInputs = [
    dieHook
    nodejs
    nodePackages.npm
    nodePackages.node2nix
  ];

  devDeps = (import testPkgListDev/override.nix {
      inherit pkgs system nodejs;
    }).gopass-ui;

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
  '';
}
