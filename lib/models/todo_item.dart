import 'package:hive/hive.dart';
import 'sync_status.dart';

part 'todo_item.g.dart';

@HiveType(typeId: 2)
class TodoItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String listId;

  @HiveField(2)
  String title;

  @HiveField(3)
  bool completed;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  SyncStatus syncStatus;

  @HiveField(7)
  bool isDeleted;

  TodoItem({
    required this.id,
    required this.listId,
    required this.title,
    this.completed = false,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'listId': listId,
      'title': title,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory TodoItem.fromFirestore(Map<String, dynamic> data) {
    return TodoItem(
      id: data['id'] as String,
      listId: data['listId'] as String,
      title: data['title'] as String,
      completed: data['completed'] as bool? ?? false,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      isDeleted: data['isDeleted'] as bool? ?? false,
      syncStatus: SyncStatus.synced,
    );
  }

  TodoItem copyWith({
    String? id,
    String? listId,
    String? title,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    bool? isDeleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
