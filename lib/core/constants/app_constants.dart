class AppConstants {
  // App Info
  static const String appName = 'Grocli';
  static const String appTagline = 'Collaborative Smart Lists';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String listsCollection = 'lists';
  static const String itemsSubcollection = 'items';
  static const String messagesSubcollection = 'messages';
  static const String contactsSubcollection = 'contacts';
  static const String notificationsSubcollection = 'notifications';

  // Storage Paths
  static const String voiceMessagesPath = 'voice_messages';
  static const String profilePicturesPath = 'profile_pictures';

  // Notification Channels
  static const String notificationChannelId = 'grocli_channel';
  static const String notificationChannelName = 'Grocli Notifications';
  static const String reminderChannelId = 'grocli_reminders';
  static const String reminderChannelName = 'Grocli Reminders';

  // Limits
  static const int maxListTitleLength = 100;
  static const int maxListDescriptionLength = 500;
  static const int maxItemContentLength = 200;
  static const int maxMessageLength = 1000;
  static const int maxVoiceMessageDuration = 300; // 5 minutes in seconds
  static const int maxContactsPerUser = 500;
  static const int maxSharedUsersPerList = 50;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int animationDuration = 300; // milliseconds

  // Categories
  static const List<String> defaultCategories = [
    'Groceries',
    'Shopping',
    'Travel',
    'Party',
    'Work',
    'Personal',
    'Other',
  ];

  // AI
  static const int maxAISuggestionsCount = 5;
  static const int aiProcessingTimeout = 10; // seconds

  // Cache
  static const Duration cacheExpiration = Duration(days: 7);
  static const String hiveBoxUsers = 'users';
  static const String hiveBoxLists = 'lists';
  static const String hiveBoxItems = 'items';
  static const String hiveBoxMessages = 'messages';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String permissionError = 'Permission denied. Please enable required permissions.';

  // Success Messages
  static const String listCreated = 'List created successfully!';
  static const String listUpdated = 'List updated successfully!';
  static const String listDeleted = 'List deleted successfully!';
  static const String itemAdded = 'Item added successfully!';
  static const String messageSent = 'Message sent!';
  static const String contactAdded = 'Contact added!';
}
