import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String displayName;
  
  @HiveField(3)
  final String? photoUrl;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime updatedAt;
  
  @HiveField(6)
  final List<String> contactIds;
  
  @HiveField(7)
  final List<String> blockedUserIds;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.contactIds = const [],
    this.blockedUserIds = const [],
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? contactIds,
    List<String>? blockedUserIds,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contactIds: contactIds ?? this.contactIds,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'contactIds': contactIds,
      'blockedUserIds': blockedUserIds,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      contactIds: List<String>.from(json['contactIds'] ?? []),
      blockedUserIds: List<String>.from(json['blockedUserIds'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        updatedAt,
        contactIds,
        blockedUserIds,
      ];
}