import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/list_item.dart';

class OptimisticUpdate {
  final String itemId;
  final ListItem originalItem;
  final ListItem optimisticItem;
  final DateTime timestamp;

  OptimisticUpdate({
    required this.itemId,
    required this.originalItem,
    required this.optimisticItem,
    required this.timestamp,
  });
}

class OptimisticUpdatesNotifier extends StateNotifier<Map<String, OptimisticUpdate>> {
  OptimisticUpdatesNotifier() : super({});

  void addUpdate(String itemId, ListItem original, ListItem optimistic) {
    state = {
      ...state,
      itemId: OptimisticUpdate(
        itemId: itemId,
        originalItem: original,
        optimisticItem: optimistic,
        timestamp: DateTime.now(),
      ),
    };
  }

  void confirmUpdate(String itemId) {
    final newState = Map<String, OptimisticUpdate>.from(state);
    newState.remove(itemId);
    state = newState;
  }

  void rollbackUpdate(String itemId) {
    final newState = Map<String, OptimisticUpdate>.from(state);
    newState.remove(itemId);
    state = newState;
  }

  OptimisticUpdate? getUpdate(String itemId) {
    return state[itemId];
  }
}

final optimisticUpdatesProvider =
    StateNotifierProvider<OptimisticUpdatesNotifier, Map<String, OptimisticUpdate>>((ref) {
  return OptimisticUpdatesNotifier();
});
