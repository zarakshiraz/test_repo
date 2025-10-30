import 'package:cloud_firestore/cloud_firestore.dart';

class CollaborationList {
  final String id;
  final String title;
  final String createdBy;
  final DateTime createdAt;
  final List<String> participants;

  CollaborationList({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    required this.participants,
  });

  factory CollaborationList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollaborationList(
      id: doc.id,
      title: data['title'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'participants': participants,
    };
  }

  CollaborationList copyWith({
    String? id,
    String? title,
    String? createdBy,
    DateTime? createdAt,
    List<String>? participants,
  }) {
    return CollaborationList(
      id: id ?? this.id,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
    );
  }
}
