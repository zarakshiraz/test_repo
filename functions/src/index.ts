import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

interface Reminder {
  id: string;
  listId: string;
  title: string;
  description?: string;
  scheduledTime: admin.firestore.Timestamp;
  audience: "self" | "allParticipants";
  createdBy: string;
  isActive: boolean;
  notifiedUsers: string[];
}

interface TodoList {
  id: string;
  name: string;
  ownerId: string;
  participantIds: string[];
}

export const scheduleReminderNotifications = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const oneMinuteFromNow = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 60000
    );

    const remindersSnapshot = await admin
      .firestore()
      .collection("reminders")
      .where("isActive", "==", true)
      .where("scheduledTime", ">=", now)
      .where("scheduledTime", "<=", oneMinuteFromNow)
      .get();

    const batch = admin.firestore().batch();
    const notifications: Promise<any>[] = [];

    for (const reminderDoc of remindersSnapshot.docs) {
      const reminder = reminderDoc.data() as Reminder;

      const listDoc = await admin
        .firestore()
        .collection("lists")
        .doc(reminder.listId)
        .get();

      if (!listDoc.exists) continue;

      const list = listDoc.data() as TodoList;

      let targetUserIds: string[] = [];
      if (reminder.audience === "self") {
        targetUserIds = [reminder.createdBy];
      } else if (reminder.audience === "allParticipants") {
        targetUserIds = list.participantIds;
      }

      targetUserIds = targetUserIds.filter(
        (userId) => !reminder.notifiedUsers.includes(userId)
      );

      for (const userId of targetUserIds) {
        const userTokensSnapshot = await admin
          .firestore()
          .collection("userTokens")
          .doc(userId)
          .get();

        if (userTokensSnapshot.exists) {
          const tokens = userTokensSnapshot.data()?.tokens || [];

          for (const token of tokens) {
            const message = {
              notification: {
                title: reminder.title,
                body: reminder.description || `Reminder for ${list.name}`,
              },
              data: {
                listId: reminder.listId,
                reminderId: reminder.id,
                type: "reminder",
              },
              token: token,
            };

            notifications.push(
              admin
                .messaging()
                .send(message)
                .catch((error) => {
                  console.error("Error sending notification:", error);
                  if (
                    error.code === "messaging/invalid-registration-token" ||
                    error.code === "messaging/registration-token-not-registered"
                  ) {
                    return admin
                      .firestore()
                      .collection("userTokens")
                      .doc(userId)
                      .update({
                        tokens: admin.firestore.FieldValue.arrayRemove(token),
                      });
                  }
                  return null;
                })
            );
          }
        }

        batch.update(reminderDoc.ref, {
          notifiedUsers: admin.firestore.FieldValue.arrayUnion(userId),
        });
      }

      if (targetUserIds.length > 0) {
        const allNotified =
          reminder.audience === "self" ||
          targetUserIds.length === list.participantIds.length;

        if (allNotified) {
          batch.update(reminderDoc.ref, {
            isActive: false,
          });
        }
      }
    }

    await Promise.all(notifications);
    await batch.commit();

    console.log(`Processed ${remindersSnapshot.docs.length} reminders`);
    return null;
  });

export const onReminderCreated = functions.firestore
  .document("reminders/{reminderId}")
  .onCreate(async (snap, context) => {
    const reminder = snap.data() as Reminder;

    console.log(`New reminder created: ${reminder.id} for list ${reminder.listId}`);

    return null;
  });

export const onReminderUpdated = functions.firestore
  .document("reminders/{reminderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data() as Reminder;
    const after = change.after.data() as Reminder;

    if (before.isActive && !after.isActive) {
      console.log(`Reminder ${after.id} was cancelled`);
    }

    return null;
  });

export const saveFCMToken = functions.https.onCall(
  async (data: { token: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const userId = context.auth.uid;
    const token = data.token;

    await admin
      .firestore()
      .collection("userTokens")
      .doc(userId)
      .set(
        {
          tokens: admin.firestore.FieldValue.arrayUnion(token),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

    console.log(`Saved FCM token for user ${userId}`);
    return {success: true};
  }
);

export const removeFCMToken = functions.https.onCall(
  async (data: { token: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const userId = context.auth.uid;
    const token = data.token;

    await admin
      .firestore()
      .collection("userTokens")
      .doc(userId)
      .update({
        tokens: admin.firestore.FieldValue.arrayRemove(token),
      });

    console.log(`Removed FCM token for user ${userId}`);
    return {success: true};
  }
);
