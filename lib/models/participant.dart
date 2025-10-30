import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  final String id;
  final String name;
  final DateTime joinedAt;
  final bool isOnline;

  Participant({
    required this.id,
    required this.name,
    required this.joinedAt,
    required this.isOnline,
  });

  factory Participant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Participant(
      id: doc.id,
      name: data['name'] ?? '',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnline: data['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isOnline': isOnline,
    };
  }
}
