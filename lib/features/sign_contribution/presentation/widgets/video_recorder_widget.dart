import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class VideoRecorderWidget extends StatefulWidget {
  final String? videoPath;
  final ValueChanged<String?> onVideoRecorded;

  const VideoRecorderWidget({
    super.key,
    required this.videoPath,
    required this.onVideoRecorded,
  });

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  VideoPlayerController? _videoController;
  bool _isPlayerInitialized = false;
  bool _isPlaying = false;
  bool _isRecordingAction = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _initVideoPlayer(widget.videoPath!);
    }
  }

  @override
  void didUpdateWidget(covariant VideoRecorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPath != oldWidget.videoPath) {
      if (widget.videoPath != null) {
        _initVideoPlayer(widget.videoPath!);
      } else {
        _disposeVideoPlayer();
      }
    }
  }

  Future<void> _initVideoPlayer(String path) async {
    await _disposeVideoPlayer();
    try {
      if (path.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(path));
      } else {
        _videoController = VideoPlayerController.file(File(path));
      }

      await _videoController!.initialize();
      _videoController!.setLooping(true);
      if (mounted) {
        setState(() {
          _isPlayerInitialized = true;
          _isPlaying = false;
        });
      }
    } catch (e) {
      print("Error initializing contribution video preview: $e");
    }
  }

  Future<void> _disposeVideoPlayer() async {
    if (_videoController != null) {
      await _videoController!.pause();
      await _videoController!.dispose();
      _videoController = null;
      if (mounted) {
        setState(() {
          _isPlayerInitialized = false;
          _isPlaying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    super.dispose();
  }

  // Attempts real video recording. If it fails or returns empty, falls back to simulated video asset copy
  Future<void> _recordVideo() async {
    if (mounted) setState(() => _isRecordingAction = true);
    HapticFeedback.mediumImpact();

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 15),
      );

      if (video != null) {
        widget.onVideoRecorded(video.path);
      } else {
        // Fallback or gallery option, but here we can prompt the user to use simulated video if camera is unavailable
        _showSimulatedVideoChoice();
      }
    } catch (e) {
      print("Camera recording failed, prompting simulated fallback: $e");
      _useSimulatedFallback();
    } finally {
      if (mounted) setState(() => _isRecordingAction = false);
    }
  }

  Future<void> _useSimulatedFallback() async {
    try {
      // Load standard test.mp4 asset and write to temp directory
      final byteData = await rootBundle.load('assets/animation/test.mp4');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/simulated_sign_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
      widget.onVideoRecorded(tempFile.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر تشغيل الكاميرا. تم استخدام فيديو محاكاة للتجربة.',
              style: TextStyle(fontFamily: 'Outfit'),
            ),
            backgroundColor: AppColors.stateYellow,
          ),
        );
      }
    } catch (err) {
      print("Error copying simulated asset: $err");
    }
  }

  void _showSimulatedVideoChoice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تنبيه الكاميرا',
          textAlign: TextAlign.right,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'لم يتم تسجيل فيديو. هل ترغب في استخدام فيديو محاكاة افتراضي لإتمام الاختبار؟',
          textAlign: TextAlign.right,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _useSimulatedFallback();
            },
            child: const Text('نعم، محاكاة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _togglePlay() {
    if (_videoController != null && _isPlayerInitialized) {
      setState(() {
        if (_isPlaying) {
          _videoController!.pause();
          _isPlaying = false;
        } else {
          _videoController!.play();
          _isPlaying = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoPath == null) {
      return _buildRecordPrompt();
    }

    return _buildVideoPreview();
  }

  Widget _buildRecordPrompt() {
    return GestureDetector(
      onTap: _isRecordingAction ? null : _recordVideo,
      child: GlassContainer(
        height: 200,
        borderRadius: 24,
        borderColor: AppColors.primary.withOpacity(0.4),
        backgroundColor: AppColors.surfaceCard.withOpacity(0.5),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRecordingAction)
                const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                )
              else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGlow,
                  ),
                  child: const Icon(
                    Icons.videocam_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تسجيل فيديو للإشارة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'اضغط لبدء الكاميرا وتسجيل الإشارة بحد أقصى ١٥ ثانية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isPlayerInitialized && _videoController != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),

            // Play/Pause Overlay GestureDetector
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlay,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: _isPlaying ? Colors.transparent : Colors.black26,
                  child: !_isPlaying
                      ? const Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 64,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // Delete & Re-record Button (Top Left)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_forever_rounded, color: AppColors.stateRed, size: 22),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _disposeVideoPlayer();
                    widget.onVideoRecorded(null);
                  },
                ),
              ),
            ),

            // Status Badge (Top Right)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.stateGreenGlow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.stateGreen.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.stateGreen, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'تم التسجيل',
                      style: TextStyle(
                        color: AppColors.stateGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
