import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AIService {
  // This would connect to your backend AI service (OpenAI, Google Cloud, etc.)
  // For now, we'll create a simple mock implementation
  
  static const String _apiUrl = 'YOUR_AI_API_ENDPOINT'; // Replace with actual endpoint
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with actual API key

  /// Extracts list items from transcribed or typed text
  /// Uses AI to clean up and structure the input
  Future<List<String>> extractListItems(String input) async {
    try {
      // For production, this would call an AI service like OpenAI
      // For now, we'll implement a simple rule-based extraction
      
      if (input.isEmpty) return [];

      // Split by common separators
      final separators = [',', 'and', '\n', ';'];
      String processed = input.toLowerCase();
      
      // Remove common filler words
      final fillerWords = [
        'i need',
        'i want',
        'get',
        'buy',
        'pick up',
        'grab',
        'please',
        'can you',
      ];
      
      for (final filler in fillerWords) {
        processed = processed.replaceAll(filler, '');
      }

      // Split into items
      List<String> items = [];
      for (final separator in separators) {
        if (processed.contains(separator)) {
          items = processed.split(separator);
          break;
        }
      }

      if (items.isEmpty) {
        // If no separator found, treat as single item
        items = [processed];
      }

      // Clean up items
      items = items
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty && item.length > 1)
          .map((item) => _capitalizeFirst(item))
          .toList();

      return items;
    } catch (e) {
      debugPrint('Error extracting list items: $e');
      return [];
    }
  }

  /// Gets smart suggestions based on existing items
  /// In production, this would use ML to suggest related items
  Future<List<String>> getSuggestions(List<String> existingItems) async {
    try {
      if (existingItems.isEmpty) return [];

      // Simple rule-based suggestions
      // In production, use ML model or API
      final suggestions = <String>[];
      final suggestionMap = {
        'bread': ['butter', 'jam', 'milk'],
        'milk': ['bread', 'eggs', 'cereal'],
        'eggs': ['milk', 'bread', 'bacon'],
        'pasta': ['tomato sauce', 'cheese', 'basil'],
        'rice': ['beans', 'chicken', 'vegetables'],
        'chicken': ['rice', 'vegetables', 'sauce'],
        'tomato': ['onion', 'garlic', 'pasta'],
        'onion': ['garlic', 'tomato', 'pepper'],
        'apple': ['banana', 'orange', 'grapes'],
        'banana': ['apple', 'strawberry', 'yogurt'],
      };

      for (final item in existingItems) {
        final key = item.toLowerCase();
        for (final mapKey in suggestionMap.keys) {
          if (key.contains(mapKey)) {
            suggestions.addAll(suggestionMap[mapKey]!);
          }
        }
      }

      // Remove duplicates and items already in the list
      return suggestions
          .toSet()
          .where((s) => !existingItems.any(
              (item) => item.toLowerCase().contains(s.toLowerCase())))
          .take(5)
          .toList();
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  /// Processes voice transcription to extract items
  Future<List<String>> processVoiceTranscription(String transcription) async {
    // In production, this would use more sophisticated NLP
    return extractListItems(transcription);
  }

  /// Call actual AI API (for production use)
  Future<List<String>> _callAIAPI(String input, String endpoint) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'input': input,
          'task': 'extract_list_items',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['items'] ?? []);
      }
      
      return [];
    } catch (e) {
      debugPrint('Error calling AI API: $e');
      return [];
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
