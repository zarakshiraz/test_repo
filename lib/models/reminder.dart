import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderAudience {
  self,
  allParticipants,
}

class Reminder {
  final String id;
  final String listId;
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final ReminderAudience audience;
  final String createdBy;
  final bool isActive;
  final List<String> notifiedUsers;

  Reminder({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.audience,
    required this.createdBy,
    this.isActive = true,
    this.notifiedUsers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listId': listId,
      'title': title,
      'description': description,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'audience': audience.name,
      'createdBy': createdBy,
      'isActive': isActive,
      'notifiedUsers': notifiedUsers,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',
      listId: map['listId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      audience: ReminderAudience.values.firstWhere(
        (e) => e.name == map['audience'],
        orElse: () => ReminderAudience.self,
      ),
      createdBy: map['createdBy'] ?? '',
      isActive: map['isActive'] ?? true,
      notifiedUsers: List<String>.from(map['notifiedUsers'] ?? []),
    );
  }

  Reminder copyWith({
    String? id,
    String? listId,
    String? title,
    String? description,
    DateTime? scheduledTime,
    ReminderAudience? audience,
    String? createdBy,
    bool? isActive,
    List<String>? notifiedUsers,
  }) {
    return Reminder(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      audience: audience ?? this.audience,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      notifiedUsers: notifiedUsers ?? this.notifiedUsers,
    );
  }
}
