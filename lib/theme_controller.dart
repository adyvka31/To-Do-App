import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var isTheme = false.obs;

  void changeTheme() {
    isTheme.value = !isTheme.value;
    if (isTheme.value) {
      Get.changeTheme(ThemeData.dark());
    } else {
      Get.changeTheme(ThemeData.light());
    }
  }
}