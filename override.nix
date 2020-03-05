{pkgs ? import <nixpkgs> {
  inherit system;
}, system ? builtins.currentSystem}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };

  inherit (import ./electron-bin-fetchers.nix { inherit pkgs system; })
    electron-chromedriver electron;

  buildInputs = with pkgs; [
    # tree

    # Patching various `package.json` files.
    jq
  ];

  preRebuild = ''
    # wrapProgram $out/bin/dnschain --suffix PATH : ${pkgs.openssl.bin}/bin
    # 1>&2 tree
    # false

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


    pngquant_post_install_script_patch() {
      # local pkg_dir="."
      local pkg_dir="./node_modules/pngquant-bin"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pkgs.pngquant}/bin/pngquant" "$pkg_dir/vendor/pngquant"
    }

    pngquant_post_install_script_patch


    optipng_post_install_script_patch() {
      # local pkg_dir="."
      local pkg_dir="./node_modules/optipng-bin"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pkgs.optipng}/bin/optipng" "$pkg_dir/vendor/optipng"
    }

    optipng_post_install_script_patch


    cwebp_post_install_script_patch() {
      # local pkg_dir="."
      local pkg_dir="./node_modules/cwebp-bin"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pkgs.libwebp}/bin/cwebp" "$pkg_dir/vendor/cwebp"
    }

    cwebp_post_install_script_patch

    mozjpeg_post_install_script_patch() {
      # local pkg_dir="."
      local pkg_dir="./node_modules/mozjpeg"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pkgs.mozjpeg}/bin/cjpeg" "$pkg_dir/vendor/cjpeg"
    }

    mozjpeg_post_install_script_patch

    electron_cd_post_install_script_patch() {
      # local pkg_dir="."
      local pkg_dir="./node_modules/electron-chromedriver"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${electron-chromedriver}/bin" "$pkg_dir/bin"
    }

    electron_cd_post_install_script_patch


    electron_post_install_script_patch() {
      # local pkg_dir="."
      local pkg_dir="./node_modules/electron"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${electron}/bin" "$pkg_dir/dist"

      cp "${electron.pathTxtFile}" "$pkg_dir/path.txt"
    }

    electron_post_install_script_patch


    gifsicle_post_install_script_patch() {
      # local pkg_dir="."
      local pkg_dir="./node_modules/gifsicle"

      # TODO: Improve by downloading the same version as the package.
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pkgs.gifsicle}/bin/gifsicle" "$pkg_dir/vendor/gifsicle"
    }

    gifsicle_post_install_script_patch
  '';

in

nodePackages // {
  package = nodePackages.package.override {
    inherit buildInputs preRebuild;
  };

  shell = nodePackages.shell.override {
    inherit buildInputs preRebuild;
  };
}


/*

node_modules/pngquant-bin
*/


/*
```bash
$ nix-build override.nix -A package
# ..
> fsevents@1.2.7 install /nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/jest-haste-map/node_modules/fsevents
> node install

...............] - : info lifecycle fsevents@1.2.7~install: fsevents@1.2.7[0m
> gifsicle@4.0.1 postinstall /nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/gifsicle
> node lib/install.js

  ⚠ getaddrinfo ENOTFOUND raw.githubusercontent.com raw.githubusercontent.com:443
  ⚠ gifsicle pre-build test failed
  ℹ compiling from source
  ✔ gifsicle built successfully
...............] | : info lifecycle gifsicle@4.0.1~postinstall: gifsicle@4.[0m
> mozjpeg@6.0.1 postinstall /nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/mozjpeg
> node lib/install.js

  ⚠ getaddrinfo ENOTFOUND raw.githubusercontent.com raw.githubusercontent.com:443
  ⚠ mozjpeg pre-build test failed
  ℹ compiling from source
  ✖ RequestError: getaddrinfo ENOTFOUND github.com github.com:443
    at ClientRequest.req.once.err (/nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/download/node_modules/got/index.js:111:21)
    at Object.onceWrapper (events.js:286:20)
    at ClientRequest.emit (events.js:198:13)
    at TLSSocket.socketErrorListener (_http_client.js:392:9)
    at TLSSocket.emit (events.js:198:13)
    at emitErrorNT (internal/streams/destroy.js:91:8)
    at emitErrorAndCloseNT (internal/streams/destroy.js:59:3)
    at process._tickCallback (internal/process/next_tick.js:63:19)

> optipng-bin@5.1.0 postinstall /nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/optipng-bin
> node lib/install.js

  ⚠ getaddrinfo ENOTFOUND raw.githubusercontent.com raw.githubusercontent.com:443
  ⚠ optipng pre-build test failed
  ℹ compiling from source
  ✖ RequestError: getaddrinfo ENOTFOUND downloads.sourceforge.net downloads.sourceforge.net:443
    at ClientRequest.req.once.err (/nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/download/node_modules/got/index.js:111:21)
    at Object.onceWrapper (events.js:286:20)
    at ClientRequest.emit (events.js:198:13)
    at TLSSocket.socketErrorListener (_http_client.js:392:9)
    at TLSSocket.emit (events.js:198:13)
    at emitErrorNT (internal/streams/destroy.js:91:8)
    at emitErrorAndCloseNT (internal/streams/destroy.js:59:3)
    at process._tickCallback (internal/process/next_tick.js:63:19)

> cwebp-bin@5.0.0 postinstall /nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/cwebp-bin
> node lib/install.js

  ⚠ getaddrinfo ENOTFOUND raw.githubusercontent.com raw.githubusercontent.com:443
  ⚠ cwebp pre-build test failed
  ℹ compiling from source
  ✖ RequestError: getaddrinfo ENOTFOUND downloads.webmproject.org downloads.webmproject.org:80
    at ClientRequest.req.once.err (/nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/download/node_modules/got/index.js:111:21)
    at Object.onceWrapper (events.js:286:20)
    at ClientRequest.emit (events.js:198:13)
    at Socket.socketErrorListener (_http_client.js:392:9)
    at Socket.emit (events.js:198:13)
    at emitErrorNT (internal/streams/destroy.js:91:8)
    at emitErrorAndCloseNT (internal/streams/destroy.js:59:3)
    at process._tickCallback (internal/process/next_tick.js:63:19)
...............] \ : info lifecycle cwebp-bin@5.0.0~postinstall: cwebp-bin@[0m
> electron-chromedriver@3.0.0 install /nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/electron-chromedriver
> node ./download-chromedriver.js

/nix/store/yb00gyjamhha605873yrx1713215qy8p-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/electron-chromedriver/download-chromedriver.js:19
  if (err != null) throw err
                   ^

Error: getaddrinfo ENOTFOUND github.com github.com:443
    at GetAddrInfoReqWrap.onlookup [as oncomplete] (dns.js:56:26)
npm ERR! code ELIFECYCLE
npm ERR! errno 1
npm ERR! electron-chromedriver@3.0.0 install: `node ./download-chromedriver.js`
npm ERR! Exit status 1
npm ERR!
npm ERR! Failed at the electron-chromedriver@3.0.0 install script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     /build/.npm/_logs/2020-03-04T21_51_46_284Z-debug.log

builder for '/nix/store/czgzk4jghh3h00n97vj0r63x4545cm2b-node_gopass-ui-0.6.0.drv' failed with exit code 1
error: build of '/nix/store/czgzk4jghh3h00n97vj0r63x4545cm2b-node_gopass-ui-0.6.0.drv' failed
```


```
enhanced-resolve@4.1.0 /nix/store/h4f8bjh7r5dbxa6dqsyn1qnsgcjhcrlr-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/webpack/node_modules/enhanced-resolve
tapable@1.1.1 /nix/store/h4f8bjh7r5dbxa6dqsyn1qnsgcjhcrlr-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/webpack/node_modules/tapable
   ...........] - postinstall: sill install executeActions0mTreeK
> gopass-ui@0.6.0 postinstall /nix/store/h4f8bjh7r5dbxa6dqsyn1qnsgcjhcrlr-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui
> electron-builder install-app-deps

sh: /nix/store/h4f8bjh7r5dbxa6dqsyn1qnsgcjhcrlr-node_gopass-ui-0.6.0/lib/node_modules/gopass-ui/node_modules/.bin/electron-builder: /usr/bin/env: bad interpreter: No such file or directory
npm ERR! code ELIFECYCLE
npm ERR! errno 126
npm ERR! gopass-ui@0.6.0 postinstall: `electron-builder install-app-deps`
npm ERR! Exit status 126
npm ERR!
npm ERR! Failed at the gopass-ui@0.6.0 postinstall script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     /build/.npm/_logs/2020-03-05T02_56_55_259Z-debug.log

builder for '/nix/store/zrwxyrz2gl7j6vsal0apdnzwlwpq9smm-node_gopass-ui-0.6.0.drv' failed with exit code 126
error: build of '/nix/store/zrwxyrz2gl7j6vsal0apdnzwlwpq9smm-node_gopass-ui-0.6.0.drv' failed
```

Removed the scripts from the current pkg.

See `package-removed.md` for the removed content.

```
$ electron --version
events.js:174
      throw er; // Unhandled 'error' event
      ^

Error: spawn /nix/store/2y9dj49q3wwi7vmvmczv1ppsrrj9c9zi-node-dependencies-gopass-ui-0.6.0/lib/node_modules/electron/dist/electron
 ENOENT
    at Process.ChildProcess._handle.onexit (internal/child_process.js:240:19)
    at onErrorNT (internal/child_process.js:415:16)
    at process._tickCallback (internal/process/next_tick.js:63:19)
    at Function.Module.runMain (internal/modules/cjs/loader.js:834:11)
    at startup (internal/bootstrap/node.js:283:19)
    at bootstrapNodeJSCore (internal/bootstrap/node.js:623:3)
Emitted 'error' event at:
    at Process.ChildProcess._handle.onexit (internal/child_process.js:246:12)
    at onErrorNT (internal/child_process.js:415:16)
    [... lines matching original stack trace ...]
    at bootstrapNodeJSCore (internal/bootstrap/node.js:623:3)
```

*/