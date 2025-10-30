# Grocli - Collaborative Smart List App

A mobile-first Flutter application designed to simplify and enhance list creation, sharing, and real-time collaboration. Users can create personal or shared lists (groceries, errands, recipes, travel packing, etc.) that sync seamlessly across participants.

## Features

### Core Features
- **Account System**: Email, Google, and Apple login support
- **List Creation**: Create lists with AI-powered transcription and smart suggestions
- **Real-time Collaboration**: Share lists with view-only or edit permissions
- **In-list Communication**: Built-in chat with text and voice messages
- **Offline Functionality**: Create and edit lists offline with automatic sync
- **Smart Suggestions**: AI-powered item suggestions based on existing entries

### Key Capabilities
- 🎤 **Voice Input**: Record audio descriptions that are automatically transcribed into list items
- 🤝 **Sharing & Permissions**: Share lists with contacts and control their access levels
- 💬 **List-specific Chat**: Communicate within the context of each shared list
- 📱 **Cross-platform**: iOS and Android support
- 🔄 **Real-time Sync**: Changes sync instantly across all participants
- 📚 **Saved Templates**: Save and reuse frequently used lists
- 🔔 **Smart Reminders**: Set reminders for yourself or everyone on the list

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── models/            # Data models (User, List, ListItem, Message)
│   ├── pages/             # Core pages (Splash, Main)
│   ├── router/            # App navigation and routing
│   ├── services/          # Core services
│   └── utils/             # Utility functions
├── features/
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Auth data layer
│   │   ├── domain/        # Auth business logic
│   │   └── presentation/  # Auth UI components
│   ├── lists/             # Lists management feature
│   │   ├── data/          # Lists data layer
│   │   ├── domain/        # Lists business logic
│   │   └── presentation/  # Lists UI components
│   ├── chat/              # In-list chat feature
│   └── profile/           # User profile feature
└── shared/
    ├── theme/             # App theming
    └── widgets/           # Reusable UI components
```

## Tech Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: BLoC (flutter_bloc)
- **Navigation**: GoRouter
- **Local Database**: Hive + SQLite
- **Authentication**: Firebase Auth
- **Real-time Data**: Cloud Firestore
- **Voice Processing**: Speech-to-Text + OpenAI API
- **UI Components**: Material Design 3

## Dependencies

### Core Dependencies
- `flutter_bloc` - State management
- `go_router` - Navigation
- `hive` & `sqflite` - Local storage
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Backend services
- `speech_to_text`, `record`, `audioplayers` - Audio features
- `google_sign_in`, `sign_in_with_apple` - Social authentication

### UI & Utilities
- `flutter_slidable` - Swipe actions
- `cached_network_image` - Image caching
- `permission_handler` - Device permissions
- `connectivity_plus` - Network status
- `share_plus` - Native sharing

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase project setup (for authentication and real-time features)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd grocli
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure Firebase**
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Authentication and Firestore

5. **Run the app**
   ```bash
   flutter run
   ```

## Development Status

### ✅ Completed
- Project structure and architecture setup
- Core data models (User, List, ListItem, Message)
- UI foundation with Material Design 3 theming
- Navigation system with GoRouter
- Authentication UI (Login/Register pages)
- Lists management UI with mock data
- List creation with voice input simulation

### 🚧 In Progress
- Authentication system implementation
- Database setup and data persistence
- Real-time collaboration features
- AI-powered transcription and suggestions

### 📋 Planned
- In-list chat functionality
- Offline sync capabilities
- Push notifications
- Advanced sharing features
- Performance optimizations

## Contributing

This project follows clean architecture principles with feature-based organization. When contributing:

1. Follow the established folder structure
2. Use BLoC for state management
3. Write tests for business logic
4. Follow Flutter/Dart style guidelines
5. Update documentation for new features

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please contact the development team.
