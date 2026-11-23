import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared initialization for all 3 standalone apps + Ecosystem Portal
Future<void> initCijPlatform() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  try {
    await Supabase.initialize(
      url: 'https://cmtvzjcjinivkquhheqo.supabase.co',
      publishableKey: 'sb_publishable_xCwyI9klXX30unaDht3TPw_KidrW5o2',
    );
  } catch (e) {
    debugPrint('Supabase init notice: $e');
  }
}
