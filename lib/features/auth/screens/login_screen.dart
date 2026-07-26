import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/widgets/custom_button.dart';
import '../../../core/common/widgets/custom_text_field.dart';
import '../../../core/constants/app_color.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.video_call_rounded,
                  size: 72,
                  color: AppColor.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'WebRTC Call',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.textMain,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Log in to connect with audio & video calls',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 36),
                CustomTextField(
                  controller: controller.loginUsernameController,
                  label: 'Username',
                  hint: 'Enter your username',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.loginPasswordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 28),
                Obx(
                  () => CustomButton(
                    text: 'Log In',
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.login(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.registerScreen),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
