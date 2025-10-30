import 'package:cloud_firestore/cloud_firestore.dart';

class ListItem {
  final String id;
  final String title;
  final bool isChecked;
  final String createdBy;
  final DateTime createdAt;
  final String? checkedBy;
  final DateTime? checkedAt;

  ListItem({
    required this.id,
    required this.title,
    required this.isChecked,
    required this.createdBy,
    required this.createdAt,
    this.checkedBy,
    this.checkedAt,
  });

  factory ListItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListItem(
      id: doc.id,
      title: data['title'] ?? '',
      isChecked: data['isChecked'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkedBy: data['checkedBy'],
      checkedAt: (data['checkedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'isChecked': isChecked,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'checkedBy': checkedBy,
      'checkedAt': checkedAt != null ? Timestamp.fromDate(checkedAt!) : null,
    };
  }

  ListItem copyWith({
    String? id,
    String? title,
    bool? isChecked,
    String? createdBy,
    DateTime? createdAt,
    String? checkedBy,
    DateTime? checkedAt,
  }) {
    return ListItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
}
