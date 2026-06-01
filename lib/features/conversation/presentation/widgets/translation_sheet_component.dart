import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/core/widgets/glass_container.dart';
import 'package:deaf_hearing_app/features/conversation/domain/entities/message.dart';

class TranslationSheetComponent extends StatefulWidget {
  final TranslationResult result;
  final VoidCallback onReplay;

  const TranslationSheetComponent({
    super.key,
    required this.result,
    required this.onReplay,
  });

  @override
  State<TranslationSheetComponent> createState() => _TranslationSheetComponentState();
}

class _TranslationSheetComponentState extends State<TranslationSheetComponent> {
  bool _isPlayingSpeech = false;

  void _speakTranslation() {
    setState(() {
      _isPlayingSpeech = true;
    });
    HapticFeedback.lightImpact();

    // Simulate Text-To-Speech playback duration
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPlayingSpeech = false;
        });
      }
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.result.text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied translation to clipboard.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
      child: GlassContainer(
        borderRadius: 30,
        backgroundColor: AppColors.backgroundStart.withOpacity(0.92),
        borderColor: AppColors.darkGlassBorder,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slide Bar / Notch
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.stateGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI TRANSLATION ENGINE',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Translated Text Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black26,
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
              ),
              child: Text(
                widget.result.text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confidence Score Neon Gauge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DECISION METRICS',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.graphic_eq_rounded, color: AppColors.secondary, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Confidence Score',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          Text(
                            '${(widget.result.confidence * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppColors.stateGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Linear neon progress track
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.result.confidence,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          color: AppColors.stateGreen,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // Interactive Actions Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Replay gesture/avatar button
                _buildActionItem(
                  icon: Icons.replay_rounded,
                  label: 'Replay Avatar',
                  onTap: () {
                    widget.onReplay();
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                ),
                // Text-to-speech button
                _buildActionItem(
                  icon: _isPlayingSpeech ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                  iconColor: _isPlayingSpeech ? AppColors.stateBlue : null,
                  label: _isPlayingSpeech ? 'Speaking...' : 'Speak Audio',
                  onTap: _speakTranslation,
                ),
                // Copy text button
                _buildActionItem(
                  icon: Icons.copy_rounded,
                  label: 'Copy Text',
                  onTap: _copyToClipboard,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    Color? iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
