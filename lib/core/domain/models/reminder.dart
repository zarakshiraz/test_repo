import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/reminder_scope.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

@freezed
class Reminder with _$Reminder {
  const Reminder._();

  const factory Reminder({
    required String id,
    required String listId,
    String? listTitle,
    required String createdByUserId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime reminderTime,
    required ReminderScope scope,
    @Default([]) List<String> targetUserIds,
    String? message,
    @Default(false) bool isRecurring,
    String? recurringPattern,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @Default(false) bool isSent,
    @JsonKey(fromJson: _optionalTimestampFromJson, toJson: _optionalTimestampToJson)
    DateTime? sentAt,
    @Default(false) bool isCancelled,
    @JsonKey(fromJson: _optionalTimestampFromJson, toJson: _optionalTimestampToJson)
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);

  // Firestore converter
  static Reminder fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Reminder.fromJson({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  bool get isActive => !isSent && !isCancelled && reminderTime.isAfter(DateTime.now());
  bool get isPending => !isSent && !isCancelled;
  bool get isPersonal => scope.isPersonal;
  bool get isShared => scope.isShared;
}

DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is String) {
    return DateTime.parse(value);
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return DateTime.now();
}

DateTime? _optionalTimestampFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is String) {
    return DateTime.parse(value);
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return null;
}

dynamic _timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
dynamic _optionalTimestampToJson(DateTime? dateTime) =>
    dateTime != null ? Timestamp.fromDate(dateTime) : null;
