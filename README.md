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

### Environment Variables

Create `.env` file (optional):
```env
AI_API_KEY=your_api_key
AI_API_URL=your_api_url
```

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
