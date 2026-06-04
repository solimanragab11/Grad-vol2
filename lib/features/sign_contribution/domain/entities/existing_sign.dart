import 'package:equatable/equatable.dart';

class ExistingSign extends Equatable {
  final String id;
  final String meaning;
  final String category;
  final String videoUrl;

  const ExistingSign({
    required this.id,
    required this.meaning,
    required this.category,
    required this.videoUrl,
  });

  @override
  List<Object?> get props => [id, meaning, category, videoUrl];
}
