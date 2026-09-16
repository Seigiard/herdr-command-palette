#!/usr/bin/env bash
set -euo pipefail

version=0.9.0
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)
    asset=herdr-linux-x86_64
    sha256=4fa1a01158dd8043da92d31b270780b0dcc10603038d9b61cac4d81ab63fb71f
    ;;
  Darwin-arm64)
    asset=herdr-macos-aarch64
    sha256=32b53df09872628059c789a69f02a6b8e29e14ddf26711421f3463f70c1aef17
    ;;
  Darwin-x86_64)
    asset=herdr-macos-x86_64
    sha256=d0c920b2a126a74809fa1491411c9a097a44786cac9c2ca51b818a995581cf16
    ;;
  *)
    printf 'Unsupported runner: %s-%s\n' "$(uname -s)" "$(uname -m)" >&2
    exit 1
    ;;
esac

mkdir -p "$HOME/.local/bin"
destination="$HOME/.local/bin/herdr"
curl --fail --location --silent --show-error \
  "https://github.com/herdrdev/herdr/releases/download/v${version}/${asset}" \
  --output "$destination"
actual="$(shasum -a 256 "$destination" | cut -d ' ' -f 1)"
test "$actual" = "$sha256"
chmod +x "$destination"
echo "$HOME/.local/bin" >> "$GITHUB_PATH"
