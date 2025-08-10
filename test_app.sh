#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Command failed: $BASH_COMMAND"; exit 1' ERR

echo "🚀 Testing Nihongo App on both iOS and Android"

# Ensure Flutter is installed
if ! command -v flutter &>/dev/null; then
  echo "❌ Flutter is not installed. Please install Flutter: https://docs.flutter.dev/get-started/install"
  exit 1
fi

echo "📋 Checking Flutter doctor..."
flutter doctor

echo
echo "🧹 Cleaning project..."
flutter clean

echo
echo "📦 Getting dependencies..."
flutter pub get

echo
echo "🔍 Running static analysis..."
flutter analyze

echo
echo "🧪 Running tests with coverage..."
flutter test --coverage

if [[ "$(uname)" == "Darwin" ]]; then
  echo
  echo "🏗️  Testing iOS build..."
  flutter build ios --no-codesign
  echo "✅ iOS build successful!"
fi

echo
echo "🏗️  Testing Android build..."
flutter build apk
echo "✅ Android build successful!"

echo
echo "🎉 All builds completed successfully!"
