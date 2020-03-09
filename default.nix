{ lib
, system
, stdenv
, fetchgit
, fetchurl
, makeDesktopItem
, makeWrapper
, runCommand
, writeTextFile
, electron_5
, electron-chromedriver_3
, gifsicle
, jq
, libwebp
, mozjpeg
, nix-gitignore
, nodejs-10_x
, nodePackages_10_x
, optipng
, pngquant
, python2
, utillinux
} @ args:

let
  unfilteredSrc = ./.;
in

stdenv.mkDerivation rec {
  pname = "gopass-ui";
  name = "${pname}-0.6.0";

  nativeBuildInputs = [
    makeWrapper
    nodejs-10_x
    nodePackages_10_x.npm
  ];

  src = nix-gitignore.gitignoreSourcePure [
    ./.gitignore
    ''
      .git/
      /.gitignore
      .vscode/
      node_modules
      node_modules/
      /node_modules*
      result
      result-*
      *.nix
      nixify-node-deps.sh
      /pkgs/
    ''
  ] unfilteredSrc;

  nodeDeps = (lib.callPackageWith args ./node-dependencies.nix {
      gopass-ui-src = unfilteredSrc;
    }).package;

  buildInputs = [
    electron_5
  ];

  buildPhase = ''
    dev_node_modules="${nodeDeps}/lib/node_modules/gopass-ui/node_modules"
    ln -s -t "." "$dev_node_modules"

    export PATH="$dev_node_modules/.bin:$PATH"
    npm run build
  '';

  installPhase = ''
    out_app_dir="$out/share/${pname}"
    out_dist_dir="$out_app_dir/dist"
    mkdir -p "$out_dist_dir"
    find "./dist" -mindepth 1 -maxdepth 1 -exec cp -R -t "$out_dist_dir" "{}" \;
    cp -t "$out_app_dir" "./package.json"

    src_icon_dir="$out_dist_dir/assets"
    out_icon_dir="$out/share/icons/hicolor"

    mkdir -p "$out_icon_dir/512x512/apps"
    ln -s -T "$src_icon_dir/icon.png" "$out_icon_dir/512x512/apps/${pname}.png"
    mkdir -p "$out_icon_dir/96x96/apps"
    ln -s -T "$src_icon_dir/icon@2x.png" "$out_icon_dir/96x96/apps/${pname}.png"
    mkdir -p "$out_icon_dir/48x48/apps"
    ln -s -T "$src_icon_dir/icon-mac@2x.png" "$out_icon_dir/48x48/apps/${pname}.png"

    mkdir -p "$out/share/applications"
    cp $desktopItem/share/applications/* $out/share/applications

    makeWrapper "${electron_5}/bin/electron" "$out/bin/${pname}" \
      --add-flags "$out_app_dir"
  '';

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = pname;
    genericName = "Graphical user interface to gopass";
    icon = pname;
    exec = pname;
    categories = "Utility;";
  };

  passthru = {
    inherit nodeDeps;
    nixifyNodeDeps = runCommand "nixify-node-deps" {
        nativeBuildInputs = [ makeWrapper ];
      } ''
      makeWrapper "${./nixify-node-deps.sh}" "$out" \
        --add-flags "${src}" \
        --prefix PATH : "$out/${nodePackages_10_x.node2nix}"
    '';
  };
}
