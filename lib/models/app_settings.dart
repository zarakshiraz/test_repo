class AppSettings {
  final bool quietHoursEnabled;
  final int quietHoursStartHour;
  final int quietHoursEndHour;

  AppSettings({
    this.quietHoursEnabled = false,
    this.quietHoursStartHour = 22,
    this.quietHoursEndHour = 8,
  });

  bool isInQuietHours(DateTime time) {
    if (!quietHoursEnabled) return false;

    final hour = time.hour;
    if (quietHoursStartHour < quietHoursEndHour) {
      return hour >= quietHoursStartHour && hour < quietHoursEndHour;
    } else {
      return hour >= quietHoursStartHour || hour < quietHoursEndHour;
    }
  }

  AppSettings copyWith({
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursEndHour,
  }) {
    return AppSettings(
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
    );
  }
}
