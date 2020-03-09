{ lib
, stdenv
, patchelf
, makeWrapper
, fetchzip
, system
, alsaLib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, ffmpeg
, fontconfig
, freetype
, gdk-pixbuf
, glib
, glibc
, gnome2
, gtk3
, libuuid
, nspr
, nss
, xorg
}:
stdenv.mkDerivation rec {
  version = "5.0.0";
  name = "electron-${version}";

  baseUrl = "https://github.com/electron/electron/releases/download";
  urlSystemStr = let cs = system; in ({
    "x86_64-linux" = "linux-x64";
  })."${cs}";

  src = fetchzip {
    url = "${baseUrl}/v${version}/electron-v${version}-${urlSystemStr}.zip";
    sha256 = "1734zb6vnkavxpmfwjf7qxkdfdwb4spdsbibqrax6g2ldvy2yshk";
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
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      ffmpeg
      fontconfig
      freetype
      gdk-pixbuf
      glib
      glibc
      gnome2.GConf
      gnome2.gtk
      gnome2.pango
      gtk3
      libuuid
      libuuid
      nspr
      nss
      stdenv.cc.cc
      stdenv.cc.cc.lib
      xorg.libX11
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXtst
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
}