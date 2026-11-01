#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

if [[ "$(uname -s)" == "Linux" && -d /usr/share/glib-2.0/schemas ]]; then
  export GSETTINGS_SCHEMA_DIR
  GSETTINGS_SCHEMA_DIR="$(python3 tool/prepare_chrome_schemas.py)"
fi

exec flutter run -d chrome "$@"
