import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://tts-stt-grad.shares.zrok.io";
  Future<String?> convertTextToSpeechApi(String text) async {
    try {
      // بنبعت النص في الـ Body كـ Map بسيطة
      final response = await _dio.post(
        'https://tts-stt-grad.shares.zrok.io/tts',
        data: {'text': text},
      );

      if (response.statusCode == 200 && response.data['status'] == 'ok') {
        // السيرفر هيرجعلك رابط الـ mp3 اللي ولده بالذكاء الاصطناعي
        return response.data['audio_url'] as String;
      }
      return null;
    } catch (e) {
      print("Error in Online TTS API: $e");
      return null;
    }
  }

  // 1. طلب الـ TTS وحفظ الملف
  Future<String?> downloadAudio(String outputPath) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tts/sample',
        options: Options(
          headers: {"X-API-Key": "Kx7vN2mP9qR4sT8wY1zB5cD6eF0gH3jL"},
          responseType: ResponseType.bytes, // عشان نستقبل ملف صوت
        ),
      );

      File file = File(outputPath);
      await file.writeAsBytes(response.data);
      return outputPath;
    } catch (e) {
      print("Error in TTS: $e");
      return null;
    }
  }

  // 2. طلب الـ STT ورفع الملف
  Future<Map<String, dynamic>?> uploadAudioForSTT(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: "my_recording.wav",
        ),
      });

      final response = await _dio.post(
        '$_baseUrl/stt',
        data: formData,
        options: Options(
          headers: {"X-API-Key": "aB2cD4eF6gH8jK0mN2pQ4rS6tU8vW0xY"},
        ),
      );

      return response.data; // النتيجة اللي هترجع من السيرفر
    } catch (e) {
      print("Error in STT: $e");
      return null;
    }
  }
}
