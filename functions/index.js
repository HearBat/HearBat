const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onRequest} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// ================= PRODUCTION NOTIFICATIONS =================
exports.sendStreakNotifications = onSchedule({
  schedule: "every day 15:00", // 3 PM daily
  timeZone: "America/Los_Angeles",
}, async () => {
  const db = getFirestore();
  const messaging = getMessaging();
  const today = new Date().toISOString().split('T')[0];

  try {
    const tokensSnapshot = await db.collection('device_tokens').get();

    await Promise.all(tokensSnapshot.docs.map(async (doc) => {
      const deviceId = doc.id;
      const fcmToken = doc.data().token;

      const [streakData, activityData] = await Promise.all([
        db.collection('device_data')
          .doc(deviceId)
          .collection('streak_data')
          .doc('current')
          .get(),
        db.collection('device_data')
          .doc(deviceId)
          .collection('daily_activity')
          .doc(today)
          .get()
      ]);

      const currentStreak = streakData.data()?.current_streak || 0;
      const hasPracticedToday = activityData.exists;

      const message = hasPracticedToday
        ? "Great job today! Keep your streak going!"
        : currentStreak > 0
          ? `Don't break your ${currentStreak}-day streak! Practice now!`
          : "Get some practice in today!";

      try {
        await messaging.send({
          notification: {
            title: "Practice Reminder",
            body: message,
          },
          android: {
            priority: "high",
            notification: {
              sound: "default",
              channel_id: "high_importance_channel"
            }
          },
          token: fcmToken,
        });
      } catch (error) {
        if (["messaging/invalid-registration-token",
             "messaging/registration-token-not-registered"].includes(error.code)) {
          await doc.ref.delete();
        }
      }
    }));
  } catch (error) {
    console.error("Batch error:", error);
  }
});

// ================== TEST ENDPOINT ===================
exports.sendTestNotification = onRequest(async (req, res) => {
  const db = getFirestore();
  const messaging = getMessaging();
  const today = new Date().toISOString().split('T')[0];

  try {
    // Replace with your test device details
    const testToken = "YOUR_DEVICE_TOKEN";
    const testDeviceId = "YOUR_DEVICE_ID";

    const [streakData, activityData] = await Promise.all([
      db.collection('device_data')
        .doc(testDeviceId)
        .collection('streak_data')
        .doc('current')
        .get(),
      db.collection('device_data')
        .doc(testDeviceId)
        .collection('daily_activity')
        .doc(today)
        .get()
    ]);

    const currentStreak = streakData.data()?.current_streak || 0;
    const hasPracticedToday = activityData.exists;

    const message = hasPracticedToday
      ? "Great job today! Keep your streak going!"
      : currentStreak > 0
        ? `Don't break your ${currentStreak}-day streak! Practice now!`
        : "Get some practice in today!";

    await messaging.send({
      notification: {
        title: "Practice Reminder",
        body: message,
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channel_id: "high_importance_channel"
        }
      },
      token: testToken,
    });

    res.send(`Test notification sent: "${message}"`);
  } catch (error) {
    console.error("Test failed:", error);
    res.status(500).send("Error: " + error.message);
  }
});