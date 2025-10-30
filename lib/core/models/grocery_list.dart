import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'list_item.dart';

part 'grocery_list.g.dart';

@HiveType(typeId: 2)
enum ListPermission {
  @HiveField(0)
  viewOnly,
  @HiveField(1)
  canEdit,
}

@HiveType(typeId: 3)
enum ListStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  archived,
}

@HiveType(typeId: 4)
class SharedUser extends Equatable {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final ListPermission permission;
  
  @HiveField(2)
  final DateTime sharedAt;

  const SharedUser({
    required this.userId,
    required this.permission,
    required this.sharedAt,
  });

  SharedUser copyWith({
    String? userId,
    ListPermission? permission,
    DateTime? sharedAt,
  }) {
    return SharedUser(
      userId: userId ?? this.userId,
      permission: permission ?? this.permission,
      sharedAt: sharedAt ?? this.sharedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'permission': permission.name,
      'sharedAt': sharedAt.toIso8601String(),
    };
  }

  factory SharedUser.fromJson(Map<String, dynamic> json) {
    return SharedUser(
      userId: json['userId'] as String,
      permission: ListPermission.values.firstWhere(
        (e) => e.name == json['permission'],
      ),
      sharedAt: DateTime.parse(json['sharedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [userId, permission, sharedAt];
}

@HiveType(typeId: 5)
class GroceryList extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String createdByUserId;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime updatedAt;
  
  @HiveField(6)
  final List<SharedUser> sharedWith;
  
  @HiveField(7)
  final ListStatus status;
  
  @HiveField(8)
  final DateTime? completedAt;
  
  @HiveField(9)
  final bool isSaved;
  
  @HiveField(10)
  final String? reminderTime;
  
  @HiveField(11)
  final bool remindEveryone;
  
  @HiveField(12)
  final String? category;
  
  @HiveField(13)
  final int totalItems;
  
  @HiveField(14)
  final int completedItems;

  const GroceryList({
    required this.id,
    required this.title,
    this.description,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    this.sharedWith = const [],
    this.status = ListStatus.active,
    this.completedAt,
    this.isSaved = false,
    this.reminderTime,
    this.remindEveryone = false,
    this.category,
    this.totalItems = 0,
    this.completedItems = 0,
  });

  GroceryList copyWith({
    String? id,
    String? title,
    String? description,
    String? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SharedUser>? sharedWith,
    ListStatus? status,
    DateTime? completedAt,
    bool? isSaved,
    String? reminderTime,
    bool? remindEveryone,
    String? category,
    int? totalItems,
    int? completedItems,
  }) {
    return GroceryList(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sharedWith: sharedWith ?? this.sharedWith,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      isSaved: isSaved ?? this.isSaved,
      reminderTime: reminderTime ?? this.reminderTime,
      remindEveryone: remindEveryone ?? this.remindEveryone,
      category: category ?? this.category,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
    );
  }

  bool get isShared => sharedWith.isNotEmpty;
  
  double get completionPercentage => 
      totalItems > 0 ? completedItems / totalItems : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sharedWith': sharedWith.map((e) => e.toJson()).toList(),
      'status': status.name,
      'completedAt': completedAt?.toIso8601String(),
      'isSaved': isSaved,
      'reminderTime': reminderTime,
      'remindEveryone': remindEveryone,
      'category': category,
      'totalItems': totalItems,
      'completedItems': completedItems,
    };
  }

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdByUserId: json['createdByUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => SharedUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: ListStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ListStatus.active,
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isSaved: json['isSaved'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String?,
      remindEveryone: json['remindEveryone'] as bool? ?? false,
      category: json['category'] as String?,
      totalItems: json['totalItems'] as int? ?? 0,
      completedItems: json['completedItems'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        createdByUserId,
        createdAt,
        updatedAt,
        sharedWith,
        status,
        completedAt,
        isSaved,
        reminderTime,
        remindEveryone,
        category,
        totalItems,
        completedItems,
      ];
}