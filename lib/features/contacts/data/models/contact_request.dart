import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'contact_status.dart';

class ContactRequest extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUserName;
  final String? fromUserEmail;
  final String? fromUserPhotoUrl;
  final ContactStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? note;

  const ContactRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUserName,
    this.fromUserEmail,
    this.fromUserPhotoUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.note,
  });

  ContactRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? fromUserName,
    String? fromUserEmail,
    String? fromUserPhotoUrl,
    ContactStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
  }) {
    return ContactRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserEmail: fromUserEmail ?? this.fromUserEmail,
      fromUserPhotoUrl: fromUserPhotoUrl ?? this.fromUserPhotoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'fromUserEmail': fromUserEmail,
      'fromUserPhotoUrl': fromUserPhotoUrl,
      'status': status.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'note': note,
    };
  }

  factory ContactRequest.fromJson(Map<String, dynamic> json) {
    return ContactRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromUserEmail: json['fromUserEmail'] as String?,
      fromUserPhotoUrl: json['fromUserPhotoUrl'] as String?,
      status: ContactStatus.fromJson(json['status'] as String),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        fromUserName,
        fromUserEmail,
        fromUserPhotoUrl,
        status,
        createdAt,
        updatedAt,
        note,
      ];
}
