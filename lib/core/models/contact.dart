import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 8)
class Contact extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String displayName;
  
  @HiveField(3)
  final String? email;
  
  @HiveField(4)
  final String? phoneNumber;
  
  @HiveField(5)
  final String? photoUrl;
  
  @HiveField(6)
  final DateTime addedAt;
  
  @HiveField(7)
  final bool isSynced;
  
  @HiveField(8)
  final String? source; // 'phone', 'app', 'manual'

  const Contact({
    required this.id,
    required this.userId,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    required this.addedAt,
    this.isSynced = false,
    this.source,
  });

  Contact copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    DateTime? addedAt,
    bool? isSynced,
    String? source,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      addedAt: addedAt ?? this.addedAt,
      isSynced: isSynced ?? this.isSynced,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'addedAt': addedAt.toIso8601String(),
      'isSynced': isSynced,
      'source': source,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      source: json['source'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        email,
        phoneNumber,
        photoUrl,
        addedAt,
        isSynced,
        source,
      ];
}
