const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onRequest, logger} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

// Initialize Firebase Admin
initializeApp();

// ================= PRODUCTION FUNCTION =================
exports.sendStreakNotifications = onSchedule({
  schedule: "every day 15:00", // 3 PM daily
  timeZone: "America/Los_Angeles",
}, async (event) => {
  await sendNotifications();
  return null;
});

// ================= TEST ENDPOINT =================
exports.testPixel8Notification = onRequest(async (req, res) => {
  try {
    const db = getFirestore();
    const messaging = getMessaging();

    // REPLACE WITH YOUR PIXEL 8's FCM TOKEN
    const pixel8Token = "c_cNODgLQVapEezWv6Gar1:APA91bFGYiOA9P6YGt4gZD4C8P7uu3jmA0TQZOD0Heob-Os0ccar8MXKZL63HvJH2QYZOZypAYGFHMWihiFIyfOycyEpsR967blo41sQIc7-48eODkKi-S8";
    const pixel8DeviceId = "BP1A.250505.005.B1"; // Custom device ID for testing

    // Set up test data based on query params
    const scenario = req.query.scenario || "default";
    await setupTestData(db, pixel8DeviceId,
      scenario === "practiced_today" ? { streak: 5, practicedToday: true } :
      scenario === "broken_streak" ? { streak: 3, practicedToday: false } :
      { streak: 0, practicedToday: false }
    );

    // Get the device's data (same logic as original)
    const [streakData, activityData] = await Promise.all([
      db.collection("device_data")
        .doc(pixel8DeviceId)
        .collection("streak_data")
        .doc("current")
        .get(),
      db.collection("device_data")
        .doc(pixel8DeviceId)
        .collection("daily_activity")
        .doc(new Date().toISOString().split("T")[0])
        .get()
    ]);

    // Use original message logic but add TEST prefix
    const originalMessage = getNotificationMessage(
      streakData.data(),
      activityData.exists
    );

    const payload = {
      notification: {
        title: "TEST: Practice Reminder",
        body: originalMessage,
        sound: "default",
      },
      token: pixel8Token,
    };

    logger.log("Sending to Pixel 8:", payload);
    const response = await messaging.send(payload);
    logger.log("Success:", response);
    res.send(`Test notification sent to Pixel 8! Scenario: ${scenario}`);
  } catch (error) {
    logger.error("Pixel 8 test failed:", error);
    res.status(500).send("Test failed: " + error.message);
  }
});

// ================= SHARED NOTIFICATION LOGIC =================
async function sendNotifications(testScenario = null) {
  const db = getFirestore();
  const messaging = getMessaging();

  // Get test token from emulator (replace with your actual test token)
  const testToken = "YOUR_EMULATOR_FCM_TOKEN";

  // ===== EMULATOR TEST DATA SETUP =====
  if (process.env.FUNCTIONS_EMULATOR === "true") {
    const testDeviceId = "emulator_test_device";
    const today = new Date().toISOString().split("T")[0];

    // Clear previous test data
    await db.recursiveDelete(db.collection("device_data").doc(testDeviceId));

    // Set up test scenarios
    switch(testScenario) {
      case "practiced_today":
        await setupTestData(db, testDeviceId, {
          streak: 5,
          practicedToday: true
        });
        break;
      case "broken_streak":
        await setupTestData(db, testDeviceId, {
          streak: 3,
          practicedToday: false
        });
        break;
      default: // new_user
        await setupTestData(db, testDeviceId, {
          streak: 0,
          practicedToday: false
        });
    }

    // Override tokens snapshot for testing
    const tokensSnapshot = {
      docs: [{
        id: testDeviceId,
        data: () => ({ token: testToken }),
        ref: db.collection("device_tokens").doc(testDeviceId)
      }]
    };

    return processDevices(db, messaging, tokensSnapshot);
  }

  // ===== PRODUCTION EXECUTION =====
  const tokensSnapshot = await db.collection("device_tokens").get();
  return processDevices(db, messaging, tokensSnapshot);
}

// ================= HELPER FUNCTIONS =================
async function setupTestData(db, deviceId, {streak, practicedToday}) {
  const today = new Date().toISOString().split("T")[0];
  const batch = db.batch();

  // Set streak data
  const streakRef = db.collection("device_data")
    .doc(deviceId)
    .collection("streak_data")
    .doc("current");
  batch.set(streakRef, { current_streak: streak });

  // Set today's activity if needed
  if (practicedToday) {
    const activityRef = db.collection("device_data")
      .doc(deviceId)
      .collection("daily_activity")
      .doc(today);
    batch.set(activityRef, { total_time: 300 }); // 5 minutes
  }

  // Ensure device token exists
  const tokenRef = db.collection("device_tokens").doc(deviceId);
  batch.set(tokenRef, {
    token: "dM55nGnbQQCBHGwoARo86t:APA91bGi1T1q0yk6GbxBfKnYou6CHKp0nLG_6tCzosTGFFUMvL-f9YTqe_JB-FfRfAUOiX7_IFjys2yFE31_Iex2tj_Qwj8JPQbANbIsc40W7eHt5zPIANw",
    platform: "android"
  });

  await batch.commit();
}

async function processDevices(db, messaging, tokensSnapshot) {
  return Promise.all(tokensSnapshot.docs.map(async (doc) => {
    const deviceId = doc.id;
    const fcmToken = doc.data().token;

    const [streakData, activityData] = await Promise.all([
      db.collection("device_data")
        .doc(deviceId)
        .collection("streak_data")
        .doc("current")
        .get(),
      db.collection("device_data")
        .doc(deviceId)
        .collection("daily_activity")
        .doc(new Date().toISOString().split("T")[0])
        .get()
    ]);

    const message = getNotificationMessage(
      streakData.data(),
      activityData.exists
    );

    const payload = {
      notification: {
        title: process.env.FUNCTIONS_EMULATOR ?
          "[TEST] Practice Reminder" : "Practice Reminder",
        body: message,
        sound: "default",
      },
      token: fcmToken,
    };

    logger.log(`Sending to ${deviceId}:`, payload);

    try {
      const response = await messaging.send(payload);
      logger.log("Success:", response);
      return response;
    } catch (error) {
      logger.error("Error sending to " + deviceId, error);
      if (shouldRemoveToken(error)) {
        return doc.ref.delete();
      }
      return null;
    }
  }));
}

function getNotificationMessage(streakData, hasPracticedToday) {
  if (hasPracticedToday) {
    return "Great job today! Keep your streak going!";
  }
  if (streakData?.current_streak > 0) {
    return "Don't break your streak! Practice now!";
  }
  return "Get some practice in today!";
}

function shouldRemoveToken(error) {
  return [
    "messaging/invalid-registration-token",
    "messaging/registration-token-not-registered"
  ].includes(error.code);
}
