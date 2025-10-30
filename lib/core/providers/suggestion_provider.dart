import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/list_item.dart';
import '../services/suggestion_service.dart';
import '../services/analytics_service.dart';
import '../services/suggestion_cache_service.dart';

// Service providers
final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  return SuggestionService();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final suggestionCacheServiceProvider = Provider<SuggestionCacheService>((ref) {
  return SuggestionCacheService();
});

// State for suggestions
class SuggestionState {
  final List<Suggestion> suggestions;
  final bool isLoading;
  final String? error;
  
  const SuggestionState({
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
  });
  
  SuggestionState copyWith({
    List<Suggestion>? suggestions,
    bool? isLoading,
    String? error,
  }) {
    return SuggestionState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier for managing suggestions
class SuggestionNotifier extends StateNotifier<SuggestionState> {
  final SuggestionService _suggestionService;
  final AnalyticsService _analyticsService;
  
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  
  SuggestionNotifier(
    this._suggestionService,
    this._analyticsService,
  ) : super(const SuggestionState());
  
  Future<void> loadSuggestions({
    required String listId,
    required List<ListItem> currentItems,
    List<ListItem> recentItems = const [],
    String searchQuery = '',
    bool debounce = true,
  }) async {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    
    if (debounce) {
      // Set loading state immediately
      state = state.copyWith(isLoading: true);
      
      // Debounce the actual loading
      _debounceTimer = Timer(_debounceDuration, () {
        _performLoad(
          listId: listId,
          currentItems: currentItems,
          recentItems: recentItems,
          searchQuery: searchQuery,
        );
      });
    } else {
      // Load immediately without debounce
      await _performLoad(
        listId: listId,
        currentItems: currentItems,
        recentItems: recentItems,
        searchQuery: searchQuery,
      );
    }
  }
  
  Future<void> _performLoad({
    required String listId,
    required List<ListItem> currentItems,
    List<ListItem> recentItems = const [],
    String searchQuery = '',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final suggestions = await _suggestionService.getSuggestions(
        listId: listId,
        currentItems: currentItems,
        recentItems: recentItems,
        searchQuery: searchQuery,
        limit: 3,
      );
      
      state = state.copyWith(
        suggestions: suggestions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> acceptSuggestion({
    required String listId,
    required Suggestion suggestion,
  }) async {
    // Log analytics
    await _analyticsService.logSuggestionAccepted(
      suggestion: suggestion.text,
      listId: listId,
      source: suggestion.source.name,
    );
    
    // Remove from current suggestions
    final updatedSuggestions = state.suggestions
        .where((s) => s.text != suggestion.text)
        .toList();
    
    state = state.copyWith(suggestions: updatedSuggestions);
  }
  
  Future<void> dismissSuggestion({
    required String listId,
    required Suggestion suggestion,
  }) async {
    // Log analytics
    await _analyticsService.logSuggestionDismissed(
      suggestion: suggestion.text,
      listId: listId,
    );
    
    // Add to cache
    _suggestionService.dismissSuggestion(listId, suggestion.text);
    
    // Remove from current suggestions
    final updatedSuggestions = state.suggestions
        .where((s) => s.text != suggestion.text)
        .toList();
    
    state = state.copyWith(suggestions: updatedSuggestions);
  }
  
  void clearSuggestions() {
    state = const SuggestionState();
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Provider for suggestion notifier
final suggestionProvider = StateNotifierProvider.autoDispose
    .family<SuggestionNotifier, SuggestionState, String>(
  (ref, listId) {
    final suggestionService = ref.watch(suggestionServiceProvider);
    final analyticsService = ref.watch(analyticsServiceProvider);
    
    return SuggestionNotifier(
      suggestionService,
      analyticsService,
    );
  },
);
