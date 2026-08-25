#!/usr/bin/env bash

set -euo pipefail

readonly expected_version="${1:-$(nix eval --raw --file version.nix version)}"

nix flake check --no-build
result_path="$(nix build --no-link --print-out-paths .#moshi-hook)"
actual_version="$(timeout 60 "$result_path/bin/moshi-hook" --version)"
[[ "$actual_version" == "moshi-hook version $expected_version" ]] || {
  printf 'Unexpected version: %s\n' "$actual_version" >&2
  exit 1
}
