import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_cubit.dart';

class ContributionCard extends StatelessWidget {
  final Contribution item;

  const ContributionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isCorrection = item.type == ContributionType.correction;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: borderBorderSide(item.status),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Badges (Type & Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(item.status),
                Row(
                  children: [
                    _buildDialectBadge(item.dialect),
                    const SizedBox(width: 8),
                    _buildTypeBadge(item.type),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Text meaning
            Text(
              item.meaning,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),

            // Target sign info if correction
            if (isCorrection) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.targetSignName ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const Text(
                    ' :تصحيح للإشارة المعتمدة ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Icon(
                    Icons.history_toggle_off_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ],

            // Category tag
            if (item.category != null && item.category!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _translateCategory(item.category!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            // User notes (Correction notes)
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundEnd,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surface),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'ملاحظات المصحح:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Video Preview Action Trigger
            GestureDetector(
              onTap: () => _playVideo(context),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                  image: const DecorationImage(
                    image: AssetImage('assets/animation/test.mp4'), // Just as a structural container
                    fit: BoxFit.cover,
                    opacity: 0.1, // darken
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.video_library_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'تشغيل الفيديو',
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Moderation actions
            if (item.status == ContributionStatus.pending) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.stateRed,
                        side: const BorderSide(color: AppColors.stateRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => context
                          .read<ContributionCubit>()
                          .moderateContribution(item.id, ContributionStatus.rejected),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text(
                        'رفض',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.stateGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => context
                          .read<ContributionCubit>()
                          .moderateContribution(item.id, ContributionStatus.approved),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text(
                        'موافقة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Date / Creator Metadata
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(item.timestamp),
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
                Text(
                  'بواسطة: ${item.createdBy}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static BorderSide borderBorderSide(ContributionStatus status) {
    switch (status) {
      case ContributionStatus.approved:
        return const BorderSide(color: AppColors.stateGreen, width: 1.5);
      case ContributionStatus.rejected:
        return const BorderSide(color: AppColors.stateRed, width: 1.5);
      case ContributionStatus.pending:
        return BorderSide(color: AppColors.primary.withValues(alpha: 0.15), width: 1);
    }
  }

  Widget _buildStatusBadge(ContributionStatus status) {
    Color bg;
    Color fg;
    String txt;
    IconData icon;

    switch (status) {
      case ContributionStatus.approved:
        bg = AppColors.stateGreenGlow;
        fg = AppColors.stateGreen;
        txt = 'مقبول';
        icon = Icons.check_circle_rounded;
        break;
      case ContributionStatus.rejected:
        bg = AppColors.stateRedGlow;
        fg = AppColors.stateRed;
        txt = 'مرفوض';
        icon = Icons.cancel_rounded;
        break;
      case ContributionStatus.pending:
        bg = AppColors.stateYellowGlow;
        fg = AppColors.stateYellow;
        txt = 'قيد المراجعة';
        icon = Icons.hourglass_empty_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 12),
          const SizedBox(width: 4),
          Text(
            txt,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialectBadge(String dialect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.stateBlueGlow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stateBlue.withValues(alpha: 0.3)),
      ),
      child: Text(
        dialect,
        style: const TextStyle(
          color: AppColors.stateBlue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(ContributionType type) {
    final isNew = type == ContributionType.newSign;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isNew ? AppColors.primaryGlow : AppColors.secondaryGlow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isNew ? AppColors.primary : AppColors.secondary).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isNew ? 'إشارة جديدة' : 'تعديل',
        style: TextStyle(
          color: isNew ? AppColors.primary : AppColors.secondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _translateCategory(String cat) {
    switch (cat) {
      case 'greetings':
        return 'التحيات والترحيب';
      case 'medical':
        return 'الطب والخدمات الصحية';
      case 'food':
        return 'الطعام والشراب';
      case 'education':
        return 'التعليم والدراسة';
      case 'transport':
        return 'المواصلات والنقل';
      case 'emergency':
        return 'الحالات الطارئة';
      default:
        return 'عام';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month}/${dt.day} - ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Opens a fullscreen interactive popup player for video reviews
  void _playVideo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _VideoPlayerDialog(videoUrl: item.videoUrl),
    );
  }
}

class _VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerDialog({required this.videoUrl});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() async {
    try {
      if (widget.videoUrl.startsWith('http') || widget.videoUrl.isEmpty) {
        // Fallback to asset if url is empty
        final url = widget.videoUrl.isEmpty
            ? 'assets/animation/test.mp4'
            : widget.videoUrl;
        
        if (url.startsWith('assets/')) {
          _controller = VideoPlayerController.asset(url);
        } else {
          _controller = VideoPlayerController.networkUrl(Uri.parse(url));
        }
      } else {
        // Local file
        _controller = VideoPlayerController.file(File(widget.videoUrl));
      }

      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.play();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      print("Error loading dialog video: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'استعراض فيديو الإشارة',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                centerTitle: true,
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _initialized && _controller != null
                      ? AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        )
                      : const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                ),
              ),
              if (_initialized && _controller != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
