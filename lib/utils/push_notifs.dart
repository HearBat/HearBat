import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

@pragma('vm:entry-point')
class PushNotifications {
  Future<void> initFirebaseMessaging() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      await messaging.requestPermission();
      
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          print('APNS Token: $apnsToken');
        } else {
          print('APNS token not available, will retry...');
          // Wait a bit and try again
          await Future.delayed(Duration(seconds: 2));
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken == null) {
            print('APNS token still not available, skipping topic subscription');
            return;
          }
        }
      }
      
      await messaging.subscribeToTopic('daily_reminder');
      
      String? token = await messaging.getToken();
      print('FCM Token: $token');
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          print('FCM Notification Received: ${message.notification!.title}');
        }
      });
      
    } catch (e) {
      print('Firebase Messaging initialization error: $e');
    }
  }
}