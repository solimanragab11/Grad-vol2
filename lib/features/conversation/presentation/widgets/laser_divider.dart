import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/core/widgets/glass_container.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter/material.dart';

class LaserDivider extends StatelessWidget {
  final ConversationState state;

  const LaserDivider({super.key, required this.state, required bool isTyping});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 2,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        GlassContainer(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.primary.withOpacity(0.4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sync_alt_rounded,
                color: AppColors.secondary,
                size: 10,
              ),
              const SizedBox(width: 6),
              Text(
                state.isTyping ? 'PROCESSING INPUTS...' : 'REAL-TIME WORKSPACE',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
