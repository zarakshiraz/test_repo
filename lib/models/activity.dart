import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  itemAdded,
  itemChecked,
  itemUnchecked,
  itemEdited,
  participantAdded,
}

class Activity {
  final String id;
  final ActivityType type;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.timestamp,
    this.metadata,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      type: ActivityType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ActivityType.itemAdded,
      ),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'userId': userId,
      'userName': userName,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  String get description {
    switch (type) {
      case ActivityType.itemAdded:
        return '$userName added "${metadata?['itemTitle']}"';
      case ActivityType.itemChecked:
        return '$userName checked "${metadata?['itemTitle']}"';
      case ActivityType.itemUnchecked:
        return '$userName unchecked "${metadata?['itemTitle']}"';
      case ActivityType.itemEdited:
        return '$userName edited "${metadata?['itemTitle']}"';
      case ActivityType.participantAdded:
        return '$userName joined the list';
    }
  }
}
