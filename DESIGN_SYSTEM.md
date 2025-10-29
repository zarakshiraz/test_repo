# Grocli Design System Documentation

## Overview

The Grocli design system provides a cohesive, accessible, and platform-adaptive visual language for the grocery list application. This document outlines all design tokens, components, patterns, and guidelines.

## Design Principles

1. **Clarity**: Clear visual hierarchy and intuitive interactions
2. **Consistency**: Unified design language across all screens
3. **Accessibility**: WCAG AA compliant with comprehensive accessibility features
4. **Platform-Adaptive**: Native feel on both iOS and Android
5. **Delightful**: Smooth animations and micro-interactions

---

## Color System

### Primary Palette

**Primary Green** - Fresh and Natural
- Light: `#81C784` (RGB: 129, 199, 132)
- Main: `#4CAF50` (RGB: 76, 175, 80)
- Dark: `#388E3C` (RGB: 56, 142, 60)
- Usage: Primary actions, CTAs, branding

**Secondary Orange** - Energetic and Warm
- Light: `#FFB74D` (RGB: 255, 183, 77)
- Main: `#FF9800` (RGB: 255, 152, 0)
- Dark: `#F57C00` (RGB: 245, 124, 0)
- Usage: Accents, highlights, secondary actions

**Accent Blue** - Smart and Trustworthy
- Light: `#64B5F6` (RGB: 100, 181, 246)
- Main: `#2196F3` (RGB: 33, 150, 243)
- Dark: `#1976D2` (RGB: 25, 118, 210)
- Usage: Links, information, chat suggestions

### Semantic Colors

**Success**: `#388E3C` - Confirmations, completed items
**Error**: `#D32F2F` - Errors, destructive actions
**Warning**: `#FFA000` - Warnings, cautions
**Info**: `#1976D2` - Informational messages

### Surface Colors

**Light Theme**
- Background: `#FAFAFA` (RGB: 250, 250, 250)
- Surface: `#FFFFFF` (RGB: 255, 255, 255)
- Divider: `#E0E0E0` (RGB: 224, 224, 224)

**Dark Theme**
- Background: `#121212` (RGB: 18, 18, 18)
- Surface: `#1E1E1E` (RGB: 30, 30, 30)
- Divider: `#424242` (RGB: 66, 66, 66)

### Text Colors

**Light Theme**
- Primary: `#212121` (RGB: 33, 33, 33)
- Secondary: `#757575` (RGB: 117, 117, 117)
- Hint: `#BDBDBD` (RGB: 189, 189, 189)

**Dark Theme**
- Primary: `#FFFFFF` (RGB: 255, 255, 255)
- Secondary: `#B0B0B0` (RGB: 176, 176, 176)
- Hint: `#616161` (RGB: 97, 97, 97)

### Contrast Ratios

All color combinations meet WCAG AA standards:
- Normal text: 4.5:1 minimum
- Large text: 3:1 minimum
- Interactive elements: 3:1 minimum

---

## Typography

### Font Family

Primary: **Roboto** (system default on Android)
Fallback: **San Francisco** (system default on iOS)

### Type Scale

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| H1 | 32px | Bold (700) | 1.2 | -0.5px | Page titles |
| H2 | 28px | Bold (700) | 1.3 | -0.3px | Section headers |
| H3 | 24px | SemiBold (600) | 1.3 | 0px | Card titles |
| H4 | 20px | SemiBold (600) | 1.4 | 0.15px | Subsection headers |
| H5 | 18px | SemiBold (600) | 1.4 | 0.15px | List headers |
| Subtitle 1 | 16px | Medium (500) | 1.5 | 0.15px | Emphasized text |
| Subtitle 2 | 14px | Medium (500) | 1.5 | 0.1px | De-emphasized text |
| Body 1 | 16px | Regular (400) | 1.5 | 0.5px | Primary body text |
| Body 2 | 14px | Regular (400) | 1.5 | 0.25px | Secondary body text |
| Button | 14px | SemiBold (600) | 1.4 | 1.25px | Button labels |
| Caption | 12px | Regular (400) | 1.4 | 0.4px | Helper text, labels |
| Overline | 10px | Medium (500) | 1.6 | 1.5px | Category labels |

### Text Accessibility

- Supports dynamic text scaling from 0.8x to 2.0x
- Maintains readability at all scale factors
- Proper contrast ratios at all sizes

---

## Spacing System

### Base Unit: 8px

All spacing follows an 8-point grid system for visual consistency.

### Spacing Tokens

| Token | Value | Usage |
|-------|-------|-------|
| xxxs | 2px | Minimal gaps, tight inline elements |
| xxs | 4px | Very tight spacing |
| xs | 8px | Compact spacing, list item gaps |
| sm | 12px | Small padding, close elements |
| md | 16px | Default spacing, standard padding |
| lg | 24px | Large spacing, section separation |
| xl | 32px | Extra large spacing, screen margins |
| xxl | 48px | Section breaks, major divisions |
| xxxl | 64px | Large section spacing |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 4px | Small elements, inner corners |
| md | 8px | Cards, inputs, standard components |
| lg | 12px | Prominent cards, dialogs |
| xl | 16px | FAB, large buttons |
| round | 999px | Pills, chips, fully rounded |

### Component Dimensions

**Icons**
- Small: 16px
- Medium: 24px
- Large: 32px
- Extra Large: 48px

**Buttons**
- Small: 36px height
- Medium: 48px height
- Large: 56px height

**Inputs**
- Small: 40px height
- Medium: 48px height
- Large: 56px height

**List Items**
- Standard: 72px height
- Compact: 56px height

### Elevation

| Level | Value | Usage |
|-------|-------|-------|
| Low | 2dp | Cards, contained elements |
| Medium | 4dp | Floating action button, app bar |
| High | 8dp | Dialogs, modals, dropdown menus |

---

## Components

### Grocery List Item

**Visual Structure**
- Checkbox (24x24px)
- Content area with name and category
- Quantity badge (rounded pill)
- Swipe-to-delete background

**States**
- Default: Full opacity, no strike-through
- Completed: Reduced opacity, strike-through text
- Hover/Press: Elevation change

**Interactions**
- Tap: Show item details
- Checkbox: Toggle completion state
- Swipe left: Reveal delete action
- Swipe delete: Remove with animation

**Accessibility**
- Semantic label: "[Item name], [quantity] items, [completed/not completed]"
- Hint: "Toggle completion"
- Haptic feedback on toggle

### Chat Message Bubble

**Visual Structure**
- Bubble container with rounded corners
- Adaptive corner radius (sender vs receiver)
- Optional suggestion chips below

**Variants**
- User message: Right-aligned, primary green background, white text
- Assistant message: Left-aligned, surface background, primary text

**Suggestion Chips**
- Outline style with accent blue
- Add icon prefix
- Tap to accept suggestion

**Accessibility**
- Semantic label: "[Sender] said: [message text]"
- Button role for suggestion chips
- Haptic feedback on chip tap

### Progress Indicator

**Circular Progress**
- 60x60px size
- 6px stroke width
- Animated value changes
- Percentage text in center

**Usage**
- Shopping list completion tracking
- Animates from current to new value
- Updates on item completion

### Floating Action Button

**Visual Properties**
- 56x56px size (standard)
- 40x40px size (mini)
- 16px border radius
- Elevation: 4dp (default), 8dp (pressed)

**States**
- Default: Primary color background
- Hover: Slight elevation increase
- Pressed: Deeper elevation, haptic feedback

**Accessibility**
- Semantic label describing action
- Minimum touch target: 48x48px
- Haptic feedback on press

---

## Animations & Micro-interactions

### Duration Guidelines

| Type | Duration | Curve | Usage |
|------|----------|-------|-------|
| Fast | 150-200ms | ease-out | Small UI changes, highlights |
| Standard | 250-300ms | ease-in-out | Page transitions, dialogs |
| Slow | 400-600ms | ease-in-out | Large movements, reveals |
| Elastic | 600ms | elasticOut | Celebration, emphasis |

### List Operations

**Add Item**
- Slide in from right (300ms, ease-out)
- Fade in simultaneously
- Haptic success pattern on completion

**Delete Item**
- Swipe reveal delete background (follows gesture)
- Fade out and scale down (200ms, ease-in)
- Haptic medium feedback on delete

**Toggle Completion**
- Checkbox scale animation (150ms)
- Text decoration crossfade (200ms)
- Haptic selection click

**Reorder** (future)
- Item follows touch position
- Other items animate aside (200ms)
- Drop shadow during drag

### Page Transitions

**Onboarding Navigation**
- Horizontal page view
- Page indicator animation (300ms)
- Scale animation on page content (600ms, elastic)

**Chat Screen**
- Slide in from right (300ms, ease-in-out)
- Slide out to left on back

**Dialog Appearance**
- Fade in backdrop (200ms)
- Scale up dialog (250ms, ease-out)
- Platform-specific on iOS (Cupertino)

### Micro-interactions

**Button Press**
- Scale down to 0.95 (100ms)
- Scale up on release (100ms)
- Haptic light impact

**Input Focus**
- Border color transition (200ms)
- Border width increase (150ms)

**Suggestion Chip Tap**
- Scale down (100ms)
- Fade out (200ms)
- Haptic light impact

**Typing Indicator**
- Three dots with staggered fade (600ms each)
- Continuous loop while typing
- Offset start times: 0ms, 150ms, 300ms

---

## Haptic Feedback

### Feedback Types

| Type | Usage | Pattern |
|------|-------|---------|
| Light | Navigation, selections | Single light impact |
| Medium | Actions, confirmations | Single medium impact |
| Heavy | Errors, important alerts | Single heavy impact |
| Selection | Item selection, toggle | Selection click |
| Success | Successful completion | Medium + delayed light |
| Error | Error occurred | Two heavy impacts (50ms apart) |

### Implementation

```dart
// Light feedback for navigation
GrocliHaptics.light();

// Success feedback for item added
GrocliHaptics.success();

// Error feedback
GrocliHaptics.error();
```

---

## Accessibility

### Screen Reader Support

All interactive elements include:
- Descriptive labels
- State information
- Action hints
- Proper semantic roles

### Examples

```dart
Semantics(
  label: 'Add new grocery item',
  button: true,
  hint: 'Opens dialog to add item',
  child: FloatingActionButton(...)
)

Semantics(
  label: 'Milk, 2 items, completed',
  button: true,
  checked: true,
  onTapHint: 'Toggle completion',
  child: GroceryListItem(...)
)
```

### Text Scaling

- Minimum scale: 0.8x
- Maximum scale: 2.0x
- All layouts adapt to text size changes
- No text truncation at supported scales

### Color Contrast

All text and interactive elements meet WCAG AA standards:
- Primary text on background: 15:1 ratio
- Secondary text on background: 7:1 ratio
- Button text on primary: 4.5:1 ratio

### Touch Targets

- Minimum size: 48x48px
- Adequate spacing between targets
- Clear press states

---

## Platform Adaptation

### Android (Material Design)

- Material 3 components
- Ripple effects on press
- Material dialogs and sheets
- System navigation bar
- Floating Action Button

### iOS (Cupertino)

- Cupertino components where appropriate
- Cupertino dialogs and action sheets
- iOS navigation patterns
- Swipe-back navigation
- SF Symbols (when available)

### Adaptive Components

```dart
// Dialog example
if (Platform.isIOS) {
  showCupertinoDialog(...);
} else {
  showDialog(...);
}
```

---

## Usage Guidelines

### Color Usage

**Do:**
- Use primary green for main actions
- Use secondary orange for emphasis
- Use semantic colors consistently
- Maintain contrast ratios

**Don't:**
- Mix color meanings (e.g., red for success)
- Use colors alone to convey information
- Override semantic color meanings

### Typography Usage

**Do:**
- Use type scale consistently
- Maintain hierarchy
- Allow text scaling
- Use proper line heights

**Don't:**
- Use too many type sizes on one screen
- Override user text size preferences
- Use all caps except for buttons
- Sacrifice readability for aesthetics

### Spacing Usage

**Do:**
- Follow 8pt grid
- Use consistent spacing tokens
- Maintain breathing room
- Group related elements

**Don't:**
- Use arbitrary spacing values
- Overcrowd interfaces
- Inconsistent spacing between similar elements

### Animation Usage

**Do:**
- Use animations to guide attention
- Keep animations smooth and quick
- Provide haptic feedback
- Allow users to disable if needed

**Don't:**
- Over-animate interfaces
- Use animations longer than 600ms
- Animate everything
- Sacrifice performance

---

## Design Tokens Reference

All design tokens are defined in:
- `lib/design_system/colors.dart`
- `lib/design_system/typography.dart`
- `lib/design_system/spacing.dart`
- `lib/design_system/theme.dart`

### Importing Design System

```dart
import 'package:testing_repo/design_system/colors.dart';
import 'package:testing_repo/design_system/spacing.dart';
import 'package:testing_repo/design_system/typography.dart';
import 'package:testing_repo/design_system/theme.dart';
```

### Using Design Tokens

```dart
// Colors
color: GrocliColors.primaryGreen,
backgroundColor: GrocliColors.surfaceLight,

// Spacing
padding: EdgeInsets.all(GrocliSpacing.md),
borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),

// Typography
style: GrocliTypography.h1,
textStyle: GrocliTypography.body1,
```

---

## Future Enhancements

### Planned Features

1. **Dark Mode**: Comprehensive dark theme support
2. **Custom Themes**: User-selectable color schemes
3. **Animation Controls**: User preference for reduced motion
4. **High Contrast Mode**: Enhanced contrast theme option
5. **Larger Text Mode**: Support for accessibility text sizes up to 3.0x

### Design System Evolution

- Regular accessibility audits
- User feedback integration
- Platform update adaptations
- Performance optimizations
- New component patterns

---

## Resources

### External Guidelines

- [Material Design 3](https://m3.material.io/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Design Patterns](https://flutter.dev/docs/development/ui/widgets)

### Internal Resources

- Design system implementation: `lib/design_system/`
- Component examples: `lib/widgets/`
- Screen implementations: `lib/screens/`

---

**Last Updated**: November 2024
**Version**: 1.0.0
**Maintained by**: Grocli Design Team
