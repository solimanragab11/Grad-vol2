import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/entities/existing_sign.dart';
import '../../domain/repositories/contribution_repository.dart';
import 'contribution_state.dart';

class ContributionCubit extends Cubit<ContributionState> {
  final ContributionRepository _repository;

  ContributionCubit(this._repository) : super(const ContributionState());

  // Initialize and load all necessary data
  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await loadExistingSigns();
    await loadContributionsAndDrafts();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> loadExistingSigns() async {
    try {
      final signs = await _repository.getExistingSigns();
      emit(state.copyWith(existingSigns: signs));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to load existing library signs: $e"));
    }
  }

  Future<void> loadContributionsAndDrafts() async {
    try {
      final contributions = await _repository.getContributions();
      final drafts = await _repository.getLocalDrafts();
      emit(state.copyWith(
        contributions: contributions,
        localDrafts: drafts,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to load contributions: $e"));
    }
  }

  // Form manipulation methods
  void updateType(ContributionType type) {
    emit(state.copyWith(selectedType: type));
  }

  void updateDialect(String dialect) {
    emit(state.copyWith(selectedDialect: dialect));
  }

  void updateCategory(String? category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void updateMeaning(String meaning) {
    emit(state.copyWith(meaning: meaning));
  }

  void updateNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  void selectTargetSign(ExistingSign? sign) {
    emit(state.copyWith(
      targetSign: sign,
      meaning: sign?.meaning ?? state.meaning, // pre-populate meaning for corrections
      selectedCategory: sign?.category ?? state.selectedCategory,
    ));
  }

  void setLocalVideo(String? path) {
    emit(state.copyWith(localVideoPath: path));
  }

  void clearForm() {
    emit(state.clearForm());
  }

  // Submission pipeline
  Future<void> submitContribution() async {
    // Validation checks
    if (state.selectedType == null) {
      emit(state.copyWith(errorMessage: "الرجاء اختيار نوع المساهمة"));
      return;
    }
    if (state.localVideoPath == null) {
      emit(state.copyWith(errorMessage: "الرجاء تسجيل أو رفع فيديو للإشارة"));
      return;
    }

    final isNew = state.selectedType == ContributionType.newSign;

    if (isNew && state.meaning.trim().isEmpty) {
      emit(state.copyWith(errorMessage: "الرجاء إدخال معنى الكلمة/الإشارة"));
      return;
    }

    if (!isNew && state.targetSign == null) {
      emit(state.copyWith(errorMessage: "الرجاء تحديد الإشارة المراد تصحيحها"));
      return;
    }

    emit(state.copyWith(isLoading: true, isSuccess: false));

    final contributionId = 'contrib_${DateTime.now().millisecondsSinceEpoch}';
    final targetId = isNew ? null : state.targetSign!.id;
    final targetName = isNew ? null : state.targetSign!.meaning;

    final contribution = Contribution(
      id: contributionId,
      type: state.selectedType!,
      videoUrl: '', // Will be updated with storage download URL by repository
      meaning: state.meaning.trim(),
      dialect: state.selectedDialect,
      category: state.selectedCategory ?? 'other',
      targetSignId: targetId,
      targetSignName: targetName,
      status: ContributionStatus.pending,
      createdBy: 'deaf_user_1', // Simulated active user ID
      timestamp: DateTime.now(),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
    );

    try {
      await _repository.submitContribution(contribution, state.localVideoPath!);
      
      // Submit successful!
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
      ));
      
      // Reload lists
      await loadContributionsAndDrafts();
    } catch (e) {
      // Submission failed, but repository has saved it as a draft locally!
      print("Submit failed, draft saved: $e");
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "تعذر الاتصال بالشبكة. تم حفظ المساهمة كمسودة محلياً.",
        isSuccess: false,
      ));
      
      // Reload local drafts
      await loadContributionsAndDrafts();
    }
  }

  // Draft action handlers
  Future<void> deleteDraft(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.deleteDraft(id);
      await loadContributionsAndDrafts();
    } catch (e) {
      emit(state.copyWith(errorMessage: "تعذر حذف المسودة: $e"));
    }
    emit(state.copyWith(isLoading: false));
  }

  Future<void> syncDrafts() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.syncDrafts();
      await loadContributionsAndDrafts();
    } catch (e) {
      emit(state.copyWith(errorMessage: "تعذر مزامنة المسودات. تأكد من اتصالك بالإنترنت: $e"));
    }
    emit(state.copyWith(isLoading: false));
  }

  Future<void> retryDraftUpload(Contribution draft) async {
    emit(state.copyWith(isLoading: true));
    try {
      final cleanContribution = Contribution(
        id: draft.id,
        type: draft.type,
        videoUrl: '',
        meaning: draft.meaning,
        dialect: draft.dialect,
        category: draft.category,
        targetSignId: draft.targetSignId,
        targetSignName: draft.targetSignName,
        status: draft.status,
        createdBy: draft.createdBy,
        timestamp: draft.timestamp,
        notes: draft.notes,
      );
      await _repository.submitContribution(cleanContribution, draft.videoUrl);
      await _repository.deleteDraft(draft.id);
      await loadContributionsAndDrafts();
    } catch (e) {
      emit(state.copyWith(errorMessage: "فشلت إعادة محاولة الرفع. تأكد من اتصالك بالشبكة: $e"));
    }
    emit(state.copyWith(isLoading: false));
  }

  // Moderation action handler
  Future<void> moderateContribution(String id, ContributionStatus status) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.moderateContribution(id, status);
      await loadContributionsAndDrafts();
    } catch (e) {
      emit(state.copyWith(errorMessage: "تعذر تحديث حالة المساهمة: $e"));
    }
    emit(state.copyWith(isLoading: false));
  }

  // Filter updates
  void updateFilters(ContributionStatus? status, ContributionType? type) {
    emit(state.copyWith(
      statusFilter: status,
      typeFilter: type,
    ));
  }
}
