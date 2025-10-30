# Grocli - Collaborative Smart List App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)
![Provider](https://img.shields.io/badge/State-Provider-blue)
![License](https://img.shields.io/badge/License-MIT-green)

**A beautiful, collaborative, AI-powered list management app built with Flutter**

[Features](#features) • [Setup](#setup) • [Documentation](#documentation) • [Screenshots](#screenshots) • [Contributing](#contributing)

</div>

---

## 📖 Overview

**Grocli** is a mobile-first collaborative list app that makes creating and sharing lists effortless. Whether it's groceries, errands, travel packing, or party planning, Grocli helps you coordinate with others in real-time with AI-powered features.

### Why Grocli?

- 🎤 **Voice Input**: Create lists by speaking naturally
- 🤖 **AI-Powered**: Automatically extract and format items
- 👥 **Real-time Collaboration**: Share and sync lists instantly
- 💬 **Built-in Chat**: Communicate within each list
- 📴 **Offline-First**: Works without internet, syncs when online
- 🔔 **Smart Reminders**: Never forget your lists
- 🎨 **Beautiful UI**: Modern, intuitive, and delightful to use

---

## ✨ Features

### Core Features
- ✅ **Multi-method Input**: Type or speak to create lists
- ✅ **AI Extraction**: Convert natural speech to organized items
- ✅ **Smart Suggestions**: Context-aware item recommendations
- ✅ **Real-time Sync**: Instant updates across all devices
- ✅ **Collaboration**: Share with view-only or edit permissions
- ✅ **In-list Chat**: Text and voice messages per list
- ✅ **Offline Support**: Full functionality without internet
- ✅ **Templates**: Save and reuse common lists
- ✅ **Reminders**: Time-based notifications
- ✅ **Contact Management**: Sync and manage contacts

### Authentication
- Email/Password
- Google Sign-In
- Apple Sign-In (iOS)

### List Management
- Create, edit, delete lists
- Categorize lists
- Track completion progress
- Reorder items with drag-drop
- Auto-complete from suggestions
- Archive completed lists

### Collaboration
- Share with multiple users
- Granular permissions (View/Edit)
- See who completed items
- Real-time participant updates
- Revoke access anytime

### Communication
- Text messaging per list
- Voice message recording
- Read receipts
- Auto-delete on list completion

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.9.2+
- Firebase account
- Android Studio / Xcode

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd grocli

# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Setup Firebase (see SETUP_GUIDE.md)
flutterfire configure

# Run the app
flutter run
```

---

## 📱 Screenshots

<!-- Add screenshots here -->
_Coming soon..._

---

## 🏗️ Architecture

```
Grocli/
├── lib/
│   ├── core/
│   │   ├── models/          # Data models
│   │   ├── providers/       # State management
│   │   ├── services/        # Business logic
│   │   ├── router/          # Navigation
│   │   ├── constants/       # App constants
│   │   └── pages/           # Core pages
│   ├── features/
│   │   ├── auth/            # Authentication
│   │   ├── lists/           # List management
│   │   ├── chat/            # Messaging
│   │   └── profile/         # User profile
│   ├── shared/
│   │   └── theme/           # Theming
│   └── main.dart
├── android/                 # Android config
├── ios/                     # iOS config
└── test/                    # Tests
```

### State Management: Provider

We use the Provider package for state management:
- **AuthProvider**: Authentication state
- **ListProvider**: List CRUD operations
- **MessageProvider**: Chat functionality  
- **ContactProvider**: Contact management
- **NotificationProvider**: Notifications & reminders

### Backend: Firebase

- **Authentication**: Email, Google, Apple
- **Firestore**: Real-time database
- **Storage**: Voice messages, images
- **Cloud Messaging**: Push notifications
- **Cloud Functions**: AI processing (optional)

### Local Storage: Hive

All data is cached locally using Hive for:
- Offline functionality
- Fast app startup
- Reduced network usage

---

## 📚 Documentation

- [Setup Guide](SETUP_GUIDE.md) - Detailed setup instructions
- [Features Documentation](FEATURES.md) - Complete feature list
- [Implementation Details](README_IMPLEMENTATION.md) - Technical details

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.9.2 - UI framework
- **Provider** 6.1.2 - State management
- **Go Router** 14.2.7 - Navigation
- **Hive** 2.2.3 - Local database

### Backend
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **Firebase Storage** - File storage
- **Firebase Messaging** - Push notifications

### Features
- **Speech-to-Text** - Voice input
- **Audio Recording** - Voice messages
- **Local Notifications** - Reminders
- **Contacts Service** - Contact sync

### UI/UX
- Material Design 3
- Custom animations
- Responsive layouts
- Dark mode support

---

## 🔧 Configuration

### Firebase Setup

1. Create Firebase project
2. Add Android and iOS apps
3. Download config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Run `flutterfire configure`

### Backend Setup (Cloud Functions)

The AI features require Firebase Cloud Functions to proxy OpenAI API calls. This ensures API keys are never stored client-side.

#### Prerequisites
- Node.js 18+ and npm
- Firebase CLI: `npm install -g firebase-tools`
- OpenAI API key: [Get one here](https://platform.openai.com/api-keys)
- Firebase Blaze plan (required for Cloud Functions)

#### Setup Steps

1. **Initialize Firebase Functions** (if not already done):
```bash
firebase init functions
# Select JavaScript or TypeScript
# Select your Firebase project
# Install dependencies
```

2. **Install Dependencies**:
```bash
cd functions
npm install openai
npm install --save firebase-admin firebase-functions
```

3. **Set OpenAI API Key**:
```bash
firebase functions:config:set openai.api_key="your-openai-api-key-here"
```

4. **Create Cloud Functions** in `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { OpenAI } = require('openai');

admin.initializeApp();

// Initialize OpenAI with API key from config
const openai = new OpenAI({
  apiKey: functions.config().openai.api_key,
});

/**
 * Transcribe audio using OpenAI Whisper
 * Input: { audioUrl: string }
 * Output: { text: string, confidence: number, language: string }
 */
exports.transcribeAudio = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { audioUrl } = data;
  if (!audioUrl) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'audioUrl is required'
    );
  }

  try {
    // Download audio from Firebase Storage
    const bucket = admin.storage().bucket();
    const fileName = audioUrl.split('/').pop().split('?')[0];
    const file = bucket.file(fileName);
    
    // Download to temporary file
    const tempPath = `/tmp/${fileName}`;
    await file.download({ destination: tempPath });

    // Transcribe with Whisper
    const transcription = await openai.audio.transcriptions.create({
      file: require('fs').createReadStream(tempPath),
      model: 'whisper-1',
      response_format: 'verbose_json',
    });

    // Cleanup temp file
    require('fs').unlinkSync(tempPath);

    return {
      text: transcription.text,
      confidence: 1.0, // Whisper doesn't provide confidence
      language: transcription.language,
    };
  } catch (error) {
    console.error('Transcription error:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Transcription failed: ${error.message}`
    );
  }
});

/**
 * Extract list items from text using GPT
 * Input: { text: string }
 * Output: { items: Array<{content, confidence, category, notes}> }
 */
exports.extractListItems = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { text } = data;
  if (!text) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'text is required'
    );
  }

  try {
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: `You are a helpful assistant that extracts list items from natural language text.
Extract individual items and return them as a JSON array.
Each item should have: content (string), confidence (0-1), category (optional), notes (optional).
Clean up the text, remove filler words, and standardize formatting.
Example input: "I need milk, eggs, and maybe some bread"
Example output: {"items": [{"content": "Milk", "confidence": 1.0}, {"content": "Eggs", "confidence": 1.0}, {"content": "Bread", "confidence": 0.7}]}`
        },
        {
          role: 'user',
          content: text
        }
      ],
      temperature: 0.3,
      response_format: { type: 'json_object' },
    });

    const result = JSON.parse(completion.choices[0].message.content);
    return result;
  } catch (error) {
    console.error('Extraction error:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Item extraction failed: ${error.message}`
    );
  }
});
```

5. **Deploy Functions**:
```bash
firebase deploy --only functions
```

6. **Configure CORS** (if needed):
```bash
# In Firebase Console -> Storage -> Rules
# Allow authenticated users to read/write their transcription files
```

#### API Contract

**transcribeAudio**
- **Input**: `{ audioUrl: string }` - Firebase Storage URL
- **Output**: `{ text: string, confidence: number, language: string }`
- **Auth**: Firebase Auth ID token (automatic)

**extractListItems**
- **Input**: `{ text: string }` - Raw text to process
- **Output**: `{ items: Array<{content, confidence, category?, notes?}> }`
- **Auth**: Firebase Auth ID token (automatic)

#### Cost Estimates

- Whisper API: ~$0.006 per minute of audio
- GPT-3.5 Turbo: ~$0.0005 per request (typical)
- Firebase Storage: Free tier usually sufficient
- Cloud Functions: Free tier: 2M invocations/month

#### Testing

Test your functions locally:
```bash
cd functions
npm run serve
# Use Firebase Emulator Suite
```

#### Security Notes

- ✅ API keys stored securely in Cloud Functions config
- ✅ Never exposed to client-side code
- ✅ Firebase Auth ensures only authenticated users can call functions
- ✅ Audio files stored in user-specific Storage paths
- ✅ Automatic cleanup of processed audio files

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Coverage report
flutter test --coverage
```

---

## 📦 Build

### Android
```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build
flutter build ios --release

# Archive in Xcode
open ios/Runner.xcworkspace
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow [Flutter style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before committing
- Write tests for new features
- Update documentation

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Development Team

- **Lead Developer**: [Your Name]
- **UI/UX Designer**: [Designer Name]
- **Backend Engineer**: [Engineer Name]

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for robust backend services
- The open-source community
- All contributors and testers

---

## 📞 Support

- **Email**: support@grocli.app
- **Issues**: [GitHub Issues](https://github.com/yourusername/grocli/issues)
- **Documentation**: [Wiki](https://github.com/yourusername/grocli/wiki)

---

## 🗺️ Roadmap

### Version 1.1 (Coming Soon)
- [ ] Custom categories
- [ ] Template marketplace
- [ ] Spending tracker
- [ ] Barcode scanner
- [ ] Receipt capture

### Version 1.2
- [ ] Smart home integration
- [ ] Location reminders
- [ ] Store navigation
- [ ] Price comparison
- [ ] Deals & coupons

### Version 2.0
- [ ] Team workspaces
- [ ] Advanced analytics
- [ ] AI assistant
- [ ] Voice-only mode
- [ ] Meal planning

---

## 📊 Status

- [x] Core functionality
- [x] Authentication
- [x] Real-time sync
- [x] Offline support
- [x] Chat functionality
- [ ] App Store release
- [ ] Play Store release
- [ ] Web version
- [ ] Desktop apps

---

<div align="center">

**Built with ❤️ using Flutter and Firebase**

⭐ Star us on GitHub — it helps!

[Website](https://grocli.app) • [Twitter](https://twitter.com/grocli) • [Discord](https://discord.gg/grocli)

</div>
