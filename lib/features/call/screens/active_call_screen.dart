import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/constants/app_color.dart';
import '../controllers/call_controller.dart';

class ActiveCallScreen extends GetView<CallController> {
  const ActiveCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.callScreenBg,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Remote Video View / Audio Call View
            Positioned.fill(
              child: Obx(() {
                if (controller.isVideoCall.value) {
                  final isReady = controller.isRemoteVideoReady.value;
                  if (!isReady || controller.remoteRenderer.srcObject == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColor.primary.withValues(alpha: 0.2),
                            child: Text(
                              controller.currentRemoteName.value.isNotEmpty
                                  ? controller.currentRemoteName.value[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(color: AppColor.primary),
                          const SizedBox(height: 16),
                          const Text(
                            'Connecting video stream...',
                            style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }
                  return RTCVideoView(
                    controller.remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  );
                }

                // Audio Call Main View
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColor.primary.withValues(alpha: 0.2),
                        child: Text(
                          controller.currentRemoteName.value.isNotEmpty
                              ? controller.currentRemoteName.value[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        controller.currentRemoteName.value,
                        style: const TextStyle(
                          color: AppColor.textMain,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ongoing Audio Call',
                        style: TextStyle(color: AppColor.textMuted, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // 2. Picture-in-Picture Local Camera View (Direct Positioned child of Stack)
            Positioned(
              top: 20,
              right: 20,
              width: 110,
              height: 160,
              child: Obx(() {
                if (controller.isVideoCall.value && !controller.isVideoOff.value) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.black,
                      child: RTCVideoView(
                        controller.localRenderer,
                        mirror: true,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),

            // 3. Top Call Info Header (Direct Positioned child of Stack)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, size: 16, color: AppColor.success),
                    const SizedBox(width: 6),
                    Obx(
                      () => Text(
                        controller.currentRemoteName.value,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Bottom Control Action Bar (Direct Positioned child of Stack)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.cardSurface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Mic Button
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isMuted.value ? Icons.mic_off : Icons.mic,
                          color: controller.isMuted.value ? AppColor.danger : Colors.white,
                          size: 26,
                        ),
                        onPressed: () => controller.toggleMute(),
                      ),
                    ),

                    // Toggle Video Button (Only for Video Calls)
                    Obx(() {
                      if (!controller.isVideoCall.value) return const SizedBox.shrink();
                      return IconButton(
                        icon: Icon(
                          controller.isVideoOff.value ? Icons.videocam_off : Icons.videocam,
                          color: controller.isVideoOff.value ? AppColor.danger : Colors.white,
                          size: 26,
                        ),
                        onPressed: () => controller.toggleVideo(),
                      );
                    }),

                    // Switch Camera Button
                    Obx(() {
                      if (!controller.isVideoCall.value) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 26),
                        onPressed: () => controller.switchCamera(),
                      );
                    }),

                    // Speakerphone Button
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isSpeakerOn.value ? Icons.volume_up : Icons.volume_off,
                          color: controller.isSpeakerOn.value ? AppColor.primary : Colors.white,
                          size: 26,
                        ),
                        onPressed: () => controller.toggleSpeakerphone(),
                      ),
                    ),

                    // End Call Button
                    FloatingActionButton.small(
                      heroTag: 'end_active_call',
                      backgroundColor: AppColor.danger,
                      onPressed: () => controller.endCall(),
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
