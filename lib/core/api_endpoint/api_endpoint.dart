class ApiEndpoint {
  static const String baseUrl = 'https://webrtctest-m6me.onrender.com';
  static const String wsBaseUrl = 'wss://webrtctest-m6me.onrender.com';

  static const String register = '$baseUrl/api/register';
  static const String login = '$baseUrl/api/login';
  static const String users = '$baseUrl/api/users';

  static String userWebSocket(String userId) => '$wsBaseUrl/ws/user/$userId';
}
