import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const String _eventsKey = 'analytics_events';
  
  Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = prefs.getStringList(_eventsKey) ?? [];
      
      final eventData = {
        'event': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'parameters': parameters,
      };
      
      events.add(eventData.toString());
      
      // Keep only last 100 events
      if (events.length > 100) {
        events.removeAt(0);
      }
      
      await prefs.setStringList(_eventsKey, events);
      
      debugPrint('Analytics: $eventName - $parameters');
    } catch (e) {
      debugPrint('Error logging analytics event: $e');
    }
  }
  
  Future<void> logSuggestionAccepted({
    required String suggestion,
    required String listId,
    required String source,
  }) async {
    await logEvent('suggestion_accepted', {
      'suggestion': suggestion,
      'list_id': listId,
      'source': source,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> logSuggestionDismissed({
    required String suggestion,
    required String listId,
  }) async {
    await logEvent('suggestion_dismissed', {
      'suggestion': suggestion,
      'list_id': listId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<List<String>> getRecentEvents({int limit = 20}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = prefs.getStringList(_eventsKey) ?? [];
      return events.take(limit).toList();
    } catch (e) {
      debugPrint('Error retrieving analytics events: $e');
      return [];
    }
  }
  
  Future<void> clearEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_eventsKey);
    } catch (e) {
      debugPrint('Error clearing analytics events: $e');
    }
  }
}
