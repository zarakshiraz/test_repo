# AI Features Integration Guide

## Overview

This guide explains how to use the AI-powered transcription and item extraction features in Grocli. The implementation allows users to add list items through voice recording or text input, with AI automatically extracting and formatting the items.

## Architecture

### Service Layer

**AITranscriptionService** (`lib/core/services/ai_transcription_service.dart`)
- Uploads audio files to Firebase Storage
- Calls Cloud Functions for transcription (OpenAI Whisper)
- Calls Cloud Functions for item extraction (OpenAI GPT)
- Manages audio file lifecycle

**SpeechService** (`lib/core/services/speech_service.dart`)
- Handles microphone permissions
- Records audio using the `record` package
- Manages recording state

### State Management

**AIProvider** (`lib/core/providers/ai_provider.dart`)
- Manages AI processing workflow state
- Tracks progress through multiple stages
- Handles errors and retries
- Provides clean interface for UI components

### UI Components

**AIItemInputSheet** (`lib/features/lists/widgets/ai_item_input_sheet.dart`)
- Bottom sheet modal for input
- Supports both text and voice input
- Shows processing progress
- Handles errors gracefully

**AIItemsConfirmationDialog** (`lib/features/lists/widgets/ai_items_confirmation_dialog.dart`)
- Displays extracted items for review
- Allows editing, removing, and adding items
- Shows confidence scores
- Highlights low-confidence items

## Usage

### 1. Basic Integration

Add the AI input button to any list screen:

```dart
import 'package:provider/provider.dart';
import '../../core/providers/ai_provider.dart';
import '../../core/services/ai_transcription_service.dart';
import '../widgets/ai_item_input_sheet.dart';
import '../widgets/ai_items_confirmation_dialog.dart';

// In your widget
FloatingActionButton.extended(
  onPressed: () => _showAIInputSheet(context),
  icon: const Icon(Icons.auto_awesome),
  label: const Text('AI Input'),
)

void _showAIInputSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ChangeNotifierProvider(
      create: (_) => AIProvider(),
      child: AIItemInputSheet(
        onItemsExtracted: (extractedItems) {
          _showItemsConfirmation(context, extractedItems);
        },
      ),
    ),
  );
}

void _showItemsConfirmation(
  BuildContext context,
  List<ExtractedItem> extractedItems,
) {
  showDialog(
    context: context,
    builder: (context) => AIItemsConfirmationDialog(
      extractedItems: extractedItems,
      onConfirm: (confirmedItems) {
        _addExtractedItems(context, confirmedItems);
      },
    ),
  );
}

Future<void> _addExtractedItems(
  BuildContext context,
  List<ExtractedItem> items,
) async {
  final authProvider = context.read<AuthProvider>();
  final listProvider = ListProvider(userId: authProvider.currentUser!.id);
  
  for (final item in items) {
    await listProvider.addListItem(
      listId: widget.listId,
      content: item.content,
      notes: item.notes,
    );
  }
}
```

### 2. Voice Input Flow

1. User taps "AI Input" button
2. Bottom sheet appears with voice/text toggle
3. User taps "Start Recording"
4. Audio is recorded using device microphone
5. User taps "Done" to finish recording
6. Audio is uploaded to Firebase Storage
7. Cloud Function transcribes audio (Whisper)
8. Cloud Function extracts items (GPT)
9. Confirmation dialog shows extracted items
10. User reviews, edits, and confirms
11. Items are added to the list

### 3. Text Input Flow

1. User taps "AI Input" button
2. Bottom sheet appears in text mode
3. User types or pastes text
4. User taps "Extract Items with AI"
5. Cloud Function extracts items (GPT)
6. Confirmation dialog shows extracted items
7. User reviews, edits, and confirms
8. Items are added to the list

## AI Processing States

The `AIProvider` tracks the following states:

- `idle` - No processing
- `recording` - Recording audio
- `uploading` - Uploading audio to Storage
- `transcribing` - Transcribing audio
- `extracting` - Extracting items from text
- `completed` - Processing complete
- `error` - An error occurred

Progress is tracked from 0.0 to 1.0 across all stages.

## Data Models

### ExtractedItem

```dart
class ExtractedItem {
  final String content;      // Item name (e.g., "Milk")
  final double confidence;   // 0.0-1.0 confidence score
  final String? category;    // Optional category (e.g., "dairy")
  final String? notes;       // Optional notes
}
```

### TranscriptionResponse

```dart
class TranscriptionResponse {
  final String text;         // Transcribed text
  final double confidence;   // 0.0-1.0 confidence score
  final String? language;    // Detected language (e.g., "en")
}
```

### ItemExtractionResponse

```dart
class ItemExtractionResponse {
  final List<ExtractedItem> items;  // Extracted items
  final String? originalText;       // Original input text
}
```

## Error Handling

The system handles various error scenarios:

### Network Errors
- No internet connection
- Firebase Storage unavailable
- Cloud Functions timeout

### Permission Errors
- Microphone permission denied
- Storage permission issues

### API Errors
- OpenAI API quota exceeded
- Invalid API key
- Rate limiting

### User Actions
- Cancel recording anytime
- Retry failed operations
- Edit extracted items before adding

## Best Practices

### 1. User Experience

- Show clear progress indicators
- Provide helpful error messages
- Allow retry on failure
- Let users edit before confirming
- Support both voice and text input

### 2. Performance

- Upload audio in background
- Cache transcription results
- Batch add multiple items
- Clean up audio files after use

### 3. Security

- Never store API keys client-side
- Validate user authentication
- Use Firebase Auth tokens
- Restrict Storage access with rules
- Clean up old audio files

### 4. Cost Optimization

- Delete audio after transcription
- Implement rate limiting
- Use appropriate model sizes
- Cache common requests
- Monitor API usage

## Customization

### Changing AI Models

Edit the Cloud Functions to use different models:

```javascript
// For transcription
const transcription = await openai.audio.transcriptions.create({
  model: 'whisper-1', // Only model currently available
  // ...
});

// For item extraction
const completion = await openai.chat.completions.create({
  model: 'gpt-3.5-turbo', // Or 'gpt-4' for better quality
  // ...
});
```

### Adjusting Confidence Threshold

Filter items by confidence in the confirmation dialog:

```dart
final highConfidenceItems = extractedItems
    .where((item) => item.confidence >= 0.7)
    .toList();
```

### Customizing Prompts

Edit the system prompt in Cloud Functions for better extraction:

```javascript
{
  role: 'system',
  content: `Your custom instructions here...
  - Rule 1
  - Rule 2
  - Return format: JSON`
}
```

## Testing

### Unit Tests

Test service methods:

```dart
test('AITranscriptionService uploads audio', () async {
  final service = AITranscriptionService();
  final url = await service.uploadAudioFile('/path/to/audio.m4a');
  expect(url, isNotEmpty);
});
```

### Integration Tests

Test the full workflow:

```dart
testWidgets('AI input flow completes successfully', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap AI input button
  await tester.tap(find.byIcon(Icons.auto_awesome));
  await tester.pumpAndSettle();
  
  // Enter text
  await tester.enterText(find.byType(TextField), 'milk, eggs, bread');
  
  // Extract items
  await tester.tap(find.text('Extract Items with AI'));
  await tester.pumpAndSettle();
  
  // Confirm items
  await tester.tap(find.text('Add to List'));
  await tester.pumpAndSettle();
  
  // Verify items added
  expect(find.text('Milk'), findsOneWidget);
  expect(find.text('Eggs'), findsOneWidget);
  expect(find.text('Bread'), findsOneWidget);
});
```

## Troubleshooting

### "Unauthenticated" Error
- Ensure user is signed in
- Check Firebase Auth token is valid
- Verify Cloud Functions security rules

### "Transcription Failed" Error
- Check audio file format (m4a, mp3, wav)
- Verify file size (< 10MB)
- Check OpenAI API status
- Verify Firebase Storage rules

### "No Items Extracted" Error
- Check input text quality
- Verify GPT prompt is correct
- Try more explicit text (e.g., "buy milk" vs "I think maybe")

### Low Confidence Scores
- Use clearer speech/text
- Avoid ambiguous terms
- Provide context (e.g., "2 apples" vs "some")

## Monitoring

### Firebase Console
- Monitor Cloud Functions execution
- Check error rates
- Track API usage
- Review logs

### OpenAI Dashboard
- Monitor API usage
- Check rate limits
- Review costs
- Track errors

## Future Enhancements

Potential improvements:

1. **Offline Support**: Cache transcriptions locally
2. **Multi-language**: Support multiple languages
3. **Categories**: Auto-categorize items
4. **Smart Suggestions**: Suggest related items
5. **Voice Commands**: Support commands like "add milk and eggs"
6. **Batch Processing**: Process multiple audio files
7. **History**: Save transcription history
8. **Templates**: Save common item lists

## Support

For issues or questions:
- Check Cloud Functions logs
- Review Firebase Storage rules
- Verify OpenAI API status
- Test with Firebase Emulators
- Check the main README for setup

## Resources

- [OpenAI Whisper API](https://platform.openai.com/docs/guides/speech-to-text)
- [OpenAI GPT API](https://platform.openai.com/docs/guides/text-generation)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Firebase Storage](https://firebase.google.com/docs/storage)
- [Flutter Record Package](https://pub.dev/packages/record)
