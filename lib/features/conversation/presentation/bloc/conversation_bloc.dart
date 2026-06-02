import 'package:deaf_hearing_app/core/services/api_services.dart';
import 'package:deaf_hearing_app/core/services/audio_services.dart';
import 'package:deaf_hearing_app/core/services/network_info.dart';
import 'package:deaf_hearing_app/core/services/tts_services.dart';
import 'package:deaf_hearing_app/core/widgets/animated_pulse_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deaf_hearing_app/features/conversation/domain/entities/message.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final AudioService _audioService;
  final ApiService _apiService;
  final NetworkInfo _networkInfo = NetworkInfo();
  final TtsService _ttsService;
  int swipnum = 2;
  int _messageCounter = 10;

  ConversationCubit(this._audioService, this._apiService, this._ttsService)
    : super(const ConversationState());

  // بدء التسجيل الحقيقي
  Future<void> startRecording() async {
    await _audioService.startRecording();
    emit(
      state.copyWith(
        isRecording: true,
        translationStatus: TranslationStatus.processing,
      ),
    );
  }

  // إيقاف التسجيل ورفع الملف
  Future<void> stopRecording() async {
    final path = await _audioService.stopRecording();
    emit(state.copyWith(isRecording: false));
    print("stopped");
    if (path != null) {
      emit(
        state.copyWith(
          isTyping: true,
          translationStatus: TranslationStatus.processing,
        ),
      );

      try {
        // نرفع الملف الحقيقي للـ API
        final Map<String, dynamic>? transcription = await _apiService
            .uploadAudioForSTT(path);

        if (transcription != null) {
          _messageCounter++;
          final newMessage = Message(
            id: 'voice_$_messageCounter',
            content: transcription,
            sender: MessageSender.user,
            type: MessageType.voice,
            timestamp: DateTime.now(),
            translation: TranslationResult(
              text: transcription['text'],
              confidence: 0.95,
            ),
          );
          print(newMessage.content);
          emit(
            state.copyWith(
              messages: [newMessage, ...state.messages],
              isTyping: false,
              translationStatus: TranslationStatus.ready,
              currentTranslation: TranslationResult(
                text: transcription['text'],
                confidence: 0.95,
              ),
            ),
          );
        }
      } catch (e) {
        emit(
          state.copyWith(
            isTyping: false,
            translationStatus: TranslationStatus.idle,
          ),
        );
      }
    }
  }

  // دالة لنطق أي نص موجود عندك في الشاشة يدوياً (لما يضغط على زرار السماعة)
  void speakText(String text) async {
    if (text.isEmpty) return;
    print("======================");
    print(text);
    bool isDeviceOnline = false;
    // 1. فحص حالة الشبكة بأمان
    try {
      isDeviceOnline = await _networkInfo.isConnected;
    } catch (e) {
      print("Connectivity interface error, defaulting to offline library: $e");
      isDeviceOnline =
          false; // لو المكتبة ضربت لأي سبب اعتبره offline عشان الأبلكيشن ما يقفش
    }

    // 2. اتخاذ القرار بناءً على حالة الشبكة
    if (isDeviceOnline) {
      print("Device is Online! Calling custom AI TTS API...");
      try {
        // نبعت النص للسيرفر بتاعنا عشان يرجعلنا الصوت (ملف أو رابط)
        final String? audioPathOrUrl = await _apiService.convertTextToSpeechApi(
          text,
        );

        if (audioPathOrUrl != null) {
          // هنا هتشغل الملف اللي جاي من السيرفر باستخدام الـ AudioPlayer بتاعك
          print("Playing high-quality AI voice from: $audioPathOrUrl");
          // بافتراض إن عندك دالة تشغيل ملفات في الـ audioService:
          // await _audioService.playAudioFromUrl(audioPathOrUrl);
          return; // اخرج من الدالة بنجاح
        }
      } catch (e) {
        print("API Failed or timed out, falling back to local TTS: $e");
        // لو الـ API بتاع السيرفر وقع لأي سبب، الكود هيكمل تحت وينطق بالمكتبة المحلية فوراً
      }
    }

    // 3. الحل البديل (Fallback) في حالة الـ Offline أو فشل السيرفر
    print(
      "Device is Offline (or Server down). Using local Flutter TTS library...",
    );
    await _ttsService.speak(text);
  }

  // دالة إرسال نص
  void sendMessage(String text) {
    if (text.isEmpty) return;
    _messageCounter++;
    final msg = Message(
      id: 'txt_$_messageCounter',
      content: {'text': text},
      sender: MessageSender.user,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(messages: [msg, ...state.messages]));
  }

  void swipe() {
    if (swipnum == 2) {
      swipnum = 0;
    } else {
      swipnum = 2;
    }
    emit(state.copyWith(swipNum: swipnum));
  }
}
