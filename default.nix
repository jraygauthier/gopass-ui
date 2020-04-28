{ lib
, system
, stdenv
, fetchgit
, fetchurl
, fetchFromGitHub
, makeDesktopItem
, makeWrapper
, runCommand
, writeTextFile
, electron_7
, electron-chromedriver_3 ? null
, gifsicle
, jq
, libwebp
, mozjpeg
, nix-gitignore
, nodejs-12_x
, nodePackages_12_x
, optipng
, p7zip
, pngquant
, python2
, utillinux
} @ args:

stdenv.mkDerivation rec {
  pname = "gopass-ui";
  version = "0.7.0";
  name = "${pname}-${version}";

  nativeBuildInputs = [
    makeWrapper
    nodejs-12_x
  ];

  /*
  unfilteredSrc = ./.;

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
  */

  src = fetchFromGitHub {
    owner  = "codecentric";
    repo   = "gopass-ui";
    rev    = "v${version}";
    sha256 = "1yn8x3raj8hqc6jshqdbn6yfkh6qmp2j5i6b3xz8q02xyvb1r241";
  };

  nodeDeps = (import ./node-dependencies.nix {
      inherit system;
      pkgs = args // { inherit electron-chromedriver_3; };
      # gopass-ui-src = unfilteredSrc;
      gopass-ui-src = src;
    }).package;

  buildInputs = [
    electron_7
  ];

  buildPhase = ''
    dev_node_modules="${nodeDeps}/lib/node_modules/gopass-ui/node_modules"
    ln -s -t "." "$dev_node_modules"

    export PATH="$dev_node_modules/.bin:$PATH"

    # npm run build
    NODE_ENV=production webpack --config webpack.main.prod.config.js
    NODE_ENV=production webpack --config webpack.renderer.explorer.prod.config.js
    NODE_ENV=production webpack --config webpack.renderer.search.prod.config.js
  '';

  doCheck = true;

  checkPhase = ''
    # npm run release:check
    tslint '{src,test,mocks}/**/*.{ts,tsx,js,jsx}' --project ./tsconfig.json
    jest --testRegex '\.test\.tsx?$'

    # npm run test:integration
    # jest --testRegex '\.itest\.ts$'
  '';

  installPhase = ''
    # electron-builder --publish onTag

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

    makeWrapper "${electron_7}/bin/electron" "$out/bin/${pname}" \
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
        --prefix PATH : "${nodePackages_12_x.node2nix}/bin"
    '';
  };

  meta = {
    description = "Graphical user interface to gopass";
    homepage = https://github.com/codecentric/gopass-ui;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jraygauthier ];
  };
}
