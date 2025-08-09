import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'services/realm_service.dart';
import 'app.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final realmService = RealmService();
  
  try {
    await realmService.initialize();
    
    runApp(
      ProviderScope(
        overrides: [
          realmServiceProvider.overrideWithValue(realmService),
        ],
        child: const NihongoApp(),
      ),
    );
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Critical error during app initialization: $e');
      print('Stack trace: $stackTrace');
    }
    
    // Hiển thị màn hình lỗi thay vì crash
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lỗi khởi tạo ứng dụng',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chi tiết lỗi: ${realmService.initializationError ?? e.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await realmService.initialize();
                      // Restart app nếu khởi tạo thành công
                      runApp(
                        ProviderScope(
                          overrides: [
                            realmServiceProvider.overrideWithValue(realmService),
                          ],
                          child: const NihongoApp(),
                        ),
                      );
                    } catch (retryError) {
                      // Vẫn lỗi, giữ nguyên màn hình lỗi
                      if (kDebugMode) {
                        print('Retry failed: $retryError');
                      }
                    }
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
