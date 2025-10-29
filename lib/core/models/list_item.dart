import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'list_item.g.dart';

@HiveType(typeId: 1)
class ListItem extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String listId;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final bool isCompleted;
  
  @HiveField(4)
  final String? completedByUserId;
  
  @HiveField(5)
  final DateTime? completedAt;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;
  
  @HiveField(8)
  final String createdByUserId;
  
  @HiveField(9)
  final int order;
  
  @HiveField(10)
  final String? notes;

  const ListItem({
    required this.id,
    required this.listId,
    required this.content,
    this.isCompleted = false,
    this.completedByUserId,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    this.order = 0,
    this.notes,
  });

  ListItem copyWith({
    String? id,
    String? listId,
    String? content,
    bool? isCompleted,
    String? completedByUserId,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByUserId,
    int? order,
    String? notes,
  }) {
    return ListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
      completedByUserId: completedByUserId ?? this.completedByUserId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'content': content,
      'isCompleted': isCompleted,
      'completedByUserId': completedByUserId,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdByUserId': createdByUserId,
      'order': order,
      'notes': notes,
    };
  }

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as String,
      listId: json['listId'] as String,
      content: json['content'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedByUserId: json['completedByUserId'] as String?,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdByUserId: json['createdByUserId'] as String,
      order: json['order'] as int? ?? 0,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        listId,
        content,
        isCompleted,
        completedByUserId,
        completedAt,
        createdAt,
        updatedAt,
        createdByUserId,
        order,
        notes,
      ];
}