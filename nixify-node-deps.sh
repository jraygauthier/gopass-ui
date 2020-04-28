#!/usr/bin/env nix-shell
#!nix-shell -p nodePackages.node2nix -i bash
set -euf -o pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"

src_dir="${1:-"."}"
out_dir="${2:-"$script_dir"}"

if [[ -e "$src_dir/node_modules" ]]; then
  if ! unlink "$src_dir/node_modules"; then
    printf "%s\n -> %s\n" \
      "ERROR: Non symlink '$src_dir/node_modules' directory in the way." \
      "Please move / remove '$src_dir/node_modules' manually."
    exit 1
  fi
fi

node2nix_args=( --development --nodejs-12 \
  -i "$src_dir/package.json" \
  -l "$src_dir/package-lock.json" \
  --node-env "$out_dir/node-env.nix" \
  --output "$out_dir/node-packages.nix" \
  --composition "$out_dir/node-composition.nix" \
)


echo "node2nix" "${node2nix_args[@]}"
node2nix "${node2nix_args[@]}"