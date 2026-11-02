#!/usr/bin/env bash
set -euo pipefail

readonly flutter_version="3.41.6"
readonly flutter_home="${FLUTTER_HOME:-${HOME}/.cache/flutter-${flutter_version}}"

if command -v flutter >/dev/null 2>&1; then
  flutter_bin="$(command -v flutter)"
elif [[ -x "${flutter_home}/bin/flutter" ]]; then
  flutter_bin="${flutter_home}/bin/flutter"
else
  mkdir -p "${HOME}/.cache"
  archive="$(mktemp "${TMPDIR:-/tmp}/flutter-${flutter_version}.XXXXXX.tar.xz")"
  trap 'rm -f "$archive"' EXIT

  curl --fail --location --retry 3 --silent --show-error \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz" \
    --output "$archive"
  mkdir -p "$flutter_home"
  tar -xJf "$archive" --strip-components=1 -C "$flutter_home"
  flutter_bin="${flutter_home}/bin/flutter"
fi

export PATH="$(dirname "$flutter_bin"):${PATH}"
flutter_root="$(cd "$(dirname "$flutter_bin")/.." && pwd)"
git config --global --add safe.directory "$flutter_root"

case "${1:-build}" in
  install)
    flutter pub get
    ;;
  build)
    flutter pub get
    flutter build web --release --no-wasm-dry-run
    ;;
  *)
    echo "Usage: $0 [install|build]" >&2
    exit 2
    ;;
esac
