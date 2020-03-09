#!/usr/bin/env nix-shell
#!nix-shell -p nodePackages.node2nix -i bash
set -euf -o pipefail

src_dir="${1:-"."}"
out_dir="."

node2nix --development --nodejs-10 \
  -l "$src_dir/package-lock.json" \
  --node-env "$out_dir/node-env.nix" \
  --output "$out_dir/node-packages.nix" \
  --composition "$out_dir/node-composition.nix"
