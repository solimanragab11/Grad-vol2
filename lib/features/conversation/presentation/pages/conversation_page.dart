import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/widgets/deaf_user_console.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/widgets/frictionless_metrics_dialog.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/widgets/hearing_user_console.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/widgets/laser_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deaf_hearing_app/core/widgets/animated_pulse_indicator.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/widgets/input_bar_component.dart';
import 'package:deaf_hearing_app/features/sign_contribution/presentation/pages/contribution_selection_page.dart';
import 'package:deaf_hearing_app/features/sign_contribution/presentation/bloc/contribution_cubit.dart';
import 'package:deaf_hearing_app/features/sign_contribution/data/repositories/contribution_repository_impl.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ConversationCubit, ConversationState>(
            builder: (context, state) {
              final cubit = context.read<ConversationCubit>();
              return GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! > 50) {
                    cubit.swipe();
                  }
                },
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // --- THE DUAL split-console workspace ---
                        Expanded(
                          child: Column(
                            children: [
                              // 1. DEAF USER'S INTERACTION ZONE
                              Expanded(
                                flex: 5,
                                child: RotatedBox(
                                  quarterTurns: state.swipNum,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: DeafUserConsole(state: state),
                                  ),
                                ),
                              ),

                              // 2. GLOWING NEON LASER BEAM
                              LaserDivider(
                                state: state,
                                isTyping: state.isTyping,
                              ),

                              // 3. HEARING USER'S INTERACTION ZONE
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: GestureDetector(
                                    onDoubleTap: () {
                                      cubit.speakText(
                                        "بنجرب لو دي احسن طريقة للموضوع ده",
                                      );
                                    },

                                    child: HearingUserConsole(state: state),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 76),
                      ],
                    ),

                    // Floating Smart Input Bar Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: InputBarComponent(),
                    ),

                    // Floating AI Translation Pulse status
                    Positioned(
                      bottom: 86,
                      right: 20,
                      child: AnimatedPulseIndicator(
                        status: state.translationStatus,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showFrictionlessMetrics(context, state);
                        },
                      ),
                    ),

                    // Floating button to open Sign Contribution System
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 24,
                          child: IconButton(
                            icon: const Icon(
                              Icons.volunteer_activism_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => ContributionCubit(
                                      ContributionRepositoryImpl(),
                                    )..init(),
                                    child: const ContributionSelectionPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
