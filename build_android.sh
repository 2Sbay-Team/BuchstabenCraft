#!/usr/bin/env bash
set -euo pipefail
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")"
"$GODOT" --headless --path . --editor --import --quit
"$GODOT" --headless --path . --script res://tests/smoke.gd
mkdir -p build
"$GODOT" --headless --path . --export-debug Android build/BuchstabenCraft.apk
printf 'APK created: %s\n' "$(pwd)/build/BuchstabenCraft.apk"
