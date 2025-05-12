import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifications {
  Future<void> initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission();

    await messaging.subscribeToTopic('daily_reminder');

    // Testing purposes
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Listen for foreground messages, when the app is open it should display a pop-up message on top
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Display to terminal logs for testing purposes
        print('FCM Notification Received: ${message.notification!.title}');
      }
    });
}

}