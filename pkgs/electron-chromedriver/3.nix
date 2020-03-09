{ lib
, stdenv
, patchelf
, makeWrapper
, fetchzip
, system
, glib
, nspr
, nss
, xorg
}:

stdenv.mkDerivation rec {
  version = "3.0.0";
  name = "electron-chromedriver-${version}";

  baseUrl = "https://github.com/electron/electron/releases/download";
  urlSystemStr = let cs = system; in ({
    "x86_64-linux" = "linux-x64";
  })."${cs}";

  src = fetchzip {
    url = "${baseUrl}/v${version}/chromedriver-v${version}-${urlSystemStr}.zip";
    sha256 = "17ksb5pbk2wh7jyb1s6nc8pd78rxb8h2fxcz1wg8ngkrkiig7ffm";
    # sha256 = "0jj53n3fnmj7ccvc92i2s8f5729ws8yzr6x7w7337z4w0n4fyq5x";
    stripRoot=false;
  };

  nativeBuildInputs = with xorg; [
    patchelf
  ];

  libPath = lib.makeLibraryPath [
    glib
    nspr
    nss
    xorg.libX11
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

  meta = {
    description = "Download the ChromeDriver for Electron.";
    homepage = https://github.com/electron/chromedriver;
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jraygauthier ];
  };
}