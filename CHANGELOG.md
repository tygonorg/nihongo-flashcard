# Changelog

## [0.2.0] - 2025-08-09

### 🔥 Major Changes
- **BREAKING:** Replaced Realm with SQLite for better iOS/Android compatibility
- **BREAKING:** No more code generation required - simplified development workflow

### ✅ Fixed
- **iOS Crash Fix:** Resolved "Cannot get app directory" error on iOS simulator
- **Cross-platform Stability:** App now works reliably on both iOS and Android
- **Database Initialization:** Improved error handling and auto-recovery

### ✨ Added
- SQLite-based database with automatic schema creation
- Better async/await support throughout the app
- Improved error messages and user feedback
- Loading states with FutureBuilder in UI
- Database migration handling

### 🛠️ Technical Changes
- Migrated from `realm_dart` to `sqflite`
- Updated all database operations to async methods
- Simplified Vocab and ReviewLog models with toMap/fromMap
- Updated UI screens to use FutureBuilder for data loading
- Improved RealmService (now SQLiteService) with better error handling

### 📱 Platform Support
- **iOS:** ✅ Minimum iOS 12.0, tested on iOS Simulator
- **Android:** ✅ Minimum API 21 (Android 5.0)
- **Dependencies:** Updated NDK version and build configurations

### 🧪 Testing
- Fixed all unit tests to work with new async methods
- Added comprehensive build testing script
- Both iOS and Android builds passing

### 📚 Documentation
- Updated README with SQLite-specific instructions
- Removed Realm-specific troubleshooting steps
- Added new installation and setup guide
- Updated project structure documentation

---

## [0.1.0] - 2025-07-25

### 🎉 Initial Release
- Flutter app for Japanese vocabulary learning
- Realm database integration
- SRS (Spaced Repetition System) algorithm
- Flashcards and quiz functionality
- JLPT level organization (N5-N1)
- Basic statistics and progress tracking

### Features
- Add/Edit vocabulary words
- Flashcard review system
- Multiple choice quizzes
- Statistics dashboard
- Level-based filtering
- SRS algorithm for optimal learning intervals

### Technical Stack
- Flutter 3.4.0+
- Realm database
- Riverpod state management
- Go Router navigation
- Material Design 3

---

## Legend
- 🔥 Major/Breaking Changes
- ✅ Bug Fixes
- ✨ New Features
- 🛠️ Technical Changes
- 📱 Platform Support
- 🧪 Testing
- 📚 Documentation
