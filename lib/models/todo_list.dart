import 'package:hive/hive.dart';
import 'sync_status.dart';

part 'todo_list.g.dart';

@HiveType(typeId: 1)
class TodoList extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  SyncStatus syncStatus;

  @HiveField(5)
  bool isDeleted;

  TodoList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory TodoList.fromFirestore(Map<String, dynamic> data) {
    return TodoList(
      id: data['id'] as String,
      name: data['name'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      isDeleted: data['isDeleted'] as bool? ?? false,
      syncStatus: SyncStatus.synced,
    );
  }

  TodoList copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    bool? isDeleted,
  }) {
    return TodoList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
