{pkgs ? import <nixpkgs> {
  inherit system;
}, system ? builtins.currentSystem}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };

  inherit (import ./electron-bin-fetchers.nix { inherit pkgs system; }) electron-chromedriver;
in
nodePackages // {
  package = nodePackages.package.override {
    buildInputs = with pkgs; [
      tree
      jq
    ];
    preRebuild = ''
    post_install_vendor_bin_script_patch() {
      local pkg_dir="''${1?}"
      local vendor_bin_in="''${2?}"
      local vendor_bin_out="''${3?}"

      mkdir -p "$pkg_dir/vendor"
      ln -f -s -T "$vendor_bin_in" "$vendor_bin_out"

      mv "$pkg_dir/package.json" "$pkg_dir/package-old.json"
      cat "$pkg_dir/package-old.json" | jq 'del(.scripts)' > "$pkg_dir/package.json"
      rm "$pkg_dir/package-old.json"
    }

    electron_cd_post_install_script_patch() {
      local pkg_dir="."
      # local pkg_dir="./node_modules/electron-chromedriver"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${electron-chromedriver}/bin" "$pkg_dir/bin"
    }

    electron_cd_post_install_script_patch
    '';
  };
}


/*
nix-shell -p nodePackages.npm -p nodePackages.webpack -p nodePackages.node2nix -p electron_5 -p nodejs-10_x -p tree
node2nix --nodejs-10 -i package.json
nix-build override.nix -A package

node_modules/electron-chromedriver/bin/chromedriver
node_modules/electron-chromedriver/bin/LICENSE
node_modules/electron-chromedriver/bin/LICENSES.chromium.html

```
$ node -e 'console.log(process.arch)'
x64

$ node -e 'console.log(os.platform())'
linux
```

From the `electron-download` package:

`"version": "3.0.0"`

`${this.baseUrl}${this.middleUrl}/${this.urlSuffix}`

baseUrl = `https://github.com/electron/electron/releases/download/v`

middleUrl = version

middleUrl = 3.0.0

urlSuffix = `chromedriver-v${this.version}-${this.platform}-${this.arch}.zip`


https://github.com/electron/electron/releases/download/v4.1.1/chromedriver-v4.1.1-linux-x64.zip

```
$ nix-prefetch-url --unpack https://github.com/electron/electron/releases/download/v4.1.1/chromedriver-v4.1.1-linux-x64.zip
unpacking...
Ä8.4 MiB DLÅ
path is '/nix/store/cs08qhm1c50dsd97ad9d73zlrcm1ywhl-chromedriver-v4.1.1-linux-x64.zip'
0jj53n3fnmj7ccvc92i2s8f5729ws8yzr6x7w7337z4w0n4fyq5x

Änix-shell:ü/dev/gopass-ui/fixdeps/electron-chromedriver/packageÅ$ file /nix/store/cs08qhm1c50dsd97ad9d73zlrcm1ywhl-chromedriver-v4.1.1-linux-x64.zip/chromedriver /nix/store/cs08qhm1c50dsd97ad9d73zlrcm1ywhl-chromedriver-v4.1.1-linux-x64.zip/chromedriver: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildIDÄsha1Å=cd13c2ad57331cde1da92a9c014e6de8db98049e, stripped

Änix-shell:ü/dev/gopass-ui/fixdeps/electron-chromedriver/packageÅ$ ldd /nix/store/cs08qhm1c50dsd97ad9d73zlrcm1ywhl-chromedriver-v4.1.1-linux-x64.zip/chromedriver         linux-vdso.so.1 (0x00007ffd0b396000)
        libdl.so.2 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libdl.so.2 (0x00007f6b6e40c000)
        libpthread.so.0 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libpthread.so.0 (0x00007f6b6e3eb000)
        librt.so.1 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/librt.so.1 (0x00007f6b6e3e1000)
        libglib-2.0.so.0 => not found
        libX11.so.6 => not found
        libnss3.so => not found
        libnssutil3.so => not found
        libnspr4.so => not found
        libm.so.6 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libm.so.6 (0x00007f6b6e249000)
        libgcc_s.so.1 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libgcc_s.so.1 (0x00007f6b6e033000)
        libc.so.6 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/libc.so.6 (0x00007f6b6de7d000)
        /lib64/ld-linux-x86-64.so.2 => /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib64/ld-linux-x86-64.so.2 (0x00007f6b6e413000)
```
*/


