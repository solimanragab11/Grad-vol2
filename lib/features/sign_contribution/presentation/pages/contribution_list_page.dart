import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_cubit.dart';
import '../bloc/contribution_state.dart';
import '../widgets/contribution_card.dart';

class ContributionListPage extends StatelessWidget {
  const ContributionListPage({super.key});

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
          'سجل المساهمات والتدقيق',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ContributionCubit, ContributionState>(
        builder: (context, state) {
          final contributions = state.filteredContributions;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segment Filter 1: Status (Pending, Approved, Rejected)
              _buildStatusFilterRow(context, state),
              const SizedBox(height: 8),

              // Segment Filter 2: Type (New signs, Corrections)
              _buildTypeFilterRow(context, state),
              const SizedBox(height: 12),

              // Submissions list
              Expanded(
                child: state.isLoading && contributions.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => context
                            .read<ContributionCubit>()
                            .loadContributionsAndDrafts(),
                        child: contributions.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                itemCount: contributions.length,
                                itemBuilder: (ctx, idx) {
                                  final item = contributions[idx];
                                  return ContributionCard(item: item);
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusFilterRow(BuildContext context, ContributionState state) {
    final cubit = context.read<ContributionCubit>();
    final filters = [
      {'label': 'الكل', 'value': null},
      {'label': 'قيد المراجعة', 'value': ContributionStatus.pending},
      {'label': 'مقبول', 'value': ContributionStatus.approved},
      {'label': 'مرفوض', 'value': ContributionStatus.rejected},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Arabic RTL-friendly scroll start
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: filters.map((f) {
          final isSelected = state.statusFilter == f['value'];
          final statusVal = f['value'] as ContributionStatus?;
          
          Color activeColor = AppColors.primary;
          if (statusVal == ContributionStatus.approved) activeColor = AppColors.stateGreen;
          if (statusVal == ContributionStatus.rejected) activeColor = AppColors.stateRed;
          if (statusVal == ContributionStatus.pending) activeColor = AppColors.stateYellow;

          return GestureDetector(
            onTap: () => cubit.updateFilters(statusVal, state.typeFilter),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? activeColor : Colors.transparent,
                ),
              ),
              child: Text(
                f['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeFilterRow(BuildContext context, ContributionState state) {
    final cubit = context.read<ContributionCubit>();
    final types = [
      {'label': 'جميع الأنواع', 'value': null},
      {'label': 'إشارات جديدة', 'value': ContributionType.newSign},
      {'label': 'تعديلات/تصحيحات', 'value': ContributionType.correction},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: types.map((t) {
          final isSelected = state.typeFilter == t['value'];
          final typeVal = t['value'] as ContributionType?;

          Color activeColor = AppColors.secondary;
          if (typeVal == ContributionType.newSign) activeColor = AppColors.primary;

          return GestureDetector(
            onTap: () => cubit.updateFilters(state.statusFilter, typeVal),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? activeColor : AppColors.glassBorder.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                t['label'] as String,
                style: TextStyle(
                  color: isSelected ? activeColor : AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: AppColors.textTertiary,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد مساهمات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لم يتم العثور على أي مساهمات تطابق خيارات التصفية المحددة حاليًا.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
