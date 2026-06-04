import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contribution.dart';

class ContributionModel extends Contribution {
  const ContributionModel({
    required super.id,
    required super.type,
    required super.videoUrl,
    required super.meaning,
    required super.dialect,
    super.category,
    super.targetSignId,
    super.targetSignName,
    required super.status,
    required super.createdBy,
    required super.timestamp,
    super.notes,
  });

  factory ContributionModel.fromEntity(Contribution entity) {
    return ContributionModel(
      id: entity.id,
      type: entity.type,
      videoUrl: entity.videoUrl,
      meaning: entity.meaning,
      dialect: entity.dialect,
      category: entity.category,
      targetSignId: entity.targetSignId,
      targetSignName: entity.targetSignName,
      status: entity.status,
      createdBy: entity.createdBy,
      timestamp: entity.timestamp,
      notes: entity.notes,
    );
  }

  factory ContributionModel.fromFirestore(String id, Map<String, dynamic> data) {
    final typeStr = data['type'] as String;
    final statusStr = data['status'] as String;

    final type = typeStr == 'correction'
        ? ContributionType.correction
        : ContributionType.newSign;

    final status = statusStr == 'approved'
        ? ContributionStatus.approved
        : statusStr == 'rejected'
            ? ContributionStatus.rejected
            : ContributionStatus.pending;

    // Handle timestamp conversion from Firestore Timestamp or ISO string
    DateTime timestamp;
    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is String) {
      timestamp = DateTime.parse(data['timestamp'] as String);
    } else {
      timestamp = DateTime.now();
    }

    return ContributionModel(
      id: id,
      type: type,
      videoUrl: data['videoUrl'] ?? '',
      meaning: data['meaning'] ?? '',
      dialect: data['dialect'] ?? '',
      category: data['category'],
      targetSignId: data['targetSignId'],
      targetSignName: data['targetSignName'],
      status: status,
      createdBy: data['createdBy'] ?? 'unknown',
      timestamp: timestamp,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type == ContributionType.correction ? 'correction' : 'newSign',
      'videoUrl': videoUrl,
      'meaning': meaning,
      'dialect': dialect,
      'category': category,
      'targetSignId': targetSignId,
      'targetSignName': targetSignName,
      'status': status == ContributionStatus.approved
          ? 'approved'
          : status == ContributionStatus.rejected
              ? 'rejected'
              : 'pending',
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
    };
  }

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final statusStr = json['status'] as String;

    final type = typeStr == 'correction'
        ? ContributionType.correction
        : ContributionType.newSign;

    final status = statusStr == 'approved'
        ? ContributionStatus.approved
        : statusStr == 'rejected'
            ? ContributionStatus.rejected
            : ContributionStatus.pending;

    return ContributionModel(
      id: json['id'] ?? '',
      type: type,
      videoUrl: json['videoUrl'] ?? '',
      meaning: json['meaning'] ?? '',
      dialect: json['dialect'] ?? '',
      category: json['category'],
      targetSignId: json['targetSignId'],
      targetSignName: json['targetSignName'],
      status: status,
      createdBy: json['createdBy'] ?? 'unknown',
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == ContributionType.correction ? 'correction' : 'newSign',
      'videoUrl': videoUrl,
      'meaning': meaning,
      'dialect': dialect,
      'category': category,
      'targetSignId': targetSignId,
      'targetSignName': targetSignName,
      'status': status == ContributionStatus.approved
          ? 'approved'
          : status == ContributionStatus.rejected
              ? 'rejected'
              : 'pending',
      'createdBy': createdBy,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  ContributionModel copyWith({
    String? id,
    ContributionType? type,
    String? videoUrl,
    String? meaning,
    String? dialect,
    String? category,
    String? targetSignId,
    String? targetSignName,
    ContributionStatus? status,
    String? createdBy,
    DateTime? timestamp,
    String? notes,
  }) {
    return ContributionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      videoUrl: videoUrl ?? this.videoUrl,
      meaning: meaning ?? this.meaning,
      dialect: dialect ?? this.dialect,
      category: category ?? this.category,
      targetSignId: targetSignId ?? this.targetSignId,
      targetSignName: targetSignName ?? this.targetSignName,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }
}
