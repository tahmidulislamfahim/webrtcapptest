import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger splash controller initialization
    controller;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.cardSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.primary.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.video_call_rounded,
                  size: 80,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'WebRTC Call App',
                style: TextStyle(
                  color: AppColor.textMain,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Secure P2P Audio & Video Calling',
                style: TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              const CircularProgressIndicator(
                color: AppColor.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Initializing Connection...',
                style: TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
