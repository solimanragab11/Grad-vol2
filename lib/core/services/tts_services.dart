import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    initTts();
  }

  Future<void> initTts() async {
    // 1. تحديد اللغة (طبعاً اللهجة المصرية الشيك)
    await _flutterTts.setLanguage("ar-EG");

    // 2. ضبط سرعة الكلام (0.5 هو المعدل الطبيعي والمريح)
    await _flutterTts.setSpeechRate(0.5);

    // 3. ضبط طبقة الصوت (Pitch)
    await _flutterTts.setPitch(1.0);

    // 🔥 السطر السحري: إجبار الـ Engine إنه يشتغل تماماً أوفلاين
    // لو اللغة مش متنزله على جهاز المستخدم، الـ Engine هينبهه ينزلها من إعدادات جوجل
    await _flutterTts.isLanguageAvailable("ar-EG");
  }

  // دالة النطق
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  // دالة إيقاف النطق لو المستخدم خرج من الشاشة فجأة
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
