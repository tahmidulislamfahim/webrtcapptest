import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../../call/controllers/call_controller.dart';
import '../controllers/users_controller.dart';

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate CallController to handle incoming calls globally
    final CallController callController = Get.find<CallController>();

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.cardSurface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Directory',
              style: TextStyle(color: AppColor.textMain, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Obx(
              () => Text(
                'Logged in as: ${controller.currentDisplayName.value}',
                style: const TextStyle(color: AppColor.primary, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColor.danger),
            tooltip: 'Logout',
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primary),
          );
        }

        if (controller.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: AppColor.textMuted),
                const SizedBox(height: 16),
                const Text(
                  'No other registered users found.',
                  style: TextStyle(color: AppColor.textMuted, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.loadUsers(showLoader: true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.cardSurface),
                  child: const Text('Refresh List', style: TextStyle(color: AppColor.primary)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadUsers(showLoader: false),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              final isMe = user.id == controller.currentUserId.value;
              final isOnline = isMe ? callController.signalingService.isConnected : user.isOnline;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColor.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                      child: Text(
                        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  color: AppColor.textMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? AppColor.success.withValues(alpha: 0.2)
                                      : AppColor.border,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: isOnline ? AppColor.success : AppColor.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user.username}',
                            style: const TextStyle(color: AppColor.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons for Call
                    if (isOnline && !isMe) ...[
                      IconButton(
                        icon: const Icon(Icons.phone, color: AppColor.primary, size: 22),
                        tooltip: 'Audio Call',
                        onPressed: () {
                          callController.startCall(
                            targetUserId: user.id,
                            targetName: user.displayName,
                            video: false,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam, color: AppColor.success, size: 24),
                        tooltip: 'Video Call',
                        onPressed: () {
                          callController.startCall(
                            targetUserId: user.id,
                            targetName: user.displayName,
                            video: true,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
