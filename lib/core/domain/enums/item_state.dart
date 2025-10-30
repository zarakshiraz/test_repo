enum ItemState {
  pending,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ItemState.pending:
        return 'Pending';
      case ItemState.completed:
        return 'Completed';
      case ItemState.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPending => this == ItemState.pending;
  bool get isCompleted => this == ItemState.completed;
  bool get isCancelled => this == ItemState.cancelled;
}
