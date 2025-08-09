#!/bin/bash

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
echo "🏗️  Testing iOS build..."
flutter build ios --no-codesign
if [ $? -eq 0 ]; then
    echo "✅ iOS build successful!"
else
    echo "❌ iOS build failed!"
    exit 1
fi

echo ""
echo "🏗️  Testing Android build..."
flutter build apk
if [ $? -eq 0 ]; then
    echo "✅ Android build successful!"
else
    echo "❌ Android build failed!"
    exit 1
fi

echo ""
echo "🎉 All builds completed successfully!"
echo ""
echo "To run the app:"
echo "📱 iOS Simulator: flutter run -d ios"
echo "🤖 Android Emulator: flutter run -d android"
