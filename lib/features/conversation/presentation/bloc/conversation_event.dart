import 'package:equatable/equatable.dart';
import 'package:deaf_hearing_app/core/widgets/animated_pulse_indicator.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class ToggleCameraRequested extends ConversationEvent {}

class StartRecordingRequested extends ConversationEvent {}

class StopRecordingRequested extends ConversationEvent {}

class SendMessageRequested extends ConversationEvent {
  final String text;
  const SendMessageRequested(this.text);

  @override
  List<Object?> get props => [text];
}

class WebSocketStatusChanged extends ConversationEvent {
  final bool isConnected;
  const WebSocketStatusChanged(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class UpdateTranslationStatusRequested extends ConversationEvent {
  final TranslationStatus status;
  const UpdateTranslationStatusRequested(this.status);

  @override
  List<Object?> get props => [status];
}

class TriggerMockSignPlaybackRequested extends ConversationEvent {
  final String text;
  const TriggerMockSignPlaybackRequested(this.text);

  @override
  List<Object?> get props => [text];
}

class SimulateLiveSignDetected extends ConversationEvent {}

class LoadMockMessagesRequested extends ConversationEvent {}

class GenerateMockWaveformUpdate extends ConversationEvent {
  final List<double> amplitudes;
  const GenerateMockWaveformUpdate(this.amplitudes);

  @override
  List<Object?> get props => [amplitudes];
}

class ToggleSplitScreenRequested extends ConversationEvent {}
