import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:deaf_hearing_app/core/theme/app_colors.dart';

class WaveformVisualizer extends StatefulWidget {
  final bool isRecording;
  final List<double> amplitudes;

  const WaveformVisualizer({
    super.key,
    required this.isRecording,
    this.amplitudes = const [],
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isRecording) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRecording && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 60),
          painter: WaveformPainter(
            isRecording: widget.isRecording,
            animationValue: _controller.value,
            amplitudes: widget.amplitudes,
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final bool isRecording;
  final double animationValue;
  final List<double> amplitudes;

  WaveformPainter({
    required this.isRecording,
    required this.animationValue,
    required this.amplitudes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final totalBars = 35;
    final spacing = size.width / totalBars;

    // Draw secondary neon gradient overlay to make it look premium
    final rect = Offset.zero & size;
    paint.shader = const LinearGradient(
      colors: [AppColors.secondary, AppColors.primary, AppColors.secondary],
      stops: [0.0, 0.5, 1.0],
    ).createShader(rect);

    for (int i = 0; i < totalBars; i++) {
      double amplitude = 0.15;

      if (isRecording) {
        if (amplitudes.isNotEmpty) {
          // Use real passed values if available
          final index = (i * amplitudes.length / totalBars).floor();
          if (index < amplitudes.length) {
            amplitude = amplitudes[index];
          }
        } else {
          // Fallback to sine-wave pattern modified by controller animation
          final waveValue = math.sin((i / totalBars) * 2 * math.pi + (animationValue * 2 * math.pi));
          final secondaryWaveValue = math.cos((i / totalBars) * 4 * math.pi - (animationValue * 3 * math.pi));
          amplitude = (waveValue.abs() * 0.5 + secondaryWaveValue.abs() * 0.3 + 0.1).clamp(0.1, 0.95);
        }
      } else {
        // Flat breathing wave
        amplitude = 0.08 + 0.05 * math.sin((i / totalBars) * math.pi);
      }

      final barHeight = size.height * amplitude;
      final x = i * spacing + (spacing / 2);

      canvas.drawLine(
        Offset(x, centerY - (barHeight / 2)),
        Offset(x, centerY + (barHeight / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.isRecording != isRecording ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.amplitudes != amplitudes;
  }
}
