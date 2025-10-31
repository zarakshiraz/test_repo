# Grocli Cloud Functions

This directory contains Firebase Cloud Functions for the Grocli app.

## Overview

Cloud Functions provide server-side logic for:
- AI-powered item extraction and suggestions
- User account lifecycle management
- Push notifications for list invitations
- Background data processing

## Available Functions

### Callable Functions (HTTP)

#### `helloWorld`
Test function to verify Cloud Functions setup.

**Usage:**
```dart
final result = await FirebaseFunctions.instance
  .httpsCallable('helloWorld')
  .call();
```

#### `aiProxyFunction`
Main AI processing function for natural language item extraction.

**Parameters:**
- `text` (string): Input text to process
- `operation` (string): One of `extractItems`, `suggestItems`, `categorizeItem`

**Usage:**
```dart
final result = await FirebaseFunctions.instance
  .httpsCallable('aiProxyFunction')
  .call({
    'text': 'milk bread eggs',
    'operation': 'extractItems',
  });
```

**Returns:**
```json
{
  "success": true,
  "result": ["milk", "bread", "eggs"]
}
```

### Background Functions (Triggers)

#### `onUserCreated`
Automatically creates a Firestore user document when a new user signs up.

**Trigger:** Firebase Authentication user creation

#### `onUserDeleted`
Cleans up user data when an account is deleted.

**Trigger:** Firebase Authentication user deletion

#### `sendListInvitationNotification`
Sends FCM push notification when a user is invited to a list.

**Trigger:** New document in `invitations` collection

## Setup

### Install Dependencies

```bash
npm install
```

### Build

```bash
npm run build
```

### Local Development

Run functions locally with Firebase Emulator:

```bash
npm run serve
```

This starts:
- Functions Emulator on port 5001
- Other emulators as configured

### Deploy

Deploy all functions:
```bash
firebase deploy --only functions
```

Deploy specific function:
```bash
firebase deploy --only functions:aiProxyFunction
```

## Configuration

### Environment Variables

Set configuration values:

```bash
firebase functions:config:set ai.api_key="your_key"
firebase functions:config:set ai.api_url="https://api.example.com"
```

Get current config:
```bash
firebase functions:config:get
```

### Secrets (Recommended)

For sensitive data, use Firebase secrets:

```bash
firebase functions:secrets:set AI_API_KEY
```

Update function code to use secrets:
```typescript
import {defineSecret} from 'firebase-functions/params';

const apiKey = defineSecret('AI_API_KEY');

export const myFunction = functions
  .runWith({secrets: [apiKey]})
  .https.onCall(async (data, context) => {
    const key = apiKey.value();
    // ...
  });
```

## Testing

### Unit Tests (TODO)

```bash
npm test
```

### Integration Tests

Use Firebase Emulator Suite:

```bash
# Terminal 1: Start emulators
npm run serve

# Terminal 2: Run Flutter app
flutter run
```

### Manual Testing

Test callable functions with curl:

```bash
curl -X POST http://localhost:5001/grocli-app/us-central1/helloWorld \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -d '{"data": {}}'
```

## Extending Functions

### Adding a New Function

1. Add function in `src/index.ts`:

```typescript
export const myNewFunction = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }
  
  // Your logic here
  return { result: 'success' };
});
```

2. Build and deploy:

```bash
npm run build
firebase deploy --only functions:myNewFunction
```

3. Call from Flutter:

```dart
final result = await FirebaseFunctions.instance
  .httpsCallable('myNewFunction')
  .call({'param': 'value'});
```

### Adding Background Triggers

**Firestore trigger:**
```typescript
export const onDocumentCreated = functions.firestore
  .document('collection/{docId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    // Process data
  });
```

**Storage trigger:**
```typescript
export const onFileUploaded = functions.storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    // Process file
  });
```

## AI Integration

### Current Implementation

The `aiProxyFunction` includes placeholder logic for:
- **extractItems**: Parse natural language into list items
- **suggestItems**: Suggest related items
- **categorizeItem**: Auto-categorize items

### Integrating Real AI Service

To use OpenAI, Anthropic, or similar:

1. Install SDK:
```bash
npm install openai
```

2. Update function:
```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: functions.config().ai.api_key,
});

async function extractItemsFromText(text: string): Promise<string[]> {
  const completion = await openai.chat.completions.create({
    model: "gpt-3.5-turbo",
    messages: [
      {
        role: "system",
        content: "Extract grocery items from the following text. Return as JSON array."
      },
      {
        role: "user",
        content: text
      }
    ],
  });
  
  return JSON.parse(completion.choices[0].message.content);
}
```

3. Set API key:
```bash
firebase functions:config:set ai.api_key="sk-..."
```

## Performance & Optimization

### Cold Starts

To reduce cold starts:
- Use `minInstances` option (costs more)
- Keep functions warm with scheduled pings
- Optimize dependencies (tree shaking)

```typescript
export const myFunction = functions
  .runWith({
    minInstances: 1,  // Keep 1 instance warm
    memory: '256MB',
  })
  .https.onCall(async (data, context) => {
    // ...
  });
```

### Memory & Timeout

Configure based on function needs:

```typescript
export const heavyFunction = functions
  .runWith({
    timeoutSeconds: 300,  // Max 540 for background
    memory: '1GB',        // Default 256MB
  })
  .https.onCall(async (data, context) => {
    // Heavy processing
  });
```

## Monitoring

### View Logs

Real-time logs:
```bash
firebase functions:log --only myFunction
```

### Firebase Console

View metrics in Firebase Console → Functions:
- Invocations
- Execution time
- Error rate
- Memory usage

### Error Handling

Use structured logging:

```typescript
import * as functions from 'firebase-functions';

export const myFunction = functions.https.onCall(async (data, context) => {
  try {
    // Function logic
    functions.logger.info('Processing request', {data, userId: context.auth?.uid});
    return {success: true};
  } catch (error) {
    functions.logger.error('Function failed', {error, data});
    throw new functions.https.HttpsError('internal', 'Processing failed');
  }
});
```

## Troubleshooting

### "Function returned undefined"
Ensure function returns a value or Promise

### "Timeout error"
Increase `timeoutSeconds` or optimize function

### "Out of memory"
Increase `memory` allocation

### "Permission denied"
Check Firebase security rules and IAM permissions

## Resources

- [Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [Cloud Functions Samples](https://github.com/firebase/functions-samples)
- [Best Practices](https://firebase.google.com/docs/functions/best-practices)
