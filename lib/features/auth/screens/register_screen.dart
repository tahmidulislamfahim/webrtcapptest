import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/widgets/custom_button.dart';
import '../../../core/common/widgets/custom_text_field.dart';
import '../../../core/constants/app_color.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textMain),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.textMain,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register to start audio and video calls',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: controller.regDisplayNameController,
                  label: 'Full Name',
                  hint: 'e.g. Alice Smith',
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.regUsernameController,
                  label: 'Username',
                  hint: 'Choose a unique username',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.regPasswordController,
                  label: 'Password',
                  hint: 'Choose a strong password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 28),
                Obx(
                  () => CustomButton(
                    text: 'Register Account',
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.register(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.loginScreen),
                      child: const Text(
                        'Log In',
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
