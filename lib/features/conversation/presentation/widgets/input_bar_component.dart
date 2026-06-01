import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/core/widgets/glass_container.dart';
import 'package:deaf_hearing_app/core/widgets/waveform_visualizer.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';
// import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_event.dart';

class InputBarComponent extends StatefulWidget {
  const InputBarComponent({super.key});

  @override
  State<InputBarComponent> createState() => _InputBarComponentState();
}

class _InputBarComponentState extends State<InputBarComponent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _micAnimationController;

  @override
  void initState() {
    super.initState();
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _micAnimationController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<ConversationCubit>().sendMessage(text);
      _textController.clear();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationCubit, ConversationState>(
      builder: (context, state) {
        if (state.isRecording) {
          _micAnimationController.repeat(reverse: true);
        } else {
          _micAnimationController.stop();
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
            left: 12.0,
            right: 12.0,
            top: 8.0,
          ),
          child: GlassContainer(
            borderRadius: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            backgroundColor: AppColors.surfaceCard.withOpacity(0.85),
            borderColor: AppColors.darkGlassBorder,
            child: Row(
              children: [
                // Expandable recording panel / standard text field
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state.isRecording
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.stateRed,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: WaveformVisualizer(
                                    isRecording: true,
                                    amplitudes: state.recordingAmplitudes,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Type or long-press mic to speak...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _handleSend(),
                            ),
                          ),
                  ),
                ),

                // Active Send / Voice recording toggle buttons
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _textController.text.isNotEmpty || state.isRecording
                      ? (state.isRecording
                            ? _buildRecordingStopButton()
                            : _buildSendButton())
                      : _buildMicRecordButton(state.isRecording),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicRecordButton(bool isRecording) {
    return GestureDetector(
      onLongPressStart: (_) {
        context.read<ConversationCubit>().startRecording();
        HapticFeedback.mediumImpact();
      },
      onLongPressEnd: (_) {
        context.read<ConversationCubit>().stopRecording();
        HapticFeedback.mediumImpact();
      },
      onTap: () {
        // Accessibility feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hold microphone to record your voice.'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bubbleDeaf,
        ),
        child: const Icon(
          Icons.mic_none_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRecordingStopButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(
          parent: _micAnimationController,
          curve: Curves.easeInOut,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          context.read<ConversationCubit>().stopRecording();
          HapticFeedback.mediumImpact();
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.stateRed,
          ),
          child: const Icon(Icons.stop_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: IconButton(
        onPressed: _handleSend,
        icon: const Icon(
          Icons.arrow_upward_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
