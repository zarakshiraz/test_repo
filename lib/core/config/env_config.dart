import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAiModel => dotenv.env['OPENAI_MODEL'] ?? 'gpt-4';
  
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  
  static String get appName => dotenv.env['APP_NAME'] ?? 'Grocli';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  
  static bool get enableAiFeatures => dotenv.env['ENABLE_AI_FEATURES']?.toLowerCase() == 'true';
  static bool get enableVoiceInput => dotenv.env['ENABLE_VOICE_INPUT']?.toLowerCase() == 'true';
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
