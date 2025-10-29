import 'package:hive/hive.dart';

part 'activity_log.g.dart';

@HiveType(typeId: 4)
class ActivityLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String entityType;

  @HiveField(2)
  String entityId;

  @HiveField(3)
  String action;

  @HiveField(4)
  String? conflictDetails;

  @HiveField(5)
  DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.conflictDetails,
    required this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'action': action,
      'conflictDetails': conflictDetails,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityLog.fromFirestore(Map<String, dynamic> data) {
    return ActivityLog(
      id: data['id'] as String,
      entityType: data['entityType'] as String,
      entityId: data['entityId'] as String,
      action: data['action'] as String,
      conflictDetails: data['conflictDetails'] as String?,
      timestamp: DateTime.parse(data['timestamp'] as String),
    );
  }
}
