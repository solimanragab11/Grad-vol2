import 'package:flutter_sound/flutter_sound.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool isRecording = false; // 🔥 علم الحماية

  // ... كود الـ init بتاعك ...

  Future<void> startRecording() async {
    // لو بيسجل حالياً.. اخرج فوراً ومتعملش حاجة ثانية
    if (isRecording) return;

    try {
      if (!_isRecorderInitialized) {
        await _recorder.openRecorder();
        _isRecorderInitialized = true;
      }

      isRecording = true; // رفع العلم
      await _recorder.startRecorder(
        toFile: 'audio_record.wav', // أو المسار الافتراضي بتاعك
        codec: Codec.pcm16WAV,
      );
      print("🎯 Recorder started safely once!");
    } catch (e) {
      isRecording = false;
      print("Error starting recorder: $e");
    }
  }

  Future<String?> stopRecording() async {
    // لو مش بيسجل أصلاً وجيت تقفله.. اخرج
    if (!isRecording) return null;

    try {
      final path = await _recorder.stopRecorder();
      isRecording = false; // نزل العلم
      print("🛑 Recorder stopped safely. File: $path");
      return path;
    } catch (e) {
      isRecording = false;
      print("Error stopping recorder: $e");
      return null;
    }
  }
}
