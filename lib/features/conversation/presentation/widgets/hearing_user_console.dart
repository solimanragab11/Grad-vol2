// ignore_for_file: deprecated_member_use

import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/core/widgets/glass_container.dart';
import 'package:deaf_hearing_app/features/conversation/domain/entities/message.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter/material.dart';

class HearingUserConsole extends StatelessWidget {
  final ConversationState state;
  const HearingUserConsole({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final latestSignTranslation =
        state.messages.isNotEmpty &&
            state.messages.first.sender == MessageSender.other
        ? state.messages.first.content
        : "Waiting for sign gesture input...";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: GlassContainer(
            backgroundColor: AppColors.bubbleDeaf.withOpacity(0.7),
            borderColor: AppColors.darkGlassBorder,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sign_language_rounded,
                          color: AppColors.secondary,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SIGN TRANSLATION',
                          style: TextStyle(
                            color: AppColors.secondary.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    if (state.isSplitScreen)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      latestSignTranslation.toString(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
