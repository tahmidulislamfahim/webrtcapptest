import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../controllers/call_controller.dart';

class IncomingCallScreen extends GetView<CallController> {
  const IncomingCallScreen({super.key});

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
                  backgroundColor: AppColor.primary.withValues(alpha: 0.2),
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
                    'Incoming ${controller.isVideoCall.value ? 'Video Call' : 'Audio Call'}...',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      FloatingActionButton.large(
                        heroTag: 'decline_incoming',
                        backgroundColor: AppColor.danger,
                        onPressed: () => controller.declineIncomingCall(),
                        child: const Icon(Icons.call_end, size: 36, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Decline',
                        style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      FloatingActionButton.large(
                        heroTag: 'accept_incoming',
                        backgroundColor: AppColor.success,
                        onPressed: () => controller.acceptIncomingCall(),
                        child: const Icon(Icons.call, size: 36, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Accept',
                        style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                      ),
                    ],
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
