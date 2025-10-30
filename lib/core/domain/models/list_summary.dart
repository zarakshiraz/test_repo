import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/list_status.dart';
import 'list_permission.dart';

part 'list_summary.freezed.dart';
part 'list_summary.g.dart';

@freezed
class ListSummary with _$ListSummary {
  const ListSummary._();

  const factory ListSummary({
    required String id,
    required String title,
    String? description,
    required String createdByUserId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime updatedAt,
    @JsonKey(fromJson: _participantsFromJson, toJson: _participantsToJson)
    @Default([]) List<ListPermission> participants,
    @Default(ListStatus.active) ListStatus status,
    @JsonKey(fromJson: _optionalTimestampFromJson, toJson: _optionalTimestampToJson)
    DateTime? completedAt,
    String? category,
    @Default(0) int totalItems,
    @Default(0) int completedItems,
    @Default(false) bool isSaved,
    @Default(false) bool hasReminder,
    Map<String, dynamic>? metadata,
  }) = _ListSummary;

  factory ListSummary.fromJson(Map<String, dynamic> json) =>
      _$ListSummaryFromJson(json);

  // Firestore converter
  static ListSummary fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ListSummary.fromJson({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  // Computed properties
  bool get isShared => participants.length > 1;
  bool get isActive => status.isActive;
  bool get isCompleted => status.isCompleted;
  double get completionPercentage =>
      totalItems > 0 ? completedItems / totalItems : 0.0;
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

List<ListPermission> _participantsFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .map((e) => ListPermission.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

List<Map<String, dynamic>> _participantsToJson(List<ListPermission> participants) {
  return participants.map((p) => p.toJson()).toList();
}
