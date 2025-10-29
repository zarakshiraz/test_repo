import 'list_item.dart';

class ListTemplate {
  final String id;
  final String title;
  final String userId;
  final List<ListItem> items;
  final DateTime createdAt;
  final String? originalListId;
  final int itemCount;

  ListTemplate({
    required this.id,
    required this.title,
    required this.userId,
    List<ListItem>? items,
    required this.createdAt,
    this.originalListId,
    int? itemCount,
  })  : items = items ?? [],
        itemCount = itemCount ?? (items?.length ?? 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'originalListId': originalListId,
      'itemCount': itemCount,
    };
  }

  factory ListTemplate.fromMap(Map<String, dynamic> map) {
    return ListTemplate(
      id: map['id'] as String,
      title: map['title'] as String,
      userId: map['userId'] as String,
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => ListItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      originalListId: map['originalListId'] as String?,
      itemCount: map['itemCount'] as int? ?? 0,
    );
  }

  ListTemplate copyWith({
    String? id,
    String? title,
    String? userId,
    List<ListItem>? items,
    DateTime? createdAt,
    String? originalListId,
    int? itemCount,
  }) {
    return ListTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      originalListId: originalListId ?? this.originalListId,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
