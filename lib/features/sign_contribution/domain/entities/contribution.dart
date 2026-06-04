import 'package:equatable/equatable.dart';

enum ContributionType {
  newSign,
  correction,
}

enum ContributionStatus {
  pending,
  approved,
  rejected,
}

class Contribution extends Equatable {
  final String id;
  final ContributionType type;
  final String videoUrl;
  final String meaning;
  final String dialect;
  final String? category;
  final String? targetSignId;
  final String? targetSignName;
  final ContributionStatus status;
  final String createdBy;
  final DateTime timestamp;
  final String? notes;

  const Contribution({
    required this.id,
    required this.type,
    required this.videoUrl,
    required this.meaning,
    required this.dialect,
    this.category,
    this.targetSignId,
    this.targetSignName,
    required this.status,
    required this.createdBy,
    required this.timestamp,
    this.notes,
  });

  bool get isCorrection => type == ContributionType.correction;
  bool get isNewSign => type == ContributionType.newSign;

  @override
  List<Object?> get props => [
        id,
        type,
        videoUrl,
        meaning,
        dialect,
        category,
        targetSignId,
        targetSignName,
        status,
        createdBy,
        timestamp,
        notes,
      ];
}
