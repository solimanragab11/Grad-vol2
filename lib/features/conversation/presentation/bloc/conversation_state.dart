import 'package:equatable/equatable.dart';
import 'package:deaf_hearing_app/core/widgets/animated_pulse_indicator.dart';
import 'package:deaf_hearing_app/features/conversation/domain/entities/message.dart';

enum VideoMode { idle, signPlayback, camera }

class ConversationState extends Equatable {
  final VideoMode videoMode;
  final TranslationStatus translationStatus;
  final bool isRecording;
  final bool isConnected;
  final bool isTyping;
  final List<Message> messages;
  final TranslationResult? currentTranslation;
  final List<double> recordingAmplitudes;
  final bool isSplitScreen;
  final int swipNum;
  const ConversationState({
    this.videoMode = VideoMode.idle,
    this.translationStatus = TranslationStatus.idle,
    this.isRecording = false,
    this.isConnected = true,
    this.isTyping = false,
    this.messages = const [],
    this.currentTranslation,
    this.recordingAmplitudes = const [],
    this.isSplitScreen = false,
    this.swipNum = 2,
  });

  ConversationState copyWith({
    VideoMode? videoMode,
    TranslationStatus? translationStatus,
    bool? isRecording,
    bool? isConnected,
    bool? isTyping,
    List<Message>? messages,
    TranslationResult? currentTranslation,
    List<double>? recordingAmplitudes,
    bool? isSplitScreen,
    int? swipNum,
  }) {
    return ConversationState(
      videoMode: videoMode ?? this.videoMode,
      translationStatus: translationStatus ?? this.translationStatus,
      isRecording: isRecording ?? this.isRecording,
      isConnected: isConnected ?? this.isConnected,
      isTyping: isTyping ?? this.isTyping,
      messages: messages ?? this.messages,
      currentTranslation: currentTranslation ?? this.currentTranslation,
      recordingAmplitudes: recordingAmplitudes ?? this.recordingAmplitudes,
      isSplitScreen: isSplitScreen ?? this.isSplitScreen,
      swipNum: swipNum ?? this.swipNum,
    );
  }

  @override
  List<Object?> get props => [
    videoMode,
    translationStatus,
    isRecording,
    isConnected,
    isTyping,
    messages,
    currentTranslation,
    recordingAmplitudes,
    isSplitScreen,
    swipNum,
  ];
}
