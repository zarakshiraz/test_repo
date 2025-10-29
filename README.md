# Grocli - Smart Grocery List Assistant

A beautiful, accessible, and intelligent grocery list application built with Flutter 3. Grocli helps you organize your shopping with AI-powered suggestions, smooth animations, and a polished user experience that adapts to both iOS and Android platforms.

## ✨ Features

### 🎨 Cohesive Visual Identity
- **Design System**: Comprehensive design tokens including color palette, typography, iconography, and spacing
- **Color Palette**: 
  - Primary Green (#4CAF50) - Fresh and natural
  - Secondary Orange (#FF9800) - Energetic and warm
  - Accent Blue (#2196F3) - Smart and trustworthy
- **Typography**: Hierarchical text styles with optimal readability
- **Spacing System**: Consistent 8pt grid system for layouts

### 📱 Platform-Adaptive Design
- **Material Design** for Android with Material 3 components
- **Cupertino Design** for iOS with native iOS widgets
- **Responsive Layouts** that adapt to different screen sizes
- **Platform-specific interactions** (dialogs, navigation patterns)

### ✨ Smooth Animations & Micro-interactions
- **List Operations**: 
  - Swipe-to-delete with haptic feedback
  - Smooth item addition with slide and fade animations
  - Checkbox toggle with visual feedback
- **Chat Transitions**: 
  - Slide transition for chat screen navigation
  - Typing indicator with animated dots
  - Message bubble animations
- **Suggestion Acceptance**: 
  - Interactive suggestion chips
  - Snackbar confirmation with haptic feedback
- **Progress Indicator**: 
  - Animated circular progress showing completion rate
  - Smooth percentage transitions

### ♿ Comprehensive Accessibility
- **Text Scaling**: Supports system text size from 0.8x to 2.0x
- **High Contrast**: WCAG AA compliant color contrasts
- **Screen Reader Support**: 
  - Semantic labels for all interactive elements
  - Meaningful announcements for state changes
  - Proper widget roles (button, checkbox, etc.)
- **Haptic Feedback**: 
  - Light feedback for navigation
  - Medium feedback for actions
  - Success/error patterns for confirmations
- **Keyboard Navigation**: Full keyboard support

### 🎯 User Experience
- **Onboarding Flow**: 
  - 4-screen tutorial introducing key features
  - Skip option for returning users
  - Smooth page transitions
- **Main List Screen**:
  - Clean, organized grocery list
  - Category tags for items
  - Quantity badges
  - Progress tracking
  - Empty state with helpful guidance
- **AI Chat Assistant**:
  - Smart suggestions for meal planning
  - Quick-add suggestion chips
  - Context-aware responses
  - Interactive conversation flow

## 🏗️ Architecture

### Design System Structure
```
lib/design_system/
├── colors.dart       # Color palette and theme colors
├── typography.dart   # Text styles and font definitions
├── spacing.dart      # Spacing tokens and dimensions
└── theme.dart        # Material and Cupertino themes
```

### Screen Structure
```
lib/screens/
├── onboarding_screen.dart   # Tutorial and introduction
├── home_screen.dart         # Main grocery list interface
└── chat_screen.dart         # AI assistant chat
```

### Widgets & Components
```
lib/widgets/
├── grocery_list_item.dart   # Reusable list item component
└── chat_message_bubble.dart # Chat message UI component
```

### Models & Utilities
```
lib/models/
└── grocery_item.dart        # Data models for items and messages

lib/utils/
└── haptic_feedback.dart     # Haptic feedback utilities
```

## 🎨 Design Tokens

### Color System
| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| Primary | #4CAF50 | #81C784 | Main actions, CTAs |
| Secondary | #FF9800 | #FFB74D | Accents, highlights |
| Tertiary | #2196F3 | #64B5F6 | Links, info |
| Surface | #FFFFFF | #1E1E1E | Cards, containers |
| Background | #FAFAFA | #121212 | Screen backgrounds |

### Typography Scale
| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| H1 | 32px | Bold | 1.2 | Page titles |
| H2 | 28px | Bold | 1.3 | Section headers |
| H3 | 24px | SemiBold | 1.3 | Card titles |
| Body1 | 16px | Regular | 1.5 | Primary text |
| Body2 | 14px | Regular | 1.5 | Secondary text |
| Caption | 12px | Regular | 1.4 | Helper text |

### Spacing Scale
| Token | Value | Usage |
|-------|-------|-------|
| xxxs | 2px | Minimal gaps |
| xxs | 4px | Tight spacing |
| xs | 8px | Compact spacing |
| sm | 12px | Small spacing |
| md | 16px | Default spacing |
| lg | 24px | Large spacing |
| xl | 32px | Extra large spacing |
| xxl | 48px | Section spacing |

### Border Radius
| Token | Value | Usage |
|-------|-------|-------|
| sm | 4px | Small elements |
| md | 8px | Cards, inputs |
| lg | 12px | Prominent cards |
| xl | 16px | FAB, large buttons |
| round | 999px | Pills, chips |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0+
- iOS Simulator or Android Emulator (or physical device)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd grocli
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Platform-Specific Setup

#### iOS
```bash
cd ios
pod install
cd ..
flutter run
```

#### Android
```bash
flutter run
```

#### Web
```bash
flutter run -d chrome
```

## 📸 Screenshots

### Onboarding Flow
The app features a beautiful 4-screen onboarding experience that introduces users to key features:
1. Welcome screen with Grocli branding
2. AI-powered suggestions feature
3. Item tracking and organization
4. Accessibility features

### Main List Screen
- Clean, organized grocery list with category tags
- Progress indicator showing completion rate
- Quick-add floating action button
- Swipe-to-delete functionality
- Empty state with guidance

### Chat Assistant
- Conversational AI interface
- Smart suggestions as tappable chips
- Typing indicator
- Smooth message transitions

## 🎯 Accessibility Features

### Screen Reader Support
All interactive elements include:
- Descriptive labels
- State announcements
- Semantic hints

Example:
```dart
Semantics(
  label: 'Milk, 2 items, not completed',
  button: true,
  checked: false,
  onTapHint: 'Toggle completion',
  child: ListItem(...)
)
```

### Text Scaling
The app supports system text scaling from 0.8x to 2.0x:
```dart
MediaQuery.of(context).textScaler.clamp(
  minScaleFactor: 0.8,
  maxScaleFactor: 2.0,
)
```

### Color Contrast
All text meets WCAG AA standards:
- Normal text: 4.5:1 minimum contrast
- Large text: 3:1 minimum contrast
- Interactive elements: Clear focus states

### Haptic Feedback Patterns
- **Light**: Navigation, selections
- **Medium**: Actions, confirmations
- **Heavy**: Errors, important alerts
- **Success**: Two-stage (medium + light)
- **Error**: Double heavy impact

## 🔧 Customization

### Changing Theme Colors
Edit `lib/design_system/colors.dart`:
```dart
static const Color primaryGreen = Color(0xFF4CAF50); // Your color here
```

### Modifying Spacing
Edit `lib/design_system/spacing.dart`:
```dart
static const double md = 16.0; // Your spacing value
```

### Adding Typography Styles
Edit `lib/design_system/typography.dart`:
```dart
static const TextStyle customStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
```

## 🧪 Testing

### Running Tests
```bash
flutter test
```

### Running Tests with Coverage
```bash
flutter test --coverage
```

## 📦 Dependencies

- **flutter**: SDK for building the app
- **cupertino_icons**: iOS-style icons (^1.0.8)

### Dev Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: Linting rules (^5.0.0)

## 🏆 Best Practices

### Code Organization
- Design system tokens separated from implementation
- Reusable widget components
- Clean separation of models and UI
- Consistent naming conventions

### Performance
- Efficient list rendering with ListView.builder
- Optimized animations with SingleTickerProviderStateMixin
- Minimal rebuilds with proper state management

### Accessibility
- Semantic labels on all interactive elements
- Support for screen readers
- Haptic feedback for better UX
- High contrast color ratios

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:
1. Follow Flutter style guide
2. Maintain design system consistency
3. Include accessibility features
4. Add tests for new features
5. Update documentation

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design guidelines
- iOS Human Interface Guidelines
- WCAG accessibility standards

---

**Built with ❤️ using Flutter**
