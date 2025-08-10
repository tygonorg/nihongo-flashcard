# Triển khai ứng dụng

Trang này hướng dẫn cách build và phát hành **Nihongo Flashcard**.

## Yêu cầu
- Flutter SDK >= 3.4.0
- Dart >= 3.4.0
- iOS >= 12.0
- Android >= API 21

## Build bản release

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
```

## Kiểm tra trước khi phát hành
1. Chạy `flutter analyze` để kiểm tra mã nguồn.
2. Chạy `flutter test` để đảm bảo các bài test đều pass.
3. Tạo release build và thử nghiệm trên thiết bị thực tế.

## Triển khai lên Store
- **App Store:** upload bằng Xcode hoặc `transporter` sau khi có file `.ipa`.
- **Google Play:** tải file `.aab` hoặc `.apk` lên Google Play Console, hoàn tất các bước kiểm duyệt.

## Tài liệu tham khảo
- [Publishing to the App Store](https://docs.flutter.dev/deployment/ios)
- [Publishing to Google Play](https://docs.flutter.dev/deployment/android)
