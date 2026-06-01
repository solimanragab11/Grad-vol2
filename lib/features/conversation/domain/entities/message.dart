import 'package:equatable/equatable.dart';

enum MessageSender {
  user, // Hearing user / Deaf user (Current App Owner)
  other, // The remote user in the workspace
  system, // AI / Status messages
}

enum MessageType { text, voice, translation, aiState }

class TranslationResult extends Equatable {
  final String text;
  final double confidence;
  final String? audioPath;

  const TranslationResult({
    required this.text,
    required this.confidence,
    this.audioPath,
  });

  @override
  List<Object?> get props => [text, confidence, audioPath];
}

class Message extends Equatable {
  final String id;
  final Map content;
  final MessageSender sender;
  final MessageType type;
  final DateTime timestamp;
  final String? duration; // for voice recordings
  final TranslationResult? translation; // associated translation details

  const Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.type,
    required this.timestamp,
    this.duration,
    this.translation,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    sender,
    type,
    timestamp,
    duration,
    translation,
  ];
}
