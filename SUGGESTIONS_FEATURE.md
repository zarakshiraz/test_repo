# Suggestions Feature Documentation

## Overview

The suggestions feature provides intelligent item recommendations to users while they're editing their grocery lists. It combines AI-based suggestions with heuristic rules to offer contextually relevant suggestions.

## Architecture

### Components

1. **SuggestionService** (`lib/core/services/suggestion_service.dart`)
   - Combines AI suggestions with heuristic rules
   - Sources suggestions from:
     - AI service (based on current list items)
     - Recent items (from other lists)
     - Common templates
     - Related items
   - Returns up to 3 suggestions by default

2. **SuggestionProvider** (`lib/core/providers/suggestion_provider.dart`)
   - Riverpod-based state management
   - Handles debounced suggestion loading (500ms delay)
   - Manages accept/dismiss actions
   - Family provider scoped to list ID

3. **SuggestionCacheService** (`lib/core/services/suggestion_cache_service.dart`)
   - Temporary session cache for dismissed suggestions
   - Prevents re-showing dismissed items
   - Cache expires after 1 hour
   - Per-list caching

4. **AnalyticsService** (`lib/core/services/analytics_service.dart`)
   - Local event logging for analytics
   - Tracks accepted and dismissed suggestions
   - Stores last 100 events in SharedPreferences

5. **SuggestionChipBar** (`lib/features/lists/presentation/widgets/suggestion_chip_bar.dart`)
   - UI component displaying suggestions as chips
   - Shows up to 3 suggestions
   - Each chip has accept/dismiss actions
   - Visual indicators for suggestion source (AI, recent, template)

## Features

### 1. Intelligent Suggestions

- **AI-based**: Uses AI service to suggest items based on current list
- **Recent items**: Suggests items from user's recent lists
- **Templates**: Common grocery items when list is empty
- **Context-aware**: Updates based on what's already in the list

### 2. Accept/Dismiss Actions

- **Accept**: Adds suggestion to list and logs analytics event
- **Dismiss**: Hides suggestion for current session (1 hour)
- **Dismiss All**: Quick action to dismiss all current suggestions

### 3. Analytics Tracking

- Logs when suggestions are accepted:
  ```dart
  {
    'event': 'suggestion_accepted',
    'suggestion': 'Milk',
    'list_id': 'abc123',
    'source': 'ai',
    'timestamp': '2024-01-01T12:00:00Z'
  }
  ```

- Logs when suggestions are dismissed:
  ```dart
  {
    'event': 'suggestion_dismissed',
    'suggestion': 'Milk',
    'list_id': 'abc123',
    'timestamp': '2024-01-01T12:00:00Z'
  }
  ```

### 4. Session Cache

- Dismissed suggestions won't reappear for 1 hour
- Cache is per-list
- Automatically expires old entries
- In-memory storage (clears on app restart)

### 5. Debounced Updates

- Suggestions update 300ms after user stops typing
- Provider-level debouncing (500ms)
- Prevents excessive API calls

## Usage

### In a List Detail Page

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/suggestion_chip_bar.dart';

class MyListPage extends ConsumerWidget {
  final String listId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Display suggestions above input
        SuggestionChipBar(
          listId: listId,
          onAccept: (suggestion) {
            // Add item to list
            addItemToList(suggestion);
          },
          onDismissAll: () {
            // Optional: reload suggestions
          },
        ),
        
        // Your input field
        TextField(
          onChanged: (text) {
            // Update suggestions as user types
            ref.read(suggestionProvider(listId).notifier).loadSuggestions(
              listId: listId,
              currentItems: currentItems,
              searchQuery: text,
            );
          },
        ),
      ],
    );
  }
}
```

### Manual Suggestion Loading

```dart
// Load suggestions with debouncing
ref.read(suggestionProvider(listId).notifier).loadSuggestions(
  listId: listId,
  currentItems: items,
  recentItems: recentItems,
  searchQuery: searchText,
  debounce: true,
);

// Load immediately without debounce
ref.read(suggestionProvider(listId).notifier).loadSuggestions(
  listId: listId,
  currentItems: items,
  debounce: false,
);
```

### Accept a Suggestion

```dart
final notifier = ref.read(suggestionProvider(listId).notifier);
await notifier.acceptSuggestion(
  listId: listId,
  suggestion: suggestion,
);
```

### Dismiss a Suggestion

```dart
final notifier = ref.read(suggestionProvider(listId).notifier);
await notifier.dismissSuggestion(
  listId: listId,
  suggestion: suggestion,
);
```

## Configuration

### Suggestion Limits

Change the number of suggestions returned:

```dart
final suggestions = await suggestionService.getSuggestions(
  listId: listId,
  currentItems: items,
  limit: 5, // Default is 3
);
```

### Cache Expiry

Modify cache expiry time in `SuggestionCacheService`:

```dart
final Duration _cacheExpiry = const Duration(hours: 2); // Default is 1 hour
```

### Debounce Duration

Adjust debounce timing in `SuggestionNotifier`:

```dart
static const Duration _debounceDuration = Duration(milliseconds: 300);
```

## Suggestion Sources

### 1. AI Source (Purple chip with sparkle icon)
- Uses AI service to analyze current items
- Confidence: 0.9

### 2. Recent Items (Blue chip with history icon)
- Items from user's other lists
- Confidence: 0.8

### 3. Templates (Green chip with category icon)
- Common grocery items
- Confidence: 0.6

### 4. Related Items (Orange chip with link icon)
- Items commonly bought together
- Confidence: varies

## Integration with Existing Code

The suggestions feature integrates with:

1. **Provider**: Uses provider package for list state management
2. **Riverpod**: Uses riverpod for suggestions state management
3. **AIService**: Leverages existing AI service
4. **SharedPreferences**: For analytics storage

Both Provider and Riverpod coexist by using prefixed imports:

```dart
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

## Testing

### Unit Tests

Test the suggestion service:

```dart
test('getSuggestions returns filtered suggestions', () async {
  final service = SuggestionService();
  final suggestions = await service.getSuggestions(
    listId: 'test',
    currentItems: [
      ListItem(id: '1', listId: 'test', content: 'Milk', ...),
    ],
    limit: 3,
  );
  
  expect(suggestions.length, lessThanOrEqualTo(3));
  expect(suggestions.any((s) => s.text == 'Milk'), false);
});
```

### Widget Tests

Test the chip bar:

```dart
testWidgets('SuggestionChipBar displays suggestions', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: SuggestionChipBar(
          listId: 'test',
          onAccept: (s) {},
        ),
      ),
    ),
  );
  
  // Verify chips are displayed
  expect(find.byType(ActionChip), findsWidgets);
});
```

## Future Enhancements

1. **Machine Learning**: Train ML model on user's past lists
2. **Collaborative Filtering**: Suggest items based on similar users
3. **Seasonal Suggestions**: Suggest items based on time of year
4. **Location-based**: Suggest items based on nearby stores
5. **Voice Integration**: Accept suggestions via voice commands
6. **Cross-list Learning**: Learn from shared lists
7. **Smart Ordering**: Order suggestions by likelihood of acceptance

## Troubleshooting

### Suggestions not appearing

1. Check if items exist in current list
2. Verify AI service is working
3. Check if suggestions were dismissed recently
4. Ensure list ID is correct

### Performance issues

1. Increase debounce duration
2. Reduce suggestion limit
3. Cache recent items locally
4. Optimize AI service calls

### Analytics not logging

1. Check SharedPreferences permissions
2. Verify analytics service initialization
3. Check console for errors

## API Reference

### SuggestionService

```dart
Future<List<Suggestion>> getSuggestions({
  required String listId,
  required List<ListItem> currentItems,
  List<ListItem> recentItems = const [],
  String searchQuery = '',
  int limit = 3,
})

void dismissSuggestion(String listId, String suggestion)
void clearCache(String listId)
```

### SuggestionNotifier

```dart
Future<void> loadSuggestions({
  required String listId,
  required List<ListItem> currentItems,
  List<ListItem> recentItems = const [],
  String searchQuery = '',
  bool debounce = true,
})

Future<void> acceptSuggestion({
  required String listId,
  required Suggestion suggestion,
})

Future<void> dismissSuggestion({
  required String listId,
  required Suggestion suggestion,
})

void clearSuggestions()
```

### AnalyticsService

```dart
Future<void> logEvent(String eventName, Map<String, dynamic> parameters)
Future<void> logSuggestionAccepted({
  required String suggestion,
  required String listId,
  required String source,
})
Future<void> logSuggestionDismissed({
  required String suggestion,
  required String listId,
})
Future<List<String>> getRecentEvents({int limit = 20})
Future<void> clearEvents()
```
