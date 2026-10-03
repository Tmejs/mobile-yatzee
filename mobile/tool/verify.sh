#!/usr/bin/env bash
set -euo pipefail
flutter pub get
FORMAT_PATHS=(lib test)
if [[ -d integration_test ]]; then
  FORMAT_PATHS+=(integration_test)
fi
dart format --output=none --set-exit-if-changed "${FORMAT_PATHS[@]}"
flutter analyze
flutter test
