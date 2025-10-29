import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 6)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  voice,
  @HiveField(2)
  system,
}

@HiveType(typeId: 7)
class Message extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String listId;
  
  @HiveField(2)
  final String senderId;
  
  @HiveField(3)
  final String content;
  
  @HiveField(4)
  final MessageType type;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final String? voiceUrl;
  
  @HiveField(7)
  final int? voiceDuration;
  
  @HiveField(8)
  final bool isRead;
  
  @HiveField(9)
  final String? replyToMessageId;

  const Message({
    required this.id,
    required this.listId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.voiceUrl,
    this.voiceDuration,
    this.isRead = false,
    this.replyToMessageId,
  });

  Message copyWith({
    String? id,
    String? listId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    String? voiceUrl,
    int? voiceDuration,
    bool? isRead,
    String? replyToMessageId,
  }) {
    return Message(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      isRead: isRead ?? this.isRead,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration,
      'isRead': isRead,
      'replyToMessageId': replyToMessageId,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      listId: json['listId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      voiceUrl: json['voiceUrl'] as String?,
      voiceDuration: json['voiceDuration'] as int?,
      isRead: json['isRead'] as bool? ?? false,
      replyToMessageId: json['replyToMessageId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        listId,
        senderId,
        content,
        type,
        createdAt,
        voiceUrl,
        voiceDuration,
        isRead,
        replyToMessageId,
      ];
}