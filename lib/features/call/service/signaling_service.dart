import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/api_endpoint/api_endpoint.dart';

class SignalingService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _lastUserId;
  Function(Map<String, dynamic> message)? _onMessageCallback;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  bool get isConnected => _isConnected;

  void connect({
    required String userId,
    required Function(Map<String, dynamic> message) onMessage,
    Function(dynamic error)? onError,
    Function()? onDone,
  }) {
    _lastUserId = userId;
    _onMessageCallback = onMessage;

    if (_isConnected) return;

    final wsUrl = ApiEndpoint.userWebSocket(userId);
    debugPrint('🔌 Connecting WebSocket to $wsUrl');
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      _startHeartbeat();

      _channel!.stream.listen(
        (message) {
          try {
            final Map<String, dynamic> data = jsonDecode(message);
            if (data['type'] == 'pong') return;
            onMessage(data);
          } catch (e) {
            // JSON parsing error ignored
          }
        },
        onError: (err) {
          debugPrint('⚠️ WebSocket error: $err');
          _handleDisconnect();
          if (onError != null) onError(err);
        },
        onDone: () {
          debugPrint('⚠️ WebSocket disconnected.');
          _handleDisconnect();
          if (onDone != null) onDone();
        },
      );
    } catch (e) {
      debugPrint('⚠️ WebSocket connection exception: $e');
      _handleDisconnect();
    }
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isConnected && _channel != null) {
        sendMessage({'type': 'ping'});
      }
    });
  }

  void _handleDisconnect() {
    _isConnected = false;
    _pingTimer?.cancel();
    _channel?.sink.close();
    _channel = null;

    // Schedule auto-reconnect after network drop/switch
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_isConnected && _lastUserId != null && _onMessageCallback != null) {
        debugPrint('🔄 Auto-reconnecting WebSocket for user $_lastUserId...');
        connect(userId: _lastUserId!, onMessage: _onMessageCallback!);
      }
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void callUser({
    required String targetUserId,
    required String callerName,
    required bool isVideo,
  }) {
    sendMessage({
      'type': 'call_user',
      'targetUserId': targetUserId,
      'callerName': callerName,
      'isVideo': isVideo,
    });
  }

  void acceptCall({
    required String callerId,
    required String roomId,
  }) {
    sendMessage({
      'type': 'accept_call',
      'callerId': callerId,
      'roomId': roomId,
    });
  }

  void declineCall({required String callerId}) {
    sendMessage({
      'type': 'decline_call',
      'callerId': callerId,
    });
  }

  void sendOffer({
    required String targetUserId,
    required dynamic sdp,
  }) {
    sendMessage({
      'type': 'offer',
      'targetUserId': targetUserId,
      'sdp': sdp,
    });
  }

  void sendAnswer({
    required String targetUserId,
    required dynamic sdp,
  }) {
    sendMessage({
      'type': 'answer',
      'targetUserId': targetUserId,
      'sdp': sdp,
    });
  }

  void sendIceCandidate({
    required String targetUserId,
    required dynamic candidate,
  }) {
    sendMessage({
      'type': 'ice_candidate',
      'targetUserId': targetUserId,
      'candidate': candidate,
    });
  }

  void endCall({required String targetUserId}) {
    sendMessage({
      'type': 'end_call',
      'targetUserId': targetUserId,
    });
  }

  void disconnect() {
    _isConnected = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
