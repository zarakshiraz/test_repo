import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/providers/auth_providers.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
    ref: ref,
  );
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  ProfileController({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const AsyncValue.data(null));

  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = await _userRepository.getUser(userId);
      final updatedUser = currentUser.copyWith(
        displayName: displayName,
        phoneNumber: phoneNumber,
      );
      await _userRepository.updateUser(updatedUser);
    });
  }

  Future<void> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final photoUrl = await _userRepository.uploadProfilePhoto(
        userId,
        imageFile,
      );
      final currentUser = await _userRepository.getUser(userId);
      final updatedUser = currentUser.copyWith(photoUrl: photoUrl);
      await _userRepository.updateUser(updatedUser);
    });
  }

  Future<void> updateNotificationSettings({
    required String userId,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = await _userRepository.getUser(userId);
      final updatedUser = currentUser.copyWith(
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
        pushNotificationsEnabled: pushNotificationsEnabled,
      );
      await _userRepository.updateUser(updatedUser);
    });
  }

  Future<void> deleteAccount(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepository.deleteUser(userId);
      await _authRepository.deleteAccount();
    });
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}
