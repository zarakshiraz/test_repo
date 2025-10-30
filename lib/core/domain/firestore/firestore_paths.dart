/// Central helper class for Firestore collection and document paths.
/// Provides a consistent way to reference Firestore paths across the app.
class FirestorePaths {
  // Root collections
  static const String users = 'users';
  static const String lists = 'lists';
  static const String templates = 'templates';

  // Subcollections
  static const String items = 'items';
  static const String messages = 'messages';
  static const String participants = 'participants';
  static const String activities = 'activities';
  static const String reminders = 'reminders';
  static const String contacts = 'contacts';

  // User paths
  static String user(String userId) => '$users/$userId';
  static String userContacts(String userId) => '${user(userId)}/$contacts';
  static String userContact(String userId, String contactId) =>
      '${userContacts(userId)}/$contactId';

  // List paths
  static String list(String listId) => '$lists/$listId';
  
  // List subcollection paths
  static String listItems(String listId) => '${list(listId)}/$items';
  static String listItem(String listId, String itemId) =>
      '${listItems(listId)}/$itemId';

  static String listMessages(String listId) => '${list(listId)}/$messages';
  static String listMessage(String listId, String messageId) =>
      '${listMessages(listId)}/$messageId';

  static String listParticipants(String listId) =>
      '${list(listId)}/$participants';
  static String listParticipant(String listId, String participantId) =>
      '${listParticipants(listId)}/$participantId';

  static String listActivities(String listId) => '${list(listId)}/$activities';
  static String listActivity(String listId, String activityId) =>
      '${listActivities(listId)}/$activityId';

  // Template paths
  static String template(String templateId) => '$templates/$templateId';

  // Reminder paths - stored at root level for efficient querying
  static String reminder(String reminderId) => '$reminders/$reminderId';

  // Query helpers
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String statusField = 'status';
  static const String createdByUserIdField = 'createdByUserId';
  static const String listIdField = 'listId';
  static const String userIdField = 'userId';
  static const String reminderTimeField = 'reminderTime';
  static const String isSentField = 'isSent';
  static const String isCancelledField = 'isCancelled';
}
