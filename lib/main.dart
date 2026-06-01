import 'package:deaf_hearing_app/core/services/api_services.dart';
import 'package:deaf_hearing_app/core/services/audio_services.dart';
// import 'package:deaf_hearing_app/core/services/network_info.dart';
import 'package:deaf_hearing_app/core/services/tts_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deaf_hearing_app/core/theme/app_theme.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/pages/conversation_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation colors to match dark futuristic aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ConversationCubit(AudioService(), ApiService(), TtsService()),
      child: MaterialApp(
        title: 'Aura Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const ConversationPage(),
      ),
    );
  }
}
