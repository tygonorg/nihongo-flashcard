import 'package:get/get.dart';

class LevelController extends GetxController {
  RxnString selectedLevel = RxnString();

  void setLevel(String? level) => selectedLevel.value = level;
}
