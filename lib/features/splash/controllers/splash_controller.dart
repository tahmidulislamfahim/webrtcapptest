import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/local_service/shared_preferences_helper.dart';
import '../../../routes/app_routes.dart';
import '../../call/controllers/call_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await SharedPreferencesHelper.getAccessToken();
    debugPrint("Splash token check: $token");
    if (token != null && token.isNotEmpty) {
      Get.find<CallController>().connectSignaling();
      Get.offAllNamed(AppRoutes.usersScreen);
    } else {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
}
