import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, voice }

class MessageModel {
  final String id;
  final String listId;
  final String senderId;
  final String senderName;
  final MessageType type;
  final String? textContent;
  final String? voiceUrl;
  final int? voiceDuration;
  final List<double>? waveformData;
  final DateTime timestamp;
  final Map<String, bool> readBy;

  MessageModel({
    required this.id,
    required this.listId,
    required this.senderId,
    required this.senderName,
    required this.type,
    this.textContent,
    this.voiceUrl,
    this.voiceDuration,
    this.waveformData,
    required this.timestamp,
    required this.readBy,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      listId: data['listId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      textContent: data['textContent'],
      voiceUrl: data['voiceUrl'],
      voiceDuration: data['voiceDuration'],
      waveformData: data['waveformData'] != null
          ? List<double>.from(data['waveformData'])
          : null,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      readBy: Map<String, bool>.from(data['readBy'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'listId': listId,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.toString().split('.').last,
      'textContent': textContent,
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration,
      'waveformData': waveformData,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
    };
  }

  MessageModel copyWith({
    String? id,
    String? listId,
    String? senderId,
    String? senderName,
    MessageType? type,
    String? textContent,
    String? voiceUrl,
    int? voiceDuration,
    List<double>? waveformData,
    DateTime? timestamp,
    Map<String, bool>? readBy,
  }) {
    return MessageModel(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      type: type ?? this.type,
      textContent: textContent ?? this.textContent,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      waveformData: waveformData ?? this.waveformData,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
    );
  }
}
