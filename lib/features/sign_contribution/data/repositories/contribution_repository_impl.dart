import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/contribution.dart';
import '../../domain/entities/existing_sign.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../models/contribution_model.dart';
import '../models/existing_sign_model.dart';

class ContributionRepositoryImpl implements ContributionRepository {
  final Connectivity _connectivity = Connectivity();
  bool _useSimulationMode = false;

  ContributionRepositoryImpl() {
    _checkFirebaseInitialization();
  }

  // Safe check if Firebase is initialized. If not, we attempt it.
  // If it throws, we fall back to a fully working Simulation Mode.
  Future<void> _checkFirebaseInitialization() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      print("🎯 Firebase initialized successfully for contributions.");
    } catch (e) {
      print("⚠️ Firebase not configured or initialization failed: $e");
      print("🤖 Contribution repository is running in SIMULATION/OFFLINE-DRAFT mode.");
      _useSimulationMode = true;
    }
  }

  // Network helper
  Future<bool> _isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) {
        return false;
      }
      return results.isNotEmpty;
    } catch (e) {
      return false; // Fallback to offline on exception
    }
  }

  // Files helpers for offline drafts
  Future<File> _getDraftsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, 'contribution_drafts.json'));
  }

  Future<File> _getSimulationRemoteFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, 'simulated_remote_contributions.json'));
  }

  @override
  Future<void> submitContribution(Contribution contribution, String localVideoPath) async {
    final isOnline = await _isOnline();
    if (!isOnline) {
      // Save as draft locally
      await saveDraft(contribution, localVideoPath);
      throw SocketException("No internet connection. Saved as draft locally.");
    }

    try {
      await _checkFirebaseInitialization();
      if (_useSimulationMode) {
        await _submitSimulatedContribution(contribution, localVideoPath);
        return;
      }

      // 1. Upload video to Firebase Storage
      final File videoFile = File(localVideoPath);
      if (!await videoFile.exists()) {
        throw FileNotFoundException("Video file not found at path: $localVideoPath");
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('contributions/videos/${contribution.id}.mp4');
      
      final uploadTask = await storageRef.putFile(
        videoFile,
        SettableMetadata(contentType: 'video/mp4'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 2. Save metadata to Cloud Firestore
      final contributionModel = ContributionModel.fromEntity(contribution).copyWith(
        videoUrl: downloadUrl,
      );

      await FirebaseFirestore.instance
          .collection('contributions')
          .doc(contributionModel.id)
          .set(contributionModel.toFirestore());
      
      print("🚀 Contribution submitted to remote Firebase successfully.");
    } catch (e) {
      // On failure, save as draft locally
      await saveDraft(contribution, localVideoPath);
      throw Exception("Failed to upload contribution: $e. Saved draft locally.");
    }
  }

  // Simulation fallback submission (saves to simulated remote JSON)
  Future<void> _submitSimulatedContribution(Contribution contribution, String localVideoPath) async {
    // Copy video file to a persistent mock storage folder
    final directory = await getApplicationDocumentsDirectory();
    final mockStorageDir = Directory(p.join(directory.path, 'simulated_storage'));
    if (!await mockStorageDir.exists()) {
      await mockStorageDir.create(recursive: true);
    }

    final String destPath = p.join(mockStorageDir.path, '${contribution.id}.mp4');
    final File srcFile = File(localVideoPath);
    if (await srcFile.exists()) {
      await srcFile.copy(destPath);
    }

    // Save metadata to simulated_remote_contributions.json
    final file = await _getSimulationRemoteFile();
    List<dynamic> remoteList = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        remoteList = jsonDecode(content);
      }
    }

    final contributionModel = ContributionModel.fromEntity(contribution).copyWith(
      videoUrl: destPath, // local file path acts as the URL in mock mode
    );

    // Remove if already exists, then add
    remoteList.removeWhere((item) => item['id'] == contribution.id);
    remoteList.add(contributionModel.toJson());

    await file.writeAsString(jsonEncode(remoteList));
    print("🤖 Simulated remote upload complete (local simulated file updated).");
  }

  @override
  Future<List<ExistingSign>> getExistingSigns() async {
    // Rich default signs list for local offline / mock fallback
    final List<ExistingSign> defaultSigns = [
      const ExistingSign(id: 's1', meaning: 'السلام عليكم', category: 'greetings', videoUrl: 'assets/animation/test.mp4'),
      const ExistingSign(id: 's2', meaning: 'طبيب', category: 'medical', videoUrl: 'assets/animation/test.mp4'),
      const ExistingSign(id: 's3', meaning: 'طعام', category: 'food', videoUrl: 'assets/animation/test.mp4'),
      const ExistingSign(id: 's4', meaning: 'مدرسة', category: 'education', videoUrl: 'assets/animation/test.mp4'),
      const ExistingSign(id: 's5', meaning: 'سيارة', category: 'transport', videoUrl: 'assets/animation/test.mp4'),
      const ExistingSign(id: 's6', meaning: 'حالة طوارئ', category: 'emergency', videoUrl: 'assets/animation/test.mp4'),
      const ExistingSign(id: 's7', meaning: 'شكراً', category: 'greetings', videoUrl: 'assets/animation/test.mp4'),
      const ExistingSign(id: 's8', meaning: 'مستشفى', category: 'medical', videoUrl: 'assets/animation/test.mp4'),
      const ExistingSign(id: 's9', meaning: 'ماء', category: 'food', videoUrl: 'assets/animation/test.mp4'),
    ];

    if (_useSimulationMode) {
      return defaultSigns;
    }

    try {
      final snapshot = await FirebaseFirestore.instance.collection('signs').get();
      if (snapshot.docs.isEmpty) {
        return defaultSigns;
      }
      return snapshot.docs.map((doc) => ExistingSignModel.fromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      print("Error fetching signs from firestore, returning defaults: $e");
      return defaultSigns;
    }
  }

  @override
  Future<List<Contribution>> getContributions() async {
    if (_useSimulationMode) {
      final file = await _getSimulationRemoteFile();
      if (!await file.exists()) return [];
      
      final content = await file.readAsString();
      if (content.isEmpty) return [];

      final List<dynamic> list = jsonDecode(content);
      return list.map((item) => ContributionModel.fromJson(item)).toList();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('contributions')
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ContributionModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print("Firebase fetch contributions failed, falling back to simulated file: $e");
      // Fallback to simulated database if firebase error
      final file = await _getSimulationRemoteFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> list = jsonDecode(content);
          return list.map((item) => ContributionModel.fromJson(item)).toList();
        }
      }
      return [];
    }
  }

  @override
  Future<void> moderateContribution(String id, ContributionStatus status) async {
    final statusStr = status == ContributionStatus.approved
        ? 'approved'
        : status == ContributionStatus.rejected
            ? 'rejected'
            : 'pending';

    if (_useSimulationMode) {
      final file = await _getSimulationRemoteFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> list = jsonDecode(content);
        for (var item in list) {
          if (item['id'] == id) {
            item['status'] = statusStr;
            break;
          }
        }
        await file.writeAsString(jsonEncode(list));
      }
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('contributions')
          .doc(id)
          .update({'status': statusStr});
    } catch (e) {
      print("Firebase moderate failed, trying simulation local file: $e");
      final file = await _getSimulationRemoteFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> list = jsonDecode(content);
        for (var item in list) {
          if (item['id'] == id) {
            item['status'] = statusStr;
            break;
          }
        }
        await file.writeAsString(jsonEncode(list));
      } else {
        throw Exception("Failed to update status remotely: $e");
      }
    }
  }

  @override
  Future<List<Contribution>> getLocalDrafts() async {
    final file = await _getDraftsFile();
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    if (content.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((item) => ContributionModel.fromJson(item)).toList();
    } catch (e) {
      print("Error decoding local drafts JSON: $e");
      return [];
    }
  }

  @override
  Future<void> saveDraft(Contribution contribution, String localVideoPath) async {
    final file = await _getDraftsFile();
    List<dynamic> draftList = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        draftList = jsonDecode(content);
      }
    }

    // Copy draft video to drafts storage folder so it doesn't get cleaned up by OS temp folders
    final directory = await getApplicationDocumentsDirectory();
    final draftsStorageDir = Directory(p.join(directory.path, 'drafts_storage'));
    if (!await draftsStorageDir.exists()) {
      await draftsStorageDir.create(recursive: true);
    }

    final String destPath = p.join(draftsStorageDir.path, '${contribution.id}.mp4');
    final File srcFile = File(localVideoPath);
    if (await srcFile.exists() && localVideoPath != destPath) {
      await srcFile.copy(destPath);
    }

    // Save details
    final model = ContributionModel.fromEntity(contribution).copyWith(
      videoUrl: destPath, // Local persistent path stored as URL
    );

    // Update if exists, else add
    draftList.removeWhere((item) => item['id'] == contribution.id);
    draftList.add(model.toJson());

    await file.writeAsString(jsonEncode(draftList));
    print("💾 Saved draft locally at: $destPath");
  }

  @override
  Future<void> deleteDraft(String id) async {
    final file = await _getDraftsFile();
    if (!await file.exists()) return;

    final content = await file.readAsString();
    if (content.isEmpty) return;

    final List<dynamic> list = jsonDecode(content);
    
    // Find video file and delete it if exists
    final draftJson = list.firstWhere((item) => item['id'] == id, orElse: () => null);
    if (draftJson != null && draftJson['videoUrl'] != null) {
      final videoFile = File(draftJson['videoUrl']);
      if (await videoFile.exists()) {
        await videoFile.delete();
      }
    }

    list.removeWhere((item) => item['id'] == id);
    await file.writeAsString(jsonEncode(list));
    print("🗑️ Deleted draft: $id");
  }

  @override
  Future<void> syncDrafts() async {
    final isOnline = await _isOnline();
    if (!isOnline) {
      throw SocketException("Cannot sync drafts. Device is offline.");
    }

    final drafts = await getLocalDrafts();
    if (drafts.isEmpty) return;

    print("Syncing ${drafts.length} drafts...");
    for (final draft in drafts) {
      try {
        final localPath = draft.videoUrl; // In draft state, videoUrl contains the local file path
        
        // Build remote contribution with empty video URL (will be populated on submission success)
        final Contribution cleanContribution = Contribution(
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

        // Upload and submit remotely
        await submitContribution(cleanContribution, localPath);

        // Success: remove draft locally
        await deleteDraft(draft.id);
      } catch (e) {
        print("Failed to sync draft ${draft.id}: $e. Keeping draft.");
        // Continue with other drafts
      }
    }
  }
}

class FileNotFoundException implements Exception {
  final String message;
  FileNotFoundException(this.message);
  @override
  String toString() => "FileNotFoundException: $message";
}
