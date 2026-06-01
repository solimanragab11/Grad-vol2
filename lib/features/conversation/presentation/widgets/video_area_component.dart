import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/core/widgets/glass_container.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';

class VideoAreaComponent extends StatefulWidget {
  const VideoAreaComponent({super.key});

  @override
  State<VideoAreaComponent> createState() => _VideoAreaComponentState();
}

class _VideoAreaComponentState extends State<VideoAreaComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;

  // 🔒 المفتاح السحري: عشان نضمن إنه يشتغل أول مرة بس وما يكررش مع الـ Rebuilds
  bool _hasPlayedOnce = false;

  // ==========================================
  // 📍 مسار الفيديو الخاص بك يا عمي السولي
  // ==========================================
  final String videoPath = "assets/animation/test.mp4";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _initializeVideo();
  }

  // دالة تهيئة مشغل الفيديو
  Future<void> _initializeVideo() async {
    // لو الفيديو اشتغل مرة قبل كده، اخرج فوراً وماتعملش حاجة تانية
    if (_hasPlayedOnce) return;

    try {
      _videoPlayerController = VideoPlayerController.asset(videoPath);
      await _videoPlayerController!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }

      // نضمن إن الفيديو مش هيعيد لوحده تلقائياً لما يخلص
      await _videoPlayerController!.setLooping(false);
      await _videoPlayerController!.play();

      // نرفع الراية إن الفيديو اشتغل خلاص وممنوع يشتغل تلقائي تاني
      _hasPlayedOnce = true;
      print("🎯 Video played successfully once ya omy!");
    } catch (error) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
      print("❌ Error initializing video player: $error");
    }
  }

  // ✨ دالة إعادة التشغيل الإجبارية عند الضغط المطول
  Future<void> _replayVideo() async {
    if (_videoPlayerController != null && _isVideoInitialized) {
      await _videoPlayerController!.seekTo(Duration.zero); // ارجع للبداية
      await _videoPlayerController!.play(); // اشتغل تاني
      print("🔄 Video replayed via long press ya omy!");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("=== [CURRENT VIDEO PATH]: $videoPath ===");

    return BlocBuilder<ConversationCubit, ConversationState>(
      builder: (context, state) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: GlassContainer(
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.darkGlassBackground,
            borderColor: AppColors.darkGlassBorder,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              child: SizedBox(
                height: state.videoMode == VideoMode.idle ? 180 : 300,
                width: double.infinity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildContent(state),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(ConversationState state) {
    return _buildPlaybackView();
  }

  Widget _buildPlaybackView() {
    return Container(
      key: const ValueKey('playback'),
      width: double.infinity,
      color: AppColors.backgroundStart,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. شبكة خلفية خفيفة جداً للعمق التقني
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          // 2. حاوية الفيديو (مغلفة بـ GestureDetector للـ Long Press)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onDoubleTap:
                  _replayVideo, // 🔥 السحر هنا يا عمي: اضغط ضغطة طويلة يعيد فوراً
              behavior: HitTestBehavior
                  .opaque, // عشان يلقط الضغطة في أي مكان على الكارت
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _isVideoInitialized && _videoPlayerController != null
                      ? Center(
                          child: AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          ),
                        )
                      : const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),

          // 3. شريط الحالة العلوي للفيديو
          Positioned(
            top: 24,
            left: 28,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.stateGreen,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.stateGreen.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'SIGN VIDEO PLAYBACK • ACTIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// الـ Painters المساعدة
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += step) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
