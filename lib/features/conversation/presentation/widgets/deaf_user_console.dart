import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/features/conversation/domain/entities/message.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/widgets/video_area_component.dart';
import 'package:flutter/material.dart';

class DeafUserConsole extends StatelessWidget {
  final ConversationState state;

  const DeafUserConsole({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base layer: full-width Video Widget
        const Positioned.fill(
          child: VideoAreaComponent(),
        ),

        // Overlaid Subtitles container at bottom center
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Real-time spoken translation info header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.hearing_rounded,
                      color: AppColors.stateGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SPOKEN TRANSLATION',
                      style: TextStyle(
                        color: AppColors.stateGreen.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (state.isTyping) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.bubbleAiState,
                        ),
                      ),
                    ],
                  ],
                ),
                if (state.currentTranslation != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Acc: ${(state.currentTranslation!.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // Subtitles styled like real subtitles: White, bold text
                Text(
                  state.currentTranslation != null &&
                          state.messages.isNotEmpty &&
                          state.messages.first.sender == MessageSender.user
                      ? state.currentTranslation!.text
                      : "Waiting for spoken voice input...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
