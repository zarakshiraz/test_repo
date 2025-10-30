import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'template.freezed.dart';
part 'template.g.dart';

@freezed
class TemplateItem with _$TemplateItem {
  const factory TemplateItem({
    required String content,
    String? category,
    double? quantity,
    String? unit,
    @Default(0) int order,
  }) = _TemplateItem;

  factory TemplateItem.fromJson(Map<String, dynamic> json) =>
      _$TemplateItemFromJson(json);
}

@freezed
class Template with _$Template {
  const Template._();

  const factory Template({
    required String id,
    required String name,
    String? description,
    required String createdByUserId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime updatedAt,
    @JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson)
    @Default([]) List<TemplateItem> items,
    String? category,
    @Default(false) bool isPublic,
    @Default(0) int usageCount,
    @Default([]) List<String> tags,
    Map<String, dynamic>? metadata,
  }) = _Template;

  factory Template.fromJson(Map<String, dynamic> json) =>
      _$TemplateFromJson(json);

  // Firestore converter
  static Template fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Template.fromJson({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  int get itemCount => items.length;
}

DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is String) {
    return DateTime.parse(value);
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return DateTime.now();
}

dynamic _timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);

List<TemplateItem> _itemsFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

List<Map<String, dynamic>> _itemsToJson(List<TemplateItem> items) {
  return items.map((item) => item.toJson()).toList();
}
