import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  text,
  voice,
  system,
}

@freezed
class Message with _$Message {
  const Message._();

  const factory Message({
    required String id,
    required String listId,
    required MessageType type,
    required String senderId,
    String? senderName,
    String? senderPhotoUrl,
    String? content,
    String? voiceUrl,
    int? voiceDuration,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime sentAt,
    @Default([]) List<String> readBy,
    @Default(false) bool isDeleted,
    @JsonKey(fromJson: _optionalTimestampFromJson, toJson: _optionalTimestampToJson)
    DateTime? deletedAt,
    Map<String, dynamic>? metadata,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  // Firestore converter
  static Message fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Message.fromJson({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  bool isReadBy(String userId) => readBy.contains(userId);
  bool get isText => type == MessageType.text;
  bool get isVoice => type == MessageType.voice;
  bool get isSystem => type == MessageType.system;
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
