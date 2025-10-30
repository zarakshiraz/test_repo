class AppConstants {
  // App Info
  static const String appName = 'Grocli';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'grocli.db';
  static const int databaseVersion = 1;
  
  // Hive Boxes
  static const String userBox = 'users';
  static const String listBox = 'lists';
  static const String listItemBox = 'list_items';
  static const String messageBox = 'messages';
  static const String settingsBox = 'settings';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String listsCollection = 'lists';
  static const String listItemsCollection = 'list_items';
  static const String messagesCollection = 'messages';
  
  // Shared Preferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String currentUserIdKey = 'current_user_id';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  
  // API Endpoints
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String speechToTextEndpoint = '/audio/transcriptions';
  
  // Audio Settings
  static const int maxRecordingDuration = 300; // 5 minutes in seconds
  static const int maxVoiceMessageDuration = 60; // 1 minute in seconds
  
  // List Settings
  static const int maxListItems = 1000;
  static const int maxListTitleLength = 100;
  static const int maxListDescriptionLength = 500;
  static const int maxItemContentLength = 200;
  
  // Chat Settings
  static const int maxMessageLength = 1000;
  static const int messagesPerPage = 50;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Permissions
  static const List<String> requiredPermissions = [
    'android.permission.RECORD_AUDIO',
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
  ];
}