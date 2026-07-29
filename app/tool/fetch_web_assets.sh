#!/usr/bin/env bash
# Downloads the runtime binaries the Web (PWA) target needs into web/.
#
# These are build artifacts, not source, so they are fetched rather than
# committed. Run before `flutter build web`.
set -euo pipefail

DRIFT_VERSION="${DRIFT_VERSION:-2.28.0}"
SQLITE3_VERSION="${SQLITE3_VERSION:-2.9.0}"
WEB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/web"

mkdir -p "$WEB_DIR"

echo "Fetching sqlite3.wasm (sqlite3 ${SQLITE3_VERSION})…"
curl -sSfL -o "$WEB_DIR/sqlite3.wasm" \
  "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-${SQLITE3_VERSION}/sqlite3.wasm"

echo "Fetching drift_worker.js (drift ${DRIFT_VERSION})…"
curl -sSfL -o "$WEB_DIR/drift_worker.js" \
  "https://github.com/simolus3/drift/releases/download/drift-${DRIFT_VERSION}/drift_worker.js"

echo "Web assets ready in $WEB_DIR"
