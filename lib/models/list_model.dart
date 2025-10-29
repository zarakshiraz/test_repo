import 'package:cloud_firestore/cloud_firestore.dart';

class ListModel {
  final String id;
  final String name;
  final String description;
  final List<String> participantIds;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  ListModel({
    required this.id,
    required this.name,
    required this.description,
    required this.participantIds,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });

  factory ListModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'participantIds': participantIds,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  ListModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? participantIds,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      participantIds: participantIds ?? this.participantIds,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
