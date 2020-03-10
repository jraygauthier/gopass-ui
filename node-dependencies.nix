{ system
, lib
, stdenv
, fetchgit
, fetchurl
, runCommand
, writeTextFile
, electron_5
, electron-chromedriver_3 ? null
, gifsicle
, jq
, libwebp
, mozjpeg
, nodejs-10_x
, optipng
, p7zip
, pngquant
, python2
, utillinux
, gopass-ui-src
}:

let
  nodePackages = import ./node-composition.nix {
    inherit system;
    nodejs = nodejs-10_x;
    pkgs = {
      inherit fetchurl fetchgit;
      inherit stdenv python2 utillinux runCommand writeTextFile;
    };
  };

  electron = electron_5;
  electron-chromedriver = electron-chromedriver_3;
  # This file is written by `node_modules/electron/install.js::extractFile`
  # and seems to be mandatory for the package to recognise that the bin dist
  # has been properly installed.
  electronPathTxtFile = writeTextFile (
    let
      platform = lib.lists.last (builtins.split "-" system);
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

  buildInputs = [
    # Patching various `package.json` files.
    jq
  ];

  preRebuild = ''
    post_install_package_scripts_remove() {
      local pkg_dir="''${1?}"

      mv "$pkg_dir/package.json" "$pkg_dir/package-old.json"
      cat "$pkg_dir/package-old.json" | jq 'del(.scripts)' > "$pkg_dir/package.json"
      rm "$pkg_dir/package-old.json"
    }

    post_install_vendor_bin_script_patch() {
      local pkg_dir="''${1?}"
      local vendor_bin_in="''${2?}"
      local vendor_bin_out="''${3?}"

      local vendor_bin_dir
      vendor_bin_dir="$(dirname "$vendor_bin_out")"

      mkdir -p "$vendor_bin_dir"
      ln -f -s -T "$vendor_bin_in" "$vendor_bin_out"

      post_install_package_scripts_remove "$pkg_dir"
    }

    # Now using 'dontNpmInstall' instead.
    # post_install_package_scripts_remove "."


    pngquant_post_install_script_patch() {
      local pkg_dir="./node_modules/pngquant-bin"
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${pngquant}/bin/pngquant" "$pkg_dir/vendor/pngquant"
    }

    pngquant_post_install_script_patch


    optipng_post_install_script_patch() {
      local pkg_dir="./node_modules/optipng-bin"
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${optipng}/bin/optipng" "$pkg_dir/vendor/optipng"
    }

    optipng_post_install_script_patch


    cwebp_post_install_script_patch() {
      local pkg_dir="./node_modules/cwebp-bin"
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${libwebp}/bin/cwebp" "$pkg_dir/vendor/cwebp"
    }

    cwebp_post_install_script_patch

    mozjpeg_post_install_script_patch() {
      local pkg_dir="./node_modules/mozjpeg"
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${mozjpeg}/bin/cjpeg" "$pkg_dir/vendor/cjpeg"
    }

    mozjpeg_post_install_script_patch

    electron_cd_post_install_script_patch() {
      local pkg_dir="./node_modules/electron-chromedriver"
      ${if null == electron-chromedriver
        then ''
          post_install_package_scripts_remove "$pkg_dir"
        ''
        else ''
          post_install_vendor_bin_script_patch "$pkg_dir" \
            "${electron-chromedriver}/bin" "$pkg_dir/bin"
        ''
      }
    }

    electron_cd_post_install_script_patch


    electron_post_install_script_patch() {
      local pkg_dir="./node_modules/electron"
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${electron}/bin" "$pkg_dir/dist"

      cp "${electronPathTxtFile}" "$pkg_dir/path.txt"
    }

    electron_post_install_script_patch


    gifsicle_post_install_script_patch() {
      local pkg_dir="./node_modules/gifsicle"
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${gifsicle}/bin/gifsicle" "$pkg_dir/vendor/gifsicle"
    }

    gifsicle_post_install_script_patch

    p7zip_bin_post_install_script_patch() {
      # local pkg_dir="."
      local pkg_dir="./node_modules/7zip-bin"
      rm -f "$pkg_dir/linux/x64/7za"
      post_install_vendor_bin_script_patch "$pkg_dir" \
        "${p7zip}/bin/7za" "$pkg_dir/linux/x64/7za"
    }

    p7zip_bin_post_install_script_patch
  '';

  # As we're only interested by the dependencies (at the point)
  # we keep only the package and packaeg lock files. This
  # will allow us to edit the sources without our dev environment
  # being rebuilt each time.
  srcFilter = inSrc: lib.sources.sourceByRegex inSrc [
      "^package-lock.json$"
      "^package.json$"
    ];

  filteredSrc = srcFilter gopass-ui-src;

in

nodePackages // {
  package = nodePackages.package.override {
    src = filteredSrc;
    inherit buildInputs preRebuild;
    dontNpmInstall = true;
  };

  shell = nodePackages.shell.override {
    src = filteredSrc;
    inherit buildInputs preRebuild;
    dontNpmInstall = true;
  };
}