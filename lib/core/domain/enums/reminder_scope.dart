enum ReminderScope {
  onlyMe,
  allParticipants,
  specific;

  String get displayName {
    switch (this) {
      case ReminderScope.onlyMe:
        return 'Only Me';
      case ReminderScope.allParticipants:
        return 'All Participants';
      case ReminderScope.specific:
        return 'Specific People';
    }
  }

  bool get isPersonal => this == ReminderScope.onlyMe;
  bool get isShared => this == ReminderScope.allParticipants || this == ReminderScope.specific;
}
