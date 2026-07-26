import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../core/services/local_service/shared_preferences_helper.dart';
import '../../../routes/app_routes.dart';
import '../../call/controllers/call_controller.dart';
import '../service/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final TextEditingController loginUsernameController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController regUsernameController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final TextEditingController regDisplayNameController = TextEditingController();

  final RxBool isLoading = false.obs;

  Future<void> register() async {
    final username = regUsernameController.text.trim();
    final password = regPasswordController.text.trim();
    final displayName = regDisplayNameController.text.trim();

    if (username.isEmpty || password.isEmpty || displayName.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Creating Account...');
      
      final response = await _authService.register(
        username: username,
        password: password,
        displayName: displayName,
      );

      EasyLoading.dismiss();
      isLoading.value = false;

      if (response.success) {
        Get.snackbar(
          'Success',
          'Registration successful! Please login.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        regUsernameController.clear();
        regPasswordController.clear();
        regDisplayNameController.clear();
        
        Get.offNamed(AppRoutes.loginScreen);
      }
    } catch (e) {
      EasyLoading.dismiss();
      isLoading.value = false;
      Get.snackbar('Registration Failed', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> login() async {
    final username = loginUsernameController.text.trim();
    final password = loginPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter username and password', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Logging in...');

      final response = await _authService.login(
        username: username,
        password: password,
      );

      EasyLoading.dismiss();
      isLoading.value = false;

      if (response.success && response.accessToken != null && response.user != null) {
        await SharedPreferencesHelper.saveAuthData(
          token: response.accessToken!,
          userId: response.user!.id,
          username: response.user!.username,
          displayName: response.user!.displayName,
        );

        Get.snackbar('Welcome', 'Logged in as ${response.user!.displayName}', backgroundColor: Colors.green, colorText: Colors.white);

        // Connect WebSocket signaling upon successful login
        Get.find<CallController>().connectSignaling();

        Get.offAllNamed(AppRoutes.usersScreen);
      }
    } catch (e) {
      EasyLoading.dismiss();
      isLoading.value = false;
      Get.snackbar('Login Failed', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    loginUsernameController.dispose();
    loginPasswordController.dispose();
    regUsernameController.dispose();
    regPasswordController.dispose();
    regDisplayNameController.dispose();
    super.onClose();
  }
}
