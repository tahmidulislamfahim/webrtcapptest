import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundCallService {
  static void initForegroundTask() {
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'ongoing_webrtc_call_channel',
          channelName: 'Active WebRTC Call',
          channelDescription: 'Ongoing WebRTC audio and video call session',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000),
          autoRunOnBoot: false,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
    } catch (e) {
      // Ignore init errors on custom ROMs
    }
  }

  static Future<void> startOngoingCallNotification({
    required String remoteName,
    required bool isVideo,
  }) async {
    try {
      final callType = isVideo ? 'Video Call' : 'Audio Call';
      await FlutterForegroundTask.startService(
        notificationTitle: 'Ongoing $callType',
        notificationText: 'Active call with $remoteName. Tap to return.',
      );
    } catch (e) {
      // Gracefully catch security exceptions on Android 14/15 so call never crashes
    }
  }

  static Future<void> stopOngoingCallNotification() async {
    try {
      await FlutterForegroundTask.stopService();
    } catch (e) {
      // Gracefully catch stop errors
    }
  }
}
