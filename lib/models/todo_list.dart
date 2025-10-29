import 'package:cloud_firestore/cloud_firestore.dart';

class TodoList {
  final String id;
  final String name;
  final String ownerId;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoList({
    required this.id,
    required this.name,
    required this.ownerId,
    this.participantIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'participantIds': participantIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TodoList.fromMap(Map<String, dynamic> map) {
    return TodoList(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  TodoList copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoList(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
