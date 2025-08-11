#!/usr/bin/env bash
###############################################################################
# Setup script per CI Flutter (tarball) – versione persistente
###############################################################################
set -euxo pipefail

WORKSPACE="${WORKSPACE:-/workspace}"
PROJECT_DIR="$(grep -Rl --include=pubspec.yaml -e 'sdk:[[:space:]]*flutter' "$WORKSPACE" | head -n1 | xargs dirname)"
APP_NAME="$(basename "$PROJECT_DIR")"

# ── 1. Scarica Flutter solo la prima volta ───────────────────────────────────
FLUTTER_VERSION="3.32.2"
FLUTTER_SDK_INSTALL_DIR="$HOME/flutter"
FLUTTER_TARBALL_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [[ ! -d "$FLUTTER_SDK_INSTALL_DIR" ]]; then
  echo "📦  Download Flutter $FLUTTER_VERSION …"
  curl -sL "$FLUTTER_TARBALL_URL" | tar -xJ -C "$HOME"
else
  echo "⚠️   Cache Flutter già presente → $FLUTTER_SDK_INSTALL_DIR"
fi

# Evita “dubious ownership”
git config --global --add safe.directory "$FLUTTER_SDK_INSTALL_DIR"

# ── 2. Rendi flutter/dart visibili a TUTTI gli step ──────────────────────────
export PATH="$FLUTTER_SDK_INSTALL_DIR/bin:$PATH"

# copia (o symlink) in /usr/local/bin, che è sempre nel PATH di default
sudo ln -sf "$FLUTTER_SDK_INSTALL_DIR/bin/flutter" /usr/local/bin/flutter
sudo ln -sf "$FLUTTER_SDK_INSTALL_DIR/bin/dart"    /usr/local/bin/dart

# verifica immediata
flutter --version
dart --version

# ── 3. Pre-cache minimal (solo linux desktop) ────────────────────────────────
flutter precache --linux --no-web --no-ios --no-android --no-windows --no-macos

# ── 4. Dipendenze progetto ───────────────────────────────────────────────────
cd "$PROJECT_DIR"
flutter pub get

# ── 5. build_runner se servono i file generati ───────────────────────────────
if grep -R --include='*.dart' -e 'part .*\.g\.dart' lib >/dev/null; then
  dart run build_runner build --delete-conflicting-outputs --build-filter="lib/**"
fi

echo "✅  Script completato per $APP_NAME"