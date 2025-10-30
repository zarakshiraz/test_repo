import 'package:flutter/foundation.dart';
import '../models/list_item.dart';
import 'ai_service.dart';
import 'suggestion_cache_service.dart';

enum SuggestionSource {
  ai,
  recentItems,
  template,
  relatedItems,
}

class Suggestion {
  final String text;
  final SuggestionSource source;
  final double confidence;
  
  const Suggestion({
    required this.text,
    required this.source,
    this.confidence = 1.0,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Suggestion && other.text == text;
  }
  
  @override
  int get hashCode => text.hashCode;
}

class SuggestionService {
  final AIService _aiService;
  final SuggestionCacheService _cacheService;
  
  // Common grocery templates
  static const List<String> _commonTemplates = [
    'Milk',
    'Bread',
    'Eggs',
    'Butter',
    'Cheese',
    'Chicken',
    'Beef',
    'Fish',
    'Rice',
    'Pasta',
    'Tomatoes',
    'Onions',
    'Potatoes',
    'Apples',
    'Bananas',
    'Lettuce',
    'Carrots',
    'Broccoli',
  ];
  
  SuggestionService({
    AIService? aiService,
    SuggestionCacheService? cacheService,
  })  : _aiService = aiService ?? AIService(),
        _cacheService = cacheService ?? SuggestionCacheService();
  
  Future<List<Suggestion>> getSuggestions({
    required String listId,
    required List<ListItem> currentItems,
    List<ListItem> recentItems = const [],
    String searchQuery = '',
    int limit = 3,
  }) async {
    try {
      final suggestions = <Suggestion>[];
      
      // 1. Get AI-based suggestions from existing items
      final itemContents = currentItems.map((i) => i.content).toList();
      if (itemContents.isNotEmpty) {
        final aiSuggestions = await _aiService.getSuggestions(itemContents);
        suggestions.addAll(
          aiSuggestions.map((s) => Suggestion(
            text: s,
            source: SuggestionSource.ai,
            confidence: 0.9,
          )),
        );
      }
      
      // 2. Add recent items (from other lists)
      if (recentItems.isNotEmpty) {
        final recentSuggestions = _getRecentItemSuggestions(
          currentItems,
          recentItems,
        );
        suggestions.addAll(recentSuggestions);
      }
      
      // 3. Add template-based suggestions
      if (currentItems.isEmpty || suggestions.length < limit) {
        final templateSuggestions = _getTemplateSuggestions(currentItems);
        suggestions.addAll(templateSuggestions);
      }
      
      // 4. Filter search query if provided
      List<Suggestion> filtered = suggestions;
      if (searchQuery.isNotEmpty) {
        filtered = suggestions.where((s) {
          return s.text.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }
      
      // 5. Remove duplicates
      final uniqueSuggestions = <String, Suggestion>{};
      for (final suggestion in filtered) {
        final key = suggestion.text.toLowerCase().trim();
        if (!uniqueSuggestions.containsKey(key)) {
          uniqueSuggestions[key] = suggestion;
        }
      }
      
      // 6. Filter out dismissed suggestions
      final allSuggestions = uniqueSuggestions.values.toList();
      final notDismissed = _cacheService.filterDismissedSuggestions(
        listId,
        allSuggestions.map((s) => s.text).toList(),
      );
      
      final result = allSuggestions
          .where((s) => notDismissed.contains(s.text))
          .toList();
      
      // 7. Sort by confidence and take top N
      result.sort((a, b) => b.confidence.compareTo(a.confidence));
      
      return result.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }
  
  List<Suggestion> _getRecentItemSuggestions(
    List<ListItem> currentItems,
    List<ListItem> recentItems,
  ) {
    final currentItemTexts = currentItems.map((i) => i.content.toLowerCase()).toSet();
    
    // Get unique recent items not in current list
    final recentSet = <String>{};
    final suggestions = <Suggestion>[];
    
    for (final item in recentItems) {
      final text = item.content.trim();
      final textLower = text.toLowerCase();
      
      if (!currentItemTexts.contains(textLower) && 
          !recentSet.contains(textLower) &&
          text.isNotEmpty) {
        recentSet.add(textLower);
        suggestions.add(Suggestion(
          text: text,
          source: SuggestionSource.recentItems,
          confidence: 0.8,
        ));
        
        if (suggestions.length >= 5) break;
      }
    }
    
    return suggestions;
  }
  
  List<Suggestion> _getTemplateSuggestions(List<ListItem> currentItems) {
    final currentItemTexts = currentItems.map((i) => i.content.toLowerCase()).toSet();
    
    return _commonTemplates
        .where((template) => !currentItemTexts.contains(template.toLowerCase()))
        .take(5)
        .map((template) => Suggestion(
          text: template,
          source: SuggestionSource.template,
          confidence: 0.6,
        ))
        .toList();
  }
  
  void dismissSuggestion(String listId, String suggestion) {
    _cacheService.dismissSuggestion(listId, suggestion);
  }
  
  void clearCache(String listId) {
    _cacheService.clearListCache(listId);
  }
}
