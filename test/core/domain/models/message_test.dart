import 'package:flutter_test/flutter_test.dart';
import 'package:grocli/core/domain/domain.dart';

void main() {
  group('Message', () {
    test('fromJson and toJson should be inverse operations', () {
      final original = Message(
        id: 'msg123',
        listId: 'list123',
        type: MessageType.text,
        senderId: 'user123',
        senderName: 'John Doe',
        senderPhotoUrl: 'https://example.com/photo.jpg',
        content: 'Hello, team!',
        sentAt: DateTime(2024, 1, 1, 12, 0),
        readBy: ['user123', 'user456'],
        isDeleted: false,
        metadata: {'priority': 'high'},
      );

      final json = original.toJson();
      final restored = Message.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.listId, equals(original.listId));
      expect(restored.type, equals(original.type));
      expect(restored.senderId, equals(original.senderId));
      expect(restored.senderName, equals(original.senderName));
      expect(restored.content, equals(original.content));
      expect(restored.readBy, equals(original.readBy));
      expect(restored.isDeleted, equals(original.isDeleted));
    });

    test('isReadBy should check if user has read message', () {
      final message = Message(
        id: 'msg123',
        listId: 'list123',
        type: MessageType.text,
        senderId: 'user123',
        content: 'Test message',
        sentAt: DateTime.now(),
        readBy: ['user123', 'user456'],
      );

      expect(message.isReadBy('user123'), isTrue);
      expect(message.isReadBy('user789'), isFalse);
    });

    test('message type helpers should work correctly', () {
      final textMessage = Message(
        id: 'msg123',
        listId: 'list123',
        type: MessageType.text,
        senderId: 'user123',
        content: 'Hello',
        sentAt: DateTime.now(),
      );

      expect(textMessage.isText, isTrue);
      expect(textMessage.isVoice, isFalse);
      expect(textMessage.isSystem, isFalse);
    });
  });
}
