# Firebase Cloud Functions Setup

This directory contains example code for the Firebase Cloud Functions that power Grocli's AI features.

## Overview

The Cloud Functions act as a secure proxy between the Flutter app and OpenAI's API, ensuring:
- API keys are never exposed to clients
- All requests are authenticated via Firebase Auth
- Proper error handling and rate limiting
- Audio file management and cleanup

## Functions

### 1. `transcribeAudio`
Transcribes audio files using OpenAI Whisper API.

**Input:**
```json
{
  "audioUrl": "https://firebasestorage.googleapis.com/..."
}
```

**Output:**
```json
{
  "text": "I need milk, eggs, and bread",
  "confidence": 1.0,
  "language": "en"
}
```

### 2. `extractListItems`
Extracts structured list items from text using GPT.

**Input:**
```json
{
  "text": "I need milk, eggs, and bread"
}
```

**Output:**
```json
{
  "items": [
    {
      "content": "Milk",
      "confidence": 1.0,
      "category": "dairy",
      "notes": null
    },
    {
      "content": "Eggs",
      "confidence": 1.0,
      "category": "dairy",
      "notes": null
    },
    {
      "content": "Bread",
      "confidence": 1.0,
      "category": "bakery",
      "notes": null
    }
  ],
  "originalText": "I need milk, eggs, and bread"
}
```

## Setup Instructions

### Prerequisites

1. **Node.js 18+** and npm installed
2. **Firebase CLI** installed globally:
   ```bash
   npm install -g firebase-tools
   ```
3. **OpenAI API Key** from [platform.openai.com](https://platform.openai.com/api-keys)
4. **Firebase Project** on Blaze (pay-as-you-go) plan

### Step-by-Step Setup

#### 1. Login to Firebase
```bash
firebase login
```

#### 2. Initialize Your Project
If you haven't initialized functions yet:
```bash
firebase init functions
```
- Select your Firebase project
- Choose JavaScript or TypeScript
- Install dependencies

#### 3. Copy Example Code
Copy `index.js` from this directory to your `functions/` directory:
```bash
cp functions_example/index.js functions/
```

#### 4. Install Dependencies
```bash
cd functions
npm install openai firebase-admin firebase-functions
```

#### 5. Configure OpenAI API Key
```bash
firebase functions:config:set openai.api_key="sk-your-api-key-here"
```

Verify configuration:
```bash
firebase functions:config:get
```

#### 6. Deploy Functions
```bash
firebase deploy --only functions
```

#### 7. Deploy Storage Rules
```bash
cp functions_example/storage.rules storage.rules
firebase deploy --only storage
```

## Local Development

### Using Firebase Emulators

1. **Install Emulators:**
   ```bash
   firebase init emulators
   # Select Functions, Auth, Storage
   ```

2. **Set Local Config:**
   Create `functions/.runtimeconfig.json`:
   ```json
   {
     "openai": {
       "api_key": "sk-your-api-key-here"
     }
   }
   ```
   
   ⚠️ **Important:** Add `.runtimeconfig.json` to `.gitignore`!

3. **Start Emulators:**
   ```bash
   firebase emulators:start
   ```

4. **Test Functions:**
   - Functions UI: http://localhost:4000
   - Auth Emulator: http://localhost:9099
   - Storage Emulator: http://localhost:9199

### Testing with cURL

Test `extractListItems`:
```bash
curl -X POST \
  https://us-central1-YOUR-PROJECT.cloudfunctions.net/extractListItems \
  -H 'Authorization: Bearer YOUR-ID-TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"data": {"text": "I need milk, eggs, and bread"}}'
```

## Monitoring

### View Logs
```bash
firebase functions:log
```

### View Specific Function Logs
```bash
firebase functions:log --only transcribeAudio
```

### Firebase Console
- Functions Dashboard: [console.firebase.google.com/functions](https://console.firebase.google.com/project/_/functions)
- Usage & Billing: [console.firebase.google.com/usage](https://console.firebase.google.com/project/_/usage)

## Cost Management

### Estimate Your Costs

**OpenAI API:**
- Whisper: $0.006 per minute of audio
- GPT-3.5-turbo: ~$0.0005 per request

**Firebase:**
- Cloud Functions: 2M free invocations/month
- Storage: 5GB free, $0.026/GB after
- Bandwidth: 1GB free/day

### Set Budget Alerts

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Billing → Budgets & alerts
3. Create budget with email notifications

### Rate Limiting (Optional)

Add to your functions:
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // 10 requests per minute
});
```

## Security

### Best Practices

✅ **Do:**
- Keep API keys in Firebase Functions config
- Validate all inputs
- Authenticate all requests
- Set storage size limits
- Monitor usage and costs
- Use HTTPS only
- Implement rate limiting

❌ **Don't:**
- Store API keys in client code
- Allow unauthenticated access
- Skip input validation
- Ignore error logs
- Exceed free tier without monitoring

### Security Rules

The included `storage.rules` ensures:
- Users can only access their own transcription files
- File size limits are enforced
- Only audio files can be uploaded to transcription paths
- Authenticated access only

## Troubleshooting

### Function won't deploy
```bash
# Check Node version (must be 18+)
node --version

# Update dependencies
cd functions
npm update

# Clear cache and redeploy
firebase deploy --only functions --force
```

### "Unauthenticated" error
- Ensure user is signed in to Firebase Auth
- Check ID token is being sent correctly
- Verify security rules allow the operation

### "Quota exceeded" error
- Check OpenAI API dashboard for usage
- Implement rate limiting
- Upgrade OpenAI plan if needed

### Audio transcription fails
- Verify audio file format (m4a, mp3, wav supported)
- Check file size (max 10MB recommended)
- Ensure Storage rules allow access
- Check Cloud Functions logs for details

### "Invalid response format"
- Update GPT prompt if items aren't extracted correctly
- Check OpenAI API status
- Verify response_format is set to json_object

## Support

- **Firebase Support:** [firebase.google.com/support](https://firebase.google.com/support)
- **OpenAI Support:** [help.openai.com](https://help.openai.com)
- **Project Issues:** [GitHub Issues](https://github.com/yourusername/grocli/issues)

## License

This code is part of the Grocli project and is licensed under the MIT License.
