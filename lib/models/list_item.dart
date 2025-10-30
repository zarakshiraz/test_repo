class ListItem {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final String createdBy;

  const ListItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.createdBy,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  ListItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return ListItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
