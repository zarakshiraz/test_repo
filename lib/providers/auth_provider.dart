import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class AuthState {
  final String userId;
  final String userName;

  AuthState({required this.userId, required this.userName});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(
          userId: const Uuid().v4(),
          userName: 'User ${DateTime.now().millisecondsSinceEpoch % 1000}',
        ));

  void setUserName(String name) {
    state = AuthState(userId: state.userId, userName: name);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
