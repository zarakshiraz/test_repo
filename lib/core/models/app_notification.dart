import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'app_notification.g.dart';

@HiveType(typeId: 9)
enum NotificationType {
  @HiveField(0)
  listShared,
  @HiveField(1)
  listUpdated,
  @HiveField(2)
  reminder,
  @HiveField(3)
  newMessage,
  @HiveField(4)
  itemCompleted,
}

@HiveType(typeId: 10)
class AppNotification extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final NotificationType type;
  
  @HiveField(3)
  final String title;
  
  @HiveField(4)
  final String body;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final bool isRead;
  
  @HiveField(7)
  final String? listId;
  
  @HiveField(8)
  final String? fromUserId;
  
  @HiveField(9)
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.listId,
    this.fromUserId,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? listId,
    String? fromUserId,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      listId: listId ?? this.listId,
      fromUserId: fromUserId ?? this.fromUserId,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'listId': listId,
      'fromUserId': fromUserId,
      'data': data,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.listShared,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      listId: json['listId'] as String?,
      fromUserId: json['fromUserId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        createdAt,
        isRead,
        listId,
        fromUserId,
        data,
      ];
}
