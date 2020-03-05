{ nixpkgs ? import <nixpkgs> {}}:
with nixpkgs; {
  electron-chromedriver = stdenv.mkDerivation {
    name = "electron-chromedriver-4.1.1";

    src = pkgs.fetchzip {
      url = "https://github.com/electron/electron/releases/download/v4.1.1/chromedriver-v4.1.1-linux-x64.zip";
      sha256 = "0jj53n3fnmj7ccvc92i2s8f5729ws8yzr6x7w7337z4w0n4fyq5x";
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
}

/*

```
$ ldd ./chromedriver
        linux-vdso.so.1 (0x00007ffe9fbf8000)
        libdl.so.2 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libdl.so.2 (0x00007f0a7f638000)
        libpthread.so.0 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libpthread.so.0 (0x00007f0a7f617000)
        librt.so.1 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/librt.so.1 (0x00007f0a7f60d000)
        libglib-2.0.so.0 => not found
        libX11.so.6 => not found
        libnss3.so => not found
        libnssutil3.so => not found
        libnspr4.so => not found
        libm.so.6 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libm.so.6 (0x00007f0a7f475000)
        libgcc_s.so.1 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libgcc_s.so.1 (0x00007f0a7f25f000)
        libc.so.6 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libc.so.6 (0x00007f0a7f0a9000)
        /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/ld-linux-x86-64.so.2 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib64/ld-linux-x86-64.so.2 (0x00007f0a7f63f000)
```

*/