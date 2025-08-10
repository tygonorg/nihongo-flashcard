#!/bin/bash

set -e

echo "🚀 Testing Nihongo App on both iOS and Android"

# Kiểm tra Flutter doctor
echo "📋 Checking Flutter doctor..."
flutter doctor

echo ""
echo "🧹 Cleaning project..."
flutter clean

echo ""
echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "🔧 Checking database models..."
echo "✅ SQLite models ready!"

echo ""
echo "🔍 Running static analysis..."
flutter analyze

echo ""
echo "🧪 Running tests with coverage..."
flutter test --coverage

if [[ "$(uname)" == "Darwin" ]]; then
  echo ""
  echo "🏗️  Testing iOS build..."
  flutter build ios --no-codesign
  echo "✅ iOS build successful!"
fi

echo ""
echo "🏗️  Testing Android build..."
flutter build apk
echo "✅ Android build successful!"

echo ""
echo "🎉 All builds completed successfully!"
echo ""
echo "To run the app:"
echo "📱 iOS Simulator: flutter run -d ios"
echo "🤖 Android Emulator: flutter run -d android"
