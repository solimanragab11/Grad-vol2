import '../entities/contribution.dart';
import '../entities/existing_sign.dart';

abstract class ContributionRepository {
  /// Submits a contribution (uploads video to Firebase Storage, then saves metadata to Firestore).
  Future<void> submitContribution(Contribution contribution, String localVideoPath);

  /// Retrieves the list of existing signs from the library.
  Future<List<ExistingSign>> getExistingSigns();

  /// Retrieves the list of all contributions from Firestore.
  Future<List<Contribution>> getContributions();

  /// Moderates a contribution (approves or rejects).
  Future<void> moderateContribution(String id, ContributionStatus status);

  /// Retrieves all locally saved drafts.
  Future<List<Contribution>> getLocalDrafts();

  /// Saves a draft contribution locally.
  Future<void> saveDraft(Contribution contribution, String localVideoPath);

  /// Deletes a local draft contribution.
  Future<void> deleteDraft(String id);

  /// Attempts to sync all local drafts to the remote database.
  Future<void> syncDrafts();
}
