import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/core/widgets/glass_container.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter/material.dart';

void showFrictionlessMetrics(BuildContext context, ConversationState state) {
  final translation = state.currentTranslation;
  if (translation == null) return;

  showDialog(
    context: context,
    barrierColor: Colors.black45,
    builder: (context) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassContainer(
            borderRadius: 24,
            backgroundColor: AppColors.backgroundStart.withOpacity(0.95),
            borderColor: AppColors.darkGlassBorder,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.query_stats_rounded,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI INTERPRETER METRICS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recognition Accuracy',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${(translation.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppColors.stateGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: translation.confidence,
                    backgroundColor: Colors.white10,
                    color: AppColors.stateGreen,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOLOv8 Latency',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '42 ms',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MediaPipe Processing',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '60 fps',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'DISMISS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
