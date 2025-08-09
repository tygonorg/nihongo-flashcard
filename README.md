# Nihongo - Ứng dụng học từ vựng tiếng Nhật

Ứng dụng Flutter quản lý từ vựng tiếng Nhật với hệ thống SRS (Spaced Repetition System) và flashcards.

## ✨ Tính năng

- 📚 Quản lý từ vựng theo cấp độ JLPT (N5-N1)
- 🔄 Hệ thống ôn tập theo khoảng cách (SRS)
- 📱 Flashcards tương tác
- 📊 Thống kê học tập
- 🎯 Quiz và kiểm tra

## 🛠️ Yêu cầu hệ thống

- Flutter SDK >= 3.4.0
- Dart >= 3.4.0
- iOS >= 12.0
- Android >= API 21 (Android 5.0)

## 🚀 Cài đặt và chạy

### 1. Clone repository
```bash
git clone <repository-url>
cd nihongo
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Kiểm tra database
```bash
# SQLite đã sẵn sàng, không cần generate code
echo "Database ready!"
```

### 4. Chạy ứng dụng

**iOS:**
```bash
flutter run -d ios
```

**Android:**
```bash
flutter run -d android
```

### 5. Build release

**iOS:**
```bash
flutter build ios --release
```

**Android:**
```bash
flutter build apk --release
```

## 🧪 Testing

Chạy script test tự động:
```bash
./test_app.sh
```

Hoặc test từng bước:
```bash
# Phân tích mã nguồn
flutter analyze

# Chạy unit tests
flutter test

# Build iOS
flutter build ios --no-codesign

# Build Android
flutter build apk
```

## 🔧 Khắc phục sự cố

### Lỗi Realm không khởi tạo được

1. **Xóa và tạo lại database:**
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Reset app data (iOS Simulator):**
   - Device > Erase All Content and Settings

3. **Reset app data (Android Emulator):**
   - Settings > Apps > Nihongo > Storage > Clear Data

### Lỗi build iOS

1. **Cập nhật CocoaPods:**
   ```bash
   cd ios
   pod install --repo-update
   ```

2. **Clean Xcode build:**
   ```bash
   cd ios
   rm -rf Pods/
   rm Podfile.lock
   pod install
   ```

### Lỗi build Android

1. **Clean Gradle cache:**
   ```bash
   cd android
   ./gradlew clean
   ```

2. **Invalidate caches và restart Android Studio**

## 📁 Cấu trúc dự án

```
lib/
├── models/           # Data models
├── services/         # Business logic
├── providers/        # Riverpod providers
├── ui/
│   ├── screens/     # Màn hình chính
│   └── widgets/     # UI components
├── router.dart      # Navigation routes
├── theme.dart       # App theming
├── app.dart         # Main app widget
└── main.dart        # Entry point
```

## 🔄 Cách thêm từ vựng mới

1. Mở ứng dụng
2. Nhấn nút "+" hoặc đi tới màn hình danh sách từ vựng
3. Điền thông tin:
   - **Từ:** Kanji/Kana
   - **Nghĩa:** Tiếng Việt/Anh
   - **Cấp độ:** N5, N4, N3, N2, N1
   - **Ghi chú:** (tùy chọn)
4. Nhấn "Lưu"

## 📚 Sử dụng SRS (Spaced Repetition System)

1. Các từ mới sẽ xuất hiện trong phần "Ôn tập"
2. Đánh giá mức độ nhớ từ 0-5:
   - 0-2: Khó nhớ (sẽ xuất hiện lại sớm)
   - 3-5: Dễ nhớ (khoảng cách ôn tập sẽ tăng)
3. Hệ thống tự động tính toán lịch ôn tập tối ưu

## 🎨 Customization

### Thay đổi theme
Chỉnh sửa `lib/theme.dart` để thay đổi màu sắc và font chữ.

### Thêm preset từ vựng
Thêm file JSON vào `assets/presets/` và cập nhật `lib/services/preset_loader.dart`.

## 🤝 Đóng góp

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 License

Dự án này được phân phối dưới MIT License. Xem file `LICENSE` để biết thêm chi tiết.

## 📞 Hỗ trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra phần "Khắc phục sự cố" ở trên
2. Chạy `flutter doctor -v` để kiểm tra môi trường
3. Tạo issue trên GitHub với thông tin chi tiết lỗi

---

**Chúc bạn học tiếng Nhật vui vẻ! がんばって！** 🇯🇵

# Nihongo MVP (Flutter + SQLite + SRS)

Ứng dụng học từ vựng tiếng Nhật: quản lý JLPT, flashcards, trắc nghiệm, thống kê + thuật toán SRS (SM-2 rút gọn).

## Cài đặt nhanh
```bash
flutter pub get
flutter run
```

## Cấu trúc
- `lib/models/vocab.dart`: SQLite models (không cần generate)
- `lib/services/realm_service.dart`: SQLite CRUD + query + due list
- `lib/services/srs_service.dart`: SM-2 rút gọn
- `lib/services/preset_loader.dart`: import JSON
- `lib/providers/providers.dart`: Riverpod providers
- `lib/ui/screens/*`: Home, List, Add/Edit, Flashcards, Quiz, Stats
- `lib/ui/widgets/*`: LevelChip, VocabTile, StatCard
- `assets/presets/n5.json`: dữ liệu mẫu N5

## Thay đổi chính
- **✅ Thay thế Realm bằng SQLite**: ổn định hơn trên iOS/Android
- **✅ Không cần code generation**: Models đơn giản với toMap/fromMap
- **✅ Hỗ trợ đầy đủ async/await**: UI responsive hơn
- **✅ Database migration tự động**: Tương thích ngược

## Lưu ý
- SQLite database tự động tạo khi khởi động app lần đầu
- Data được lưu trữ local, không cần internet
- Bạn có thể đổi màu chủ đạo bằng `colorSchemeSeed` trong `theme.dart`

## Roadmap
- Nhiều dạng trắc nghiệm hơn: điền khuyết, đúng/sai, matching
- Biểu đồ tiến độ, streak
- Backup/Restore, cloud sync
