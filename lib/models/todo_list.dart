class TodoList {
  final String id;
  final String title;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isShared;
  final int participantCount;

  const TodoList({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    required this.updatedAt,
    this.isShared = false,
    this.participantCount = 1,
  });

  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id'] as String,
      title: json['title'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isShared: json['isShared'] as bool? ?? false,
      participantCount: json['participantCount'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isShared': isShared,
      'participantCount': participantCount,
    };
  }

  TodoList copyWith({
    String? id,
    String? title,
    String? ownerId,
    String? ownerName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isShared,
    int? participantCount,
  }) {
    return TodoList(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isShared: isShared ?? this.isShared,
      participantCount: participantCount ?? this.participantCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoList && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
