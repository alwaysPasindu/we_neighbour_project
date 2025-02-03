import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}