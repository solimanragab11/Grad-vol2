import 'package:flutter/material.dart';
import 'package:deaf_hearing_app/core/theme/app_colors.dart';

enum TranslationStatus {
  idle,       // Red = no translation
  processing, // Yellow = processing
  ready,      // Green = translation ready
  playing,    // Blue = playback active
}

class AnimatedPulseIndicator extends StatefulWidget {
  final TranslationStatus status;
  final VoidCallback onTap;

  const AnimatedPulseIndicator({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<AnimatedPulseIndicator> createState() => _AnimatedPulseIndicatorState();
}

class _AnimatedPulseIndicatorState extends State<AnimatedPulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case TranslationStatus.idle:
        return AppColors.stateRed;
      case TranslationStatus.processing:
        return AppColors.stateYellow;
      case TranslationStatus.ready:
        return AppColors.stateGreen;
      case TranslationStatus.playing:
        return AppColors.stateBlue;
    }
  }

  Color get _statusGlow {
    switch (widget.status) {
      case TranslationStatus.idle:
        return AppColors.stateRedGlow;
      case TranslationStatus.processing:
        return AppColors.stateYellowGlow;
      case TranslationStatus.ready:
        return AppColors.stateGreenGlow;
      case TranslationStatus.playing:
        return AppColors.stateBlueGlow;
    }
  }

  IconData get _statusIcon {
    switch (widget.status) {
      case TranslationStatus.idle:
        return Icons.translate_rounded;
      case TranslationStatus.processing:
        return Icons.psychology_rounded;
      case TranslationStatus.ready:
        return Icons.check_circle_outline_rounded;
      case TranslationStatus.playing:
        return Icons.volume_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double pulseVal = _pulseController.value;
        final double opacity = (1.0 - pulseVal).clamp(0.0, 1.0);

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulsing Glow Ring
              Transform.scale(
                scale: 1.0 + (pulseVal * 0.4),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: _statusColor.withOpacity(opacity * 0.4),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Inner Ambient Glow Card
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _statusGlow,
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              // Core Interactive Button
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _statusColor.withAlpha(255),
                          Color.alphaBlend(_statusColor.withAlpha(150), Colors.black),
                        ],
                        radius: 0.85,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _statusIcon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
