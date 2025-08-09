import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'services/database_service.dart';
import 'services/migration_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final databaseService = DatabaseService.instance;
  
  try {
    // Check if migration is needed and perform it
    if (await MigrationService.needsMigration()) {
      if (kDebugMode) {
        print('Migration needed, starting migration process...');
      }
      
      final migrationResult = await MigrationService.migrate();
      if (migrationResult.success) {
        if (kDebugMode) {
          print('Migration completed successfully: ${migrationResult.message}');
        }
      } else {
        if (kDebugMode) {
          print('Migration failed: ${migrationResult.message}');
        }
        // Continue anyway, as the app might still work
      }
    }
    
    // Initialize the database service
    await databaseService.initialize();
    
    runApp(
      const ProviderScope(
        child: NihongoApp(),
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
                  'Chi tiết lỗi: ${databaseService.initializationError ?? e.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await databaseService.initialize();
                      // Restart app nếu khởi tạo thành công
                      runApp(
                        const ProviderScope(
                          child: NihongoApp(),
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
