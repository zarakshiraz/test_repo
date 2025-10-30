import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/list_item.dart';

/// Response from transcription API
class TranscriptionResponse {
  final String text;
  final double confidence;
  final String? language;

  TranscriptionResponse({
    required this.text,
    required this.confidence,
    this.language,
  });

  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionResponse(
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      language: json['language'] as String?,
    );
  }
}

/// Response from item extraction API
class ItemExtractionResponse {
  final List<ExtractedItem> items;
  final String? originalText;

  ItemExtractionResponse({
    required this.items,
    this.originalText,
  });

  factory ItemExtractionResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return ItemExtractionResponse(
      items: itemsList
          .map((item) => ExtractedItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      originalText: json['originalText'] as String?,
    );
  }
}

/// Individual extracted item with metadata
class ExtractedItem {
  final String content;
  final double confidence;
  final String? category;
  final String? notes;

  ExtractedItem({
    required this.content,
    this.confidence = 1.0,
    this.category,
    this.notes,
  });

  factory ExtractedItem.fromJson(Map<String, dynamic> json) {
    return ExtractedItem(
      content: json['content'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'confidence': confidence,
      'category': category,
      'notes': notes,
    };
  }
}

/// Service for AI-powered transcription and item extraction
/// Uses Firebase Cloud Functions to proxy OpenAI Whisper and GPT APIs
class AITranscriptionService {
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  AITranscriptionService({
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Upload audio file to Firebase Storage
  Future<String> uploadAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $filePath');
      }

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'audio_${userId}_$timestamp.m4a';
      final ref = _storage.ref().child('transcriptions/$userId/$fileName');

      // Upload file
      final uploadTask = ref.putFile(file);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Audio uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      rethrow;
    }
  }

  /// Transcribe audio using OpenAI Whisper via Cloud Function
  /// 
  /// The Cloud Function should:
  /// 1. Validate Firebase Auth token
  /// 2. Download audio from Storage URL
  /// 3. Call OpenAI Whisper API
  /// 4. Return transcribed text
  Future<TranscriptionResponse> transcribeAudio(String audioUrl) async {
    try {
      debugPrint('Transcribing audio: $audioUrl');
      
      final callable = _functions.httpsCallable('transcribeAudio');
      final result = await callable.call<Map<String, dynamic>>({
        'audioUrl': audioUrl,
      });

      if (result.data == null) {
        throw Exception('No data returned from transcription');
      }

      return TranscriptionResponse.fromJson(result.data);
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      if (e is FirebaseFunctionsException) {
        throw Exception('Transcription failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Extract list items from text using GPT via Cloud Function
  /// 
  /// The Cloud Function should:
  /// 1. Validate Firebase Auth token
  /// 2. Call OpenAI GPT API with prompt to extract list items
  /// 3. Parse messy text into structured items
  /// 4. Return items with confidence scores
  Future<ItemExtractionResponse> extractItemsFromText(String text) async {
    try {
      debugPrint('Extracting items from text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      
      final callable = _functions.httpsCallable('extractListItems');
      final result = await callable.call<Map<String, dynamic>>({
        'text': text,
      });

      if (result.data == null) {
        throw Exception('No data returned from item extraction');
      }

      return ItemExtractionResponse.fromJson(result.data);
    } catch (e) {
      debugPrint('Error extracting items: $e');
      if (e is FirebaseFunctionsException) {
        throw Exception('Item extraction failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Complete workflow: Upload audio, transcribe, and extract items
  Future<ItemExtractionResponse> processAudioToItems(String audioFilePath) async {
    try {
      // Step 1: Upload audio
      final audioUrl = await uploadAudioFile(audioFilePath);
      
      // Step 2: Transcribe
      final transcription = await transcribeAudio(audioUrl);
      
      // Step 3: Extract items
      final extraction = await extractItemsFromText(transcription.text);
      
      return ItemExtractionResponse(
        items: extraction.items,
        originalText: transcription.text,
      );
    } catch (e) {
      debugPrint('Error processing audio to items: $e');
      rethrow;
    }
  }

  /// Convert ExtractedItem to ListItem model
  ListItem extractedItemToListItem({
    required ExtractedItem extractedItem,
    required String listId,
    required String userId,
    required int order,
  }) {
    final now = DateTime.now();
    return ListItem(
      id: '', // Will be set by the list service
      listId: listId,
      content: extractedItem.content,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      createdByUserId: userId,
      order: order,
      notes: extractedItem.notes,
    );
  }

  /// Cleanup: Delete audio file from storage
  Future<void> deleteAudioFile(String audioUrl) async {
    try {
      final ref = _storage.refFromURL(audioUrl);
      await ref.delete();
      debugPrint('Audio file deleted: $audioUrl');
    } catch (e) {
      debugPrint('Error deleting audio file: $e');
      // Non-critical error, don't throw
    }
  }
}
