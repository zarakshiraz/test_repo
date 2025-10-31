# Environment Configuration Setup

This guide explains how to set up environment variables for the Grocli application.

## Overview

Grocli uses `flutter_dotenv` for environment variable management. This allows you to:
- Keep sensitive API keys out of source control
- Switch between development and production configurations
- Enable/disable features via flags
- Configure different environments easily

## Quick Start

1. **Copy the example file**:
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your values**:
   ```bash
   # Open in your editor
   nano .env
   # or
   code .env
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## Environment Files

The project supports multiple environment files:

| File | Purpose | Git Tracked |
|------|---------|-------------|
| `.env.example` | Template with all variables | ✅ Yes |
| `.env` | Default configuration (Development) | ❌ No |
| `.env.development` | Development environment | ❌ No |
| `.env.production` | Production environment | ❌ No |

**Important**: Never commit `.env`, `.env.development`, or `.env.production` files to version control. They are already in `.gitignore`.

## Required Configuration

### OpenAI API Key

AI features require an OpenAI API key:

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Add to `.env`:
   ```
   OPENAI_API_KEY=sk-your-key-here
   OPENAI_MODEL=gpt-4
   ```

**Note**: GPT-4 requires a paid OpenAI account. You can use `gpt-3.5-turbo` for free tier.

### Firebase Configuration

#### Method 1: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This automatically:
- Creates `firebase_options.dart`
- Sets up all platforms
- Configures Firebase services

#### Method 2: Manual Configuration

If you prefer manual setup or need environment-specific configs:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create or select your project
3. Go to Project Settings
4. Find your app configuration
5. Add to `.env`:
   ```
   FIREBASE_API_KEY=your-api-key
   FIREBASE_APP_ID=your-app-id
   FIREBASE_MESSAGING_SENDER_ID=your-sender-id
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_STORAGE_BUCKET=your-bucket
   ```

## Environment Variables Reference

### AI Configuration

```bash
# OpenAI API key for AI features
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx

# Model to use (gpt-4, gpt-3.5-turbo, etc.)
OPENAI_MODEL=gpt-4
```

### Firebase Configuration

```bash
# Firebase credentials (if not using firebase_options.dart)
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-storage-bucket
```

### App Configuration

```bash
# App name shown in UI
APP_NAME=Grocli Dev

# App version
APP_VERSION=1.0.0

# Environment name (development, staging, production)
ENVIRONMENT=development
```

### Feature Flags

```bash
# Enable AI-powered features (smart suggestions, voice commands)
ENABLE_AI_FEATURES=true

# Enable voice input functionality
ENABLE_VOICE_INPUT=true

# Enable analytics tracking
ENABLE_ANALYTICS=false
```

## Using Environment Variables

### In Dart Code

```dart
import 'package:grocli/core/config/env_config.dart';

// Access variables
final apiKey = EnvConfig.openAiApiKey;
final isProduction = EnvConfig.isProduction;

// Check feature flags
if (EnvConfig.enableAiFeatures) {
  // Show AI features
}

if (EnvConfig.enableVoiceInput) {
  // Enable voice input
}
```

### Direct Access

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Get value with default
final value = dotenv.env['KEY_NAME'] ?? 'default';

// Check if exists
if (dotenv.env.containsKey('KEY_NAME')) {
  // Key exists
}

// Get all keys
final keys = dotenv.env.keys;
```

## Multiple Environments

### Development Environment

```bash
# Use .env.development
cp .env.example .env.development
# Edit with development values
```

```dart
// In main.dart
await dotenv.load(fileName: '.env.development');
```

### Production Environment

```bash
# Use .env.production
cp .env.example .env.production
# Edit with production values
```

```dart
// In main.dart
await dotenv.load(fileName: '.env.production');
```

### Build Configurations

You can set up different build flavors:

```bash
# Development
flutter run --dart-define=ENVIRONMENT=development

# Production
flutter run --dart-define=ENVIRONMENT=production
```

Then in code:
```dart
const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
await dotenv.load(fileName: '.env.$environment');
```

## Security Best Practices

### ✅ DO:
- Keep `.env` files in `.gitignore`
- Use different keys for dev and production
- Rotate API keys regularly
- Use minimum required permissions
- Share keys securely (password managers, secure channels)
- Document required variables in `.env.example`

### ❌ DON'T:
- Commit `.env` files to git
- Share keys in plain text (email, chat)
- Use production keys in development
- Hardcode sensitive values in source code
- Share keys publicly (GitHub issues, forums)

## Troubleshooting

### Environment Variables Not Loading

**Problem**: Variables return empty or default values

**Solutions**:
1. Check file name is exactly `.env`
2. Verify file is in project root (same level as `pubspec.yaml`)
3. Ensure file is listed in `pubspec.yaml` assets
4. Restart the app (hot reload doesn't reload env files)
5. Check for syntax errors in `.env` file

### Syntax Errors

**Correct format**:
```bash
# Comments start with #
KEY_NAME=value
MULTI_WORD_KEY=multi word value

# No quotes needed (usually)
API_KEY=abc123

# Quotes for special characters
MESSAGE="Hello, World!"
```

**Common mistakes**:
```bash
# ❌ Spaces around =
KEY = value

# ❌ Missing value
KEY=

# ❌ Invalid characters in key
my-key=value  # Use underscores instead

# ❌ Duplicate keys
KEY=value1
KEY=value2  # Second value ignored
```

### File Not Found Error

**Error**: `Unable to load asset: .env`

**Solutions**:
1. Check `pubspec.yaml` has assets listed:
   ```yaml
   flutter:
     assets:
       - .env
   ```
2. Run `flutter clean && flutter pub get`
3. Restart the app

### Platform-Specific Issues

**iOS/macOS**: Ensure `.env` file is included in Xcode project
**Android**: Clean build with `flutter clean`
**Web**: Environment variables work but be cautious about exposing keys

## Team Setup

### For New Team Members

1. Get `.env.example` from repository
2. Copy to `.env`
3. Request API keys from team lead
4. Fill in values
5. Test with `flutter run`

### For Team Leads

1. Create `.env.example` with all variables (no values)
2. Document each variable
3. Set up secure key sharing process
4. Create separate Firebase projects for dev/prod
5. Provide onboarding instructions

## CI/CD Setup

### GitHub Actions

```yaml
- name: Create .env file
  run: |
    echo "OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }}" >> .env
    echo "FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }}" >> .env
```

### GitLab CI

```yaml
before_script:
  - echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> .env
  - echo "FIREBASE_API_KEY=$FIREBASE_API_KEY" >> .env
```

### Store secrets in:
- GitHub: Repository Settings → Secrets
- GitLab: Settings → CI/CD → Variables
- Bitbucket: Repository Settings → Pipelines → Repository variables

## Additional Resources

- [flutter_dotenv Documentation](https://pub.dev/packages/flutter_dotenv)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [Flutter Build Flavors](https://docs.flutter.dev/deployment/flavors)

## Support

If you encounter issues:
1. Check this documentation
2. Review `.env.example` for correct format
3. Check Flutter doctor: `flutter doctor`
4. Contact the development team
