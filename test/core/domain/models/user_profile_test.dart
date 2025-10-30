import 'package:flutter_test/flutter_test.dart';
import 'package:grocli/core/domain/domain.dart';

void main() {
  group('UserProfile', () {
    test('fromJson and toJson should be inverse operations', () {
      final original = UserProfile(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        phoneNumber: '+1234567890',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        contactIds: ['contact1', 'contact2'],
        blockedUserIds: ['blocked1'],
        isActive: true,
        preferences: {'theme': 'dark'},
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.email, equals(original.email));
      expect(restored.displayName, equals(original.displayName));
      expect(restored.photoUrl, equals(original.photoUrl));
      expect(restored.phoneNumber, equals(original.phoneNumber));
      expect(restored.contactIds, equals(original.contactIds));
      expect(restored.blockedUserIds, equals(original.blockedUserIds));
      expect(restored.isActive, equals(original.isActive));
      expect(restored.preferences, equals(original.preferences));
    });

    test('copyWith should create new instance with updated fields', () {
      final original = UserProfile(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      final updated = original.copyWith(displayName: 'Updated Name');

      expect(updated.id, equals(original.id));
      expect(updated.displayName, equals('Updated Name'));
      expect(updated.email, equals(original.email));
    });
  });
}
