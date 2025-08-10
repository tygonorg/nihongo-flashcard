import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController settings = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Obx(() => ListView(
            children: [
              ListTile(
                title: const Text('Cỡ chữ'),
                subtitle:
                    Text(settings.fontSize.value.toStringAsFixed(0)),
                trailing: SizedBox(
                  width: 160,
                  child: Slider(
                    min: 12,
                    max: 30,
                    value: settings.fontSize.value,
                    onChanged: settings.setFontSize,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Màu chủ đạo'),
                trailing: DropdownButton<MaterialColor>(
                  value: settings.primaryColor.value,
                  items: const [
                    DropdownMenuItem(
                        value: Colors.blue, child: Text('Xanh dương')),
                    DropdownMenuItem(value: Colors.red, child: Text('Đỏ')),
                    DropdownMenuItem(value: Colors.green, child: Text('Xanh lá')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      settings.setColor(v);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Số câu hỏi mỗi lần'),
                trailing: DropdownButton<int>(
                  value: settings.quizLength.value,
                  items: const [5, 10, 20, 50]
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      settings.setQuizLength(v);
                    }
                  },
                ),
              ),
              SwitchListTile(
                title: const Text('Âm thanh'),
                value: settings.soundEnabled.value,
                onChanged: settings.setSound,
              ),
            ],
          )),
    );
  }
}
