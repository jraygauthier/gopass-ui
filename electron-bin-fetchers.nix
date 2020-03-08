{ pkgs ? import <nixpkgs> { inherit system;}
, system ? builtins.currentSystem
, nodejs ? pkgs."nodejs-10_x"
}:
{
  electron-chromedriver = with pkgs; stdenv.mkDerivation rec {
    version = "3.0.0";
    # TODO: Attempt to retrive the version from the JSON file.
    # (builtins.fromJSON ( builtins.readFile ./node_modules/electron-chromedriver/package.json)).version
    # version = "4.1.1";
    name = "electron-chromedriver-${version}";

    baseUrl = "https://github.com/electron/electron/releases/download";
    urlSystemStr = let cs = builtins.currentSystem; in ({
      "x86_64-linux" = "linux-x64";
    })."${cs}";



    src = pkgs.fetchzip {
      url = "${baseUrl}/v${version}/chromedriver-v${version}-${urlSystemStr}.zip";
      sha256 = "17ksb5pbk2wh7jyb1s6nc8pd78rxb8h2fxcz1wg8ngkrkiig7ffm";
      # sha256 = "0jj53n3fnmj7ccvc92i2s8f5729ws8yzr6x7w7337z4w0n4fyq5x";
      stripRoot=false;
    };

    nativeBuildInputs = with xorg; [
      patchelf
    ];

    libPath = with xorg; stdenv.lib.makeLibraryPath [
      libX11
      glib
      nss
      nspr
    ];

    dontStrip = true;

    patchPhase = ''
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath $libPath \
        ./chromedriver
    '';

    installPhase = ''
      mkdir -p "$out/bin"
      find  . -mindepth 1 -maxdepth 1 -exec mv -t "$out/bin" "{}" \;
    '';
  };

  electron = with pkgs; stdenv.mkDerivation rec {
    version = "5.0.0";
    # TODO: Attempt to retrive the version from the JSON file.
    # (builtins.fromJSON ( builtins.readFile ./node_modules/electron/package.json)).version
    name = "electron-${version}";

    baseUrl = "https://github.com/electron/electron/releases/download";
    urlSystemStr = let cs = builtins.currentSystem; in ({
      "x86_64-linux" = "linux-x64";
    })."${cs}";

    src = pkgs.fetchzip {
      url = "${baseUrl}/v${version}/electron-v${version}-${urlSystemStr}.zip";
      sha256 = "1734zb6vnkavxpmfwjf7qxkdfdwb4spdsbibqrax6g2ldvy2yshk";
      # sha256 = "0jj53n3fnmj7ccvc92i2s8f5729ws8yzr6x7w7337z4w0n4fyq5x";
      stripRoot=false;
    };

    nativeBuildInputs = with xorg; [
      patchelf
      makeWrapper
    ];


    dontStrip = true;

    patchPhase = "true";

    installPhase = ''
      mkdir -p "$out/bin"
      find  . -mindepth 1 -maxdepth 1 -exec mv -t "$out/bin" "{}" \;
    '';

    preFixup = let
      packages = [
        alsaLib
        atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        gnome2.GConf
        gnome2.gtk
        gnome2.pango
        libuuid
        nspr
        nss
        xorg.libxcb
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        stdenv.cc.cc.lib
        stdenv.cc.cc
        glibc


        # libffmpeg.so => not found
        ffmpeg
        libuuid
        at-spi2-atk
        at-spi2-core
      ];
      libPathNative = lib.makeLibraryPath packages;
      libPath64 = lib.makeSearchPathOutput "lib" "lib64" packages;
      libPath = "${libPathNative}:${libPath64}";
    in ''
      # patch executable
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}:$out/bin" \
        $out/bin/electron

      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/bin/chrome-sandbox

      wrapProgram $out/bin/electron \
        --prefix LD_LIBRARY_PATH : $out/bin/electron
    '';

    passthru = {
      # This file is written by `node_modules/electron/install.js::extractFile`
      # and seems to be mandatory for the package to recognise that the bin dist
      # has been properly installed.
      pathTxtFile = writeTextFile (
        let
          platform = lib.lists.last (builtins.split "-" builtins.currentSystem);
          # Should match what is returned by `node_modules/electron/install.js::getPlatformPath`.
          content = ({
            "darwin" = "Electron.app/Contents/MacOS/Electron";
            "freebsd" = "electron";
            "linux" = "electron";
            "win32" = "electron.exe";
          })."${platform}";
        in
      {
        name = "path.txt";
        text = content;
      });
    };

  };
}