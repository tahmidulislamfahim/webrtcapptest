import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/api_endpoint/api_endpoint.dart';
import '../../../core/services/network_service/network_service.dart';
import '../../auth/models/user_model.dart';

class UsersService {
  final NetworkService _networkService = NetworkService();

  Future<List<UserModel>> fetchUsers() async {
    final response = await _networkService.get(ApiEndpoint.users);
    debugPrint('GET /api/users response: [${response.statusCode}] ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> usersJson = data['users'] as List? ?? [];
      return usersJson.map((json) => UserModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    } else {
      throw Exception('Failed to load user directory (${response.statusCode})');
    }
  }
}
