#!/usr/bin/env bash
set -euo pipefail

TARGET="${APP_TARGET:-lib/main_user.dart}"
echo "=== Building CIJ Flutter Web target: ${TARGET} ==="

if [ ! -d flutter ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get
flutter/bin/flutter build web --release --no-wasm-dry-run -t "${TARGET}"
