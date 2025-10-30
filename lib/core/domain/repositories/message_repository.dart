import '../models/message.dart';

/// Repository interface for message operations.
abstract class MessageRepository {
  // Message CRUD operations
  Future<Message> sendMessage(Message message);
  Future<Message?> getMessage(String listId, String messageId);
  Future<void> deleteMessage(String listId, String messageId);

  // Message queries
  Future<List<Message>> getListMessages(String listId, {int limit = 100});
  Future<List<Message>> getMessagesBefore(
    String listId,
    DateTime before, {
    int limit = 50,
  });
  Stream<List<Message>> watchListMessages(String listId, {int limit = 100});

  // Read receipts
  Future<void> markAsRead(String listId, String messageId, String userId);
  Future<void> markAllAsRead(String listId, String userId);
  Future<int> getUnreadCount(String listId, String userId);

  // Voice message handling
  Future<String> uploadVoiceMessage(String listId, String filePath);
  Future<void> deleteVoiceMessage(String voiceUrl);

  // Bulk operations
  Future<void> deleteAllMessages(String listId);

  // Offline support placeholders
  Future<void> syncPendingMessages();
  Future<bool> hasPendingMessages();
}
