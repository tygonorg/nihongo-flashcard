import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  RxDouble fontSize = 16.0.obs;
  Rx<MaterialColor> primaryColor = Colors.blue.obs;
  RxInt quizLength = 10.obs;
  RxBool soundEnabled = true.obs;

  void setFontSize(double v) => fontSize.value = v;
  void setColor(MaterialColor c) => primaryColor.value = c;
  void setQuizLength(int v) => quizLength.value = v;
  void setSound(bool enabled) => soundEnabled.value = enabled;
}
