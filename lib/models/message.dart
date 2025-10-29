import 'package:hive/hive.dart';
import 'sync_status.dart';

part 'message.g.dart';

@HiveType(typeId: 3)
class Message extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  SyncStatus syncStatus;

  @HiveField(5)
  bool isDeleted;

  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      id: data['id'] as String,
      content: data['content'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      isDeleted: data['isDeleted'] as bool? ?? false,
      syncStatus: SyncStatus.synced,
    );
  }

  Message copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    bool? isDeleted,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
