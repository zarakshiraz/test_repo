import 'package:equatable/equatable.dart';

enum ItemSource {
  manual,
  aiSuggested,
}

class ProvisionalItem extends Equatable {
  final String id;
  final String content;
  final ItemSource source;
  final int order;
  final String? notes;

  const ProvisionalItem({
    required this.id,
    required this.content,
    required this.source,
    required this.order,
    this.notes,
  });

  ProvisionalItem copyWith({
    String? id,
    String? content,
    ItemSource? source,
    int? order,
    String? notes,
  }) {
    return ProvisionalItem(
      id: id ?? this.id,
      content: content ?? this.content,
      source: source ?? this.source,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, content, source, order, notes];
}
