import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_cubit.dart';
import '../bloc/contribution_state.dart';
import '../widgets/video_recorder_widget.dart';

class ContributionFormPage extends StatefulWidget {
  const ContributionFormPage({super.key});

  @override
  State<ContributionFormPage> createState() => _ContributionFormPageState();
}

class _ContributionFormPageState extends State<ContributionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  final List<String> _dialects = ['مصري', 'خليجي', 'عربي فصيح', 'Other'];
  
  final List<Map<String, String>> _categories = [
    {'key': 'greetings', 'label': 'ترحيب'},
    {'key': 'medical', 'label': 'صحة/طب'},
    {'key': 'food', 'label': 'طعام'},
    {'key': 'education', 'label': 'تعليم'},
    {'key': 'transport', 'label': 'مواصلات'},
    {'key': 'emergency', 'label': 'طوارئ'},
  ];

  @override
  void dispose() {
    _meaningController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributionCubit, ContributionState>(
      listener: (context, state) {
        if (state.isSuccess) {
          _showFeedbackDialog(
            context: context,
            title: 'تم الإرسال بنجاح',
            message: 'شكرًا لمساهمتك القيمة! سيتم مراجعة طلبك وتدقيقه من قبل المشرفين قبل اعتماده في المكتبة.',
            isSuccess: true,
          );
        } else if (state.errorMessage != null) {
          if (state.errorMessage!.contains('مسودة')) {
            // Offline saved draft notification
            _showFeedbackDialog(
              context: context,
              title: 'حفظ كمسودة محليّة',
              message: 'تعذر الاتصال بالشبكة لرفع الفيديو حاليًا. تم حفظ مساهمتك كمسودة أوفلاين، ويمكنك رفعها لاحقًا عند معاودة الاتصال.',
              isSuccess: false,
              isDraft: true,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!, textAlign: TextAlign.right),
                backgroundColor: AppColors.stateRed,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final isNew = state.selectedType == ContributionType.newSign;

        return Scaffold(
          backgroundColor: AppColors.backgroundStart,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isNew ? 'إضافة إشارة جديدة' : 'تصحيح إشارة معتمدة',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mode Description Header
                      _buildHeaderInfo(isNew),
                      const SizedBox(height: 24),

                      // Section 1: Video recording
                      _buildSectionTitle('فيديو الإشارة المصورة'),
                      const SizedBox(height: 8),
                      VideoRecorderWidget(
                        videoPath: state.localVideoPath,
                        onVideoRecorded: (path) =>
                            context.read<ContributionCubit>().setLocalVideo(path),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Correction sign search OR new sign text field
                      if (!isNew) ...[
                        _buildSectionTitle('اختر الإشارة المراد تصحيحها'),
                        const SizedBox(height: 8),
                        _buildTargetSignSelector(state),
                      ] else ...[
                        _buildSectionTitle('معنى الكلمة أو الإشارة باللغة العربية'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _meaningController,
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'مثال: السلام عليكم، طبيب، ماء...',
                          ),
                          onChanged: (val) =>
                              context.read<ContributionCubit>().updateMeaning(val),
                          validator: (val) {
                            if (isNew && (val == null || val.trim().isEmpty)) {
                              return 'الرجاء كتابة معنى الإشارة';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Section 3: Dialect/Accent Dropdown
                      _buildSectionTitle('اللهجة أو اللكنة الإشارية'),
                      const SizedBox(height: 8),
                      _buildDialectDropdown(state),
                      const SizedBox(height: 24),

                      // Section 4: Category Selection Chips (Optional for new sign)
                      if (isNew) ...[
                        _buildSectionTitle('تصنيف الكلمة (اختياري)'),
                        const SizedBox(height: 8),
                        _buildCategoryChips(state),
                        const SizedBox(height: 24),
                      ],

                      // Section 5: Correction Notes (For correction mode only)
                      if (!isNew) ...[
                        _buildSectionTitle('سبب التعديل أو الملاحظات (اختياري)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'اشرح ما هو الخطأ في الإشارة القديمة وكيف تصحح...',
                          ),
                          onChanged: (val) =>
                              context.read<ContributionCubit>().updateNotes(val),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Submit button
                      const SizedBox(height: 16),
                      _buildSubmitButton(context, state),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Full Screen loading overlay
              if (state.isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderInfo(bool isNew) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNew ? AppColors.primaryGlow : AppColors.secondaryGlow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isNew ? AppColors.primary : AppColors.secondary).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isNew
                  ? 'نموذج تقديم إشارة جديدة غير متوفرة في القاموس. يرجى توثيق إشارتك بفيديو واضح ومحدد.'
                  : 'نموذج تصحيح إشارة معتمدة مسبقاً. يرجى اختيار الإشارة المراد تصحيحها من محرك البحث أدناه.',
              style: TextStyle(
                fontSize: 12,
                color: isNew ? AppColors.primary : AppColors.secondary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            isNew ? Icons.info_outline_rounded : Icons.construction_rounded,
            color: isNew ? AppColors.primary : AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildDialectDropdown(ContributionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkGlassBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.darkGlassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedDialect,
          isExpanded: true,
          dropdownColor: Colors.white,
          alignment: Alignment.centerRight,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
          onChanged: (String? newVal) {
            if (newVal != null) {
              context.read<ContributionCubit>().updateDialect(newVal);
            }
          },
          items: _dialects.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ContributionState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: _categories.map((cat) {
        final isSelected = state.selectedCategory == cat['key'];
        return GestureDetector(
          onTap: () {
            context.read<ContributionCubit>().updateCategory(
                  isSelected ? null : cat['key'],
                );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              cat['label']!,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTargetSignSelector(ContributionState state) {
    // If target sign is already selected, show a clearable bubble
    if (state.targetSign != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryGlow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: AppColors.stateRed),
              onPressed: () {
                context.read<ContributionCubit>().selectTargetSign(null);
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  state.targetSign!.meaning,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'التصنيف: ${state.targetSign!.category}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Otherwise, show searchable list
    final filteredSigns = state.existingSigns.where((sign) {
      return sign.meaning.contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _searchController,
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'ابحث عن الإشارة المعتمدة...',
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        if (_searchQuery.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.2)),
            ),
            child: filteredSigns.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'لا توجد نتائج مطابقة لبحثك',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredSigns.length,
                    itemBuilder: (ctx, idx) {
                      final sign = filteredSigns[idx];
                      return ListTile(
                        title: Text(
                          sign.meaning,
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          sign.category,
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                        ),
                        onTap: () {
                          context.read<ContributionCubit>().selectTargetSign(sign);
                          HapticFeedback.lightImpact();
                        },
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ContributionState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<ContributionCubit>().submitContribution();
          }
        },
        child: const Text(
          'إرسال المساهمة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog({
    required BuildContext context,
    required String title,
    required String message,
    required bool isSuccess,
    bool isDraft = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSuccess
                    ? AppColors.stateGreen
                    : isDraft
                        ? AppColors.stateYellow
                        : AppColors.stateRed,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(width: 8),
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : isDraft
                      ? Icons.wifi_off_rounded
                      : Icons.error_rounded,
              color: isSuccess
                  ? AppColors.stateGreen
                  : isDraft
                      ? AppColors.stateYellow
                      : AppColors.stateRed,
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess
                  ? AppColors.stateGreen
                  : isDraft
                      ? AppColors.stateYellow
                      : AppColors.stateRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close form page and return
              context.read<ContributionCubit>().clearForm();
              context.read<ContributionCubit>().loadContributionsAndDrafts();
            },
            child: const Text('موافق', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
