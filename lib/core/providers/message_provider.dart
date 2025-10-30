import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final String userId;
  final _uuid = const Uuid();

  Map<String, List<Message>> _messagesByList = {};
  bool _isLoading = false;
  String? _errorMessage;

  MessageProvider({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  List<Message> getMessagesForList(String listId) {
    return _messagesByList[listId] ?? [];
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadMessages(String listId) {
    _firestore
        .collection('lists')
        .doc(listId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      _messagesByList[listId] = snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  Future<Message?> sendTextMessage({
    required String listId,
    required String content,
    String? replyToMessageId,
  }) async {
    try {
      _errorMessage = null;
      
      final messageId = _uuid.v4();
      final now = DateTime.now();

      final message = Message(
        id: messageId,
        listId: listId,
        senderId: userId,
        content: content,
        type: MessageType.text,
        createdAt: now,
        replyToMessageId: replyToMessageId,
      );

      await _firestore
          .collection('lists')
          .doc(listId)
          .collection('messages')
          .doc(messageId)
          .set(message.toJson());

      return message;
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
      return null;
    }
  }

  Future<Message?> sendVoiceMessage({
    required String listId,
    required String voiceUrl,
    required int voiceDuration,
    String? content,
  }) async {
    try {
      _errorMessage = null;
      
      final messageId = _uuid.v4();
      final now = DateTime.now();

      final message = Message(
        id: messageId,
        listId: listId,
        senderId: userId,
        content: content ?? 'Voice message',
        type: MessageType.voice,
        createdAt: now,
        voiceUrl: voiceUrl,
        voiceDuration: voiceDuration,
      );

      await _firestore
          .collection('lists')
          .doc(listId)
          .collection('messages')
          .doc(messageId)
          .set(message.toJson());

      return message;
    } catch (e) {
      _errorMessage = 'Failed to send voice message: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteMessage(String listId, String messageId) async {
    try {
      await _firestore
          .collection('lists')
          .doc(listId)
          .collection('messages')
          .doc(messageId)
          .delete();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete message: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsRead(String listId, String messageId) async {
    try {
      await _firestore
          .collection('lists')
          .doc(listId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});

      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark message as read: $e';
      notifyListeners();
      return false;
    }
  }

  int getUnreadCount(String listId) {
    final messages = _messagesByList[listId] ?? [];
    return messages.where((m) => !m.isRead && m.senderId != userId).length;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void dispose() {
    _messagesByList.clear();
    super.dispose();
  }
}
