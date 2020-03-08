{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {inherit system;}
, system ? builtins.currentSystem
, nodejs ? import ./custom-nodejs.nix {inherit nixpkgs pkgs system;}
}:

with pkgs;

let
  nodePackages = import ./default.nix {
    inherit pkgs system nodejs;
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


  /*
  srcFilter = inSrc: nix-gitignore.gitignoreSourcePure [
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
      ''
    ] inSrc;
  */

  # As we're only interested by the dependencies (at the point)
  # we keep only the package and packaeg lock files. This
  # will allow us to edit the sources without our dev environment
  # being rebuilt each time.
  srcFilter = inSrc: lib.sources.sourceByRegex inSrc [
      "^package-lock.json$"
      "^package.json$"
    ];

in

nodePackages // {
  package = nodePackages.package.override {
    /*
      /package-lock.json
    */
    src = srcFilter ./.;
    inherit buildInputs preRebuild;
    dontNpmInstall = true;
  };

  shell = nodePackages.shell.override {
    src = srcFilter ./.;
    inherit buildInputs preRebuild;
    dontNpmInstall = true;
  };
}
