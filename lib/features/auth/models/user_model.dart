class UserModel {
  final String id;
  final String username;
  final String displayName;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawOnline = json['is_online'] ?? json['isOnline'] ?? json['online'];
    bool parsedOnline = false;
    if (rawOnline is bool) {
      parsedOnline = rawOnline;
    } else if (rawOnline is int) {
      parsedOnline = rawOnline == 1;
    } else if (rawOnline is String) {
      parsedOnline = rawOnline.toLowerCase() == 'true' || rawOnline == '1';
    }

    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? json['displayName']?.toString() ?? json['username']?.toString() ?? '',
      isOnline: parsedOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'is_online': isOnline,
    };
  }
}

class AuthResponseModel {
  final bool success;
  final String message;
  final String? accessToken;
  final UserModel? user;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.accessToken,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      accessToken: json['access_token']?.toString(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
