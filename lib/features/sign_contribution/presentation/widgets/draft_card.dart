import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_cubit.dart';

class DraftCard extends StatelessWidget {
  final Contribution draft;

  const DraftCard({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final isNew = draft.type == ContributionType.newSign;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.stateYellow.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.stateYellowGlow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.stateYellow.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off_rounded, color: AppColors.stateYellow, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'مسودة محليّة',
                        style: TextStyle(
                          color: AppColors.stateYellow,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.stateBlueGlow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        draft.dialect,
                        style: const TextStyle(color: AppColors.stateBlue, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isNew ? AppColors.primaryGlow : AppColors.secondaryGlow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isNew ? 'إشارة جديدة' : 'تعديل',
                        style: TextStyle(
                          color: isNew ? AppColors.primary : AppColors.secondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Text Meaning
            Text(
              draft.meaning.isEmpty ? '(بدون عنوان)' : draft.meaning,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),

            if (!isNew) ...[
              const SizedBox(height: 4),
              Text(
                'لتعديل الإشارة: ${draft.targetSignName}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.right,
              ),
            ],

            const SizedBox(height: 12),

            // Action Buttons (Delete & Retry Upload)
            Row(
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.stateRed,
                    side: const BorderSide(color: AppColors.stateRed, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () => _confirmDelete(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => context.read<ContributionCubit>().retryDraftUpload(draft),
                    icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                    label: const Text(
                      'رفع الآن',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المسودة', textAlign: TextAlign.right),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف هذه المسودة نهائياً؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.stateRed),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ContributionCubit>().deleteDraft(draft.id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
