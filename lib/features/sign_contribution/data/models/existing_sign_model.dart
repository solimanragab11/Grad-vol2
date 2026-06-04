import '../../domain/entities/existing_sign.dart';

class ExistingSignModel extends ExistingSign {
  const ExistingSignModel({
    required super.id,
    required super.meaning,
    required super.category,
    required super.videoUrl,
  });

  factory ExistingSignModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ExistingSignModel(
      id: id,
      meaning: data['meaning'] ?? '',
      category: data['category'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'meaning': meaning,
      'category': category,
      'videoUrl': videoUrl,
    };
  }

  factory ExistingSignModel.fromJson(Map<String, dynamic> json) {
    return ExistingSignModel(
      id: json['id'] ?? '',
      meaning: json['meaning'] ?? '',
      category: json['category'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meaning': meaning,
      'category': category,
      'videoUrl': videoUrl,
    };
  }
}
