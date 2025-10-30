import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/activity_type.dart';

part 'list_activity.freezed.dart';
part 'list_activity.g.dart';

@freezed
class ListActivity with _$ListActivity {
  const ListActivity._();

  const factory ListActivity({
    required String id,
    required String listId,
    required ActivityType type,
    required String userId,
    String? userName,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime timestamp,
    String? description,
    String? itemId,
    String? itemContent,
    String? targetUserId,
    Map<String, dynamic>? metadata,
  }) = _ListActivity;

  factory ListActivity.fromJson(Map<String, dynamic> json) =>
      _$ListActivityFromJson(json);

  // Firestore converter
  static ListActivity fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ListActivity.fromJson({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  // Generate human-readable description
  String get readableDescription {
    if (description != null) return description!;

    final user = userName ?? 'Someone';
    switch (type) {
      case ActivityType.listCreated:
        return '$user created the list';
      case ActivityType.listUpdated:
        return '$user updated the list';
      case ActivityType.listCompleted:
        return '$user completed the list';
      case ActivityType.listArchived:
        return '$user archived the list';
      case ActivityType.itemAdded:
        return '$user added "${itemContent ?? 'an item'}"';
      case ActivityType.itemUpdated:
        return '$user updated "${itemContent ?? 'an item'}"';
      case ActivityType.itemCompleted:
        return '$user completed "${itemContent ?? 'an item'}"';
      case ActivityType.itemDeleted:
        return '$user deleted "${itemContent ?? 'an item'}"';
      case ActivityType.userAdded:
        return '$user added a participant';
      case ActivityType.userRemoved:
        return '$user removed a participant';
      case ActivityType.permissionChanged:
        return '$user changed permissions';
    }
  }
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

dynamic _timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
