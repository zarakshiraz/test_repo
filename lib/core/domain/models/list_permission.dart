import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/list_permission.dart';

part 'list_permission.freezed.dart';
part 'list_permission.g.dart';

@freezed
class ListPermission with _$ListPermission {
  const ListPermission._();

  const factory ListPermission({
    required String userId,
    required ListPermissionType permission,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime grantedAt,
    String? grantedBy,
    @JsonKey(fromJson: _optionalTimestampFromJson, toJson: _optionalTimestampToJson)
    DateTime? revokedAt,
    String? revokedBy,
  }) = _ListPermission;

  factory ListPermission.fromJson(Map<String, dynamic> json) =>
      _$ListPermissionFromJson(json);

  bool get isActive => revokedAt == null;
  bool get canEdit => permission.canEdit;
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
