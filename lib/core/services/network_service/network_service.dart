import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../local_service/shared_preferences_helper.dart';

class NetworkService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SharedPreferencesHelper.getAccessToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'accept': '*/*',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    debugPrint('🌐 [HTTP GET] $url');
    debugPrint('👉 Request Headers: $headers');

    final response = await http.get(Uri.parse(url), headers: headers);

    debugPrint('👈 [HTTP ${response.statusCode}] $url');
    debugPrint('📄 Response Body: ${response.body}');
    return response;
  }

  Future<http.Response> post(String url, {dynamic body}) async {
    final headers = await _getHeaders();
    final jsonBody = body != null ? jsonEncode(body) : null;
    debugPrint('🌐 [HTTP POST] $url');
    debugPrint('👉 Request Headers: $headers');
    debugPrint('📦 Request Body: $jsonBody');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonBody,
    );

    debugPrint('👈 [HTTP ${response.statusCode}] $url');
    debugPrint('📄 Response Body: ${response.body}');
    return response;
  }
}
