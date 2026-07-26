import 'dart:convert';
import '../../../core/api_endpoint/api_endpoint.dart';
import '../../../core/services/network_service/network_service.dart';
import '../models/user_model.dart';

class AuthService {
  final NetworkService _networkService = NetworkService();

  Future<AuthResponseModel> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    final response = await _networkService.post(
      ApiEndpoint.register,
      body: {
        'username': username,
        'password': password,
        'display_name': displayName,
      },
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception(data['detail'] ?? 'Registration failed.');
    }
  }

  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _networkService.post(
      ApiEndpoint.login,
      body: {
        'username': username,
        'password': password,
      },
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception(data['detail'] ?? 'Invalid username or password.');
    }
  }
}
