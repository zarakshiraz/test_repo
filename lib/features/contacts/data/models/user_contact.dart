import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'contact_status.dart';

class UserContact extends Equatable {
  final String id;
  final String contactUserId;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final ContactStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? source;

  const UserContact({
    required this.id,
    required this.contactUserId,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.source,
  });

  UserContact copyWith({
    String? id,
    String? contactUserId,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    ContactStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
  }) {
    return UserContact(
      id: id ?? this.id,
      contactUserId: contactUserId ?? this.contactUserId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactUserId': contactUserId,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'status': status.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'source': source,
    };
  }

  factory UserContact.fromJson(Map<String, dynamic> json) {
    return UserContact(
      id: json['id'] as String,
      contactUserId: json['contactUserId'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      status: ContactStatus.fromJson(json['status'] as String),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      source: json['source'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        contactUserId,
        displayName,
        email,
        phoneNumber,
        photoUrl,
        status,
        createdAt,
        updatedAt,
        source,
      ];
}
