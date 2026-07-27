import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../../core/services/local_service/shared_preferences_helper.dart';
import '../../../routes/app_routes.dart';
import '../service/foreground_call_service.dart';
import '../service/signaling_service.dart';

enum CallState { idle, outgoing, incoming, active }

class CallController extends GetxController {
  final SignalingService signalingService = SignalingService();

  final webrtc.RTCVideoRenderer localRenderer = webrtc.RTCVideoRenderer();
  final webrtc.RTCVideoRenderer remoteRenderer = webrtc.RTCVideoRenderer();

  webrtc.RTCPeerConnection? _peerConnection;
  webrtc.MediaStream? _localStream;
  webrtc.MediaStream? _remoteStream;

  final List<webrtc.RTCIceCandidate> _remoteIceCandidatesBuffer = [];
  Timer? _vibrationTimer;

  final Rx<CallState> callState = CallState.idle.obs;
  final RxBool isVideoCall = true.obs;
  final RxBool isMuted = false.obs;
  final RxBool isVideoOff = false.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxBool isRemoteVideoReady = false.obs;

  final RxString currentRemoteUserId = ''.obs;
  final RxString currentRemoteName = ''.obs;
  final RxString currentRoomId = ''.obs;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
      {'urls': 'stun:stun.services.mozilla.com'},
      {'urls': 'stun:global.stun.twilio.com:3478'},
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelay',
        'credential': 'openrelay'
      },
      {
        'urls': 'turn:openrelay.metered.ca:443',
        'username': 'openrelay',
        'credential': 'openrelay'
      },
      {
        'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
        'username': 'openrelay',
        'credential': 'openrelay'
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  @override
  void onInit() {
    super.onInit();
    _initRenderers();
    connectSignaling();
    ForegroundCallService.initForegroundTask();
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> connectSignaling() async {
    final userId = await SharedPreferencesHelper.getUserId();
    if (userId != null && userId.isNotEmpty) {
      signalingService.connect(
        userId: userId,
        onMessage: _handleSignalingMessage,
      );
    }
  }

  Future<bool> checkAndRequestPermissions({required bool video}) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
      Permission.notification,
    ].request();

    bool micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    if (!micGranted) {
      Get.snackbar('Permissions Required', 'Microphone permission is required for calling.', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    return true;
  }

  void _startRingingFeedback() {
    _stopRingingFeedback();
    
    // Play system phone ringtone audio
    FlutterRingtonePlayer().playRingtone();

    // Haptic vibration feedback
    _vibrationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      HapticFeedback.vibrate();
    });
  }

  void _stopRingingFeedback() {
    FlutterRingtonePlayer().stop();
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  // --- Call Actions ---

  Future<void> startCall({
    required String targetUserId,
    required String targetName,
    required bool video,
  }) async {
    final hasPermissions = await checkAndRequestPermissions(video: video);
    if (!hasPermissions) return;

    isVideoCall.value = video;
    isRemoteVideoReady.value = false;
    currentRemoteUserId.value = targetUserId;
    currentRemoteName.value = targetName;
    callState.value = CallState.outgoing;

    final myName = await SharedPreferencesHelper.getDisplayName() ?? 'User';

    Get.toNamed(AppRoutes.outgoingCallScreen);

    signalingService.callUser(
      targetUserId: targetUserId,
      callerName: myName,
      isVideo: video,
    );
  }

  Future<void> _handleSignalingMessage(Map<String, dynamic> msg) async {
    final String type = msg['type'] ?? '';
    debugPrint('📩 Signaling Message Received: $type');

    switch (type) {
      case 'incoming_call':
        if (callState.value != CallState.idle) {
          signalingService.declineCall(callerId: msg['callerId']);
          return;
        }

        currentRemoteUserId.value = msg['callerId'];
        currentRemoteName.value = msg['callerName'] ?? 'Unknown Caller';
        currentRoomId.value = msg['roomId'] ?? '';
        isVideoCall.value = msg['isVideo'] ?? true;
        isRemoteVideoReady.value = false;
        callState.value = CallState.incoming;

        _startRingingFeedback();
        Get.toNamed(AppRoutes.incomingCallScreen);
        break;

      case 'call_accepted':
        if (callState.value == CallState.outgoing) {
          _stopRingingFeedback();
          currentRoomId.value = msg['roomId'] ?? '';
          await _setupLocalMedia();
          await _createPeerConnection();
          await _createAndSendOffer();
          callState.value = CallState.active;

          await ForegroundCallService.startOngoingCallNotification(
            remoteName: currentRemoteName.value,
            isVideo: isVideoCall.value,
          );

          Get.offNamed(AppRoutes.activeCallScreen);
        }
        break;

      case 'call_declined':
        _stopRingingFeedback();
        Get.snackbar('Call Declined', '${currentRemoteName.value} declined the call.', backgroundColor: Colors.red, colorText: Colors.white);
        endCall(notifyPeer: false);
        break;

      case 'end_call':
        _stopRingingFeedback();
        Get.snackbar('Call Ended', '${currentRemoteName.value} ended the call.', backgroundColor: Colors.orange, colorText: Colors.white);
        endCall(notifyPeer: false);
        break;

      case 'offer':
        if (_peerConnection == null) {
          await _setupLocalMedia();
          await _createPeerConnection();
        }
        final sdp = msg['sdp'];
        await _peerConnection?.setRemoteDescription(webrtc.RTCSessionDescription(sdp['sdp'], sdp['type']));
        await _drainIceCandidatesBuffer();

        final answer = await _peerConnection?.createAnswer({});
        await _peerConnection?.setLocalDescription(answer!);

        signalingService.sendAnswer(
          targetUserId: msg['senderId'],
          sdp: {'sdp': answer!.sdp, 'type': answer.type},
        );
        break;

      case 'answer':
        final sdp = msg['sdp'];
        await _peerConnection?.setRemoteDescription(webrtc.RTCSessionDescription(sdp['sdp'], sdp['type']));
        await _drainIceCandidatesBuffer();
        break;

      case 'ice_candidate':
        final candidateData = msg['candidate'];
        if (candidateData != null && candidateData['candidate'] != null) {
          final candidate = webrtc.RTCIceCandidate(
            candidateData['candidate'],
            candidateData['sdpMid'] ?? '0',
            candidateData['sdpMLineIndex'] ?? 0,
          );
          await _addOrBufferIceCandidate(candidate);
        }
        break;
    }
  }

  Future<void> _addOrBufferIceCandidate(webrtc.RTCIceCandidate candidate) async {
    if (_peerConnection != null) {
      final remoteDesc = await _peerConnection!.getRemoteDescription();
      if (remoteDesc != null) {
        debugPrint('✅ Adding ICE Candidate immediately: ${candidate.candidate}');
        await _peerConnection!.addCandidate(candidate);
        return;
      }
    }
    debugPrint('⏳ Buffering ICE Candidate until remoteDescription is set: ${candidate.candidate}');
    _remoteIceCandidatesBuffer.add(candidate);
  }

  Future<void> _drainIceCandidatesBuffer() async {
    if (_peerConnection == null) return;
    debugPrint('🔄 Draining ${_remoteIceCandidatesBuffer.length} buffered ICE candidates...');
    for (final candidate in _remoteIceCandidatesBuffer) {
      await _peerConnection!.addCandidate(candidate);
    }
    _remoteIceCandidatesBuffer.clear();
  }

  Future<void> acceptIncomingCall() async {
    _stopRingingFeedback();
    final hasPermissions = await checkAndRequestPermissions(video: isVideoCall.value);
    if (!hasPermissions) {
      declineIncomingCall();
      return;
    }

    await _setupLocalMedia();
    await _createPeerConnection();

    signalingService.acceptCall(
      callerId: currentRemoteUserId.value,
      roomId: currentRoomId.value,
    );

    callState.value = CallState.active;

    await ForegroundCallService.startOngoingCallNotification(
      remoteName: currentRemoteName.value,
      isVideo: isVideoCall.value,
    );

    Get.offNamed(AppRoutes.activeCallScreen);
  }

  void declineIncomingCall() {
    _stopRingingFeedback();
    signalingService.declineCall(callerId: currentRemoteUserId.value);
    endCall(notifyPeer: false);
  }

  Future<void> _setupLocalMedia() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': isVideoCall.value
          ? {
              'facingMode': 'user',
            }
          : false,
    };

    _localStream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = _localStream;

    // Enable speakerphone hardware routing after media setup
    Future.delayed(const Duration(milliseconds: 300), () {
      webrtc.Helper.setSpeakerphoneOn(isSpeakerOn.value);
    });
  }

  void _attachRemoteStream(webrtc.MediaStream stream) {
    debugPrint('🎥 Attaching Remote MediaStream: ${stream.id}, tracks=${stream.getTracks().length}');
    _remoteStream = stream;

    for (var track in stream.getTracks()) {
      track.enabled = true;
    }

    remoteRenderer.srcObject = null;
    remoteRenderer.srcObject = stream;

    // Delayed speakerphone routing to prevent Android MODE_IN_COMMUNICATION override
    Future.delayed(const Duration(milliseconds: 500), () {
      webrtc.Helper.setSpeakerphoneOn(isSpeakerOn.value);
    });

    isRemoteVideoReady.value = false;
    Future.microtask(() {
      isRemoteVideoReady.value = true;
    });
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await webrtc.createPeerConnection(_iceServers);

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onTrack = (webrtc.RTCTrackEvent event) async {
      debugPrint('📺 WebRTC onTrack: track.kind=${event.track.kind}, id=${event.track.id}');
      event.track.enabled = true;

      if (event.streams.isNotEmpty) {
        _attachRemoteStream(event.streams[0]);
      } else {
        _remoteStream ??= await webrtc.createLocalMediaStream('remote_stream');
        _remoteStream!.addTrack(event.track);
        _attachRemoteStream(_remoteStream!);
      }
    };

    _peerConnection?.onAddStream = (webrtc.MediaStream stream) {
      debugPrint('📺 WebRTC onAddStream: stream.id=${stream.id}');
      _attachRemoteStream(stream);
    };

    _peerConnection?.onIceCandidate = (webrtc.RTCIceCandidate candidate) {
      if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
        signalingService.sendIceCandidate(
          targetUserId: currentRemoteUserId.value,
          candidate: {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid ?? '0',
            'sdpMLineIndex': candidate.sdpMLineIndex ?? 0,
          },
        );
      }
    };

    _peerConnection?.onIceConnectionState = (webrtc.RTCIceConnectionState state) {
      debugPrint('🧊 ICE Connection State: $state');
      if (state == webrtc.RTCIceConnectionState.RTCIceConnectionStateFailed) {
        debugPrint('⚠️ ICE Failed! Attempting ICE restart...');
        _peerConnection?.restartIce();
      }
    };

    _peerConnection?.onConnectionState = (webrtc.RTCPeerConnectionState state) {
      debugPrint('⚡ Peer Connection State: $state');
    };
  }

  Future<void> _createAndSendOffer() async {
    final offer = await _peerConnection?.createOffer({});
    await _peerConnection?.setLocalDescription(offer!);

    signalingService.sendOffer(
      targetUserId: currentRemoteUserId.value,
      sdp: {'sdp': offer!.sdp, 'type': offer.type},
    );
  }

  void toggleMute() {
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      final track = _localStream!.getAudioTracks()[0];
      track.enabled = !track.enabled;
      isMuted.value = !track.enabled;
    }
  }

  void toggleVideo() {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      final track = _localStream!.getVideoTracks()[0];
      track.enabled = !track.enabled;
      isVideoOff.value = !track.enabled;
    }
  }

  void switchCamera() {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      webrtc.Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void toggleSpeakerphone() {
    isSpeakerOn.value = !isSpeakerOn.value;
    webrtc.Helper.setSpeakerphoneOn(isSpeakerOn.value);
  }

  void endCall({bool notifyPeer = true}) {
    _stopRingingFeedback();

    if (notifyPeer && currentRemoteUserId.value.isNotEmpty) {
      signalingService.endCall(targetUserId: currentRemoteUserId.value);
    }

    ForegroundCallService.stopOngoingCallNotification();

    _remoteIceCandidatesBuffer.clear();

    _localStream?.getTracks().forEach((track) => track.stop());
    _remoteStream?.getTracks().forEach((track) => track.stop());

    _localStream?.dispose();
    _remoteStream?.dispose();

    _peerConnection?.close();
    _peerConnection = null;

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    callState.value = CallState.idle;
    isMuted.value = false;
    isVideoOff.value = false;
    isSpeakerOn.value = true;
    isRemoteVideoReady.value = false;
    currentRemoteUserId.value = '';
    currentRemoteName.value = '';
    currentRoomId.value = '';

    if (Get.currentRoute != AppRoutes.usersScreen) {
      Get.offAllNamed(AppRoutes.usersScreen);
    }
  }

  @override
  void onClose() {
    _stopRingingFeedback();
    endCall(notifyPeer: true);
    localRenderer.dispose();
    remoteRenderer.dispose();
    signalingService.disconnect();
    super.onClose();
  }
}
