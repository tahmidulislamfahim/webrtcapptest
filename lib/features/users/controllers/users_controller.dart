import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/services/local_service/shared_preferences_helper.dart';
import '../../../routes/app_routes.dart';
import '../../auth/models/user_model.dart';
import '../../call/controllers/call_controller.dart';
import '../service/users_service.dart';

class UsersController extends GetxController {
  final UsersService _usersService = UsersService();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentDisplayName = ''.obs;
  final RxString currentUserId = ''.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    loadProfileAndUsers();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => loadUsers(showLoader: false));
  }

  Future<void> loadProfileAndUsers() async {
    final name = await SharedPreferencesHelper.getDisplayName();
    final uid = await SharedPreferencesHelper.getUserId();
    currentDisplayName.value = name ?? 'User';
    currentUserId.value = uid ?? '';

    if (Get.isRegistered<CallController>()) {
      Get.find<CallController>().connectSignaling();
    }

    await loadUsers(showLoader: true);
  }

  Future<void> loadUsers({bool showLoader = false}) async {
    try {
      if (showLoader) isLoading.value = true;
      final result = await _usersService.fetchUsers();
      users.assignAll(result);

      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().signalingService.checkConnection();
      }
    } catch (e) {
      debugPrint('UsersController loadUsers error: $e');
      if (e.toString().contains('UNAUTHORIZED')) {
        await logout();
      }
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  void handleUserStatusUpdate(Map<String, dynamic> msg) {
    debugPrint('📢 User status socket message received: $msg');

    final String targetId = (msg['userId'] ?? msg['id'] ?? msg['user_id'] ?? '').toString();
    final rawStatus = msg['status'] ?? msg['isOnline'] ?? msg['is_online'];

    bool isOnline = false;
    if (rawStatus is bool) {
      isOnline = rawStatus;
    } else if (rawStatus is String) {
      isOnline = rawStatus.toLowerCase() == 'online' || rawStatus.toLowerCase() == 'true' || rawStatus == '1';
    } else if (rawStatus is int) {
      isOnline = rawStatus == 1;
    } else if (msg['type'] == 'user_online' || msg['type'] == 'user_connected') {
      isOnline = true;
    } else if (msg['type'] == 'user_offline' || msg['type'] == 'user_disconnected') {
      isOnline = false;
    }

    if (targetId.isNotEmpty) {
      final index = users.indexWhere((u) => u.id == targetId);
      if (index != -1) {
        final existing = users[index];
        users[index] = UserModel(
          id: existing.id,
          username: existing.username,
          displayName: existing.displayName,
          isOnline: isOnline,
        );
        users.refresh();
        return;
      }
    }

    loadUsers(showLoader: false);
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    await SharedPreferencesHelper.clearAuthData();
    Get.offAllNamed(AppRoutes.loginScreen);
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
