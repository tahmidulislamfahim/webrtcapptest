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
  int _failedPings = 0;

  bool get isConnected => _isConnected && _channel != null;

  void connect({
    required String userId,
    required Function(Map<String, dynamic> message) onMessage,
    Function(dynamic error)? onError,
    Function()? onDone,
  }) {
    _lastUserId = userId;
    _onMessageCallback = onMessage;

    if (_isConnected && _channel != null) {
      debugPrint('🔌 WebSocket already connected for user $userId');
      return;
    }

    final wsUrl = ApiEndpoint.userWebSocket(userId);
    debugPrint('🔌 Connecting WebSocket to $wsUrl');

    _cleanUpSocket();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      _failedPings = 0;
      _startHeartbeat();

      _channel!.stream.listen(
        (message) {
          _failedPings = 0; // Reset failed count when any data arrives from server
          try {
            final Map<String, dynamic> data = jsonDecode(message);
            if (data['type'] == 'pong') return;
            onMessage(data);
          } catch (e) {
            // JSON parsing error ignored
          }
        },
        onError: (err) {
          debugPrint('⚠️ WebSocket stream error: $err');
          _handleDisconnect();
          if (onError != null) onError(err);
        },
        onDone: () {
          debugPrint('⚠️ WebSocket connection closed (onDone).');
          _handleDisconnect();
          if (onDone != null) onDone();
        },
      );
    } catch (e) {
      debugPrint('⚠️ WebSocket connection exception: $e');
      _handleDisconnect();
    }
  }

  void checkConnection() {
    if (!isConnected) {
      if (_lastUserId != null && _onMessageCallback != null) {
        debugPrint('🔌 Connection check failed: Reconnecting WebSocket for user $_lastUserId...');
        connect(userId: _lastUserId!, onMessage: _onMessageCallback!);
      }
    }
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (isConnected) {
        _failedPings++;
        if (_failedPings > 3) {
          debugPrint('⚠️ WebSocket missed 3 ping heartbeats. Forcing reconnect...');
          _handleDisconnect();
          return;
        }
        sendMessage({'type': 'ping'});
      }
    });
  }

  void _cleanUpSocket() {
    _pingTimer?.cancel();
    _pingTimer = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _isConnected = false;
  }

  void _handleDisconnect() {
    _cleanUpSocket();

    // Schedule auto-reconnect after network drop/switch
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      if (!isConnected && _lastUserId != null && _onMessageCallback != null) {
        debugPrint('🔄 Auto-reconnecting WebSocket for user $_lastUserId...');
        connect(userId: _lastUserId!, onMessage: _onMessageCallback!);
      }
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        debugPrint('⚠️ Error adding message to WebSocket sink: $e');
        _handleDisconnect();
      }
    } else {
      debugPrint('⚠️ WebSocket not connected. Message dropped: ${message['type']}');
      _handleDisconnect();
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
    _cleanUpSocket();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _lastUserId = null;
    _onMessageCallback = null;
  }
}
