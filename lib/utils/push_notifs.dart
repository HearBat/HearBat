import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

@pragma('vm:entry-point')
class PushNotifications {
  Future<void> initFirebaseMessaging() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      await messaging.requestPermission().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('Permission request timed out');
          return NotificationSettings(
            providesAppNotificationSettings: AppleNotificationSetting.disabled,
            alert: AppleNotificationSetting.disabled,
            announcement: AppleNotificationSetting.disabled,
            badge: AppleNotificationSetting.disabled,
            carPlay: AppleNotificationSetting.disabled,
            lockScreen: AppleNotificationSetting.disabled,
            notificationCenter: AppleNotificationSetting.disabled,
            showPreviews: AppleShowPreviewSetting.never,
            timeSensitive: AppleNotificationSetting.disabled,
            criticalAlert: AppleNotificationSetting.disabled,
            sound: AppleNotificationSetting.disabled,
            authorizationStatus: AuthorizationStatus.denied,
          );
        },
      );
      
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken().timeout(
          Duration(seconds: 5),
          onTimeout: () {
            print('APNS token request timed out');
            return null;
          },
        );
        
        if (apnsToken != null) {
          print('APNS Token: $apnsToken');
        } else {
          print('APNS token not available, will retry...');
          await Future.delayed(Duration(seconds: 2));
          apnsToken = await messaging.getAPNSToken().timeout(
            Duration(seconds: 3),
            onTimeout: () {
              print('APNS token retry timed out');
              return null;
            },
          );
          
          if (apnsToken == null) {
            print('APNS token still not available, skipping topic subscription');
            return;
          }
        }
      }
      
      await messaging.subscribeToTopic('daily_reminder').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('Topic subscription timed out');
        },
      );
      
      String? token = await messaging.getToken().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('FCM token request timed out');
          return null;
        },
      );
      
      if (token != null) {
        print('FCM Token: $token');
      }
      
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