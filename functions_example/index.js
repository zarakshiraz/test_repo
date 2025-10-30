/**
 * Firebase Cloud Functions for AI-powered list item extraction
 * 
 * This file contains the backend Cloud Functions that proxy OpenAI API calls.
 * These functions ensure API keys are never exposed to the client.
 * 
 * Setup:
 * 1. Initialize Firebase Functions: firebase init functions
 * 2. Install dependencies: npm install openai firebase-admin firebase-functions
 * 3. Set API key: firebase functions:config:set openai.api_key="your-key"
 * 4. Deploy: firebase deploy --only functions
 * 
 * @see README.md for complete setup instructions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { OpenAI } = require('openai');

admin.initializeApp();

// Initialize OpenAI with API key from Firebase config
const openai = new OpenAI({
  apiKey: functions.config().openai.api_key,
});

/**
 * Transcribe audio using OpenAI Whisper API
 * 
 * This function:
 * 1. Validates the user is authenticated
 * 2. Downloads audio from Firebase Storage
 * 3. Sends audio to OpenAI Whisper for transcription
 * 4. Returns transcribed text
 * 
 * @param {Object} data - Request data
 * @param {string} data.audioUrl - Firebase Storage URL of audio file
 * @param {Object} context - Function context with auth info
 * @returns {Object} { text: string, confidence: number, language: string }
 */
exports.transcribeAudio = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to use transcription'
    );
  }

  const { audioUrl } = data;
  if (!audioUrl) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'audioUrl is required'
    );
  }

  console.log(`Transcribing audio for user ${context.auth.uid}`);

  try {
    // Parse Storage URL to get file path
    const urlParts = new URL(audioUrl);
    const pathParts = urlParts.pathname.split('/');
    const filePath = decodeURIComponent(
      pathParts.slice(pathParts.indexOf('o') + 1).join('/')
    );

    // Download audio from Firebase Storage
    const bucket = admin.storage().bucket();
    const file = bucket.file(filePath);
    
    // Check file exists
    const [exists] = await file.exists();
    if (!exists) {
      throw new Error(`File not found: ${filePath}`);
    }

    // Download to temporary file
    const tempPath = `/tmp/${Date.now()}_${file.name.split('/').pop()}`;
    await file.download({ destination: tempPath });

    console.log(`Downloaded audio to ${tempPath}`);

    // Transcribe with OpenAI Whisper
    const fs = require('fs');
    const transcription = await openai.audio.transcriptions.create({
      file: fs.createReadStream(tempPath),
      model: 'whisper-1',
      response_format: 'verbose_json',
      language: 'en', // Optional: can be auto-detected
    });

    console.log(`Transcription completed: "${transcription.text}"`);

    // Cleanup temp file
    fs.unlinkSync(tempPath);

    return {
      text: transcription.text,
      confidence: 1.0, // Whisper doesn't provide confidence scores
      language: transcription.language || 'en',
    };
  } catch (error) {
    console.error('Transcription error:', error);
    
    // Provide user-friendly error messages
    if (error.message.includes('File not found')) {
      throw new functions.https.HttpsError(
        'not-found',
        'Audio file not found in storage'
      );
    }
    
    throw new functions.https.HttpsError(
      'internal',
      `Transcription failed: ${error.message}`
    );
  }
});

/**
 * Extract list items from text using OpenAI GPT
 * 
 * This function:
 * 1. Validates the user is authenticated
 * 2. Sends text to GPT with specialized prompt
 * 3. Extracts structured list items
 * 4. Returns items with confidence scores
 * 
 * @param {Object} data - Request data
 * @param {string} data.text - Text to extract items from
 * @param {Object} context - Function context with auth info
 * @returns {Object} { items: Array<{content, confidence, category?, notes?}> }
 */
exports.extractListItems = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to use item extraction'
    );
  }

  const { text } = data;
  if (!text || typeof text !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'text is required and must be a string'
    );
  }

  if (text.length > 5000) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'text is too long (max 5000 characters)'
    );
  }

  console.log(`Extracting items for user ${context.auth.uid}`);

  try {
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: `You are a helpful assistant that extracts list items from natural language text.
Your task is to identify individual items and return them as a structured JSON array.

Rules:
- Extract each distinct item separately
- Remove filler words (like "I need", "please get", etc.)
- Standardize formatting (capitalize first letter)
- Preserve quantities if mentioned (e.g., "2 apples")
- Assign confidence score (0.0-1.0) based on clarity
- Optionally categorize items (e.g., "dairy", "produce", "meat")
- Add notes for context if helpful

Return format: {"items": [{"content": string, "confidence": number, "category": string?, "notes": string?}]}

Examples:
Input: "I need milk, eggs, and maybe some bread"
Output: {"items": [{"content": "Milk", "confidence": 1.0, "category": "dairy"}, {"content": "Eggs", "confidence": 1.0, "category": "dairy"}, {"content": "Bread", "confidence": 0.7, "category": "bakery"}]}

Input: "get 2 apples and some oranges oh and tomato sauce for pasta"
Output: {"items": [{"content": "2 Apples", "confidence": 1.0, "category": "produce"}, {"content": "Oranges", "confidence": 0.9, "category": "produce"}, {"content": "Tomato sauce", "confidence": 1.0, "category": "canned", "notes": "for pasta"}]}`
        },
        {
          role: 'user',
          content: text
        }
      ],
      temperature: 0.3, // Lower temperature for more consistent output
      response_format: { type: 'json_object' },
      max_tokens: 1000,
    });

    const result = JSON.parse(completion.choices[0].message.content);
    
    // Validate response structure
    if (!result.items || !Array.isArray(result.items)) {
      throw new Error('Invalid response format from GPT');
    }

    // Ensure each item has required fields
    const validatedItems = result.items.map(item => ({
      content: item.content || 'Unknown item',
      confidence: typeof item.confidence === 'number' ? item.confidence : 1.0,
      category: item.category || null,
      notes: item.notes || null,
    }));

    console.log(`Extracted ${validatedItems.length} items`);

    return {
      items: validatedItems,
      originalText: text,
    };
  } catch (error) {
    console.error('Extraction error:', error);
    
    // Provide user-friendly error messages
    if (error.message.includes('API key')) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'API configuration error. Please contact support.'
      );
    }
    
    if (error.message.includes('quota')) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'API quota exceeded. Please try again later.'
      );
    }
    
    throw new functions.https.HttpsError(
      'internal',
      `Item extraction failed: ${error.message}`
    );
  }
});

/**
 * Optional: Batch process multiple texts
 * Useful for processing multiple list items at once
 */
exports.batchExtractItems = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { texts } = data;
  if (!Array.isArray(texts) || texts.length === 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'texts must be a non-empty array'
    );
  }

  if (texts.length > 10) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Maximum 10 texts per batch'
    );
  }

  try {
    const results = await Promise.all(
      texts.map(text => 
        exports.extractListItems.run({ text }, context)
      )
    );

    return {
      results,
      count: results.length,
    };
  } catch (error) {
    console.error('Batch extraction error:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Batch extraction failed: ${error.message}`
    );
  }
});

/**
 * Optional: Health check endpoint
 * Useful for monitoring
 */
exports.healthCheck = functions.https.onRequest((req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    functions: {
      transcribeAudio: 'available',
      extractListItems: 'available',
    },
  });
});
