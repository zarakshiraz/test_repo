class GroceryItem {
  final String id;
  final String name;
  final String? category;
  final int quantity;
  final bool isCompleted;
  final DateTime createdAt;

  GroceryItem({
    required this.id,
    required this.name,
    this.category,
    this.quantity = 1,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.suggestions,
  }) : timestamp = timestamp ?? DateTime.now();
}
