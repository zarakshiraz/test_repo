enum ListStatus {
  active,
  completed,
  archived;

  String get displayName {
    switch (this) {
      case ListStatus.active:
        return 'Active';
      case ListStatus.completed:
        return 'Completed';
      case ListStatus.archived:
        return 'Archived';
    }
  }

  bool get isActive => this == ListStatus.active;
  bool get isCompleted => this == ListStatus.completed;
  bool get isArchived => this == ListStatus.archived;
}
