class SuggestionCacheService {
  // Session cache - stores dismissed suggestions temporarily
  final Map<String, Set<String>> _dismissedSuggestions = {};
  
  // Keeps track of when suggestions were dismissed
  final Map<String, DateTime> _dismissalTimestamps = {};
  
  // Cache expiry duration (suggestions reappear after this time)
  final Duration _cacheExpiry = const Duration(hours: 1);
  
  void dismissSuggestion(String listId, String suggestion) {
    if (!_dismissedSuggestions.containsKey(listId)) {
      _dismissedSuggestions[listId] = <String>{};
    }
    
    final key = _getCacheKey(listId, suggestion);
    _dismissedSuggestions[listId]!.add(suggestion);
    _dismissalTimestamps[key] = DateTime.now();
  }
  
  bool isSuggestionDismissed(String listId, String suggestion) {
    final key = _getCacheKey(listId, suggestion);
    
    // Check if suggestion is in cache
    if (!_dismissedSuggestions.containsKey(listId)) {
      return false;
    }
    
    if (!_dismissedSuggestions[listId]!.contains(suggestion)) {
      return false;
    }
    
    // Check if cache entry has expired
    final dismissalTime = _dismissalTimestamps[key];
    if (dismissalTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    if (now.difference(dismissalTime) > _cacheExpiry) {
      // Cache expired, remove from dismissed list
      _dismissedSuggestions[listId]!.remove(suggestion);
      _dismissalTimestamps.remove(key);
      return false;
    }
    
    return true;
  }
  
  List<String> filterDismissedSuggestions(String listId, List<String> suggestions) {
    return suggestions
        .where((s) => !isSuggestionDismissed(listId, s))
        .toList();
  }
  
  void clearListCache(String listId) {
    _dismissedSuggestions.remove(listId);
    
    // Remove all timestamps for this list
    final keysToRemove = _dismissalTimestamps.keys
        .where((key) => key.startsWith('$listId:'))
        .toList();
    
    for (final key in keysToRemove) {
      _dismissalTimestamps.remove(key);
    }
  }
  
  void clearAllCache() {
    _dismissedSuggestions.clear();
    _dismissalTimestamps.clear();
  }
  
  String _getCacheKey(String listId, String suggestion) {
    return '$listId:${suggestion.toLowerCase().trim()}';
  }
  
  int getDismissedCount(String listId) {
    return _dismissedSuggestions[listId]?.length ?? 0;
  }
}
