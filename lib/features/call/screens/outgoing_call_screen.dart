import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../controllers/call_controller.dart';

class OutgoingCallScreen extends GetView<CallController> {
  const OutgoingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.callScreenBg,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: AppColor.cardSurface,
                  child: Text(
                    controller.currentRemoteName.value.isNotEmpty
                        ? controller.currentRemoteName.value[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => Text(
                    controller.currentRemoteName.value,
                    style: const TextStyle(
                      color: AppColor.textMain,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Text(
                    'Calling (${controller.isVideoCall.value ? 'Video Call' : 'Audio Call'})...',
                    style: const TextStyle(
                      color: AppColor.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                children: [
                  FloatingActionButton.large(
                    heroTag: 'cancel_call',
                    backgroundColor: AppColor.danger,
                    onPressed: () => controller.endCall(),
                    child: const Icon(Icons.call_end, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cancel',
                    style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
