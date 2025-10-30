import '../constants/permissions.dart';

class Participant {
  final String userId;
  final String userName;
  final String userEmail;
  final PermissionRole role;
  final DateTime addedAt;

  const Participant({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
    required this.addedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      role: permissionRoleFromString(json['role'] as String),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'role': role.value,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  Participant copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    PermissionRole? role,
    DateTime? addedAt,
  }) {
    return Participant(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      role: role ?? this.role,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participant &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
