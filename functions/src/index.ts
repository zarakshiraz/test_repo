import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const helloWorld = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to call this function."
    );
  }

  return {message: "Hello from Grocli Cloud Functions!"};
});

export const aiProxyFunction = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to call this function."
      );
    }

    const {text, operation} = data;

    if (!text || !operation) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields: text and operation"
      );
    }

    try {
      let result;

      switch (operation) {
        case "extractItems":
          result = await extractItemsFromText(text);
          break;
        case "suggestItems":
          result = await suggestRelatedItems(text);
          break;
        case "categorizeItem":
          result = await categorizeItem(text);
          break;
        default:
          throw new functions.https.HttpsError(
            "invalid-argument",
            `Unknown operation: ${operation}`
          );
      }

      await logAIRequest(context.auth.uid, operation, text);

      return {
        success: true,
        result: result,
      };
    } catch (error) {
      console.error("AI proxy error:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to process AI request",
        error
      );
    }
  }
);

async function extractItemsFromText(text: string): Promise<string[]> {
  console.log("Extracting items from:", text);
  const words = text.toLowerCase().split(/[,\s]+/);
  return words.filter((word) => word.length > 2);
}

async function suggestRelatedItems(itemName: string): Promise<string[]> {
  console.log("Suggesting items for:", itemName);
  const suggestions: {[key: string]: string[]} = {
    milk: ["bread", "eggs", "butter", "cheese"],
    bread: ["butter", "jam", "peanut butter"],
    eggs: ["milk", "bread", "bacon"],
  };

  return suggestions[itemName.toLowerCase()] || [];
}

async function categorizeItem(itemName: string): Promise<string> {
  console.log("Categorizing item:", itemName);
  const categories: {[key: string]: string} = {
    milk: "Dairy",
    bread: "Bakery",
    eggs: "Dairy",
    apple: "Produce",
    banana: "Produce",
  };

  return categories[itemName.toLowerCase()] || "Other";
}

async function logAIRequest(
  userId: string,
  operation: string,
  input: string
): Promise<void> {
  await admin.firestore().collection("ai_logs").add({
    userId: userId,
    operation: operation,
    input: input,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}

export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const userDoc = {
    uid: user.uid,
    email: user.email,
    displayName: user.displayName || null,
    photoURL: user.photoURL || null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastSeen: admin.firestore.FieldValue.serverTimestamp(),
  };

  await admin.firestore().collection("users").doc(user.uid).set(userDoc);

  console.log("Created user document for:", user.uid);
});

export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const batch = admin.firestore().batch();

  batch.delete(admin.firestore().collection("users").doc(user.uid));

  const listsSnapshot = await admin
    .firestore()
    .collection("lists")
    .where("ownerId", "==", user.uid)
    .get();

  listsSnapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();

  console.log("Deleted user data for:", user.uid);
});

export const sendListInvitationNotification = functions.firestore
  .document("invitations/{invitationId}")
  .onCreate(async (snapshot, context) => {
    const invitation = snapshot.data();
    const recipientId = invitation.recipientId;

    const recipientDoc = await admin
      .firestore()
      .collection("users")
      .doc(recipientId)
      .collection("private")
      .doc("tokens")
      .get();

    if (!recipientDoc.exists) {
      console.log("No FCM token found for user:", recipientId);
      return;
    }

    const tokens = recipientDoc.data()?.fcmTokens || [];

    if (tokens.length === 0) {
      return;
    }

    const message = {
      notification: {
        title: "New List Invitation",
        body: `${invitation.senderName} invited you to ${invitation.listName}`,
      },
      data: {
        type: "list_invitation",
        invitationId: context.params.invitationId,
        listId: invitation.listId,
      },
      tokens: tokens,
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      console.log("Successfully sent notification:", response);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });
