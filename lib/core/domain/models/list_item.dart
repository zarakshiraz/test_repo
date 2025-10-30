import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/item_state.dart';

part 'list_item.freezed.dart';
part 'list_item.g.dart';

@freezed
class ListItem with _$ListItem {
  const ListItem._();

  const factory ListItem({
    required String id,
    required String listId,
    required String content,
    @Default(ItemState.pending) ItemState state,
    String? completedByUserId,
    @JsonKey(fromJson: _optionalTimestampFromJson, toJson: _optionalTimestampToJson)
    DateTime? completedAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime updatedAt,
    required String createdByUserId,
    @Default(0) int order,
    String? notes,
    String? category,
    double? quantity,
    String? unit,
    Map<String, dynamic>? metadata,
  }) = _ListItem;

  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);

  // Firestore converter
  static ListItem fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ListItem.fromJson({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  // Computed properties
  bool get isCompleted => state.isCompleted;
  bool get isPending => state.isPending;
  bool get isCancelled => state.isCancelled;
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
