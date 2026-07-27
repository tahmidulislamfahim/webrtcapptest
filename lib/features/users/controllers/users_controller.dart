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
