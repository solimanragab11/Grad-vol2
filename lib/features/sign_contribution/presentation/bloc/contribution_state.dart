import 'package:equatable/equatable.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/entities/existing_sign.dart';

class ContributionState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  // Data lists
  final List<ExistingSign> existingSigns;
  final List<Contribution> contributions;
  final List<Contribution> localDrafts;

  // Form selections
  final ContributionType? selectedType;
  final String selectedDialect;
  final String? selectedCategory;
  final String meaning;
  final String notes;
  final ExistingSign? targetSign;
  final String? localVideoPath;

  // Filter selections
  final ContributionStatus? statusFilter;
  final ContributionType? typeFilter;

  const ContributionState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.existingSigns = const [],
    this.contributions = const [],
    this.localDrafts = const [],
    this.selectedType,
    this.selectedDialect = 'مصري',
    this.selectedCategory,
    this.meaning = '',
    this.notes = '',
    this.targetSign,
    this.localVideoPath,
    this.statusFilter,
    this.typeFilter,
  });

  // Filtered lists helper
  List<Contribution> get filteredContributions {
    return contributions.where((item) {
      if (statusFilter != null && item.status != statusFilter) return false;
      if (typeFilter != null && item.type != typeFilter) return false;
      return true;
    }).toList();
  }

  ContributionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    List<ExistingSign>? existingSigns,
    List<Contribution>? contributions,
    List<Contribution>? localDrafts,
    ContributionType? selectedType,
    String? selectedDialect,
    String? selectedCategory,
    String? meaning,
    String? notes,
    ExistingSign? targetSign,
    String? localVideoPath,
    ContributionStatus? statusFilter,
    ContributionType? typeFilter,
  }) {
    return ContributionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Reset if not specified
      isSuccess: isSuccess ?? this.isSuccess,
      existingSigns: existingSigns ?? this.existingSigns,
      contributions: contributions ?? this.contributions,
      localDrafts: localDrafts ?? this.localDrafts,
      selectedType: selectedType ?? this.selectedType,
      selectedDialect: selectedDialect ?? this.selectedDialect,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      meaning: meaning ?? this.meaning,
      notes: notes ?? this.notes,
      targetSign: targetSign ?? this.targetSign,
      localVideoPath: localVideoPath ?? this.localVideoPath,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }

  // Clear form helper
  ContributionState clearForm() {
    return ContributionState(
      existingSigns: existingSigns,
      contributions: contributions,
      localDrafts: localDrafts,
      statusFilter: statusFilter,
      typeFilter: typeFilter,
      selectedDialect: 'مصري',
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        isSuccess,
        existingSigns,
        contributions,
        localDrafts,
        selectedType,
        selectedDialect,
        selectedCategory,
        meaning,
        notes,
        targetSign,
        localVideoPath,
        statusFilter,
        typeFilter,
      ];
}
