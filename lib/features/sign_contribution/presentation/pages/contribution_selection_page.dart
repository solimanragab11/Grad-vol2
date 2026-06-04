import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_cubit.dart';
import '../bloc/contribution_state.dart';
import '../widgets/draft_card.dart';
import 'contribution_form_page.dart';
import 'contribution_list_page.dart';

class ContributionSelectionPage extends StatelessWidget {
  const ContributionSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'مساهمة لغة الإشارة',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ContributionCubit, ContributionState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: const TextStyle(fontFamily: 'Outfit', color: Colors.white),
                  textAlign: TextAlign.right,
                ),
                backgroundColor: AppColors.stateRed,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Main content scrollable
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'اختر نوع المساهمة التي تود تقديمها لمجتمع الصم والبكم',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Option 1: New Sign
                    _buildOptionCard(
                      context: context,
                      title: 'إضافة إشارة جديدة',
                      description: 'قم بتسجيل وتوثيق إشارة جديدة غير مسجلة في التطبيق لمساعدتنا في توسيع القاموس.',
                      icon: Icons.add_circle_outline_rounded,
                      glowColor: AppColors.primary,
                      onTap: () {
                        context.read<ContributionCubit>().clearForm();
                        context.read<ContributionCubit>().updateType(ContributionType.newSign);
                        _navigateToForm(context);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Option 2: Correction
                    _buildOptionCard(
                      context: context,
                      title: 'تصحيح إشارة موجودة',
                      description: 'هل لاحظت إشارة مسجلة بشكل غير دقيق؟ شاركنا التصحيح بالفيديو مع توضيح السبب.',
                      icon: Icons.auto_fix_high_rounded,
                      glowColor: AppColors.secondary,
                      onTap: () {
                        context.read<ContributionCubit>().clearForm();
                        context.read<ContributionCubit>().updateType(ContributionType.correction);
                        _navigateToForm(context);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Option 3: History & Moderation
                    _buildOptionCard(
                      context: context,
                      title: 'سجل المساهمات والتحكيم',
                      description: 'استعرض مساهماتك السابقة، وتحقق من طلبات بقية الأعضاء للموافقة عليها وتدقيقها.',
                      icon: Icons.dashboard_customize_rounded,
                      glowColor: AppColors.stateGreen,
                      onTap: () {
                        final cubit = context.read<ContributionCubit>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => BlocProvider.value(
                              value: cubit..loadContributionsAndDrafts(),
                              child: const ContributionListPage(),
                            ),
                          ),
                        );
                      },
                    ),

                    // Local Offline Drafts section
                    if (state.localDrafts.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.stateYellowGlow,
                              foregroundColor: AppColors.stateYellow,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: AppColors.stateYellow),
                              ),
                            ),
                            onPressed: () => context.read<ContributionCubit>().syncDrafts(),
                            icon: const Icon(Icons.sync_rounded, size: 16),
                            label: const Text(
                              'مزامنة الكل',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '(${state.localDrafts.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.stateYellow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'مسودات معلقة (أوفلاين)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.localDrafts.length,
                        itemBuilder: (context, index) {
                          final draft = state.localDrafts[index];
                          return DraftCard(draft: draft);
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // Full Screen Loading Indicator
              if (state.isLoading)
                Container(
                  color: Colors.black38,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: GlassContainer(
          borderRadius: 24,
          borderColor: glowColor.withOpacity(0.3),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: glowColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: glowColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: glowColor,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context) {
    final cubit = context.read<ContributionCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: cubit,
          child: const ContributionFormPage(),
        ),
      ),
    );
  }
}
